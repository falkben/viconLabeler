function varargout = assign_labels(varargin)
% ASSIGN_LABELS MATLAB code for assign_labels.fig
%      ASSIGN_LABELS, by itself, creates a new ASSIGN_LABELS or raises the existing
%      singleton*.
%
%      H = ASSIGN_LABELS returns the handle to a new ASSIGN_LABELS or the handle to
%      the existing singleton*.
%
%      ASSIGN_LABELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ASSIGN_LABELS.M with the given input arguments.
%
%      ASSIGN_LABELS('Property','Value',...) creates a new ASSIGN_LABELS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before assign_labels_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to assign_labels_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help assign_labels

% Last Modified by GUIDE v2.5 19-Mar-2012 17:03:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @assign_labels_OpeningFcn, ...
                   'gui_OutputFcn',  @assign_labels_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before assign_labels is made visible.
function assign_labels_OpeningFcn(hObject, eventdata, handles, varargin)
global assign_labels
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to assign_labels (see VARARGIN)

% Choose default command line output for assign_labels
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
assign_labels=[];

% UIWAIT makes assign_labels wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function open_ratings_file(handles)
global assign_labels

if save_before_discard()
  return;
end

if ispref('vicon_labeler','ratings') && ...
    exist(getpref('vicon_labeler','ratings'),'dir')
  pn=getpref('vicon_labeler','ratings');
else
  pn=uigetdir([],'Set the directory for your ratings file');
  if pn~=0
    setpref('vicon_labeler','ratings',pn);
  end
end
[fn pn] = uigetfile('*.mat','Pick file to label',pn);
if ~isequal(fn,0)
  setpref('vicon_labeler','ratings',pn);
  assign_labels=[];
  load([pn fn]);
  assign_labels.ratings_pathname=pn;
  assign_labels.ratings_filename=fn;
  assign_labels.rating = label_ratings.rating;
  assign_labels.d3_analysed = label_ratings.d3_analysed;
  if ~isfield(label_ratings,'tracks')
    [assign_labels.tracks assign_labels.labels] = build_tracks_from_ratings(label_ratings.d3_analysed,...
      label_ratings.rating);
    load_label_items(handles);
    assign_labels.edited = 1;
    change_track_num(1);
    set(handles.orig_rating_sort,'value',1);
  else
    assign_labels.tracks = label_ratings.tracks;
    assign_labels.labels = label_ratings.labels;
    assign_labels.label_items = label_ratings.label_items;
    assign_labels.cur_track_num = label_ratings.cur_track_num;
    markers = label_ratings.label_items.markers;
    set_label_popup(markers,handles);
    if isfield(label_ratings,'sorted_by')
      assign_labels.sorted_by = label_ratings.sorted_by;
    else
      assign_labels.sorted_by = 'orig_rating';
    end
    switch assign_labels.sorted_by
      case 'orig_rating'
        set(handles.orig_rating_sort,'value',1)
      case 'frame'
        set(handles.frame_sort,'value',1)
      case 'cur_rating'
        set(handles.cur_rating_sort,'value',1)
      case 'length'
        set(handles.length_sort,'value',1)
    end
    change_track_num(assign_labels.cur_track_num);
  end
  initialize(handles);
  update(handles);
end

function [tracks labels] = build_tracks_from_ratings(d3_analysed,rating)
disp('Building tracks... this can take some time');
tracks = auto_build_tracks(d3_analysed,rating);
labels = cell(length(tracks),1);

function load_label_items(handles)
global assign_labels

if isfield(assign_labels,'label_items')
  choice = questdlg(['Label items found/n'...
    'Loading a new set of label items will discard previous track labeling. Continue?'], ...
    'Load label items?', ...
    'Yes','No','No');
  switch choice
    case 'Yes'
      assign_labels = rmfield(assign_labels,'label_items');
      assign_labels.labels = cell(length(assign_labels.tracks),1);
    case 'No'
      return;
  end
end

if ispref('vicon_labeler','label_items') && ...
    exist(getpref('vicon_labeler','label_items'),'dir')
  pn=getpref('vicon_labeler','label_items');
else
  pn=uigetdir([],'Set the directory for your label items');
  if pn~=0
    setpref('vicon_labeler','label_items',pn);
  end
end
[fn pn] = uigetfile('*.mat','Pick label items',pn);

