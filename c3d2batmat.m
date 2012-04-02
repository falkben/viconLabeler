function c3d2batmat(autosave,pn,fn)

if nargin<1
  autosave=1;
end

if nargin<3
  if ispref('vicon_labeler','c3d_files') && ...
      exist(getpref('vicon_labeler','c3d_files'),'dir')
    pn=getpref('vicon_labeler','c3d_files');
  else
    pn=uigetdir([],'Set the directory for your c3d files');
    if pn~=0
      setpref('vicon_labeler','c3d_files',pn);
    end
  end
  [fn pn] = uigetfile('*.c3d','Pick file to label',pn);
  
  if ~isequal(fn,0)
    setpref('vicon_labeler','c3d_files',pn);
  else
    return;
  end
end

c3d_trial=open_c3d(pn,fn);
new_UB=crop_trial(c3d_trial.unlabeled_bat);
[bat_sm bat_avg plot_frames ignore_frames]=extract_bat_postion(new_UB);

d3_analysed = create_d3_analysed(c3d_trial, bat_avg, new_UB, plot_frames, ignore_frames);

save_d3_analysed(d3_analysed,autosave);



function save_d3_analysed(d3_analysed,autosave)
if ispref('vicon_labeler','processed_vicon') && ...
    exist(getpref('vicon_labeler','processed_vicon'),'dir')
  pn=getpref('vicon_labeler','processed_vicon');
else
  pn=uigetdir([],'Set the directory for your ratings file');
  if pn~=0
    setpref('vicon_labeler','processed_vicon',pn);
  end
