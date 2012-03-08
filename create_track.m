%connecting points, frame by frame
%unlabeled_bat - cell array which contains all unlabled points at each frame
function [track ending] = create_track(frame,point,unlabeled_bat,max_length)
% function track = create_track(track,d3_analysed,frame,point,direction)

if nargin == 4
  sub_length=round(max_length/2);
else
  sub_length=[];
end
[start_track start_ending] = sub_create_track(point,frame,unlabeled_bat,1,sub_length);
[end_track end_ending] = sub_create_track(point,frame,unlabeled_bat,-1,sub_length);

track=[start_track end_track];
track = remove_duplicate_frames(track);

ending = [start_ending end_ending];

% track = remove_duplicate_points(track);


%direction is either -1 or +1, sub_length is the length of the track to make
function [track ending] = sub_create_track(point,frame,unlabeled_bat,direction,sub_length)
ending='';
speed_thresh=1.8; %multiplier
dir_thresh=45; %degrees

track(1).point=point;
track(1).frame=frame;
last_point = point;
f=0;
while frame+(f+1)*direction >= 1 && frame+(f+1)*direction <= length(unlabeled_bat) && ...
    ( isempty(sub_length) || length(track) < sub_length )
  f = f+1;
  other_points = unlabeled_bat{frame+f*direction};
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
  
  if ~isempty(p) && ...
      (isempty(speed) || (M < speed_thresh*speed(end) && dir_diff < dir_thresh*pi/180))
    track(end+1).point=other_points(p,:);
    track(end).frame=frame+f*direction;
    last_point = track(end).point;
  else
    if ~isempty(p)
      if ~isempty(speed) && M < speed_thresh*speed(end)
        ending='spd';
      elseif ~isempty(dir_diff) && dir_diff < dir_thresh*pi/180
        ending='dir';
      end
    end
    return;
  end
end