if ~isequal(fn,0)
  setpref('vicon_labeler','label_items',pn);
  LI=load([pn fn]);
  assign_labels.label_items = LI.label_items;
  set_label_popup(markers,handles)
else
  manage_label_items();
  load_label_items(handles);
end

function set_label_popup(markers,handles)
for k=1:length(markers)
  cname = conv_cspec_to_cname(markers(k).color);
  label_popup_txt{k} = ['<HTML><FONT COLOR="' cname '">'...
    markers(k).name ': ' markers(k).color ...
    '</FONT></HTML>'];
%   label_popup_txt{k}=[markers(k).name ': ' markers(k).color];
end
set(handles.label_popup,'string',[{''} label_popup_txt]);


function manage_label_items()
waitfor(label_items);

function initialize(handles)
global assign_labels

%turning this warnign off once for minimizing gui when we animate
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

set(handles.max_tracks,'string',num2str(length(assign_labels.tracks)));

set(handles.track_num_down_button,'enable','on');
set(handles.track_num_up_button,'enable','on');
set(handles.track_num_edit,'enable','on');
set(handles.refocus_button,'enable','on');
set(handles.full_trial_radio,'enable','on');
set(handles.zoomed_radio,'enable','on');
set(handles.label_popup,'enable','on');
set(handles.orig_rating_sort,'enable','on');
set(handles.frame_sort,'enable','on');
set(handles.cur_rating_sort,'enable','on');
set(handles.length_sort,'enable','on');
set(handles.advance_checkbox,'enable','on');
set(handles.edit_start_point,'enable','on');
set(handles.edit_end_point,'enable','on');
set(handles.rebuild_current_track,'enable','on');
set(handles.rebuild_all_tracks,'enable','on');
set(handles.animate_button,'enable','on');
set(handles.save_animation,'enable','on');
set(handles.next_unlabeled,'enable','on');
set(handles.pts_before,'enable','on');
set(handles.pts_after,'enable','on');
set(handles.load_label_items_menu,'enable','on');
set(handles.thresh_length_checkbox,'enable','on');
set(handles.thresh_length_edit,'enable','on');
set(handles.thresh_rank_checkbox,'enable','on');
set(handles.thresh_rank_edit,'enable','on');

set(handles.pts_before,'string','0');
set(handles.pts_after,'string','0');

set(handles.figure1,'name',['Assign Labels: ' assign_labels.ratings_filename]);

figure(1); view(3); rotate3d on;
figure(2); view(3); rotate3d on;

function update(handles)
global assign_labels
unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
all_points = cell2mat(unlabeled_bat);
all_points(all_points(:,1)==0,:) = [];

track = assign_labels.tracks{assign_labels.cur_track_num}.points;
[track_points track_frames] = get_track_points_frames(track);

if isempty(track_frames)
  plotting_frames=[];
  unlab_near_track=[];
else
  plotting_frames = determine_plotting_frames(handles,track_frames,length(unlabeled_bat));
  plotting_frames(plotting_frames > length(unlabeled_bat)) = [];
  plotting_frames(plotting_frames < 1) = [];
  unlab_near_track = cell2mat(unlabeled_bat(plotting_frames));
  unlab_near_track(unlab_near_track(:,1)==0,:) = [];
end

track_color= get_track_color(assign_labels.labels{assign_labels.cur_track_num});

if ~isempty(assign_labels.labels{assign_labels.cur_track_num})
  label_indx = find(~cellfun(@isempty,strfind({assign_labels.label_items.markers.name},...
    assign_labels.labels{assign_labels.cur_track_num}.label)),1) + 1;
else
  label_indx = 1;
end
set(handles.label_popup,'value',label_indx);

set_track_info(handles);

[labels labeled_colors lab_tracks_in_zoom lab_clrs_in_zoom]=get_labels_for_plotting(...
  assign_labels.labels,plotting_frames);

scrn_size=get(0,'ScreenSize');

figure(1);
[az,el] = view;
clf;
set(gcf,'position',[15 .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)])
hold on;
plot3(all_points(:,1),all_points(:,2),all_points(:,3),...
  'ok','markersize',3,'markerfacecolor','k');
plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
  '-o','color',track_color,'markersize',11,'linewidth',2);

