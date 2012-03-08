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

% Last Modified by GUIDE v2.5 08-Mar-2012 15:05:28

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
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to assign_labels (see VARARGIN)

% Choose default command line output for assign_labels
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

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
  tracks = auto_build_tracks(label_ratings.d3_analysed,label_ratings.rating);
  assign_labels.tracks = tracks;
  assign_labels.rating = label_ratings.rating;
  assign_labels.d3_analysed = label_ratings.d3_analysed;
  initialize(handles);
  update();
end

function load_label_items()
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
  load([pn fn]);
  assign_labels.label_items = label_items;
else
  %none selected - new label items
end
set(handles.label_popup,'string',{label_items.name});

function new_label_items()
waitfor(label_items);

function edit_label_items()
waitfor(label_items);

function initialize(handles)
global assign_labels
set(handles.track_num_edit,'string','1');
set(handles.max_tracks,'string',num2str(length(assign_labels.tracks)));
assign_labels.cur_track_num=1;

load_label_items(handles);

figure(1); view(3);
figure(2); view(3);

function update()
global assign_labels
unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
all_points = cell2mat(unlabeled_bat);
all_points(all_points(:,1)==0,:) = [];

track = assign_labels.tracks{assign_labels.cur_track_num};
track_points = reshape([track.point],3,length([track.point])/3)';
track_frames = [track.frame];
unlab_near_track = cell2mat(unlabeled_bat(track_frames));
unlab_near_track(unlab_near_track(:,1)==0,:) = [];

scrn_size=get(0,'ScreenSize');

figure(1);
[az,el] = view;
clf;
set(gcf,'position',[15 .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)])
hold on;
plot3(all_points(:,1),all_points(:,2),all_points(:,3),...
  'ok','markersize',3,'markerfacecolor','k');
plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
  '-og','markersize',8);
axis vis3d;
view([az,el]);
grid on;

figure(2);
[az,el] = view;
clf;
set(gcf,'position',[30+.3*scrn_size(3) .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)]);
hold on;
plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
  '-og','markersize',8);
plot3(unlab_near_track(:,1),unlab_near_track(:,2),unlab_near_track(:,3),...
  'ok','markersize',3,'markerfacecolor','k');
axis vis3d;
view([az,el]);
grid on;

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

merged_tracks=cell2mat(assign_labels.tracks);
merged_track_points = reshape([merged_tracks.point],3,length([merged_tracks.point])/3)';

point_diff = merged_track_points - ones(length(merged_track_points),1)*c_info.Position;
[M find_indx]=min(distance([0 0 0],point_diff));
track_lengths = cellfun(@length,assign_labels.tracks);
track_indx = find(cumsum(track_lengths) - find_indx >= 0,1);

change_track_num(track_indx,handles);

update();

function change_track_num(n,handles)
global assign_labels
if n < 1
  n=1;
elseif n > length(assign_labels.tracks)
  n=length(assign_labels.tracks);
end
set(handles.track_num_edit,'string',num2str(n));
assign_labels.cur_track_num=n;


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


% --------------------------------------------------------------------
function save_as_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_as_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function track_num_edit_Callback(hObject, eventdata, handles)
% hObject    handle to track_num_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_track_num(str2double(get(hObject,'String')),handles);
update();

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
change_track_num(str2double(get(handles.track_num_edit,'String'))+1,handles);
update();

% --- Executes on button press in track_num_down_button.
function track_num_down_button_Callback(hObject, eventdata, handles)
% hObject    handle to track_num_down_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_track_num(str2double(get(handles.track_num_edit,'String'))-1,handles);
update();

% --- Executes when user attempts to close GUI.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
function open_label_items_Callback(hObject, eventdata, handles)
% hObject    handle to open_label_items (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function edit_label_items_Callback(hObject, eventdata, handles)
% hObject    handle to edit_label_items (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function new_label_items_Callback(hObject, eventdata, handles)
% hObject    handle to new_label_items (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
