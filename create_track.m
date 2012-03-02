%connecting points, frame by frame
function track = create_track(frame,point,d3_analysed,max_length)
% function track = create_track(track,d3_analysed,frame,point,direction)

if nargin == 4
  sub_length=round(max_length/2);
else
  sub_length=[];
end
start_track = sub_create_track(point,frame,d3_analysed,1,sub_length);
end_track = sub_create_track(point,frame,d3_analysed,-1,sub_length);

track=[start_track end_track];
track = remove_duplicate_frames(track);

% track = remove_duplicate_points(track);


%direction is either -1 or +1, sub_length is the length of the track to make
function track = sub_create_track(point,frame,d3_analysed,direction,sub_length)
track(1).point=point;
track(1).frame=frame;
last_point = point;
f=0;
while isempty(sub_length) || length(track) < sub_length
  f = f+1;
  other_points = d3_analysed.unlabeled_bat{frame+f*direction};
  D = distance(last_point,other_points);
  [M p]=min(D);
  
  [speed dir] = get_track_vel(track);
  
  if ~isempty(dir)
    THETA = cart2pol(other_points(p,1)-last_point(1),...
       other_points(p,2)-last_point(2));
    
    dir_diff = (THETA - dir(end));
    if dir_diff > 2*pi
      dir_diff = dir_diff - 2*pi;
    elseif dir_diff < -2*pi
      dir_diff = dir_diff + 2*pi;
    end
    dir_diff = abs(dir_diff);
  end
  
  if isempty(speed) || (M < 1.8*speed(end) && dir_diff < 45*pi/180)
    track(end+1).point=other_points(p,:);
    track(end).frame=frame+f*direction;
    last_point = track(end).point;
  else
    return;
  end
end