if ~isempty(labels) %plotting all the labeled tracks
  for LT = 1:length(labels)
    LT_points = reshape([labels(LT).track.points.point],3,...
      length([labels(LT).track.points.point])/3)';
    plot3(LT_points(:,1),LT_points(:,2),LT_points(:,3),...
      '-o','color',labeled_colors(LT),'markersize',7);
  end
end

unlabeled_empty = cellfun(@(c) ~isempty(find(c, 1)),unlabeled_bat);
first_frame_with_points = find(unlabeled_empty,1);
last_frame_with_points = find(unlabeled_empty,1,'last');
trial_start_loc = mean(unlabeled_bat{first_frame_with_points},1);
trial_end_loc = mean(unlabeled_bat{last_frame_with_points},1);
text(trial_start_loc(1),trial_start_loc(2)-.2,trial_start_loc(3)+.2,...
  'START');
text(trial_end_loc(1)+.2,trial_end_loc(2),trial_end_loc(3)+.2,...
  'END');

axis vis3d;
view([az,el]);
grid on;

figure(2);
set(gcf,'position',[30+.3*scrn_size(3) .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)]);
if isempty(plotting_frames)
  cla;
  a = axis;
  text((a(1)+a(2))/2,(a(3)+a(4))/2,'No track points','fontsize',14);
  grid off;
else
  [az,el] = view;
  clf;
  hold on;
  plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
    '-o','color',track_color,'markersize',11,'linewidth',2);
  plot3(unlab_near_track(:,1),unlab_near_track(:,2),unlab_near_track(:,3),...
    'ok','markersize',3,'markerfacecolor','k');
  for lab=1:length(lab_tracks_in_zoom)
    lab_frames = [lab_tracks_in_zoom{lab}.frame];
    [c ia]=intersect(lab_frames,plotting_frames);
    lab_points = reshape([lab_tracks_in_zoom{lab}.point],3,...
      length([lab_tracks_in_zoom{lab}.point])/3)';
    plot3(lab_points(ia,1),lab_points(ia,2),lab_points(ia,3),...
      '-o','color',lab_clrs_in_zoom{lab},'markersize',7);
  end
  text(track_points(1,1),track_points(1,2),track_points(1,3)+.15,...
    'START');
  text(track_points(end,1),track_points(end,2),track_points(end,3)+.15,...
    'END');
  axis vis3d;
  view([az,el]);
  grid on;
end

function set_track_info(handles)
global assign_labels
set(handles.track_num_edit,'string',num2str(assign_labels.cur_track_num));

if ~isempty(assign_labels.tracks{assign_labels.cur_track_num}.points)
  set(handles.frame_text,'string',...
    num2str(assign_labels.tracks{assign_labels.cur_track_num}.points(1).frame));
  set(handles.length_text,'string',...
    num2str(length(assign_labels.tracks{assign_labels.cur_track_num}.points)));

  sort_value = cellfun(@(c) c.rating.spd_var * c.rating.dir_var,assign_labels.tracks);
  [B,IX] = sort(sort_value);

  [sm_speed dir] = get_track_vel(assign_labels.tracks{assign_labels.cur_track_num}.points);
  spd_var = var(sm_speed);
  dir_var = var(dir);

  rank=find(IX==assign_labels.cur_track_num);
  set(handles.ranking_text,'string',...
    [num2str(rank/length(assign_labels.tracks)* 100,'%2.1f') ' %']);
  set(handles.ranking_text,'TooltipString',...
    num2str(rank));
  set(handles.spd_text,'string',...
    num2str(spd_var,'%0.3f'));
  set(handles.dir_text,'string',...
    num2str(dir_var,'%0.3f'));
else
  set(handles.frame_text,'string','');
  set(handles.length_text,'string','');
  set(handles.ranking_text,'string','');
  set(handles.ranking_text,'TooltipString','');
  set(handles.spd_text,'string','');
  set(handles.dir_text,'string','');
end

function refocus(handles)
global assign_labels
if get(handles.full_trial_radio,'value')
  figure(1);
else
  figure(2);
end
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','datatip',...
  'SnapToDataVertex','off','Enable','on')
disp('Select point to zoom on and label, then press enter');
pause
rotate3d on;
c_info = getCursorInfo(dcm_obj);

