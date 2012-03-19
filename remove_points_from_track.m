function track_cell = remove_points_from_track(track_cell,points)
track = track_cell.points;
track_points=reshape([track(:).point],3,length([track(:).point])/3)';
[b, m] = setdiff(track_points,points,'rows','stable');
if ~isequal(m',1:length(track_points))
  track_cell.points = track(m);
end