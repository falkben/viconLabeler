%in meters / frame
function [sm_speed, dir] = get_track_vel(track)
if length(track) >= 3
  track_points=reshape([track(:).point],3,length([track(:).point])/3)';
  point_diff = diff(track_points);
  speed = distance([0 0 0],point_diff);
  sm_speed = smooth(speed);
  
%   THETA = cart2pol(point_diff(:,1),point_diff(:,2));
  
  THETA=nan(size(point_diff,1)-1,1);
  for pp=1:size(point_diff,1)-1
    a=point_diff(pp,:);
    b=point_diff(pp+1,:);
    THETA(pp)=vector_angle(a',b');
  end
  dir = unwrap(THETA);
  
%   figure(10); 
%   subplot(2,1,1); plot(speed);
%   subplot(2,1,2); plot(dir);
else
  sm_speed=[];dir=[];
end