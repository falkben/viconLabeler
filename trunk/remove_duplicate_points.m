%remove duplicate points in track
function track = remove_duplicate_points(track)
track_points=reshape([track(:).point],3,length([track(:).point])/3)';
[~, m] = unique(track_points,'rows');
track = track(m);
track = sort_track(track);