if ~isempty(c_info)

  all_tracks=cell2mat(assign_labels.tracks);
  merged_tracks=[all_tracks.points];
  merged_track_points = reshape([merged_tracks.point],3,length([merged_tracks.point])/3)';

  point_diff = merged_track_points - ones(length(merged_track_points),1)*c_info.Position;
  [M find_indx]=min(distance([0 0 0],point_diff));

  point = merged_track_points(find_indx,:);
  ia=find(ismember(merged_track_points,point,'rows'));

  track_lengths = cellfun(@(c) length(c.points),assign_labels.tracks);

  if length(ia) == 1
    track_indx = find(cumsum(track_lengths) - ia >= 0,1);
  else %choose the one with the best rating
    for k=1:length(ia)
      t_indx = find(cumsum(track_lengths) - ia(k) >= 0,1);
      track = assign_labels.tracks{t_indx};

      [sm_speed dir] = get_track_vel(track.points);
      spd_var = var(sm_speed);
      dir_var = var(dir);
      rating(k)=spd_var*dir_var;
    end
    [M best_rating] = min(rating);
    track_indx = find(cumsum(track_lengths) - ia(best_rating) >= 0,1);
  end
    
  change_track_num(track_indx);

end

update(handles);


function change_track_num(n)
global assign_labels
if n < 1
  n=1;
elseif n > length(assign_labels.tracks)
  n=length(assign_labels.tracks);
end
assign_labels.cur_track_num=n;


function find_next_unlabeled(handles)
global assign_labels
cur_track_num = assign_labels.cur_track_num;

tracks = assign_labels.tracks(cur_track_num+1:end);
track_indx=1:length(tracks);

if get(handles.thresh_length_checkbox,'value')
  len_thresh=str2double(get(handles.thresh_length_edit,'string'));
  track_lengths = cellfun(@(c) length(c.points),tracks);
  track_indx = intersect(track_indx,...
    find(track_lengths>=len_thresh));
end

if get(handles.thresh_rank_checkbox,'value')
  sort_value = cellfun(@(c) c.rating.spd_var * c.rating.dir_var,assign_labels.tracks);
  [B,IX] = sort(sort_value);
  [B,IX]=sort(IX);
  rank_percent = IX./length(assign_labels.tracks)*100;
  
  rank_thresh = str2double(get(handles.thresh_rank_edit,'string'));
  rank_percent = rank_percent(cur_track_num+1:end);
  track_indx = intersect(track_indx,...
    find(rank_percent<=rank_thresh));
end

if ~isempty(track_indx)
  labels = assign_labels.labels(cur_track_num+1:end);
  labels = labels(track_indx);
  first_empty_label=find(cellfun(@isempty,labels),1);
  if ~isempty(first_empty_label)
    change_track_num(cur_track_num + track_indx(first_empty_label));
  end
end


function remove_labeled_points_from_other_tracks(track)
global assign_labels
track_points = get_track_points_frames(track.points);

track_indx = setdiff(1:length(assign_labels.tracks),assign_labels.cur_track_num);
edited_tracks = cellfun(@(c) {remove_points_from_track(c,track_points)},...
  assign_labels.tracks(track_indx));

assign_labels.tracks(track_indx) = edited_tracks;


function track_labeled(selected_label_item)
global assign_labels

LI_indx = selected_label_item - 1;

if LI_indx > 0
  remove_labeled_points_from_other_tracks(assign_labels.tracks{assign_labels.cur_track_num});
  
  assign_labels.labels{assign_labels.cur_track_num}.color = ...
    assign_labels.label_items.markers(LI_indx).color;
  assign_labels.labels{assign_labels.cur_track_num}.track = ...
    assign_labels.tracks{assign_labels.cur_track_num};
  assign_labels.labels{assign_labels.cur_track_num}.label = ...
    assign_labels.label_items.markers(LI_indx).name;
else
  assign_labels.labels{assign_labels.cur_track_num}=[];
end
assign_labels.edited = 1;

function sort_tracks(sort_type)
global assign_labels
switch sort_type
  case 'orig_rating'
    sort_value = cellfun(@(c) c.rating.spd_var * c.rating.dir_var,assign_labels.tracks);
  case 'frame'
    sort_value = cellfun(@(c) c.rating.frame,assign_labels.tracks);
  case 'cur_rating'
    [spd dir]=cellfun(@(c) get_track_vel(c.points), assign_labels.tracks,...
      'uniformoutput',0);
    sort_value = cellfun(@var,spd) .* cellfun(@var,dir);
  case 'length'
    sort_value = 1./cell2mat(cellfun(@(c) length(c.points), assign_labels.tracks,...
      'uniformoutput',0));
