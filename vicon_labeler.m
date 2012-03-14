function [track d3_analysed] = vicon_labeler

d3_analysed = load_trial;
trialfig = plot_trial(d3_analysed);
[point_indx point] = get_start_point(trialfig);
frame = get_frame_from_point_indx(point_indx,d3_analysed);
plot_point_subset(d3_analysed,frame,point);
track = create_track(frame,point,d3_analysed);
track = remove_duplicate_frames(track);
track = sort_track(track);
plot_track(track);


messaround(track,d3_analysed);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%loading the trial
function d3_analysed = load_trial(fname)
if nargin < 1
  if ispref('vicon_labeler','d3path') && ...
      exist(getpref('vicon_labeler','d3path'),'dir')
    pn=getpref('vicon_labeler','d3path');
  else
    pn=[];
  end
  [filename pathname] = uigetfile('*.mat','Pick file for labeling (rated files folder)',pn);
  if isequal(filename,0)
    return;
  end
  setpref('vicon_labeler','d3path',pathname);

  fname=[pathname filename];
end
load(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plotting the trial
function trialfig = plot_trial(d3_analysed)
trialfig = figure(1);clf;
all_points=cell2mat(d3_analysed.unlabeled_bat);
all_points(all_points==0)=nan;
plot3(all_points(:,1),all_points(:,2),all_points(:,3),...
  'ok','markersize',2,'markerfacecolor','k');
axis vis3d;
grid on;
view(3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%grabbing the point
function [point_indx point] = get_start_point(trialfig)
figure(trialfig);
grid on;
dcm_obj = datacursormode(trialfig);
set(dcm_obj,'DisplayStyle','datatip',...
  'SnapToDataVertex','off','Enable','on')
disp('Select point to zoom on and label, then press enter');
pause
c_info = getCursorInfo(dcm_obj);
point_indx = c_info.DataIndex;
point = c_info.Position;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plotting the subset of points around the selected points
function plot_point_subset(d3_analysed,frame,point)
figure(2);clf;view(3);grid on;
hold on;
frames2plot=frame-20:frame+20;
for f=frames2plot
  points=d3_analysed.unlabeled_bat{f};
  if ~isempty(find(points, 1))
    plot3(points(:,1),points(:,2),points(:,3),...
      'ok','markersize',2,'markerfacecolor','k');
  end
end
plot3(point(1),point(2),point(3),...
  'or','linewidth',2);
axis([point(1)-.5,point(1)+.5,...
  point(2)-.5,point(2)+.5,...
  point(3)-.25,point(3)+.25]);
hold off;
axis vis3d;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot track
function plot_track(track)
figure(2);
hold on;
track_points=reshape([track(:).point],3,length([track(:).point])/3)';
plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
  '.-','color',[.5 .5 .5]);
hold off;


% frames=1:length(d3_analysed.unlabeled_bat);
% for f=frames
% %   clf;
%   hold on;
%   grid on;
%   points=d3_analysed.unlabeled_bat{f};
%   if ~isempty(find(points, 1))
%     plot3(points(:,1),points(:,2),points(:,3),...
%       '.k');
%     axis([mean(points(:,1))-.5,mean(points(:,1))+.5,...
%       mean(points(:,2))-.5,mean(points(:,2))+.5,...
%       mean(points(:,3))-.25,mean(points(:,3))+.25]);
%   %   hold off;
%     drawnow;
%     pause(.1);
%   end
% end