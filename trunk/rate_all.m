function rating = rate_all(d3_analysed)
%rates all the points in a d3_analysed trial

all_points=cell2mat(d3_analysed.unlabeled_bat);

all_points_no_zero = all_points(all_points(:,1)~=0,:);
disp('Rating all points.  This could take a while...');
tic
for k=1:length(all_points_no_zero)
  frame = get_frame_from_point(all_points_no_zero(k,:),d3_analysed);
  rating(k) = rate_point(frame,all_points_no_zero(k,:),d3_analysed);
end
toc
