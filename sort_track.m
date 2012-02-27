%sort the track
function track = sort_track(track)
track_frames=[track.frame];
[B,IX] = sort(track_frames);
track = track(IX);