%remove duplicate frames in track
function track = remove_duplicate_frames(track)
[b, m, n] = unique([track.frame]);
track = track(m);