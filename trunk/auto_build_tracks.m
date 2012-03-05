function tracks = auto_build_tracks(d3_analysed)

if nargin < 1 
  d3_analysed = load_trial();
  DIAG=1;
else
  DIAG=0;
end

rating = rate_all(d3_analysed);

% [b ranking_spd]=sort([rating.spd_var]);
% [bb ranking_dir]=sort([rating.dir_var]);

[bbb ranking_spd_dir]=sort([rating.spd_var].*[rating.dir_var]);

sorted_rating=rating(ranking_spd_dir);
sorted_points=reshape([sorted_rating.point],3,length([sorted_rating.point])/3)';

k=1;
tracks={};
points=sorted_points;
unlabeled_bat = d3_analysed.unlabeled_bat;
while length(points) >= .1*length(sorted_points)
  point=points(1,:);
  [b findx] = intersect(sorted_points,point,'rows');
  frame = sorted_rating(findx).frame;
  
  tracks{k} = create_track(frame,point,unlabeled_bat);
  
  track_points = reshape([tracks{k}.point],3,length([tracks{k}.point])/3)';
  
  [r i]=setxor(points,track_points,'rows');
  points = points(sort(i),:);
  unlabeled_bat = rem_points_from_unlabeled_bat(unlabeled_bat,track_points,[tracks{k}.frame]);
  k=k+1;
end

if DIAG
  colors='rbgymc';
  close all;
  figure(3); clf; hold on;
  for k=1:length(tracks)
    track = tracks{k};
    track_points = reshape([track.point],3,length([track.point])/3)';

    plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
      'color',colors(rem(k,length(colors))+1),'linewidth',3);
  end
  plot3(sorted_points(:,1),sorted_points(:,2),sorted_points(:,3),...
    '.k');
  hold off;
  grid on;
  axis vis3d;
end


%removes the tracked points from unlabeled cell array
function unlabeled_bat = rem_points_from_unlabeled_bat(unlabeled_bat,track_points,track_frames)

for k=1:size(track_points,1)
  unlabeled_bat{track_frames(k)} = setxor(unlabeled_bat{track_frames(k)},...
    track_points(k,:),'rows');
end











