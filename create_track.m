%connecting points, frame by frame
function track = create_track(frames2plot,frame,point,d3_analysed)
% function track = create_track(track,d3_analysed,frame,point,direction)

start_frames = fliplr(frames2plot(frames2plot<=frame));
end_frames = frames2plot(frames2plot>=frame);

start_track = sub_create_track(point,frame,start_frames,d3_analysed);
end_track = sub_create_track(point,frame,end_frames,d3_analysed);

track=[start_track end_track];
track = remove_duplicate_frames(track);

% track = remove_duplicate_points(track);

function track = sub_create_track(point,frame,frames,d3_analysed)
track(1).point=point;
track(1).frame=frame;
last_point = point;
for f=1:length(frames)
  other_points = d3_analysed.unlabeled_bat{frames(f)};
  D = distance(last_point,other_points);
  [M p]=min(D);
  track(end+1).point=other_points(p,:);
  track(end).frame=frames(f);
  last_point = track(end).point;
end