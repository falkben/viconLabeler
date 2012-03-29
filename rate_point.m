function rating = rate_point(frame,point,unlabeled_bat)
%rating includes a 5 point track, as well as measures of the track quality

track = create_track(frame,point,unlabeled_bat,5);
track = remove_duplicate_points(track);
[sm_speed dir] = get_track_vel(track);

spd_var = var(sm_speed);
dir_var = var(dir);

% figure(2);
% text(point(1)+.005,point(2),point(3),...
%   ['dir: ' num2str(dir_var,'%2.3f')]);
% text(point(1)+.005,point(2)+.005,point(3),...
%   ['spd: ' num2str(spd_var,'%2.3f')]);

rating.spd_var = spd_var;
rating.dir_var = dir_var;
rating.point = point;
rating.frame = frame;
rating.track = track;

% figure; plot(sm_speed);
% figure; plot(dir);

% points=reshape([track(:).point],3,length([track(:).point])/3)';

% figure; plot3(points(:,1),points(:,2),points(:,3),'or')