end
if ~isequal(pn,0)
  setpref('vicon_labeler','processed_vicon',pn);
  if autosave==0
    [FileName,PathName] = uiputfile('.mat','Save ratings file',[pn '\' d3_analysed.trialcode '.mat']);
  else
    PathName=[pn '\'];
    FileName=[d3_analysed.trialcode '.mat'];
  end

  if ~isequal(FileName,0) && ~isequal(PathName,0)
    save([PathName FileName],'d3_analysed');
    disp(['Saved File: ' [PathName FileName]]);
  end

end

function d3_analysed=create_d3_analysed(c3d_trial, bat, UB, plot_frames, ignore_frames)

d3_analysed = struct;

d3_analysed.object(1).video = bat;
d3_analysed.object(1).name = 'bat';
d3_analysed.unlabeled_bat = UB;
d3_analysed.fvideo = c3d_trial.frame_rate;

fname=[c3d_trial.pn c3d_trial.fn];
if strfind(fname,'/')
  slashes = strfind(fname,'/');
else
  slashes = strfind(fname,'\');
end
datecode=fname(slashes(end-3)+1:slashes(end-2)-1);
bat_name = fname(slashes(end-2)+1:slashes(end-1)-1);
trial_num = fname(slashes(end)+6:slashes(end)+7);

d3_analysed.trialcode = [bat_name '.' datecode '.' ...
  num2str(trial_num,'%1.2d')];

d3_analysed.startframe = plot_frames(1);
d3_analysed.endframe = plot_frames(end);

d3_analysed.ignore_segs = ignore_frames;



function c3d_trial = open_c3d(pn,fn)
c3d_trial=[];
[point_array, frame_rate, trig_rt, trig_sig, start_f, end_f] = lc3d( [pn fn] );

trial_s_frame=max(round((trig_rt-8)*frame_rate),1);
frames=trial_s_frame:round(trig_rt*frame_rate);

unlabeled_bat=cell(length(frames),1);
for f=1:length(frames)
  frame=frames(f);
  unlabeled_bat{f,:}=cell2mat(cellfun(@(c) c.traj(frame,:)./1e3,point_array,...
    'uniformoutput',0));
end
unlabeled_bat=cellfun(@(c) c(c(:,1)~=0,:),unlabeled_bat,'uniformoutput',0);

c3d_trial.unlabeled_bat_original = unlabeled_bat;
c3d_trial.unlabeled_bat = unlabeled_bat;
c3d_trial.frame_rate = frame_rate;
c3d_trial.start_f = start_f;
c3d_trial.end_f = end_f;
% c3d_trial.trig_frame = floor(trig_rt*frame_rate);
c3d_trial.fn = fn;
c3d_trial.pn = pn;



function new_UB=crop_trial(unlabeled_bat,frame)
thresh_distance=.3;

UB = unlabeled_bat;

frames=1:length(UB);

if nargin<2
  frame=frames(round(length(frames)/2));
end

new_UB=cell(length(UB),1);

for p = 1:size(UB{frame},1)
  last_point = UB{frame}(p,:);
  
  other_bat_points=cell(length(UB),1);
  
  for f=frame:length(frames)
    other_points=UB{f};
    
    D = distance(other_points,last_point);
    
    other_bat_points{f} = other_points(D<=thresh_distance,:);
    
    curr_centroid = mean(other_bat_points{f},1);
    if ~isnan(curr_centroid(1))
      last_point = curr_centroid;
    end
    
  end
  
  last_point=UB{frame}(p,:);
  for f=frame-1:-1:1
    other_points=UB{f};
    
    D = distance(other_points,last_point);
    
    other_bat_points{f} = other_points(D<=thresh_distance,:);
    
    curr_centroid = mean(other_bat_points{f},1);
    if ~isnan(curr_centroid(1))
      last_point = curr_centroid;
    end
  end
  
  %   if length(find(cellfun(@isempty,other_bat_points))) < length(find(cellfun(@isempty,new_UB)))
  %     new_UB=other_bat_points;
  %   end
  %   if sum(cellfun(@length,other_bat_points)) > sum(cellfun(@length,new_UB))
  %     new_UB=other_bat_points;
  %   end
  if length(unique(cell2mat(other_bat_points),'rows')) > ...
      length(unique(cell2mat(new_UB),'rows'))
    new_UB=other_bat_points;
  end
  
end

all_bat=cell2mat(new_UB);
if isempty(all_bat)
  frame=randi(length(frames),1);
  new_UB=crop_trial(unlabeled_bat,frame);
  all_bat=cell2mat(new_UB);
end
figure(5);
plot3(all_bat(:,1),all_bat(:,2),all_bat(:,3),'.k');
axis equal;
grid on;

disp(['Num of empty frames: ' num2str(length(find(cellfun(@isempty,new_UB))))]);
disp(['Num unique points: ' num2str(length(unique(all_bat,'rows')))]);



function [bat_sm bat_avg plot_frames ignore_frames]=extract_bat_postion(UB)

centroids_cell = cellfun(@(c) mean(c,1),UB,...
  'uniformoutput',0);

plot_frames = find(~cellfun(@(c) isnan(c(:,1)),centroids_cell));
ignore_frames = find(cellfun(@(c) isnan(c(:,1)),centroids_cell));

bat_avg=nan(length(centroids_cell),3);
bat_avg(plot_frames,:)=cell2mat(centroids_cell(plot_frames));

bat_sm=nan(length(centroids_cell),3);
for k=1:length(ignore_frames)
  
  if k==1
    sframe=plot_frames(1);
    eframe=ignore_frames(1)-1;
  elseif k==length(ignore_frames)
    sframe=ignore_frames(end)+1;
    eframe=plot_frames(end);
  else
    sframe=plot_frames(...
      find(plot_frames<ignore_frames(k) & plot_frames>ignore_frames(k-1),1) ...
      );
    eframe=plot_frames(...
      find(plot_frames<ignore_frames(k) & plot_frames>ignore_frames(k-1),1,'last') ...
      );
  end
  
  bat_sm(sframe:eframe,:)=[smooth(bat_avg(sframe:eframe,1)) ...
    smooth(bat_avg(sframe:eframe,2)) ...
    smooth(bat_avg(sframe:eframe,3))];
end

figure(7); plot3(bat_sm(:,1),bat_sm(:,2),bat_sm(:,3),'linewidth',3)
hold on; plot3(bat_avg(:,1),bat_avg(:,2),bat_avg(:,3),'r','linewidth',3)
all_points=cell2mat(UB);
plot3(all_points(:,1),all_points(:,2),all_points(:,3),'.k');
grid on;






