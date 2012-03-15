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

% Last Modified by GUIDE v2.5 15-Mar-2012 17:23:50

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
  assign_labels.cur_track_num = 1;
  if ~isfield(label_ratings,'tracks')
    [assign_labels.tracks assign_labels.labels] = build_tracks_from_ratings(label_ratings.d3_analysed,...
      label_ratings.rating);
    load_label_items(handles);
  else
    assign_labels.tracks = label_ratings.tracks;
    assign_labels.labels = label_ratings.labels;
    assign_labels.label_items = label_ratings.label_items;
    markers = label_ratings.label_items.markers;
    for k=1:length(markers)
      label_popup_txt{k}=[markers(k).name ': ' markers(k).color];
    end
    set(handles.label_popup,'string',[{''} label_popup_txt]);
    sort_tracks('orig_rating',handles);
    change_track_num(1);
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
  markers = LI.label_items.markers;
  for k=1:length(markers)
    label_popup_txt{k}=[markers(k).name ': ' markers(k).color];
  end
  set(handles.label_popup,'string',[{''} label_popup_txt]);
else
  manage_label_items();
  load_label_items(handles);
end

function manage_label_items()
waitfor(label_items);

function initialize(handles)
global assign_labels
set(handles.track_num_edit,'string','1');
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

set(handles.pts_before,'string','0');
set(handles.pts_after,'string','0');
set(handles.orig_rating_sort,'value',1);

figure(1); view(3);
figure(2); view(3);

function update(handles)
global assign_labels
unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
all_points = cell2mat(unlabeled_bat);
all_points(all_points(:,1)==0,:) = [];

track = assign_labels.tracks{assign_labels.cur_track_num}.points;
track_points = reshape([track.point],3,length([track.point])/3)';
track_frames = [track.frame];

plotting_frames = track_frames(1)-str2double(get(handles.pts_before,'string')):...
  track_frames(end)+str2double(get(handles.pts_after,'string'));
unlab_near_track = cell2mat(unlabeled_bat(plotting_frames));
unlab_near_track(unlab_near_track(:,1)==0,:) = [];

if isempty(assign_labels.labels{assign_labels.cur_track_num})
  track_color = [.5 .5 .5];
  set(handles.label_popup,'value',1);
else
  track_color = assign_labels.labels{assign_labels.cur_track_num}.color;
  label_indx = find(~cellfun(@isempty,strfind({assign_labels.label_items.markers.name},...
    assign_labels.labels{assign_labels.cur_track_num}.label)),1);
  set(handles.label_popup,'value',label_indx+1);
end

set_track_info(handles);

labels = [assign_labels.labels{~cellfun(@isempty,assign_labels.labels)}];
if ~isempty(labels)
  labeled_colors = [labels.color];
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
trial_start_loc = mean(unlabeled_bat{first_frame_with_points});
trial_end_loc = mean(unlabeled_bat{last_frame_with_points});
text(trial_start_loc(1),trial_start_loc(2)-.2,trial_start_loc(3)+.2,...
  'START');
text(trial_end_loc(1)+.2,trial_end_loc(2),trial_end_loc(3)+.2,...
  'END');

axis vis3d;
view([az,el]);
grid on;

figure(2);
[az,el] = view;
clf;
set(gcf,'position',[30+.3*scrn_size(3) .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)]);
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

function set_track_info(handles)
global assign_labels
set(handles.track_num_edit,'string',num2str(assign_labels.cur_track_num));

set(handles.frame_text,'string',...
  num2str(assign_labels.tracks{assign_labels.cur_track_num}.rating.frame));
set(handles.length_text,'string',...
  num2str(length(assign_labels.tracks{assign_labels.cur_track_num}.points)));

[sm_speed dir] = get_track_vel(assign_labels.tracks{assign_labels.cur_track_num}.points);
spd_var = var(sm_speed);
dir_var = var(dir);

set(handles.rating_text,'string',...
  num2str((spd_var) * (dir_var),...
  '%0.6f'));
set(handles.spd_text,'string',...
  num2str(spd_var,'%0.3f'));
set(handles.dir_text,'string',...
  num2str(dir_var,'%0.3f'));

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


