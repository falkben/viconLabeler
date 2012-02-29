function plot_point_subset()
global vicon_label
figure(2);clf;grid on;
hold on;
frames2plot=vicon_label.frame+vicon_label.internal.start_frame...
  :vicon_label.frame+vicon_label.internal.end_frame;

points=cell2mat(vicon_label.d3_analysed.unlabeled_bat(frames2plot));
points(points==0)=nan;
plot3(points(:,1),points(:,2),points(:,3),...
  'ok','markersize',2,'markerfacecolor','k');

plot3(vicon_label.point(1),vicon_label.point(2),vicon_label.point(3),...
  'or','markersize',10,'linewidth',2);

axis([vicon_label.point(1)-.5,vicon_label.point(1)+.5,...
  vicon_label.point(2)-.5,vicon_label.point(2)+.5,...
  vicon_label.point(3)-.25,vicon_label.point(3)+.25]);
hold off;
axis vis3d;
view(3);