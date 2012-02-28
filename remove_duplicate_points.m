%remove duplicate points in track
function track = remove_duplicate_points(track)
track_points=reshape([track(:).point],3,length([track(:).point])/3)';
[b, m, n] = unique(track_points(:,1));
track = track(m);
track = sort_track(track);