function find_next_unlabeled()
global assign_labels
cur_track_num = assign_labels.cur_track_num;
first_empty_label=find(cellfun(@isempty,assign_labels.labels(cur_track_num+1:end)),1);
change_track_num(cur_track_num+first_empty_label);


function track_labeled(selected_label_item)
global assign_labels

LI_indx = selected_label_item - 1;

if LI_indx > 0
  assign_labels.labels{assign_labels.cur_track_num}.color = ...
    assign_labels.label_items.markers(LI_indx).color;
  assign_labels.labels{assign_labels.cur_track_num}.track = ...
    assign_labels.tracks{assign_labels.cur_track_num};
  assign_labels.labels{assign_labels.cur_track_num}.label = ...
    assign_labels.label_items.markers(LI_indx).name;
else
  assign_labels.labels{assign_labels.cur_track_num}=[];
end

function sort_tracks(sort_type,handles)
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
c_info = getCursorInfo(dcm_obj);

if ~isempty(c_info)
  
  selected_point = c_info.Position;
  
  old_track = assign_labels.tracks{assign_labels.cur_track_num}.points;
  old_track_points = reshape([old_track.point],3,length([old_track.point])/3)';
  
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
  
  update(handles);
  
end


function save_trial(fn,pn)
global assign_labels
label_ratings = assign_labels;
label_ratings.ratings_pathname = pn;
label_ratings.ratings_filename = fn;
save([pn fn],'label_ratings');
disp(['Saved at: ' datestr(now,14)]);


function animate_zoom(saving)
global assign_labels

track = assign_labels.tracks{assign_labels.cur_track_num}.points;
track_points = reshape([track.point],3,length([track.point])/3)';
track_frames = [track.frame];
unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;

if isempty(assign_labels.labels{assign_labels.cur_track_num})
  track_color = [.5 .5 .5];
else
  track_color = assign_labels.labels{assign_labels.cur_track_num}.color;
  label_indx = find(~cellfun(@isempty,strfind({assign_labels.label_items.markers.name},...
    assign_labels.labels{assign_labels.cur_track_num}.label)),1);
end

unlab_near_track = unlabeled_bat(track_frames);

figure(2);
[az,el] = view;

