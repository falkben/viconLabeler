%convert the point_indx to a frame
function frame = get_frame_from_point_indx(point_indx,d3_analysed)
frame_lengths=cellfun(@(c) size(c,1),d3_analysed.unlabeled_bat);
frame = find( cumsum(frame_lengths) - point_indx + 1 >= 0 ,1);