function [PathName,FileName] = c3d2batmat(autosave,c3dfname,select_start)
PathName = ''; FileName = '';

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
    else
      return;
    end
  end
  [fn, pn] = uigetfile('*.c3d','Pick file to label',pn);
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

new_UB=crop_trial(c3d_trial.unlabeled_bat,[],autosave,1,select_start);
if isempty(find(~cellfun(@isempty,new_UB),1))
  disp('nothing found after cropping')
  return;
end


all_bat=cell2mat(new_UB);
disp(['Num of empty frames: ' num2str(length(find(cellfun(@isempty,new_UB))))]);
disp(['Num unique points: ' num2str(length(unique(all_bat,'rows')))]);

[bat_sm,bat_avg,plot_frames,ignore_frames]=extract_bat_postion(new_UB,autosave);
d3_analysed = create_d3_analysed(c3d_trial,bat_avg,new_UB,ignore_frames);

all_p=cell2mat(new_UB);
figure(1); clf
plot3(all_p(:,1),all_p(:,2),all_p(:,3),'ok');
view(3);axis equal;
a=axis;
hold on;
prev_points=cell2mat(c3d_trial.unlabeled_bat);
plot3(prev_points(:,1),prev_points(:,2),prev_points(:,3),...
  '.','color',[.5 .5 .5]);
hold off;
axis equal;
axis(a);grid on;
drawnow;
[PathName,FileName] = save_d3_analysed(d3_analysed,autosave);





function new_UB = crop_trial(UB,frame,autosave,ntimesrun,select_start)
thresh_distance=.8;

UB_all = cell2mat(UB);
frames=1:length(UB);

if isempty(frame) 
  if ~select_start
    frame=randi([length(frames)-900,length(frames)-100],1);
  else
    figure(6); clf;
    plot3(UB_all(:,1),UB_all(:,2),UB_all(:,3),'o','color',[.5 .5 .5])
    axis equal;
    grid on;
    dcm_obj = datacursormode(gcf);
    set(dcm_obj,'DisplayStyle','datatip',...
      'SnapToDataVertex','off','Enable','on')
    disp('Select point to zoom on and label, then press enter');
    pause
    c_info = getCursorInfo(dcm_obj);
    if ~isempty(c_info)
      selected_point = c_info.Position;
      frame=get_frame_from_point(selected_point,UB);
    end
  end
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
%     figure(5); clf;
%     all_bat=cell2mat(other_bat_points);
%     plot3(all_bat(:,1),all_bat(:,2),all_bat(:,3),'.k');
%     hold on;
%     plot3(last_point(1),last_point(2),last_point(3),'or');
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
  figure(6);clf;
  AB=cell2mat(other_bat_points);
  plot3(AB(:,1),AB(:,2),AB(:,3),'.k');
  hold on; axis equal; a=axis;
  plot3(UB_all(:,1),UB_all(:,2),UB_all(:,3),'o','color',[.5 .5 .5])
  axis(a);
  grid on;
  strtpt=points_at_frame(p,:);
  text(strtpt(1),strtpt(2),strtpt(3),'START')
  if length(unique(cell2mat(other_bat_points),'rows')) > 3e3 && ...
      (bat_range(1) > 2.8 && bat_range(2) > 3.5 && bat_range(3) > .6) && ...
      sum(bat_range) >= sum(prev_range)
    new_UB=other_bat_points;
  end
end

all_bat=cell2mat(new_UB);
if  ntimesrun <= 5 && (isempty(all_bat) || length(unique(cell2mat(new_UB),'rows')) < 2e3)
  frame=randi([length(frames)-900,length(frames)-100],1);
  new_UB=crop_trial(UB,frame,autosave,ntimesrun+1);
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
  axis equal;
end





