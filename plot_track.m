function plot_track(track)
figure(2);
hold on;
track_points=reshape([track(:).point],3,...
  length([track(:).point])/3)';
plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
  'o-','color',[.5 .5 .5],'markersize',5,'linewidth',2);
hold off;