if saving
  vid_frate = assign_labels.d3_analysed.fvideo / 20;
  fname = [assign_labels.d3_analysed.trialcode '_track_' num2str(assign_labels.cur_track_num) '.avi'];
  [status, result] = dos('echo %USERPROFILE%\Desktop');
  pn = result;
  aviobj = avifile([pn(1:end-1) '\' fname],'compression','None','Fps',vid_frate);
end

figure(3);clf;
all_points=cell2mat(unlabeled_bat(track_frames));
plot3(all_points(:,1),all_points(:,2),all_points(:,3),'.k');
a=axis;
for k=1:size(track_points,1)
  clf; hold on;
  plot3(track_points(k,1),track_points(k,2),track_points(k,3),...
    '-o','color',track_color,'markersize',8);
  plot3(unlab_near_track{k}(:,1),unlab_near_track{k}(:,2),unlab_near_track{k}(:,3),...
    'ok','markersize',3,'markerfacecolor','k');
  text(track_points(1,1),track_points(1,2),track_points(1,3)+.15,...
    'START');
  text(track_points(end,1),track_points(end,2),track_points(end,3)+.15,...
    'END');
  text(a(1),a(3),num2str(track_frames(k)));
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
  %encode the file
end

% set(gcf,'position',[30+.3*scrn_size(3) .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)]);
% for lab=1:length(lab_tracks_in_zoom)
%   lab_points = reshape([lab_tracks_in_zoom{lab}.point],3,...
%     length([lab_tracks_in_zoom{lab}.point])/3)';
%   plot3(lab_points(:,1),lab_points(:,2),lab_points(:,3),...
%     '-o','color',lab_clrs_in_zoom{lab},'markersize',8);
% end

% --- Outputs from this function are returned to the command line.
function varargout = assign_labels_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function open_menu_Callback(hObject, eventdata, handles)
% hObject    handle to open_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open_ratings_file(handles);


% --------------------------------------------------------------------
function save_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global assign_labels
save_trial(assign_labels.ratings_filename,assign_labels.ratings_pathname);

% --------------------------------------------------------------------
function save_as_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_as_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
% hObject    handle to track_num_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_track_num(str2double(get(hObject,'String')));
update(handles);

% Hints: get(hObject,'String') returns contents of track_num_edit as text
%        str2double(get(hObject,'String')) returns contents of track_num_edit as a double


% --- Executes during object creation, after setting all properties.
function track_num_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to track_num_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in refocus_button.
function refocus_button_Callback(hObject, eventdata, handles)
% hObject    handle to refocus_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refocus(handles);


% --- Executes on button press in track_num_up_button.
function track_num_up_button_Callback(hObject, eventdata, handles)
% hObject    handle to track_num_up_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_track_num(str2double(get(handles.track_num_edit,'String'))+1);
update(handles);

% --- Executes on button press in track_num_down_button.
function track_num_down_button_Callback(hObject, eventdata, handles)
% hObject    handle to track_num_down_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_track_num(str2double(get(handles.track_num_edit,'String'))-1);
update(handles);

% --- Executes when user attempts to close GUI.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global assign_labels
assign_labels = [];

% Hint: delete(hObject) closes the figure
delete(hObject);

close all;


% --- Executes on selection change in label_popup.
function label_popup_Callback(hObject, eventdata, handles)
% hObject    handle to label_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns label_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from label_popup
track_labeled(get(hObject,'Value'));
if get(handles.advance_checkbox,'value')
  change_track_num(str2double(get(handles.track_num_edit,'String'))+1);
end
update(handles);

% --- Executes during object creation, after setting all properties.
function label_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to label_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function label_menu_Callback(hObject, eventdata, handles)
% hObject    handle to label_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function manage_label_items_Callback(hObject, eventdata, handles)
% hObject    handle to manage_label_items (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manage_label_items();


% --- Executes when selected object is changed in sort_panel.
function sort_panel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in sort_panel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if get(handles.orig_rating_sort,'value')
  sort_type = 'orig_rating';
elseif get(handles.frame_sort,'value')
  sort_type = 'frame';
elseif get(handles.cur_rating_sort,'value')
  sort_type = 'cur_rating';
elseif get(handles.length_sort,'value')
  sort_type = 'length';
end
sort_tracks(sort_type,handles);
update(handles);


% --- Executes on button press in advance_checkbox.
function advance_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to advance_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of advance_checkbox


% --- Executes on button press in rebuild_current_track.
function rebuild_current_track_Callback(hObject, eventdata, handles)
% hObject    handle to rebuild_current_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
update(handles);

% --- Executes on button press in rebuild_all_tracks.
function rebuild_all_tracks_Callback(hObject, eventdata, handles)
% hObject    handle to rebuild_all_tracks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
update(handles);

% --- Executes on button press in edit_start_point.
function edit_start_point_Callback(hObject, eventdata, handles)
% hObject    handle to edit_start_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
crop_track(handles,'start');


% --- Executes on button press in edit_end_point.
function edit_end_point_Callback(hObject, eventdata, handles)
% hObject    handle to edit_end_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
crop_track(handles,'end');


% --- Executes on button press in animate_button.
function animate_button_Callback(hObject, eventdata, handles)
% hObject    handle to animate_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
animate_zoom(get(handles.save_animation,'value'));


% --- Executes on button press in save_animation.
function save_animation_Callback(hObject, eventdata, handles)
% hObject    handle to save_animation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save_animation


% --- Executes on button press in next_unlabeled.
function next_unlabeled_Callback(hObject, eventdata, handles)
% hObject    handle to next_unlabeled (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
find_next_unlabeled();
update(handles);



function pts_before_Callback(hObject, eventdata, handles)
% hObject    handle to pts_before (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pts_before as text
%        str2double(get(hObject,'String')) returns contents of pts_before as a double
if str2double(get(hObject,'String')) < 0
  set(hObject,'String','0');
end
update(handles);

% --- Executes during object creation, after setting all properties.
function pts_before_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pts_before (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pts_after_Callback(hObject, eventdata, handles)
% hObject    handle to pts_after (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pts_after as text
%        str2double(get(hObject,'String')) returns contents of pts_after as a double
if str2double(get(hObject,'String')) < 0
  set(hObject,'String','0');
end
update(handles);

% --- Executes during object creation, after setting all properties.
function pts_after_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pts_after (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
