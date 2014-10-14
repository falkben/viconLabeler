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

% Last Modified by GUIDE v2.5 01-Oct-2014 15:40:19

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
function assign_labels_OpeningFcn(hObject, ~, handles, varargin)
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

if ispref('vicon_labeler','ratings') && ...
    exist(getpref('vicon_labeler','ratings'),'dir')
  pn=getpref('vicon_labeler','ratings');
else
  pn=uigetdir([],'Set the directory for your ratings file');
  if pn~=0
    setpref('vicon_labeler','ratings',pn);
  else return;
  end
end
[fn, pn] = uigetfile('*.mat','Pick file to label',pn);
if ~isequal(fn,0)
  setpref('vicon_labeler','ratings',pn);
  assign_labels=[];
  disp('Loading...')
  load([pn fn]);
  disp('Loaded trial.')
  assign_labels.ratings_pathname=pn;
  assign_labels.ratings_filename=fn;
  assign_labels.rating = label_ratings.rating;
  assign_labels.d3_analysed = label_ratings.d3_analysed;
  assign_labels.origin = 'rating';
  if ~isfield(label_ratings,'tracks')
    [assign_labels.tracks, assign_labels.labels] = build_tracks_from_ratings(label_ratings.d3_analysed,...
      label_ratings.rating);
    load_label_items(handles);
    assign_labels.edited = 1;
    set(handles.frame_sort,'value',1);
    change_track_num(1,handles);
    sort_tracks(handles);
    change_track_num(1,handles);
  else
    assign_labels.tracks = label_ratings.tracks;
    assign_labels.labels = label_ratings.labels;
    assign_labels.label_items = label_ratings.label_items;
    if isfield(label_ratings,'cur_track_num')
      assign_labels.cur_track_num = label_ratings.cur_track_num;
    else
      assign_labels.cur_track_num = 1;
    end
    markers = label_ratings.label_items.markers;
    set_label_popup(markers,handles);
    if isfield(label_ratings,'sorted_by')
      assign_labels.sorted_by = label_ratings.sorted_by;
    else
      assign_labels.sorted_by = 'frame';
      sort_tracks(handles);
      assign_labels.cur_track_num = 1;
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
    change_track_num(assign_labels.cur_track_num,handles);
  end
  initialize(handles);
  update(handles);
end


function [tracks, labels] = build_tracks_from_ratings(d3_analysed,rating)
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
[fn, pn] = uigetfile('*.mat','Pick label items',pn);

if ~isequal(fn,0)
  setpref('vicon_labeler','label_items',pn);
  LI=load([pn fn]);
  assign_labels.label_items = LI.label_items;
  set_label_popup(assign_labels.label_items.markers,handles)
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
if get(handles.advance_checkbox,'value')
  set(handles.auto_animate,'enable','on');
end
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
set(handles.new_track_button,'enable','on');
set(handles.use_all_radio,'enable','on');
set(handles.use_unlabeled_radio,'enable','on');
set(handles.del_button,'enable','on');
set(handles.labels_listbox,'enable','on');
set(handles.prev_unlabeled,'enable','on');
set(handles.all_labels_as_options,'enable','on');
set(handles.labels_listbox,'enable','on');
set(handles.labels_listbox,'Value',1);
set(handles.animate_from_beg,'enable','on');
set(handles.animate_from_cur,'enable','on');
set(handles.animate_all_fps,'enable','on');
set(handles.lock_flight_dir_checkbox,'enable','on');

set(handles.photron_toggle,'enable','on');
set(handles.cam1_edit,'enable','on');
set(handles.cam2_edit,'enable','on');
set(handles.photron_fps_edit,'enable','on');
set(handles.cam1_button,'enable','on');
set(handles.cam2_button,'enable','on');
set(handles.autoload_photron_button,'enable','on');

set(handles.photron_toggle,'Value',0);
set(handles.cam1_edit,'String','');
set(handles.cam1_edit,'tooltipString','');
set(handles.cam2_edit,'String','');
set(handles.cam2_edit,'tooltipString','');
set(handles.photron_fps_edit,'String','');

set(handles.figure1,'name',['Assign Labels: ' assign_labels.ratings_filename]);

figure(1); view(3); rotate3d on;
figure(2); view(3); rotate3d on;

function update(handles)
global assign_labels
unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
all_points = cell2mat(unlabeled_bat);
all_points(all_points(:,1)==0,:) = [];

if get(handles.lock_flight_dir_checkbox,'value')
  if ~isfield(assign_labels,'turn_angle')
    all_C=assign_labels.d3_analysed.object(1).video;
    sm_C = sm_centroid(all_C,100,0);
    assign_labels.sm_C=sm_C;
    assign_labels.turn_angle=calc_turn_angle(sm_C,0);
  end
  turn_angle=assign_labels.turn_angle;
end

track = assign_labels.tracks{assign_labels.cur_track_num}.points;
[track_points,track_frames] = get_track_points_frames(track);

if isempty(track_frames)
  plotting_frames=[];
  unlab_near_track=[];
else
  plotting_frames = determine_plotting_frames(handles,track_frames,length(unlabeled_bat));
  unlab_near_track = cell2mat(unlabeled_bat(plotting_frames));
  unlab_near_track(unlab_near_track(:,1)==0,:) = [];
end

track_color= get_track_color(assign_labels.labels{assign_labels.cur_track_num});

