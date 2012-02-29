%extend the track by estimating where the next point is
%can skip over gaps
function track = extend_track(track,d3_analysed)

thresh = 9e-3;

frames = [track.frame];
next_frame = frames(end)+1;

for k=1:10

  next_points = d3_analysed.unlabeled_bat{next_frame};
  
  plot_point_subset();
  plot_track(track);
  
  figure(2);
  hold on;
  plot3(next_points(:,1),next_points(:,2),next_points(:,3),...
    'om','markersize',4,'markerfacecolor','m');
  hold off;

  %speed
  track_speed_sm = smooth(get_track_speed(track,d3_analysed.fvideo));
  
  %direction
  track_dir = get_track_dir(track);
  
  D=distance(track(end).point,next_points);
  proper_D = track_speed_sm(end)/d3_analysed.fvideo / (next_frame-frames(end));

  [M i]=min(abs(D-proper_D));

  if M < thresh
    track(end+1).point = next_points(i,:);
    track(end).frame = next_frame;
    
    hold on;
    plot3(track(end).point(:,1),track(end).point(:,2),track(end).point(:,3),...
      '.k');
    hold off;
  end
  
  next_frame = next_frame + 1;
  
end

function [track_dir Z] = get_track_dir(track)

%only look at the last 10 points
track_points=reshape([track(end-9:end).point],3,...
  length([track(end-9:end).point])/3)';

[track_dir,RHO,Z] = cart2pol(track_points(end,1)-track_points(1,1),...
  track_points(end,2)-track_points(1,2),...
  track_points(end,3)-track_points(1,3));

% figure; plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
%   '.-');
% grid on;



function track_speed = get_track_speed(track,fvideo)
track_points=reshape([track(:).point],3,length([track(:).point])/3)';
track_points_dist = distance([0 0 0],diff(track_points));
track_speed = track_points_dist./(diff([track.frame])')*fvideo;