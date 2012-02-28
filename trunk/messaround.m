%messing with track
function messaround(track,d3_analysed)
track_points=reshape([track(:).point],3,length([track(:).point])/3)';
track_points_dist = distance([0 0 0],diff(track_points));
track_speed = track_points_dist./(diff([track.frame])')*d3_analysed.fvideo;
figure(4); plot(2:length(track_points),track_speed); ylabel('m/s');
% figure; plot(track_points_dist)

vel_dir = -cart2pol(track_points(end,1)-track_points(1,1),...
  track_points(end,2)-track_points(1,2));
% [thetavel] = bat_velocity_direction(track_points);
% theta = median(thetavel);

rotmat=[cos(vel_dir) sin(vel_dir) 0; -sin(vel_dir) cos(vel_dir) 0; 0 0 1];
track_points_rot = track_points*rotmat;

frames = [track.frame];
all_points_rot = cell2mat(d3_analysed.unlabeled_bat(frames))*rotmat;
frame_lengths=cellfun(@(c) size(c,1),d3_analysed.unlabeled_bat(frames));
for k=1:length(frames)
  xx{k}=k*ones(1,frame_lengths(k));
end
xx=[xx{:}];



tfit=(1:.01:size(frames,2))';
x=1:size(track_points_rot,1);
% x=(1:size(track_points_rot,1))';
% p = polyfit(x,track_points_rot(:,1),1);
% xfit =  p(1) * tfit + p(2);
% [tfit xfit]=fit_sine(track_points_rot(:,2));
xfit = spline(x,track_points_rot(:,1),tfit);

% [tfit yfit]=fit_sine(track_points_rot(:,2));
yfit = spline(x,track_points_rot(:,2),tfit);

% [tfit zfit]=fit_sine(track_points_rot(:,3));
zfit = spline(x,track_points_rot(:,3),tfit);


figure(3); clf;

subplot(3,1,1);
hold on;
plot(tfit,xfit,'r-','LineWidth',2);
plot(xx,all_points_rot(:,1),'.g');
plot(track_points_rot(:,1),'.');
hold off;
ylabel('X')

subplot(3,1,2);
hold on;
plot(tfit,yfit,'r-','LineWidth',2)
plot(xx,all_points_rot(:,2),'.g');
plot(track_points_rot(:,2),'.');
hold off;
ylabel('Y')

subplot(3,1,3);
hold on;
plot(tfit,zfit,'r-','LineWidth',2)
plot(xx,all_points_rot(:,3),'.g');
plot(track_points_rot(:,3),'.');
hold off;
ylabel('Z')

rotmat_rev=[cos(-vel_dir) sin(-vel_dir) 0; -sin(-vel_dir) cos(-vel_dir) 0; 0 0 1];

fit_rerotate = [xfit  yfit  zfit ]*rotmat_rev;

figure(2);
hold on;
plot3(fit_rerotate(:,1),fit_rerotate(:,2),fit_rerotate(:,3),...
  '-r','LineWidth',2);
hold off;

figure(4); hold on;
fit_dist = distance([0 0 0],diff(fit_rerotate));
fit_speed = fit_dist./diff(tfit)*d3_analysed.fvideo;
figure(4); plot(tfit(2:end),fit_speed,...
  '-r','linewidth',2);
hold off;


% figure; plot3(track_points_rot(:,1),track_points_rot(:,2),track_points_rot(:,3))
