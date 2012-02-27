%connecting points, frame by frame
function track = create_track(track,d3_analysed,frame,point,direction)
frames2plot=frame-40:frame+40;
if direction < 0
  frames = fliplr(frames2plot(frames2plot<frame));
else
  frames = frames2plot(frames2plot>frame);
end
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