[labels,labeled_colors]=get_all_labels_colors(assign_labels.labels);
markers=assign_labels.label_items.markers;
if ~isempty(assign_labels.labels{assign_labels.cur_track_num})
  label_indx = find(~cellfun(@isempty,strfind({assign_labels.label_items.markers.name},...
    assign_labels.labels{assign_labels.cur_track_num}.label)),1) + 1;
else
  label_indx = 1;
  if ~get(handles.all_labels_as_options,'value')
    [~,~,lab_name_in_zoom]=get_labels_for_plotting(...
      labels,track_frames);
    marker_names={assign_labels.label_items.markers.name};
    [~,ia] = setdiff(marker_names,lab_name_in_zoom);
    markers = assign_labels.label_items.markers(sort(ia));
  end
end
set_label_popup(markers,handles);
set(handles.label_popup,'value',label_indx);

set_track_info(handles);

set_label_listbox(handles);

[lab_tracks_in_zoom,lab_clrs_in_zoom]=get_labels_for_plotting(labels,plotting_frames);

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

% axis vis3d;
view([az,el]); axis equal;
grid on;

%zoom view
figure(2);
set(gcf,'position',[30+.3*scrn_size(3) .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)]);
if isempty(plotting_frames)
  cla;
  a = axis;
  text((a(1)+a(2))/2,(a(3)+a(4))/2,'No track points','fontsize',14);
  grid off;
else
  if get(handles.lock_flight_dir_checkbox,'value')
    [~,el] = view;
    az=turn_angle(track_frames(1))-90;
  else
    [az,el] = view;
  end
  clf;
  hold on;
  plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
    '-o','color',track_color,'markersize',11,'linewidth',2);
  plot3(unlab_near_track(:,1),unlab_near_track(:,2),unlab_near_track(:,3),...
    'ok','markersize',3,'markerfacecolor','k');
  for lab=1:length(lab_tracks_in_zoom)
    lab_frames = [lab_tracks_in_zoom{lab}.frame];
    [~, ia]=intersect(lab_frames,plotting_frames);
    lab_points = reshape([lab_tracks_in_zoom{lab}.point],3,...
      length([lab_tracks_in_zoom{lab}.point])/3)';
    plot3(lab_points(ia,1),lab_points(ia,2),lab_points(ia,3),...
      '-o','color',lab_clrs_in_zoom{lab},'markersize',7);
  end
  text(track_points(1,1),track_points(1,2),track_points(1,3)+.15,...
    'START');
  text(track_points(end,1),track_points(end,2),track_points(end,3)+.15,...
    'END');
  %   axis vis3d;
  view([az,el]); axis equal;
  grid on;
end

if get(handles.photron_toggle,'Value')
  plot_photron(handles)
else
  fig_nums = get(0,'children');
  close(intersect([4 5],fig_nums));
end

if isempty(assign_labels.track_history)
  set(handles.backbutton,'enable','off');
end
if isempty(assign_labels.track_forw_history)
  set(handles.forwardbutton,'enable','off');
end

function plot_photron(handles,frame,cam_num,animation_frames)
global assign_labels

photron_fvideo_text = get(handles.photron_fps_edit,'string');
if isequal(photron_fvideo_text,'')
  display('Set frame rate');
  return;
end
photron_fvideo = str2double(photron_fvideo_text);

if ispref('vicon_labeler','d3_path') && ...
    exist(getpref('vicon_labeler','d3_path'),'dir')
  d3_path=getpref('vicon_labeler','d3_path');
else
  d3_path=uigetdir([],'Locate the d3 directory');
  if d3_path~=0
    setpref('vicon_labeler','d3_path',d3_path);
  else
    return;
  end
