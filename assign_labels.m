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

% Last Modified by GUIDE v2.5 06-Mar-2012 16:34:27

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

function initialize(handles)
global assign_labels
set(handles.track_num_edit,'string','1');
set(handles.max_tracks,'string',num2str(length(assign_labels.tracks)));
assign_labels.cur_track=1;

function update()
global assign_labels
unlabeled_bat = assign_labels.d3_analysed.unlabeled_bat;
all_points = cell2mat(unlabeled_bat);
all_points(all_points(:,1)==0,:) = [];

track = assign_labels.tracks{assign_labels.cur_track};
track_points = reshape([track.point],3,length([track.point])/3)';
track_frames = [track.frame];
unlab_near_track = cell2mat(unlabeled_bat(track_frames));
unlab_near_track(unlab_near_track(:,1)==0,:) = [];

figure(1);clf;
hold on;
plot3(all_points(:,1),all_points(:,2),all_points(:,3),...
  'ok','markersize',3,'markerfacecolor','k');
plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
  '-og','markersize',8);
axis vis3d;
view(3)
grid on;

figure(2);clf;
hold on;
plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
  '-og','markersize',8);
plot3(unlab_near_track(:,1),unlab_near_track(:,2),unlab_near_track(:,3),...
  'ok','markersize',3,'markerfacecolor','k');
axis vis3d;
view(3)
grid on;


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
global assign_labels
% hObject    handle to track_num_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n=str2double(get(hObject,'String'));
if n < 1
  n=1;
elseif n > length(assign_labels.tracks)
  n=length(assign_labels.tracks);
end
set(hObject,'string',num2str(n));
assign_labels.cur_track=n;
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
