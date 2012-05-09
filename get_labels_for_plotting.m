function [lab_tracks_in_zoom lab_clrs_in_zoom lab_name_in_zoom]=get_labels_for_plotting(labels,plotting_frames)
lab_tracks_in_zoom = {};
lab_clrs_in_zoom = {};
lab_name_in_zoom = {};
for lab=1:length(labels)
  lab_track = labels(lab).track.points;
  lab_frames = [lab_track.frame];
  isect_lab_track = intersect(lab_frames,plotting_frames);
  if ~isempty(isect_lab_track)
    lab_tracks_in_zoom{end+1} = lab_track;
    lab_clrs_in_zoom{end+1} = labels(lab).color;
    lab_name_in_zoom{end+1} = labels(lab).label;
  end
end