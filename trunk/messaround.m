%messing with track
function messaround(track,d3_analysed)
track_points=reshape([track(:).point],3,length([track(:).point])/3)';
track_points_dist = distance([0 0 0],diff(track_points));
track_speed = track_points_dist*d3_analysed.fvideo;


vel_dir = -cart2pol(track_points(end,1)-track_points(1,1),...
  track_points(end,2)-track_points(1,2));

[thetavel] = bat_velocity_direction(track_points);

theta = median(thetavel);

rotmat=[cos(vel_dir) sin(vel_dir) 0; -sin(vel_dir) cos(vel_dir) 0; 0 0 1];
track_points_rot = track_points*rotmat;

% figure;plot(track_points_dist)
figure(3); 
% plot([track(2:end).frame],track_speed); ylabel('m/s');
subplot(3,1,1);
plot(track_points_rot(:,1),'.');
%linear regression
x=(1:size(track_points_rot,1))';
y=track_points_rot(:,1);
p = polyfit(x,y,1);
yfit =  p(1) * x + p(2);
hold on;
plot(x,yfit,'r-','LineWidth',2)
hold off;

subplot(3,1,2);
plot(track_points_rot(:,2),'.');
[tfit yfit]=fit_sine(track_points_rot(:,2));

subplot(3,1,3);
plot(track_points_rot(:,3),'.');
[tfit yfit]=fit_sine(track_points_rot(:,3));

% figure; plot3(track_points_rot(:,1),track_points_rot(:,2),track_points_rot(:,3))
