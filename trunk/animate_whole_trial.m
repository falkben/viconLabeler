function [ff,az]=animate_whole_trial(handles,starting_area)
global assign_labels

%minimizing the GUI window during animation to prevent accidental clicking
%of GUI which then starts to animate the GUI...\
jFrame = get(handles.figure1,'JavaFrame');
jFrame.setMinimized(true);

tracks=assign_labels.tracks(cellfun(@(c) ~isempty(c.points),assign_labels.tracks));
labels=assign_labels.labels(cellfun(@(c) ~isempty(c.points),assign_labels.tracks));

track_start_frames=cellfun(@(c) c.points(1).frame,tracks);
track_end_frames=cellfun(@(c) c.points(end).frame,tracks);
if strcmp(starting_area,'beg')
  start_frame = min(track_start_frames);
else
  start_frame = assign_labels.tracks{assign_labels.cur_track_num}.points(1).frame;
end
end_frame = max(track_end_frames);

all_C=assign_labels.d3_analysed.object(1).video;
if ~isfield(assign_labels,'sm_C')
  UB=assign_labels.d3_analysed.unlabeled_bat;
  assign_labels.sm_C = weighted_smooth_centroid(all_C,100,UB,1,0);
end
sm_C=assign_labels.sm_C;
if ~isfield(assign_labels,'turn_angle')
  assign_labels.turn_angle=calc_turn_angle(sm_C,60,0);
end
turn_angle=assign_labels.turn_angle;

f3=figure(3);clf;
a3=gca;

pbpauseplay = uicontrol(f3,'Style','togglebutton','String','ll','value',0,...
  'Position',[45 20 30 40],'fontsize',16); %pause/play '<html>&#9658;</html>'
pbstop = uicontrol(f3,'Style','togglebutton','value',0,...
  'String','<html>&#9632;</html>',...
  'Position',[80 20 30 40],'fontsize',16); %stop
pbrewind = uicontrol(f3,'Style','togglebutton','value',0,...
  'String','<',...
  'Position',[10 20 30 40],'fontsize',16); %stop

des_frate=str2double(get(handles.animate_all_fps,'String'));%fps

warning('off','MATLAB:hg:patch:RGBColorDataNotSupported');
ff=start_frame;
while ff <= end_frame
  tic
    
  %check pause and/or stop button
  if get(pbstop,'value')
    set(pbstop,'value',0)
    ff=ff-1;
    break
  end
  
  if get(pbpauseplay,'value')
    set(pbpauseplay,'string','<html>&#9658;</html>')
    while get(pbpauseplay,'value')
      pause(.25)
      if  get(pbstop,'value')
        ff=ff-1;
        break
      end
    end
    set(pbpauseplay,'string','ll')
  end
  
  if get(pbrewind,'value')
    set(pbrewind,'value',0)
    ff=max(ff-60,1);
  end
  
  centroid=sm_C(ff,:);
    
  axis([-.2 .2 -.2 .2 -.15 .15]);
  
  %get all the tracks index at this frame
  t_ii=find(ff >= track_start_frames & ff <= track_end_frames);
  if isfinite(all_C(ff,1)) && ~isempty(t_ii)
    t_pp=nan(length(t_ii),3);
    cc=zeros(length(t_ii),3);
    for tt=1:length(t_ii)
      t_ff=[tracks{t_ii(tt)}.points.frame] == ff;
      if ~isempty(find(t_ff,1))
        t_pp(tt,:)=tracks{t_ii(tt)}.points(t_ff).point-centroid;
      end
      
      %get the labels of all those points
      lab=labels{t_ii(tt)};
      if ~isempty(lab)
        cc(tt,:) = bitget(find('krgybmcw'==lab.color)-1,1:3);
      end
    end
    
    %plot the points
    scatter3(a3,t_pp(:,1),t_pp(:,2),t_pp(:,3),50,cc,'fill');
    grid(a3,'on');
    set(a3,'xticklabel',[],'yticklabel',[],'zticklabel',[]);
  else
    set(get(a3,'children'),'visible','off');
  end
  az=turn_angle(ff)-90;
  view(az,60);
  
  %     axis([centroid(1)-.2 centroid(1)+.2...
  %       centroid(2)-.2 centroid(2)+.2...
  %       centroid(3)-.2 centroid(3)+.2]);
  %     axis(a3,'equal');
  axis([-.2 .2 -.2 .2 -.15 .15]);
  
  zlabel(num2str(ff),'fontsize',16,'rotation',0)
  
  ff=ff+1;
  
  drawnow;
  ff_time=toc;
  if ff_time < 1/des_frate
    pause(1/des_frate-ff_time)
  end
end

if ff>end_frame
  ff=ff-1;
  disp('animated whole trial')
end
warning('on','MATLAB:hg:patch:RGBColorDataNotSupported');
jFrame.setMinimized(false);