function rating = rate_all(unlabeled_bat)
%rates all the points in a d3_analysed trial

all_points=cell2mat(unlabeled_bat);

all_points_no_zero = unique(all_points(all_points(:,1)~=0,:),'rows');
disp('Rating all points.  This could take a while...');

reverseStr = '';
for k=1:length(all_points_no_zero)
  frame = get_frame_from_point(all_points_no_zero(k,:),unlabeled_bat);
  rating(k) = rate_point(frame,all_points_no_zero(k,:),unlabeled_bat);
  
  
  msg = sprintf('Processed %2.1f % done', k/length(all_points_no_zero)*100);
  fprintf([reverseStr, msg]);
  reverseStr = repmat(sprintf('\b'), 1, length(msg));
end

fprintf(char(10));