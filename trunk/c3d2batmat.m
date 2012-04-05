function c3d2batmat(autosave,c3dfname)
if nargin<1
  autosave=0;
end
if nargin<2
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
    c3dfname = [pn fn];
  else
    return;
  end
end

c3d_trial=open_c3d(c3dfname);
if isempty(c3d_trial)
  disp('problem loading c3d file');
  return;
end

new_UB=crop_trial(c3d_trial.unlabeled_bat,[],autosave,1);
if isempty(find(~cellfun(@isempty,new_UB),1))
  disp('nothing found after cropping')
  return;
end


all_bat=cell2mat(new_UB);
disp(['Num of empty frames: ' num2str(length(find(cellfun(@isempty,new_UB))))]);
disp(['Num unique points: ' num2str(length(unique(all_bat,'rows')))]);

[bat_sm bat_avg plot_frames ignore_frames]=extract_bat_postion(new_UB,autosave);
d3_analysed = create_d3_analysed(c3d_trial,bat_avg,new_UB,ignore_frames);

all_p=cell2mat(new_UB);
figure(1);
plot3(all_p(:,1),all_p(:,2),all_p(:,3),'.k');
view(3);axis equal;
a=axis;
prev_points=cell2mat(c3d_trial.unlabeled_bat);
plot3(prev_points(:,1),prev_points(:,2),prev_points(:,3),...
  '.','color',[.5 .5 .5]);
hold on;
plot3(all_p(:,1),all_p(:,2),all_p(:,3),'.k');
hold off;
axis(a);grid on;
drawnow;
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

function d3_analysed=create_d3_analysed(c3d_trial, bat, UB, ignore_frames)

d3_analysed = struct;

d3_analysed.object(1).video = bat;
d3_analysed.object(1).name = 'bat';
d3_analysed.unlabeled_bat = UB;
d3_analysed.fvideo = c3d_trial.frame_rate;

fname=c3d_trial.fn;
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

d3_analysed.startframe = c3d_trial.start_f;
d3_analysed.endframe = c3d_trial.end_f;

d3_analysed.ignore_segs = ignore_frames;



function c3d_trial = open_c3d(c3dfname)
c3d_trial=[];
try
  [point_array, frame_rate, trig_rt, trig_sig, start_f, end_f] = lc3d( c3dfname );

  if ~isnan(trig_rt)
    trial_s_frame=max(round((trig_rt-8)*frame_rate),1);
    frames=trial_s_frame:round(trig_rt*frame_rate);
  else
    disp('No trigger detected... skipping.');
    return
  end
catch
  disp('Failed to load c3d file... skipping.');
  return;
end

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
c3d_trial.start_f = frames(1)-round(trig_rt*frame_rate);
c3d_trial.end_f = frames(end)-round(trig_rt*frame_rate);
% c3d_trial.trig_frame = floor(trig_rt*frame_rate);
c3d_trial.fn = c3dfname;



function new_UB = crop_trial(unlabeled_bat,frame,autosave,ntimesrun)
thresh_distance=.4;

UB = unlabeled_bat;
frames=1:length(UB);

if isempty(frame)
  frame=randi([300,length(frames)-300],1);
%   frame=frames(round(length(frames)/2));
end

new_UB=cell(length(UB),1);
points_at_frame = unique(UB{frame},'rows');
for p = 1:size(points_at_frame,1)
  other_bat_points=cell(length(UB),1);
  
  last_point = points_at_frame(p,:);
  for f=frame:length(frames)
    [other_bat_points{f} last_point] = ...
      grab_nearest_points(UB{f},last_point,thresh_distance);
  end
  
  last_point=points_at_frame(p,:);
  for f=frame-1:-1:1
    [other_bat_points{f} last_point] = ...
      grab_nearest_points(UB{f},last_point,thresh_distance);
  end
  
  
%   figure(5);
%   all_bat=cell2mat(other_bat_points);
%   plot3(all_bat(:,1),all_bat(:,2),all_bat(:,3),'.k');
%   axis equal;
%   grid on;
%   title(num2str(p));
%   a=axis;
%   UB_all=cell2mat(UB);
%   plot3(UB_all(:,1),UB_all(:,2),UB_all(:,3),'.','color',[.5 .5 .5]);
%   hold on;
%   plot3(all_bat(:,1),all_bat(:,2),all_bat(:,3),'.k');
%   hold off;
%   axis(a);rotate3d on;grid on;
%   
%   last_point=points_at_frame(p,:);
%   figure(1); clf; hold on;
%   nearpoints=cell2mat(UB(max(frame-50,1):min(frame+50,length(UB))));
%   plot3(nearpoints(:,1),nearpoints(:,2),nearpoints(:,3),'.','color',[.5 .5 .5])
%   other_points=UB{frame};
%   plot3(other_points(:,1),other_points(:,2),other_points(:,3),'.k');
%   plot3(last_point(1),last_point(2),last_point(3),'or')
%   plot3(other_bat_points{frame}(:,1),other_bat_points{frame}(:,2),other_bat_points{frame}(:,3),'og')
%   rotate3d on;grid on;view(3);axis equal;
%   hold off;
    
  %choose the one with a threshold # of unique points and range of points larger than...
  bat_range=range(cell2mat(other_bat_points));
  prev_range=range(cell2mat(new_UB));
  if length(unique(cell2mat(other_bat_points),'rows')) > 4.5e3 && ...
      (bat_range(1) > 2 && bat_range(2) > 2 && bat_range(3) > .75) && ...
      sum(bat_range) > sum(prev_range)
    new_UB=other_bat_points;
  end
end

all_bat=cell2mat(new_UB);
if  ntimesrun <= 5 && (isempty(all_bat) || length(unique(cell2mat(new_UB),'rows')) < 2e3)
  frame=randi([300,length(frames)-300],1);
  new_UB=crop_trial(unlabeled_bat,frame,autosave,ntimesrun+1);
end

if ~isempty(find(~cellfun(@isempty,new_UB),1)) && (~exist('autosave','var') || ~autosave)
  figure(6);clf;
  all_bat=cell2mat(new_UB);
  plot3(all_bat(:,1),all_bat(:,2),all_bat(:,3),'.k');
  axis equal;
  grid on;
end



function [other_bat_points last_point mean_distance]=grab_nearest_points(other_points,last_point,thresh_distance)
mean_distance=nan;
D = distance(other_points,last_point);
other_bat_points = other_points(D<=thresh_distance,:);
curr_centroid = mean(other_bat_points,1);
if ~isnan(curr_centroid(1))
  last_point = curr_centroid;
  mean_distance = mean(D(D<=thresh_distance));
end



function [bat_sm bat_avg plot_frames ignore_frames]=extract_bat_postion(UB,autosave)

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

if nargin < 2 || ~autosave
  figure(7); clf; plot3(bat_sm(:,1),bat_sm(:,2),bat_sm(:,3),'linewidth',3)
  hold on; plot3(bat_avg(:,1),bat_avg(:,2),bat_avg(:,3),'r','linewidth',3)
  all_points=cell2mat(UB);
  plot3(all_points(:,1),all_points(:,2),all_points(:,3),'.k');
  grid on;
end





