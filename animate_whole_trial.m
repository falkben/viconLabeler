function animate_whole_trial(handles,starting_area)
global assign_labels

%minimizing the GUI window during animation to prevent accidental clicking
%of GUI which then starts to animate the GUI...\
jFrame = get(handles.figure1,'JavaFrame');
jFrame.setMinimized(true);

track_start_frames=cellfun(@(c) c.points(1).frame,assign_labels.tracks);
if strcmp(starting_area,'beg')
  start_frame = min(track_start_frames);
else
  start_frame = track_start_frames(assign_labels.cur_track_num);
end
end_frame = max(track_start_frames);

for ff=start_frame:end_frame

%plot all tracks
%pause button
%stop button
  
end

jFrame.setMinimized(false);