end
[B,IX] = sort(sort_value);
assign_labels.tracks = assign_labels.tracks(IX);
assign_labels.labels = assign_labels.labels(IX);
assign_labels.sorted_by = sort_type;
change_track_num(find(IX==assign_labels.cur_track_num,1))


function crop_track(handles,crop_side)
global assign_labels
if get(handles.full_trial_radio,'value')
  figure(1);
else
  figure(2);
end
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','datatip',...
  'SnapToDataVertex','off','Enable','on')
disp('Select point to crop to, then press enter');
pause
rotate3d 'on';
c_info = getCursorInfo(dcm_obj);

if ~isempty(c_info)
  
  selected_point = c_info.Position;
  
  old_track = assign_labels.tracks{assign_labels.cur_track_num}.points;
  old_track_points = get_track_points_frames(old_track);
    
  point_diff = old_track_points - ones(length(old_track_points),1)*selected_point;
  [M find_indx]=min(distance([0 0 0],point_diff));
  
  switch crop_side
    case 'start'
      new_track = old_track(find_indx:end);
    case 'end'
      new_track = old_track(1:find_indx);
  end
  
  assign_labels.tracks{assign_labels.cur_track_num}.points=new_track;
  if ~isempty(assign_labels.labels{assign_labels.cur_track_num})
    assign_labels.labels{assign_labels.cur_track_num}.track.points = new_track;
  end
  
  assign_labels.edited = 1;
  
  update(handles);
  
end


function save_trial(fn,pn)
global assign_labels
if isfield(assign_labels,'edited')
  assign_labels=rmfield(assign_labels,'edited');
end
label_ratings = assign_labels;
label_ratings.ratings_pathname = pn;
label_ratings.ratings_filename = fn;
save([pn fn],'label_ratings');
disp(['Saved at: ' datestr(now,14)]);

function plotting_frames = determine_plotting_frames(handles,track_frames,trial_length)
plotting_frames = track_frames(1)-str2double(get(handles.pts_before,'string')):...
  track_frames(end)+str2double(get(handles.pts_after,'string'));
plotting_frames(plotting_frames < 1) = [];
plotting_frames(plotting_frames > trial_length) = [];


function track_color = get_track_color(label)
if isempty(label)
  track_color = [.5 .5 .5];
else
  track_color = label.color;
end

function [track_points track_frames] = get_track_points_frames(track)
track_points = reshape([track.point],3,length([track.point])/3)';
track_frames = [track.frame];

function [labels labeled_colors lab_tracks_in_zoom lab_clrs_in_zoom]=get_labels_for_plotting(all_labels,plotting_frames)

labels = [all_labels{~cellfun(@isempty,all_labels)}];
if ~isempty(labels)
  labeled_colors = [labels.color];
else
  labeled_colors = [];
end

lab_tracks_in_zoom = {};
lab_clrs_in_zoom = {};
for lab=1:length(labels)
  lab_track = labels(lab).track.points;
  lab_frames = [lab_track.frame];
  isect_lab_track = intersect(lab_frames,plotting_frames);
  if ~isempty(isect_lab_track)
    lab_tracks_in_zoom{end+1} = lab_track;
    lab_clrs_in_zoom{end+1} = labels(lab).color;
  end
end


function animate_zoom(saving,handles)
global assign_labels

%minimizing the GUI window during animation to prevent accidental clicking
%of GUI which then starts to animate the GUI...\
jFrame = get(handles.figure1,'JavaFrame');
jFrame.setMinimized(true);


track = assign_labels.tracks{assign_labels.cur_track_num}.points;
[track_points track_frames] = get_track_points_frames(track);

unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
plotting_frames = determine_plotting_frames(handles,track_frames,length(unlabeled_bat));

track_color = get_track_color(assign_labels.labels{assign_labels.cur_track_num});

[labels labeled_colors lab_tracks_in_zoom lab_clrs_in_zoom]=get_labels_for_plotting(...
  assign_labels.labels,plotting_frames);

unlab_near_track = unlabeled_bat(plotting_frames);
unlab_near_track=cellfun(@(c) c(c(:,1)~=0,:),unlab_near_track,'uniformoutput',0);

figure(2);
[az,el] = view;

