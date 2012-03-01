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
for f=2:length(frames)
  other_points = d3_analysed.unlabeled_bat{frames(f)};
  D = distance(last_point,other_points);
  [M p]=min(D);
  
  [speed dir] = get_track_vel(track);
  
  if ~isempty(dir)
    THETA = cart2pol(other_points(p,1),other_points(p,2));
    
    dir_diff = (THETA - dir(end));
    if dir_diff > 2*pi
      dir_diff = dir_diff - 2*pi;
    elseif dir_diff < -2*pi
      dir_diff = dir_diff + 2*pi;
    end
  end
  
  if isempty(speed) || (M < 1.8*speed(end) && dir_diff < 10*pi/180)
    track(end+1).point=other_points(p,:);
    track(end).frame=frames(f);
    last_point = track(end).point;
  else
    return;
  end
end

%in meters / frame
function [sm_speed sm_dir] = get_track_vel(track)
if length(track) >= 3
  points = reshape([track(:).point],3,...
    length([track(:).point])/3)';
  frames = [track.frame]';
  point_diff = diff(points);
  speed = distance([0 0 0],point_diff) ./ abs(diff(frames));
  sm_speed = smooth(speed);
  
  THETA = cart2pol(points(:,1),points(:,2));
  sm_dir = smooth(unwrap(THETA));
    
  figure(10); 
  subplot(2,1,1); plot(speed);
  subplot(2,1,2); plot(unwrap(THETA));
else
  sm_speed=[];sm_dir=[];
end

