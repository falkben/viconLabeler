function rating = rate_all(unlabeled_bat)
%rates all the points in a d3_analysed trial

all_points=cell2mat(unlabeled_bat);

all_points_no_zero = all_points(all_points(:,1)~=0,:);
disp('Rating all points.  This could take a while...');
tic
for k=1:length(all_points_no_zero)
  frame = get_frame_from_point(all_points_no_zero(k,:),unlabeled_bat);
  rating(k) = rate_point(frame,all_points_no_zero(k,:),unlabeled_bat);
end
toc
