%in meters / frame
function [sm_speed dir] = get_track_vel(track)
if length(track) >= 3
  points = reshape([track(:).point],3,...
    length([track(:).point])/3)';
  frames = [track.frame]';
  point_diff = diff(points);
  speed = distance([0 0 0],point_diff) ./ abs(diff(frames));
  sm_speed = smooth(speed);
  
  THETA = cart2pol(point_diff(:,1),point_diff(:,2));
  dir = unwrap(THETA);
    
%   figure(10); 
%   subplot(2,1,1); plot(speed);
%   subplot(2,1,2); plot(dir);
else
  sm_speed=[];dir=[];
end