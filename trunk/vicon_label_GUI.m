function varargout = vicon_label_GUI(varargin)
% VICON_LABEL_GUI MATLAB code for vicon_label_GUI.fig
%      VICON_LABEL_GUI, by itself, creates a new VICON_LABEL_GUI or raises the existing
%      singleton*.
%
%      H = VICON_LABEL_GUI returns the handle to a new VICON_LABEL_GUI or the handle to
%      the existing singleton*.
%
%      VICON_LABEL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VICON_LABEL_GUI.M with the given input arguments.
%
%      VICON_LABEL_GUI('Property','Value',...) creates a new VICON_LABEL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vicon_label_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vicon_label_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vicon_label_GUI

% Last Modified by GUIDE v2.5 27-Feb-2012 15:56:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vicon_label_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @vicon_label_GUI_OutputFcn, ...
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


% --- Executes just before vicon_label_GUI is made visible.
function vicon_label_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vicon_label_GUI (see VARARGIN)

% Choose default command line output for vicon_label_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes vicon_label_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = vicon_label_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function plot_trial()
global vicon_label
figure(1);clf;view(3);
all_points=cell2mat(vicon_label.d3_analysed.unlabeled_bat);
all_points(all_points==0)=nan;
plot3(all_points(:,1),all_points(:,2),all_points(:,3),...
  'ok','markersize',2,'markerfacecolor','k');
axis vis3d;
grid on;
view(3);


function plot_point_subset()
global vicon_label
figure(2);clf;grid on;
hold on;
frames2plot=vicon_label.frame-20:vicon_label.frame+20;
for f=frames2plot
  points=vicon_label.d3_analysed.unlabeled_bat{f};
  if ~isempty(find(points, 1))
    plot3(points(:,1),points(:,2),points(:,3),...
      'ok','markersize',2,'markerfacecolor','k');
  end
end
plot3(vicon_label.point(1),vicon_label.point(2),vicon_label.point(3),...
  'or','linewidth',2);
axis([vicon_label.point(1)-.5,vicon_label.point(1)+.5,...
  vicon_label.point(2)-.5,vicon_label.point(2)+.5,...
  vicon_label.point(3)-.25,vicon_label.point(3)+.25]);
hold off;
axis vis3d;
view(3);

function plot_track()
global vicon_label
figure(2);
hold on;
track_points=reshape([vicon_label.track(:).point],3,...
  length([vicon_label.track(:).point])/3)';
plot3(track_points(:,1),track_points(:,2),track_points(:,3),...
  '.-','color',[.5 .5 .5]);
hold off;

% --- Executes on button press in load_trial_button.
function load_trial_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_trial_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vicon_label
if ispref('vicon_labeler','d3path') && ...
    exist(getpref('vicon_labeler','d3path'),'dir')
  pn=getpref('vicon_labeler','d3path');
else
  pn=[];
end
[filename pathname] = uigetfile('*.mat','Pick c3d file to label',pn);
if isequal(filename,0)
  return;
end
setpref('vicon_labeler','d3path',pathname);

fname=[pathname filename];
load(fname);
vicon_label.d3_analysed = d3_analysed;
scrn_size=get(0,'ScreenSize');
figure(1);
set(gcf,'position',[15 .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)])
plot_trial();


% --- Executes on button press in grab_start_point_button.
function grab_start_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to grab_start_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vicon_label
figure(1);
grid on;
dcm_obj = datacursormode(gcf);
set(dcm_obj,'DisplayStyle','datatip',...
  'SnapToDataVertex','off','Enable','on')
disp('Select point to zoom on and label, then press enter');
pause
c_info = getCursorInfo(dcm_obj);
point_indx = c_info.DataIndex;
point = c_info.Position;
vicon_label.frame = get_frame_from_point_indx(point_indx,vicon_label.d3_analysed);
vicon_label.point_indx = point_indx;
vicon_label.point = point;
scrn_size=get(0,'ScreenSize');
figure(2);
set(gcf,'position',[30+.3*scrn_size(3) .5*scrn_size(4)-85 .3*scrn_size(3) .5*scrn_size(4)])
plot_point_subset();

track = create_track([],vicon_label.d3_analysed,vicon_label.frame,...
  vicon_label.point,1);
track = create_track(track,vicon_label.d3_analysed,vicon_label.frame,...
  vicon_label.point,-1);
track = remove_duplicate_frames(track);
track = sort_track(track);
vicon_label.track=track;
plot_track();

messaround(vicon_label.track,vicon_label.d3_analysed);




