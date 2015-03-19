function rating = rate_all(unlabeled_bat,disp_status)
%rates all the points in a d3_analysed trial

all_points=cell2mat(unlabeled_bat);

all_points_no_zero = unique(all_points(all_points(:,1)~=0,:),'rows');
disp('Rating all points.  This could take a while...');

if nargin > 1 && disp_status
  reverseStr = '';
else
  disp_status=0;
end
for k=1:length(all_points_no_zero)
  frame = get_frame_from_point(all_points_no_zero(k,:),unlabeled_bat);
  rating(k) = rate_point(frame,all_points_no_zero(k,:),unlabeled_bat);
  
  if disp_status
    msg = sprintf('Processed %2.1f % done', k/length(all_points_no_zero)*100);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
  end
end

if disp_status
  fprintf(char(10));
end