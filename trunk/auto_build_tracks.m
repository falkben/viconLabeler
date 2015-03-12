function tracks = auto_build_tracks(d3_analysed,rating)

if nargin < 1 
  d3_analysed = load_trial();
  rating = rate_all(d3_analysed.unlabeled_bat);
  DIAG=1;
else
  DIAG=0;
end

% [b ranking_spd]=sort([rating.spd_var]);
% [bb ranking_dir]=sort([rating.dir_var]);

%removes tracks which had no spd from consideration
Dsum=nan(size(rating));
for k=1:length(rating)
  Dsum(k)=sum(distance(rating(k).track(1).point,reshape([rating(k).track.point],3,[])'));
end
for k=find(Dsum<.001)
  rating(k).spd_var=nan;
end

[~,ranking_spd_dir]=sort([rating.spd_var].*[rating.dir_var]);

sorted_rating=rating(ranking_spd_dir);
sorted_points=reshape([sorted_rating.point],3,length([sorted_rating.point])/3)';

k=1;
tracks={};
points=sorted_points;
unlabeled_bat = d3_analysed.unlabeled_bat;
while length(points) >= .1*length(sorted_points)
  point=points(1,:);
  [~,rindx] = intersect(sorted_points,point,'rows');
  frame = sorted_rating(rindx).frame;
%   r_track_points = reshape([sorted_rating(rindx).track.point],3,...
%     length([sorted_rating(rindx).track.point])/3)';
%   if points_in_unlabeled(unlabeled_bat,r_track_points,...
%       [sorted_rating(rindx).track.frame])
  [track,endings] = create_track(frame,point,unlabeled_bat);
  
  tracks{k}.points = track;
  tracks{k}.endings = endings;
  tracks{k}.rating = sorted_rating(rindx);
  
  track_points = reshape([tracks{k}.points.point],3,length([tracks{k}.points.point])/3)';
  [~,i]=setxor(points,track_points,'rows');
%     track_frames = [tracks{k}.frame];
  points = points(sort(i),:);
  k=k+1;
%   else
%     track_points = point;
%     track_frames = frame;
%     points(1,:) = [];
%   end
%   unlabeled_bat = rem_points_from_unlabeled_bat(unlabeled_bat,track_points,...
%     track_frames);
end

if DIAG
%   colors='rbgymc';
  close all;
  figure(3); clf; hold on;
  for k=1:length(tracks)
    track = tracks{k}.points;
    endings = tracks{k}.ending;
    track_points = reshape([track.point],3,length([track.point])/3)';

%     plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
%       'color',colors(rem(k,length(colors))+1),'linewidth',3);
    if ~isempty(strfind(endings,'spd')) && isempty(strfind(endings,'dir'))
      col='r';
    elseif ~isempty(strfind(endings,'dir')) && isempty(strfind(endings,'spd'))
      col='b';
    elseif ~isempty(strfind(endings,'dir')) && ~isempty(strfind(endings,'spd'))
      col='m';
    else
      col='g';
    end
    plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
      'color',col,'linewidth',3);
  end
  plot3(sorted_points(:,1),sorted_points(:,2),sorted_points(:,3),...
    '.k');
  hold off;
  grid on;
  axis vis3d;
  view(3);
end





%determines if the points are in unlabeled bat
function in_unlabeled = points_in_unlabeled(unlabeled_bat,track_points,track_frames)
in_unlabeled = 0;
for k=1:size(track_points,1)
  if isempty(intersect(unlabeled_bat{track_frames(k)},track_points(k,:),'rows'))
    return;
  end
end
in_unlabeled = 1;


%removes the tracked points from unlabeled cell array
function unlabeled_bat = rem_points_from_unlabeled_bat(unlabeled_bat,track_points,track_frames)

for k=1:size(track_points,1)
  unlabeled_bat{track_frames(k)} = setxor(unlabeled_bat{track_frames(k)},...
    track_points(k,:),'rows');
end











