%this function translates and rotates vicon data with d3 data using the 
%calibration wand
function object_rot = align_vicon_with_d3(datecode,xyz,DIAG)

trialcode=datestr(datecode,'yyyymmdd');

pn=getpref('vicon_labeler','ratings');
origin_d3_dir = [pn '..\d3\Origin\'];

%%%%%%%%%%%%%%%%%%%%%%%%

origin_file=dir([origin_d3_dir datestr(datecode,'yyyy.mm.dd') '*_d3.mat']);
if isempty(origin_file)
  object_rot=[];
  return;
end
origin_fname=origin_file.name;

%origin
orig_d3 = load([origin_d3_dir origin_fname]);

origin=orig_d3.d3_analysed.object(3).video(1,:);

for k=1:length(orig_d3.d3_analysed.object)
  wand(k,:)=orig_d3.d3_analysed.object(k).video(1,:)-origin;
end

%vectors from origin
pts=[1 2 4 5];
angles=cart2pol(wand(pts,1),wand(pts,2),wand(pts,3));
angles(3)= angles(3)-pi/2;
angles(4)= angles(4)+pi/2;
angles = angles - pi/2; %it needs to be rotated 90 degrees to start with

%%%%%%%%%%%%%%%%%%%%%%%%

theta=mean(-angles);

rotmat = [cos(theta) sin(theta) 0;...
  -sin(theta) cos(theta) 0 ;...
  0 0 1];

obj=xyz;
object_rot = (obj) / rotmat + ones(size(obj,1),1)*origin; 


if nargin == 3 && DIAG

  figure(1);
  plot3(wand(:,1),...
    wand(:,2),...
    wand(:,3),...
    '*r');
  axis equal; grid on;

  D=sqrt(sum(diff(wand).^2,2));

  D(4)=D(4)-D(3);
  D./D(1)/2; %middle 1/2, 1/2 -- top 1/3, 2/3

  wand_rot = wand * rotmat;
  figure(1); hold on;
  plot3(wand_rot(:,1),...
    wand_rot(:,2),...
    wand_rot(:,3),...
    '*g');
  axis equal; grid on;

  figure(2);clf;
  plot3(object_rot(:,1),object_rot(:,2),object_rot(:,3),'-r','linewidth',3);
  hold on;

  %loading d3 data
  [filename pathname] = uigetfile('..\d3\',...
    ['Get your processed d3 file for trial, ' trialcode]);
  if ~isequal(filename,0)
    load([pathname filename]);
    d3_object=d3_analysed.object(1).video;
    plot3(d3_object(:,1),d3_object(:,2),d3_object(:,3),'-g','linewidth',3);
    axis equal; grid on;
  end

end
