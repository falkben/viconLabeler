%load the labeled file
%[fname fdir]=uigetfile()
%load([fdir fname])

startframe=label_ratings.d3_analysed.startframe;
endframe=label_ratings.d3_analysed.endframe;
label_coords=struct('label',{label_ratings.label_items.markers.name},...
  'coords',nan(length(startframe:endframe),3));


non_empty_labels=find(~cellfun(@isempty, label_ratings.labels))';
for k=non_empty_labels
  LL=label_ratings.labels{k};
  
  %extract coords
  coords=reshape([LL.track.points.point],3,...
      length([LL.track.points.point])/3)';
  frames=[LL.track.points.frame]';
  label_type=LL.label;
  
  ii=strcmp({label_coords.label},label_type);
  label_coords(ii).coords(frames,:)=coords;
end


%saving...
% d3_analysed=label_ratings.d3_analysed;
% save([fdir fname(1:end-3) '_labelcoords.mat'],'label_coords','d3_analysed')


%plotting all
figure(1); 
clf;
hold on;
clrs=[label_ratings.label_items.markers.color];
for ii=1:length(label_coords)
  plot3(label_coords(ii).coords(:,1),...
    label_coords(ii).coords(:,2),...
    label_coords(ii).coords(:,3),['.' clrs(ii)]);
end
axis equal
grid on