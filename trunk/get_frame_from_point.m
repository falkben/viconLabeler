%convert the point_indx to a frame
function [frame point] = get_frame_from_point(point,d3_analysed)

all_points=cell2mat(d3_analysed.unlabeled_bat);

point_diff = all_points - ones(length(all_points),1)*point;

[M find_indx]=min(distance([0 0 0],point_diff));

point = all_points(find_indx,:);
frame = get_frame_from_point_indx(find_indx,d3_analysed);

% for k=1:3
%   find_indx{k} = find(abs(all_points(:,k)-point(k)) <= 1e-10);
% end

% f_indx = unique([find_indx{:}]);



%convert the point_indx to a frame
function frame = get_frame_from_point_indx(point_indx,d3_analysed)
frame_lengths=cellfun(@(c) size(c,1),d3_analysed.unlabeled_bat);
frame = find( cumsum(frame_lengths) - point_indx >= 0 ,1);