if saving
  vid_frate = assign_labels.d3_analysed.fvideo / 20;
  fname = [assign_labels.d3_analysed.trialcode '_track_' num2str(assign_labels.cur_track_num) '.avi'];
  [status, result] = dos('echo %USERPROFILE%\Desktop');
  pn = result;
  aviobj = avifile([pn(1:end-1) '\' fname],'compression','None','Fps',vid_frate);
end

h3=figure(3);clf;
all_points=cell2mat(unlab_near_track);
plot3(all_points(:,1),all_points(:,2),all_points(:,3),'.k');
a=axis;
for k=1:length(plotting_frames)
  clf(h3); hold on;
  
  frame=plotting_frames(k);
  track_indx=find(track_frames == frame);
  if ~isempty(track_indx)
    plot3(track(track_indx).point(1),track(track_indx).point(2),track(track_indx).point(3),...
      '-o','color',track_color,'markersize',11,'linewidth',2);
  end
  plot3(unlab_near_track{k}(:,1),unlab_near_track{k}(:,2),unlab_near_track{k}(:,3),...
    'ok','markersize',3,'markerfacecolor','k');
  
  for lab=1:length(lab_tracks_in_zoom)
    lab_frames = [lab_tracks_in_zoom{lab}.frame];
    [c ia]=intersect(lab_frames,frame);
    lab_points = reshape([lab_tracks_in_zoom{lab}.point],3,...
      length([lab_tracks_in_zoom{lab}.point])/3)';
    plot3(lab_points(ia,1),lab_points(ia,2),lab_points(ia,3),...
      '-o','color',lab_clrs_in_zoom{lab},'markersize',7);
  end
  
  text(track_points(1,1),track_points(1,2),track_points(1,3)+.15,...
    'START');
  text(track_points(end,1),track_points(end,2),track_points(end,3)+.15,...
    'END');
  text(a(1),a(3),num2str(frame));
  axis(a);
  axis vis3d;
  view([az,el]);
  grid on;
  if saving
    currFrame = getframe(gcf);
    aviobj = addframe(aviobj,currFrame);
  else
    pause(.02); %add another 20 milliseconds to each frame draw
  end
end

if saving
  aviobj = close(aviobj);
  system(['explorer.exe /select,' pn(1:end-1) '\' fname])
  %encode the file?
end

jFrame.setMinimized(false);

function close_GUI(hObject)
global assign_labels

if save_before_discard()
  return
end

assign_labels = [];
% Hint: delete(hObject) closes the figure
delete(hObject);
close all;

function canceled = save_before_discard()
global assign_labels
canceled = 0;
if isfield(assign_labels,'edited') && assign_labels.edited
  choice = questdlg('Edits detected, save first?', ...
    'Save?', ...
    'Yes','No','Cancel','Yes');
  % Handle response
  switch choice
    case 'Yes'
      save_trial(assign_labels.ratings_filename,assign_labels.ratings_pathname);
    case 'Cancel'
      canceled = 1;
  end
end


%%%%%%%%%%%%%%%%%%%%%% CALLBACKS %%%%%%%%%%%%%%%%%%%%%%


function varargout = assign_labels_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function file_menu_Callback(hObject, eventdata, handles)


function open_menu_Callback(hObject, eventdata, handles)
open_ratings_file(handles);


function save_menu_Callback(hObject, eventdata, handles)
global assign_labels
save_trial(assign_labels.ratings_filename,assign_labels.ratings_pathname);

function save_as_menu_Callback(hObject, eventdata, handles)
global assign_labels
if ispref('vicon_labeler','ratings') && ...
    exist(getpref('vicon_labeler','ratings'),'dir')
  pn=getpref('vicon_labeler','ratings');
else
  pn=uigetdir([],'Set the directory for your labeled files');
  if pn~=0
    setpref('vicon_labeler','ratings',pn);
  end
end

[FileName,PathName] = uiputfile('*.mat',[],[pn assign_labels.ratings_filename]);
if isequal(FileName,0) || isequal(PathName,0)
 return;
else
 save_trial(FileName,PathName);
end

function track_num_edit_Callback(hObject, eventdata, handles)
change_track_num(str2double(get(hObject,'String')));
update(handles);

function track_num_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function refocus_button_Callback(hObject, eventdata, handles)
refocus(handles);


function track_num_up_button_Callback(hObject, eventdata, handles)
change_track_num(str2double(get(handles.track_num_edit,'String'))+1);
update(handles);

function track_num_down_button_Callback(hObject, eventdata, handles)
change_track_num(str2double(get(handles.track_num_edit,'String'))-1);
update(handles);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
%from the close [x] button
close_GUI(hObject);

function close_GUI_Callback(hObject, eventdata, handles)
%from the menu dropdown
close_GUI(handles.figure1);

function label_popup_Callback(hObject, eventdata, handles)
track_labeled(get(hObject,'Value'));
if get(handles.advance_checkbox,'value')
  find_next_unlabeled(handles);
end
update(handles);

function label_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function label_menu_Callback(hObject, eventdata, handles)

function manage_label_items_Callback(hObject, eventdata, handles)
manage_label_items();

function sort_panel_SelectionChangeFcn(hObject, eventdata, handles)
if get(handles.orig_rating_sort,'value')
  sort_type = 'orig_rating';
elseif get(handles.frame_sort,'value')
  sort_type = 'frame';
elseif get(handles.cur_rating_sort,'value')
  sort_type = 'cur_rating';
elseif get(handles.length_sort,'value')
  sort_type = 'length';
end
sort_tracks(sort_type);
update(handles);


function advance_checkbox_Callback(hObject, eventdata, handles)

function rebuild_current_track_Callback(hObject, eventdata, handles)
global assign_labels
if ~isempty(assign_labels.labels{assign_labels.cur_track_num})
  choice = questdlg('Continuing will wipe the current label', ...
    'Rebuild current track', ...
    'OK','Cancel','Cancel');
  switch choice
    case 'Cancel'
      return;
  end
end
frame = assign_labels.tracks{assign_labels.cur_track_num}.rating.frame;
point = assign_labels.tracks{assign_labels.cur_track_num}.rating.point;
unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
[track endings] = create_track(frame,point,unlabeled_bat);
assign_labels.tracks{assign_labels.cur_track_num}.points = track;
assign_labels.tracks{assign_labels.cur_track_num}.endings = endings;
assign_labels.labels{assign_labels.cur_track_num}=[];
assign_labels.edited = 1;
update(handles);

function rebuild_all_tracks_Callback(hObject, eventdata, handles)
global assign_labels
choice = questdlg('Continuing will wipe all tracks and labels', ...
	'Rebuild all tracks', ...
	'OK','Cancel','Cancel');
switch choice
  case 'Cancel'
    return;
end
[assign_labels.tracks assign_labels.labels] = build_tracks_from_ratings(assign_labels.d3_analysed,...
assign_labels.rating);
assign_labels.edited = 1;
update(handles);

function edit_start_point_Callback(hObject, eventdata, handles)
crop_track(handles,'start');

function edit_end_point_Callback(hObject, eventdata, handles)
crop_track(handles,'end');


function animate_button_Callback(hObject, eventdata, handles)
animate_zoom(get(handles.save_animation,'value'),handles);

function save_animation_Callback(hObject, eventdata, handles)

function next_unlabeled_Callback(hObject, eventdata, handles)
find_next_unlabeled(handles);
update(handles);


function pts_before_Callback(hObject, eventdata, handles)
if str2double(get(hObject,'String')) < 0
  set(hObject,'String','0');
end
update(handles);

function pts_before_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pts_after_Callback(hObject, eventdata, handles)
if str2double(get(hObject,'String')) < 0
  set(hObject,'String','0');
end
update(handles);

function pts_after_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function load_label_items_menu_Callback(hObject, eventdata, handles)
load_label_items(handles);
update(handles);


function thresh_length_checkbox_Callback(hObject, eventdata, handles)


function thresh_rank_checkbox_Callback(hObject, eventdata, handles)



function thresh_length_edit_Callback(hObject, eventdata, handles)
global assign_labels
max_length = max(cellfun(@(c) length(c.points),assign_labels.tracks));
value=str2double(get(hObject,'String'));
if value<0
  set(hObject,'string','0');
elseif value > max_length
  set(hObject,'string',num2str(max_length));
end

function thresh_length_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function thresh_rank_edit_Callback(hObject, eventdata, handles)
value = str2double(get(hObject,'String'));
if value < 0
  set(hObject,'string','0');
elseif value > 100
  set(hObject,'string','100');
end

function thresh_rank_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
