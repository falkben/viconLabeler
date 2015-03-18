function [PathName,FileName] = c3d2batmat_manual(autosave,c3dfname,DIAG)
PathName = ''; FileName = '';

if nargin<1
  autosave=0;
end

if nargin<2
  c3dfname=get_c3dfname;
end

if nargin<3
  DIAG=0;
end

c3d_trial=open_c3d(c3dfname);
if isempty(c3d_trial)
  disp('problem loading c3d file');
  return;
end

new_UB=crop_trial(c3d_trial.unlabeled_bat,[],autosave);
if isempty(find(~cellfun(@isempty,new_UB),1))
  disp('nothing found after cropping')
  return;
end

[~,bat_avg,~,ignore_frames]=extract_bat_postion(new_UB,DIAG);
d3_analysed = create_d3_analysed(c3d_trial,bat_avg,new_UB,ignore_frames);

[PathName,FileName] = save_d3_analysed(d3_analysed,autosave);

all_bat=cell2mat(new_UB);
disp(['Num of empty frames: ' num2str(length(find(cellfun(@isempty,new_UB))))]);
disp(['Num unique points: ' num2str(length(unique(all_bat,'rows')))]);


function new_UB = crop_trial(UB,frame,autosave)
thresh_distance=.35;

UB_all = cell2mat(UB);
frames=1:length(UB);

BP=cell(length(UB),1); %bat points
go_on=1; ab=[];

figure(6); clf; set(gcf,'pos',[10 40 525 575]);
while go_on
  if isempty(ab)
    plot3(UB_all(:,1),UB_all(:,2),UB_all(:,3),'o','color',[.5 .5 .5])
    view(3);
    axis equal;
    axis([-3 3 -4.2 3.8 .3 2.6]);
    view(2)
    hold on; grid on;
  end
  
  if isempty(ab)
    dcm_obj = datacursormode(gcf);
    set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','off','Enable','on')
  end
  str = input('Select pt., then press enter','s');
  c_info = getCursorInfo(dcm_obj);
  delete(findall(gcf,'Type','hggroup'));
  if ~isempty(c_info)
    selected_point = c_info.Position;
    frame=get_frame_from_point(selected_point,UB);
  else
    prompt = 'Finished? Y/N [Y]: ';
    str = input(prompt,'s');
    if isempty(str)
      str = 'Y';
    end
    if strcmp(str,'Y') || strcmp(str,'y')
      break
    else
      prompt = 'Start trial over? Y/N [Y]: ';
      str = input(prompt,'s');
      if isempty(str)
        str = 'Y';
      end
      if strcmp(str,'Y') || strcmp(str,'y')
        BP=cell(length(UB),1); %bat points
        delete(ab); ab=[];
      end
      continue;
    end
  end
  
  LBP=BP; %last bat points
  
  %crop around point
  last_point = selected_point;
  for f=frame:length(frames)
    [BP{f},last_point] = ...
      grab_nearest_points(UB{f},last_point,thresh_distance);
    if ~isempty(BP{f-1}) && ~isempty(BP{f}) &&...
        distance(mean(BP{f},1),mean(BP{f-1},1))<.002
      break
    end
  end
  
  last_point=selected_point;
  for f=frame-1:-1:1
    [BP{f},last_point] = ...
      grab_nearest_points(UB{f},last_point,thresh_distance);
    if ~isempty(BP{f+1}) && ~isempty(BP{f}) &&...
        distance(mean(BP{f},1),mean(BP{f+1},1))<.002
      break
    end
  end
  
  %merge the two together
  for f=union(find(~cellfun(@isempty,BP)),find(~cellfun(@isempty,LBP)) )'
    BP{f}=unique([BP{f}; LBP{f}],'rows');
  end
  
  %plot updated points
  all_bat=cell2mat(BP);
  if ~isempty(ab)
    delete(ab);
  end
  ab=plot3(all_bat(:,1),all_bat(:,2),all_bat(:,3),'.k');
  drawnow;
end

new_UB=BP;




function [other_bat_points,last_point,mean_distance]=grab_nearest_points(other_points,last_point,thresh_distance)
mean_distance=nan;
D = distance(other_points,last_point);
other_bat_points = other_points(D<=thresh_distance,:);
curr_centroid = mean(other_bat_points,1);
if ~isnan(curr_centroid(1))
  last_point = curr_centroid;
  mean_distance = mean(D(D<=thresh_distance));
end



function [bat_sm,bat_avg,plot_frames,ignore_frames]=extract_bat_postion(UB,DIAG)

centroids_cell = cellfun(@(c) nanmean(c,1),UB,...
  'uniformoutput',0);

centroids_cell(cellfun(@isempty,centroids_cell))={nan(1,3)};
plot_frames = find(~cellfun(@(c) isnan(c(:,1)),centroids_cell));
ignore_frames = find(cellfun(@(c) isnan(c(:,1)),centroids_cell));

bat_avg=nan(length(centroids_cell),3);
bat_avg(plot_frames,:)=cell2mat(centroids_cell(plot_frames));

bat_sm=nan(length(centroids_cell),3);
for k=1:length(ignore_frames)
  
  if k==1
    sframe=plot_frames(1);
    eframe=ignore_frames(1)-1;
  elseif k==length(ignore_frames)
    sframe=ignore_frames(end)+1;
    eframe=plot_frames(end);
  else
    sframe=plot_frames(...
      find(plot_frames<ignore_frames(k) & plot_frames>ignore_frames(k-1),1) ...
      );
    eframe=plot_frames(...
      find(plot_frames<ignore_frames(k) & plot_frames>ignore_frames(k-1),1,'last') ...
      );
  end
  
  bat_sm(sframe:eframe,:)=[smooth(bat_avg(sframe:eframe,1)) ...
    smooth(bat_avg(sframe:eframe,2)) ...
    smooth(bat_avg(sframe:eframe,3))];
end

if nargin >1 && DIAG
  figure(7); clf; plot3(bat_sm(:,1),bat_sm(:,2),bat_sm(:,3),'linewidth',3)
  hold on; plot3(bat_avg(:,1),bat_avg(:,2),bat_avg(:,3),'r','linewidth',3)
  all_points=cell2mat(UB);
  plot3(all_points(:,1),all_points(:,2),all_points(:,3),'.k');
  grid on;
  axis equal;
  a=axis;
  
%   figure(8); clf;
%   for ff=1:length(UB)
%     ah=plot3(UB{ff}(:,1),UB{ff}(:,2),UB{ff}(:,3),'.k');
%     axis equal; axis(a); grid on;
%     drawnow;
%     delete(ah);
%   end
end


function c3dfname=get_c3dfname
c3dfname=0;
if ispref('vicon_labeler','c3d_files') && ...
    exist(getpref('vicon_labeler','c3d_files'),'dir')
  pn=getpref('vicon_labeler','c3d_files');
else
  pn=uigetdir([],'Set the directory for your c3d files');
  if pn~=0
     setpref('vicon_labeler','c3d_files',pn);
  else
    return;
  end
end
[fn, pn] = uigetfile('*.c3d','Pick file to label',pn);
if ~isequal(fn,0)
  setpref('vicon_labeler','c3d_files',pn);
  c3dfname = [pn fn];
else
  return;
end