end
d3_path = [d3_path '\'];
addpath(d3_path);

dots = strfind(assign_labels.d3_analysed.trialcode,'.');
datecode = datevec(assign_labels.d3_analysed.trialcode(dots(1)+1:dots(2)-1),...
  'mmddyyyy');
year = num2str(datecode(1));
if str2double(year) < 2010
  datecode = datevec(assign_labels.d3_analysed.trialcode(dots(1)+1:dots(2)-1),...
  'yyyymmdd');
  year = num2str(datecode(1));
end
if ~isfield(assign_labels.d3_analysed,'calibration')
  year_dir = dir([d3_path year '*']);
  year_dir_pname = year_dir.name;
  
  clb_files = dir([d3_path year_dir_pname '\' year '*']);
  clb_fnames = {clb_files.name};
  clb_datestr = cellfun(@(c) c(1:end-4), clb_fnames,'uniformoutput',0);
  clb_datenums = cell2mat(cellfun(@(c) datenum(c,'yyyy.mm.dd'), clb_datestr,'uniformoutput',0));
  clb_indx = find(clb_datenums < datenum(datecode), 1 , 'last');
  clb_fname = [d3_path year_dir_pname '\' clb_fnames{clb_indx}];
  calibration = load(clb_fname,'-mat');
  assign_labels.d3_analysed.calibration = calibration;
else
  calibration = assign_labels.d3_analysed.calibration;
end

A=calibration.variable.A;

c1_fname=get(handles.cam1_edit,'string');
c2_fname=get(handles.cam2_edit,'string');

if isempty(c2_fname) && isempty(c1_fname)
  return;
end

if ~isempty(c1_fname) && (nargin<=2 || cam_num==1)
  obj_C1 = VideoReader(c1_fname);
end
if ~isempty(c2_fname) && (nargin<=2 || cam_num==2)
  obj_C2 = VideoReader(c2_fname);
end

track = assign_labels.tracks{assign_labels.cur_track_num}.points;
[~, track_frames] = get_track_points_frames(track);
track_color = get_track_color(assign_labels.labels{assign_labels.cur_track_num});

if nargin < 2
  frame = track_frames(1);
end

[lab_tracks_in_zoom, lab_clrs_in_zoom]=get_labels_for_plotting(...
  [assign_labels.labels{~cellfun(@isempty,assign_labels.labels)}],frame);

object_rot = align_vicon_with_d3(datecode,...
  assign_labels.d3_analysed.unlabeled_bat{frame},0);
if ~isempty(object_rot)
  [xy1] = invdlt(A(:,1),[object_rot(:,1) object_rot(:,3) -object_rot(:,2)]);
  [xy2] = invdlt(A(:,2),[object_rot(:,1) object_rot(:,3) -object_rot(:,2)]);
end

track_indx=find(track_frames == frame);
if ~isempty(track_indx)
  track_rot = align_vicon_with_d3(datecode,...
    track(track_indx).point,0);
  track_rot_xy1 = invdlt(A(:,1),[track_rot(:,1) track_rot(:,3) -track_rot(:,2)]);
  track_rot_xy2 = invdlt(A(:,2),[track_rot(:,1) track_rot(:,3) -track_rot(:,2)]);
end

lab_indx=[];
pts_rot_xy1={};
pts_rot_xy2={};
if ~isempty(object_rot)
  for lab=1:length(lab_tracks_in_zoom)
    lab_frames = [lab_tracks_in_zoom{lab}.frame];
    [~, lab_indx(lab)]=intersect(lab_frames,frame);
    lab_points = reshape([lab_tracks_in_zoom{lab}.point],3,...
      length([lab_tracks_in_zoom{lab}.point])/3)';
    
    pts_rot = align_vicon_with_d3(datecode,...
      lab_points,0);
    pts_rot_xy1{lab} = invdlt(A(:,1),[pts_rot(:,1) pts_rot(:,3) -pts_rot(:,2)]);
    pts_rot_xy2{lab} = invdlt(A(:,2),[pts_rot(:,1) pts_rot(:,3) -pts_rot(:,2)]);
  end
end

fvideo = assign_labels.d3_analysed.fvideo;
vicon_frames = length(assign_labels.d3_analysed.unlabeled_bat);
frame_time = (vicon_frames-frame)/fvideo;

% wind_size=150; %used as a window on all sides (actual window is 4*wind_size)

%cam1
if ~isempty(c1_fname) && (nargin<=2 || cam_num==1)
  figure(4);
  c1frame = obj_C1.NumberOfFrames - round(frame_time*photron_fvideo);
  ia = 1;
  if isfield(assign_labels,'photron') && isfield(assign_labels.photron,'c1frames')
    [c,ia]=intersect(assign_labels.photron.c1frames,c1frame);
    if isempty(c)
      ia=1;
      if exist('animation_frames','var')
        c1frames = [0:round((animation_frames(end)-frame)/fvideo*photron_fvideo)] ...
          + c1frame;
        assign_labels.photron.c1_video = read(obj_C1,[c1frames(1) c1frames(end)]);
        assign_labels.photron.c1frames = c1frames;
      else
        assign_labels.photron.c1_video = read(obj_C1,c1frame);
        assign_labels.photron.c1frames = c1frame;
      end
    end
  else
    if exist('animation_frames','var')
      c1frames = [0:round((animation_frames(end)-frame)/fvideo*photron_fvideo)] ...
        + c1frame;
      assign_labels.photron.c1_video = read(obj_C1,[c1frames(1) c1frames(end)]);
      assign_labels.photron.c1frames = c1frames;
    else
      assign_labels.photron.c1_video = read(obj_C1,c1frame);
      assign_labels.photron.c1frames = c1frame;
    end
  end
  imshow(assign_labels.photron.c1_video(:,:,:,ia));
  set(gca,'position',[0 0 1 1]);
  
  if ~isempty(object_rot)
    hold on;
    plot(xy1(:,1),xy1(:,2),...
      'ow','markersize',2,...
      'markerfacecolor','w');
    if ~isempty(track_indx)
      plot(track_rot_xy1(1),track_rot_xy1(2),...
        '-o','color',track_color,'markersize',11,'linewidth',2);
    end
    for lab=1:length(lab_tracks_in_zoom)
      plot(pts_rot_xy1{lab}(lab_indx(lab),1),pts_rot_xy1{lab}(lab_indx(lab),2),...
        '-o','color',lab_clrs_in_zoom{lab},'markersize',7);
    end
    hold off;
    %     axis([min(xy1(:,1))-wind_size max(xy1(:,1))+wind_size...
    %       min(xy1(:,2))-wind_size max(xy1(:,2))+wind_size]);
  end
  title('Cam 1');
end

%cam2
if  ~isempty(c2_fname) && (nargin<=2 || cam_num==2)
  figure(5);
  c2frame = obj_C2.NumberOfFrames - round(frame_time*photron_fvideo);
  ia = 1;
  if isfield(assign_labels,'photron') && isfield(assign_labels.photron,'c2frames')
    [c,ia]=intersect(assign_labels.photron.c2frames,c2frame);
    if isempty(c)
      ia=1;
      if exist('animation_frames','var')
        c2frames = (0:round((animation_frames(end)-frame)/fvideo*photron_fvideo)) ...
          + c2frame;
        assign_labels.photron.c2_video = read(obj_C2,[c2frames(1) c2frames(end)]);
        assign_labels.photron.c2frames = c2frames;
      else
        assign_labels.photron.c2_video = read(obj_C2,c2frame);
        assign_labels.photron.c2frames = c2frame;
      end
    end
  else
    if exist('animation_frames','var')
      c2frames = (0:round((animation_frames(end)-frame)/fvideo*photron_fvideo)) ...
        + c2frame;
      assign_labels.photron.c2_video = read(obj_C2,[c2frames(1) c2frames(end)]);
      assign_labels.photron.c2frames = c2frames;
    else
      assign_labels.photron.c2_video = read(obj_C2,c2frame);
      assign_labels.photron.c2frames = c2frame;
    end
  end
  imshow(assign_labels.photron.c2_video(:,:,:,ia));
  set(gca,'position',[0 0 1 1]);
  
  if ~isempty(object_rot)
    hold on;
    plot(xy2(:,1),xy2(:,2),...
      'ow','markersize',2,...
      'markerfacecolor','w');
    if ~isempty(track_indx)
      plot(track_rot_xy2(1),track_rot_xy2(2),...
        '-o','color',track_color,'markersize',11,'linewidth',2);
    end
    for lab=1:length(lab_tracks_in_zoom)
      plot(pts_rot_xy2{lab}(lab_indx(lab),1),pts_rot_xy2{lab}(lab_indx(lab),2),...
        '-o','color',lab_clrs_in_zoom{lab},'markersize',7);
    end
    hold off;
    %     axis([min(xy2(:,1))-wind_size max(xy2(:,1))+wind_size...
    %       min(xy2(:,2))-wind_size max(xy2(:,2))+wind_size]);
  end
  title('Cam 2');
end




function set_track_info(handles)
global assign_labels
set(handles.max_tracks,'string',num2str(length(assign_labels.tracks)));

set(handles.track_num_edit,'string',num2str(assign_labels.cur_track_num));

if ~isempty(assign_labels.tracks{assign_labels.cur_track_num}.points)
  set(handles.frame_text,'string',...
    num2str(assign_labels.tracks{assign_labels.cur_track_num}.points(1).frame));
  set(handles.length_text,'string',...
    num2str(length(assign_labels.tracks{assign_labels.cur_track_num}.points)));
  
  sort_value = cellfun(@(c) c.rating.spd_var * c.rating.dir_var,assign_labels.tracks);
  [~,IX] = sort(sort_value);
  
  [sm_speed, dir] = get_track_vel(assign_labels.tracks{assign_labels.cur_track_num}.points);
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

function set_label_listbox(handles)
global assign_labels

labels_isempty=cellfun(@isempty,assign_labels.labels);
labels=assign_labels.labels(~labels_isempty);
ik=find(~labels_isempty);
% labelstrings=cellfun(@(c) ['<html><font color="' conv_cspec_to_cname(c.color) '">' ...
%   num2str(c.track.points(1).frame) ': ' num2str(c.label) ', len: ' num2str(length(c.track.points))...
%   '</font></html>'],...
%   labels,'uniformoutput',0);
labelstrings=cell(length(labels),1);
for k=1:length(labels)
  c=labels{k};
  if isempty(c.track.points)
    continue
  end
  labelstrings{k}=['<html><font color="' conv_cspec_to_cname(c.color) '">' ...
  '#' num2str(ik(k)) ': ' num2str(c.label) ...
  ', frm ' num2str(c.track.points(1).frame) ...
  ', len ' num2str(length(c.track.points))...
  '</font></html>'];
end
set(handles.labels_listbox,'String',labelstrings);

if ~isempty(assign_labels.labels{assign_labels.cur_track_num})
  indx=sum(~labels_isempty(1:assign_labels.cur_track_num));
  set(handles.labels_listbox,'value',indx,'max',1);
else
  set(handles.labels_listbox,'value',[],'max',2);
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
  [~, find_indx]=min(distance([0 0 0],point_diff));
  
  point = merged_track_points(find_indx,:);
  ia=find(ismember(merged_track_points,point,'rows'));
  
  track_lengths = cellfun(@(c) length(c.points),assign_labels.tracks);
  
  if length(ia) == 1
    track_indx = find(cumsum(track_lengths) - ia >= 0,1);
  else %choose the one with the best rating
    for k=1:length(ia)
      t_indx = find(cumsum(track_lengths) - ia(k) >= 0,1);
      track = assign_labels.tracks{t_indx};
      
      [sm_speed, dir] = get_track_vel(track.points);
      spd_var = var(sm_speed);
      dir_var = var(dir);
      rating(k)=spd_var*dir_var;
    end
    [~, best_rating] = min(rating);
    track_indx = find(cumsum(track_lengths) - ia(best_rating) >= 0,1);
  end
  
  change_track_num(track_indx,handles);
  
end

update(handles);

function update_track_history(handles)
global assign_labels

if isfield(assign_labels,'track_history')
  assign_labels.track_history(end+1)=assign_labels.cur_track_num;
  set(handles.backbutton,'enable','on')
else
  assign_labels.track_history=assign_labels.cur_track_num;
end
set(handles.forwardbutton,'enable','off');
assign_labels.track_forw_history=[];


function change_track_num(n,handles)
global assign_labels
if n < 1
  n=1;
elseif n > length(assign_labels.tracks)
  n=length(assign_labels.tracks);
end
update_track_history(handles);
assign_labels.cur_track_num=n;


function find_next_unlabeled(handles,direction)
global assign_labels
cur_track_num = assign_labels.cur_track_num;

if direction==1
  track_subset=cur_track_num+1:length(assign_labels.tracks);
  find_dir='first';
else
  track_subset=1:cur_track_num-1;
  find_dir='last';
end
tracks = assign_labels.tracks(track_subset);
track_indx=1:length(tracks);

if get(handles.thresh_length_checkbox,'value')
  len_thresh=str2double(get(handles.thresh_length_edit,'string'));
  track_lengths = cellfun(@(c) length(c.points),tracks);
  track_indx = intersect(track_indx,...
    find(track_lengths>=len_thresh));
end

if get(handles.thresh_rank_checkbox,'value')
  sort_value = cellfun(@(c) c.rating.spd_var * c.rating.dir_var,assign_labels.tracks);
  [~,IX] = sort(sort_value);
  [~,IX]=sort(IX);
  rank_percent = IX./length(assign_labels.tracks).*100;
  
  rank_thresh = str2double(get(handles.thresh_rank_edit,'string'));
  rank_percent = rank_percent(track_subset);
  track_indx = intersect(track_indx,...
    find(rank_percent<=rank_thresh));
end

if ~isempty(track_indx)
  labels = assign_labels.labels(track_subset);
  labels = labels(track_indx);
  first_empty_label=find(cellfun(@isempty,labels),1,find_dir);
  if ~isempty(first_empty_label)
    if direction==1
      change_track_num(cur_track_num + track_indx(first_empty_label),handles);
    else
      change_track_num(track_indx(first_empty_label),handles);
    end
  end
end


function remove_labeled_points_from_other_tracks(track)
global assign_labels

if ~isempty(find(strfind(assign_labels.label_items.name,'NN'),1)) || ...
    strcmp(assign_labels.origin,'NN') %we don't remove labeled stuff from a NN
  return
end

track_points = get_track_points_frames(track.points);

track_indx = setdiff(1:length(assign_labels.tracks),assign_labels.cur_track_num);
edited_tracks=cellfun(@(c) {remove_points_from_track(c,track_points)},...
  assign_labels.tracks(track_indx));
assign_labels.tracks(track_indx) = edited_tracks;

non_empty_labels=intersect(find(~cellfun(@isempty,assign_labels.labels)),track_indx)';
if ~isempty(non_empty_labels)
  remove_labels=[];
  for k=non_empty_labels
    assign_labels.labels{k}.track=...
      remove_points_from_track(assign_labels.labels{k}.track,track_points);
    if isempty(assign_labels.labels{k}.track.points)
      remove_labels(end+1)=k;
    end
  end
  assign_labels.labels(remove_labels)=[];
  assign_labels.tracks(remove_labels)=[];
  assign_labels.cur_track_num=assign_labels.cur_track_num-...
    sum(remove_labels<assign_labels.cur_track_num);
end

function track_labeled(selected_label_item,marker_names)
global assign_labels

%checking if side matches labeled side
LRlabel=0;
if ~isempty(strfind(marker_names{selected_label_item},'Left'))
  LRlabel=1;
elseif ~isempty(strfind(marker_names{selected_label_item},'Right'))
  LRlabel=-1;
end

if LRlabel || -LRlabel
  if ~isfield(assign_labels,'sm_C')
    all_C=assign_labels.d3_analysed.object(1).video;
    assign_labels.sm_C = sm_centroid(all_C,100,0);
  end
  bat=assign_labels.sm_C;
  pts=reshape([assign_labels.tracks{assign_labels.cur_track_num}.points.point],...
    3,[])';
  frms=[assign_labels.tracks{assign_labels.cur_track_num}.points.frame];
  side=determine_side(bat,pts,frms,1);
  if mode(side) ~= LRlabel
    disp(['track #' num2str(assign_labels.cur_track_num) ': labeled side doesn''t match calc. side']);
  end
end

LI_indx = selected_label_item - 1;

if LI_indx > 0
  all_ms=assign_labels.label_items.markers;
  
  for k=1:length(all_ms)
    names_to_match{k}=['<HTML><FONT COLOR="' conv_cspec_to_cname(all_ms(k).color) '">'...
      all_ms(k).name ': ' all_ms(k).color '</FONT></HTML>'];
  end
  
  [~,ia] = intersect(names_to_match,marker_names);
  markers=all_ms(sort(ia));
  
  remove_labeled_points_from_other_tracks(assign_labels.tracks{assign_labels.cur_track_num});
  
  assign_labels.labels{assign_labels.cur_track_num}.color = ...
    markers(LI_indx).color;
  assign_labels.labels{assign_labels.cur_track_num}.label = ...
    markers(LI_indx).name;
  assign_labels.labels{assign_labels.cur_track_num}.track = ...
    assign_labels.tracks{assign_labels.cur_track_num};
else
  assign_labels.labels{assign_labels.cur_track_num}=[];
end
assign_labels.edited = 1;

function sort_tracks(handles)
global assign_labels

if get(handles.orig_rating_sort,'value')
  sort_type = 'orig_rating';
  sort_value = cellfun(@(c) c.rating.spd_var * c.rating.dir_var,assign_labels.tracks);
elseif get(handles.frame_sort,'value')
  sort_type = 'frame';
  sort_value = cellfun(@(c) c.rating.frame,assign_labels.tracks);
elseif get(handles.cur_rating_sort,'value')
  sort_type = 'cur_rating';
  [spd, dir]=cellfun(@(c) get_track_vel(c.points), assign_labels.tracks,...
    'uniformoutput',0);
  sort_value = cellfun(@var,spd) .* cellfun(@var,dir);
elseif get(handles.length_sort,'value')
  sort_type = 'length';
  sort_value = 1./cell2mat(cellfun(@(c) length(c.points), assign_labels.tracks,...
    'uniformoutput',0));
end

[~,IX] = sort(sort_value);
assign_labels.tracks = assign_labels.tracks(IX);
assign_labels.labels = assign_labels.labels(IX);
assign_labels.sorted_by = sort_type;

assign_labels.cur_track_num=find(IX==assign_labels.cur_track_num,1);
if isfield(assign_labels,'track_history')
  [~,assign_labels.track_history]=ismember(assign_labels.track_history,IX);
  assign_labels.track_forw_history=ismember(assign_labels.track_forw_history,IX);
end


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
  [~, find_indx]=min(distance([0 0 0],point_diff));
  
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
disp('Saving...');
save([pn fn],'label_ratings','-v7');
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

function [track_points, track_frames] = get_track_points_frames(track)
track_points = reshape([track.point],3,length([track.point])/3)';
track_frames = [track.frame];

function [labels, labeled_colors]=get_all_labels_colors(all_labels)
labels = [all_labels{~cellfun(@isempty,all_labels)}];
if ~isempty(labels)
  labeled_colors = [labels.color];
else
  labeled_colors = [];
end

function animate_zoom(saving,handles)
global assign_labels

%minimizing the GUI window during animation to prevent accidental clicking
%of GUI which then starts to animate the GUI...\
jFrame = get(handles.figure1,'JavaFrame');
jFrame.setMinimized(true);

track = assign_labels.tracks{assign_labels.cur_track_num}.points;
[track_points, track_frames] = get_track_points_frames(track);

unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
plotting_frames = determine_plotting_frames(handles,track_frames,...
  length(unlabeled_bat));

track_color = get_track_color(assign_labels.labels{assign_labels.cur_track_num});

[lab_tracks_in_zoom, lab_clrs_in_zoom]=get_labels_for_plotting(...
  [assign_labels.labels{~cellfun(@isempty,assign_labels.labels)}],plotting_frames);

unlab_near_track = unlabeled_bat(plotting_frames);
unlab_near_track=cellfun(@(c) c(c(:,1)~=0,:),unlab_near_track,'uniformoutput',0);

figure(2);
[az,el] = view;

if saving
  vid_frate = assign_labels.d3_analysed.fvideo / 20;
  fname = [assign_labels.d3_analysed.trialcode '_track_'...
    num2str(assign_labels.cur_track_num) '.mp4'];
  [~, result] = dos('echo %USERPROFILE%\Desktop');
  pn = result;
  aviobj = VideoWriter([pn(1:end-1) '\' fname],'MPEG-4');
  aviobj.FrameRate = vid_frate;
  aviobj.Quality = 95;
  open(aviobj);
end

des_frate=str2double(get(handles.animate_all_fps,'string'));

h3=figure(3);clf;
all_points=cell2mat(unlab_near_track);
plot3(all_points(:,1),all_points(:,2),all_points(:,3),'.k');
% axis vis3d;
view([az,el]); axis equal;
a=axis;
for k=1:length(plotting_frames)
  tic
  frame=plotting_frames(k);
  
  figure(h3); clf(h3); hold on;
  
  track_indx=find(track_frames == frame);
  if ~isempty(track_indx)
    plot3(track(track_indx).point(1),track(track_indx).point(2),track(track_indx).point(3),...
      '-o','color',track_color,'markersize',11,'linewidth',2);
  end
  plot3(unlab_near_track{k}(:,1),unlab_near_track{k}(:,2),unlab_near_track{k}(:,3),...
    'ok','markersize',3,'markerfacecolor','k');
  
  for lab=1:length(lab_tracks_in_zoom)
    lab_frames = [lab_tracks_in_zoom{lab}.frame];
    [~, ia]=intersect(lab_frames,frame);
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
  view([az,el]);axis equal;
  axis(a);
  grid on;
  
  tt=toc;
  if saving
    currFrame = getframe(gca);
    writeVideo(aviobj,currFrame);
  else
    delay_time=1/des_frate-tt;
    if delay_time > 0
      pause(delay_time);
    end
  end
end

if saving
  close(aviobj);
  system(['explorer.exe /select,' pn(1:end-1) '\' fname]) %open file browser to video
  %encode the file?
end

%cam 1
if get(handles.photron_toggle,'Value')
  for k=1:length(plotting_frames)
    frame=plotting_frames(k);
    plot_photron(handles,frame,1,plotting_frames);
    %     pause(.02);
  end
  %cam2
  for k=1:length(plotting_frames)
    frame=plotting_frames(k);
    plot_photron(handles,frame,2,plotting_frames);
    %     pause(.02);
  end
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


function create_new_track(handles)
global assign_labels
if get(handles.full_trial_radio,'value')
  figure(1);
else
  figure(2);
end
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','datatip',...
  'SnapToDataVertex','off','Enable','on')
disp('Select point to start new track from, then press enter');
pause
rotate3d 'on';
c_info = getCursorInfo(dcm_obj);

if ~isempty(c_info)
  
  unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
  [frame, point] = get_frame_from_point(c_info.Position,unlabeled_bat);
  if get(handles.use_all_radio,'value')
    other_points = unlabeled_bat;
  else
    other_points = remove_labeled_points(unlabeled_bat);
  end
  
  [track, endings] = create_track(frame,point,other_points);
  rating = rate_point(frame,point,unlabeled_bat);
  assign_labels.cur_track_num = length(assign_labels.tracks)+1;
  assign_labels.tracks{assign_labels.cur_track_num}.points = track;
  assign_labels.tracks{assign_labels.cur_track_num}.endings = endings;
  assign_labels.tracks{assign_labels.cur_track_num}.rating = rating;
  assign_labels.labels{assign_labels.cur_track_num}=[];
  assign_labels.edited = 1;
  
  sort_tracks(handles);
  update(handles);
  
end

function other_points = remove_labeled_points(unlabeled_bat)
global assign_labels

labels = assign_labels.labels(~cellfun(@isempty,assign_labels.labels));

for k=1:length(labels)
  [track_points, track_frames] = get_track_points_frames(labels{k}.track.points);
  for f=1:length(track_frames)
    unlabeled_bat{track_frames(f)}=setdiff(unlabeled_bat{track_frames(f)},track_points(f,:),...
      'rows');
  end
end
other_points=unlabeled_bat;


function delete_current_track(handles)
global assign_labels
assign_labels.tracks(assign_labels.cur_track_num)=[];
assign_labels.labels(assign_labels.cur_track_num)=[];
assign_labels.edited = 1;
change_track_num(assign_labels.cur_track_num-1,handles);


function set_photron_fps(pathname,filename,handles)

%find photron cih file
indx=strfind(filename,'_compressed');
fname = [filename(1:indx-1) '.cih'];
cih_file=dir([pathname fname]);
if isempty(cih_file)
  return;
end
cih_fname=cih_file.name;
fid = fopen([pathname cih_fname]);
format = '%s';
x = textscan(fid, format);
fclose(fid);

row=find(~cellfun(@isempty,strfind(x{1},'Rate(fps)')),1);
fps=x{1}{row+2};

set(handles.photron_fps_edit,'string',fps);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function varargout = assign_labels_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function open_menu_Callback(hObject, eventdata, handles)
if save_before_discard()
  return;
end
open_ratings_file(handles);


% --------------------------------------------------------------------
function open_c3d_menu_Callback(hObject, eventdata, handles)
if save_before_discard()
  return;
end
waitfor(c3d_edit);


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
change_track_num(str2double(get(hObject,'String')),handles);
update(handles);

function track_num_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


function refocus_button_Callback(hObject, eventdata, handles)
refocus(handles);


function track_num_up_button_Callback(hObject, eventdata, handles)
change_track_num(str2double(get(handles.track_num_edit,'String'))+1,handles);
update(handles);

function track_num_down_button_Callback(hObject, eventdata, handles)
change_track_num(str2double(get(handles.track_num_edit,'String'))-1,handles);
update(handles);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
%from the close [x] button
close_GUI(hObject);

function close_GUI_Callback(hObject, eventdata, handles)
%from the menu dropdown
close_GUI(handles.figure1);

function label_popup_Callback(hObject, eventdata, handles)
track_labeled(get(hObject,'Value'),get(hObject,'String'));
if get(handles.advance_checkbox,'value')
  find_next_unlabeled(handles,1);
end
update(handles);

if get(handles.advance_checkbox,'value')
  if get(handles.auto_animate,'value')
    animate_zoom(0,handles);
  end
end

function label_popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


function label_menu_Callback(hObject, eventdata, handles)

function manage_label_items_Callback(hObject, eventdata, handles)
manage_label_items();

function sort_panel_SelectionChangeFcn(hObject, eventdata, handles)
sort_tracks(handles);
update(handles);


function advance_checkbox_Callback(hObject, eventdata, handles)
if get(hObject,'value')
  set(handles.auto_animate,'enable','on');
else
  set(handles.auto_animate,'enable','off');
end

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
[track,endings] = create_track(frame,point,unlabeled_bat);
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
find_next_unlabeled(handles,1);
update(handles);
if strcmp(get(handles.auto_animate,'enable'),'on') && get(handles.auto_animate,'value')
  animate_zoom(0,handles);
end

function prev_unlabeled_Callback(hObject, eventdata, handles)
find_next_unlabeled(handles,-1);
update(handles);
if strcmp(get(handles.auto_animate,'enable'),'on') && get(handles.auto_animate,'value')
  animate_zoom(0,handles);
end

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


function new_track_button_Callback(hObject, eventdata, handles)
create_new_track(handles);
update(handles);


function del_button_Callback(hObject, eventdata, handles)
choice = questdlg('Are you sure you want to delete the current track?', ...
  'Delete?', ...
  'OK','Cancel','Cancel');
switch choice
  case 'Cancel'
    return;
end
delete_current_track(handles);
update(handles);


function labels_listbox_Callback(hObject, eventdata, handles)
global assign_labels
label_num = get(hObject,'Value');
if isempty(label_num)
  return
end

labels_isempty=cellfun(@isempty,assign_labels.labels);

indx=find(cumsum(~labels_isempty)==label_num,1);
change_track_num(indx,handles);
update(handles);

function labels_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


function all_labels_as_options_Callback(hObject, eventdata, handles)
update(handles);


% --- Executes when selected object is changed in new_from_panel.
function new_from_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in new_from_panel
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in photron_toggle.
function photron_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to photron_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update(handles);
% Hint: get(hObject,'Value') returns toggle state of photron_toggle



function cam1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cam1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cam1_edit as text
%        str2double(get(hObject,'String')) returns contents of cam1_edit as a double


% --- Executes during object creation, after setting all properties.
function cam1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end



function cam2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cam2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cam2_edit as text
%        str2double(get(hObject,'String')) returns contents of cam2_edit as a double


% --- Executes during object creation, after setting all properties.
function cam2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cam2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cam1_button.
function cam1_button_Callback(hObject, eventdata, handles)
global assign_labels
% hObject    handle to cam1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile([assign_labels.ratings_pathname '..\photron\*cam1*.avi'],...
  ['Select Cam1 Video for trial ' assign_labels.ratings_filename]);
if ~isequal(filename,0)
  set(handles.cam1_edit,'String',[pathname filename]);
  set(handles.cam1_edit,'tooltipString',[pathname filename]);
  set_photron_fps(pathname,filename,handles);
end

% --- Executes on button press in cam2_button.
function cam2_button_Callback(hObject, eventdata, handles)
global assign_labels
% hObject    handle to cam2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile([assign_labels.ratings_pathname '..\photron\*cam2*.avi'],...
  ['Select Cam2 Video for trial ' assign_labels.ratings_filename]);
if ~isequal(filename,0)
  set(handles.cam2_edit,'String',[pathname filename]);
  set(handles.cam2_edit,'tooltipString',[pathname filename]);
  set_photron_fps(pathname,filename,handles);
end



function photron_fps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to photron_fps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of photron_fps_edit as text
%        str2double(get(hObject,'String')) returns contents of photron_fps_edit as a double


% --- Executes during object creation, after setting all properties.
function photron_fps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to photron_fps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in autoload_photron_button.
function autoload_photron_button_Callback(hObject, eventdata, handles)
global assign_labels
dots = strfind(assign_labels.d3_analysed.trialcode,'.');
bat = assign_labels.d3_analysed.trialcode(1:dots(1)-1);
trialnum = assign_labels.d3_analysed.trialcode(dots(end)+1:end);
datecode = datevec(assign_labels.d3_analysed.trialcode(dots(1)+1:dots(2)-1),...
  'yyyymmdd');
cam1_fname = [datestr(datecode,'yyyy.mm.dd') '.cam1.' bat '*C001S00' trialnum '*.avi'];
cam2_fname = [datestr(datecode,'yyyy.mm.dd') '.cam2.' bat '*C001S00' trialnum '*.avi'];

vicon_data_path = getpref('vicon_labeler','ratings');
c1file=dir([vicon_data_path '..\photron\' cam1_fname]);
c2file=dir([vicon_data_path '..\photron\' cam2_fname]);

if ~isempty(c1file)
  set(handles.cam1_edit,'string',[vicon_data_path '..\photron\' c1file.name]);
  set(handles.cam1_edit,'tooltipString',[vicon_data_path '..\photron\' c1file.name]);
  set_photron_fps([vicon_data_path '..\photron\'],c1file.name,handles);
end

if ~isempty(c2file)
  set(handles.cam2_edit,'string',[vicon_data_path '..\photron\' c2file.name]);
  set(handles.cam2_edit,'tooltipString',[vicon_data_path '..\photron\' c2file.name]);
  set_photron_fps([vicon_data_path '..\photron\'],c2file.name,handles);
end

function animate_from_beg_Callback(hObject, eventdata, handles)
animate_trial(handles,'beg')

function animate_from_cur_Callback(hObject, eventdata, handles)
animate_trial(handles,'cur');

function animate_trial(handles,from_when)
global assign_labels
[ff,view_az]=animate_whole_trial(handles,from_when);
%get all the tracks index at this frame

track_start_frames=nan(length(assign_labels.tracks),1);
track_end_frames=nan(length(assign_labels.tracks),1);
for gg=1:length(assign_labels.tracks)
  if ~isempty(assign_labels.tracks{gg}.points)
    track_start_frames(gg)=assign_labels.tracks{gg}.points(1).frame;
    track_end_frames(gg)=assign_labels.tracks{gg}.points(end).frame;
  end
end

t_ii=find(ff >= track_start_frames & ff <= track_end_frames);
l_ii=find(~cellfun(@isempty,assign_labels.labels(t_ii)));

if ~isempty(l_ii) %returning the first labeled track
  ii=t_ii(l_ii);
  [~,I]=min(track_start_frames(ii));
  assign_labels.cur_track_num = ii(I);
else %if no labeled tracks, returning the first track in the frame
  [~,I]=min(track_start_frames(t_ii));
  if isempty(I)
    [~,t_ii]=min(abs(track_start_frames-ff));
    I=1;
  end
  assign_labels.cur_track_num = t_ii(I);
end
figure(2);
[~,el]=view;
view(view_az,el);
update(handles);



function animate_all_fps_Callback(hObject, eventdata, handles)

function animate_all_fps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
  set(hObject,'BackgroundColor','white');
end


function auto_animate_Callback(hObject, eventdata, handles)


function lock_flight_dir_checkbox_Callback(hObject, eventdata, handles)


function backbutton_Callback(hObject, eventdata, handles)
global assign_labels
n=assign_labels.track_history(end);
if ~isfield(assign_labels,'track_forw_history')
  assign_labels.track_forw_history=[];
end
assign_labels.track_forw_history=[assign_labels.track_forw_history assign_labels.cur_track_num];
set(handles.forwardbutton,'enable','on')

assign_labels.track_history(end)=[];

assign_labels.cur_track_num=n;
update(handles);

function forwardbutton_Callback(hObject, eventdata, handles)
global assign_labels
n=assign_labels.track_forw_history(end);

assign_labels.track_history=[assign_labels.track_history assign_labels.cur_track_num];
set(handles.backbutton,'enable','on')

assign_labels.track_forw_history(end)=[];

assign_labels.cur_track_num=n;
update(handles);
