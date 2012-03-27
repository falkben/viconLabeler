function varargout = c3d_edit(varargin)
% C3D_EDIT MATLAB code for c3d_edit.fig
%      C3D_EDIT, by itself, creates a new C3D_EDIT or raises the existing
%      singleton*.
%
%      H = C3D_EDIT returns the handle to a new C3D_EDIT or the handle to
%      the existing singleton*.
%
%      C3D_EDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in C3D_EDIT.M with the given input arguments.
%
%      C3D_EDIT('Property','Value',...) creates a new C3D_EDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before c3d_edit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to c3d_edit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help c3d_edit

% Last Modified by GUIDE v2.5 27-Mar-2012 16:42:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @c3d_edit_OpeningFcn, ...
                   'gui_OutputFcn',  @c3d_edit_OutputFcn, ...
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


% --- Executes just before c3d_edit is made visible.
function c3d_edit_OpeningFcn(hObject, eventdata, handles, varargin)
global c3d_file
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to c3d_edit (see VARARGIN)

% Choose default command line output for c3d_edit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


c3d_file=[];
% UIWAIT makes c3d_edit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = c3d_edit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function Untitled_1_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function open_menu_Callback(hObject, eventdata, handles)
% hObject    handle to open_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global c3d_trial
if ispref('vicon_labeler','c3d_files') && ...
    exist(getpref('vicon_labeler','c3d_files'),'dir')
  pn=getpref('vicon_labeler','c3d_files');
else
  pn=uigetdir([],'Set the directory for your c3d files');
  if pn~=0
    setpref('vicon_labeler','c3d_files',pn);
  end
end
[fn pn] = uigetfile('*.c3d','Pick file to label',pn);
if ~isequal(fn,0)
  c3d_trial=[];
  setpref('vicon_labeler','c3d_files',pn);
  [point_array, frame_rate, trig_rt, trig_sig, start_f, end_f] = lc3d( [pn fn] );
  frames=round((trig_rt-8)*frame_rate):round(trig_rt*frame_rate);
  
  unlabeled_bat=cell(length(frames),1);
  for f=1:length(frames)
    frame=frames(f);
    unlabeled_bat{f,:}=cell2mat(cellfun(@(c) c.traj(frame,:)./1e3,point_array,...
      'uniformoutput',0));
  end
  c3d_trial.unlabeled_bat = unlabeled_bat;
  c3d_trial.frame_rate = frame_rate;
  c3d_trial.start_f = start_f;
  c3d_trial.end_f = end_f;
  c3d_trial.fn = fn;
  c3d_trial.pn = pn;
  
  crop_points();
end


% --------------------------------------------------------------------
function save_as_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_as_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ispref('vicon_labeler','ratings') && ...
    exist(getpref('vicon_labeler','ratings'),'dir')
  pn=getpref('vicon_labeler','ratings');
else
  pn=uigetdir([],'Set the directory for your ratings file');
  if pn~=0
    setpref('vicon_labeler','ratings',pn);
  end
end
if ~isequal(pn,0)
  setpref('vicon_labeler','ratings',pn);
  
  label_ratings.ratings_pathname = pn;
  label_ratings.ratings_filename = fn;
  label_ratings.origin = 'c3d';
  
  d3_analysed.fvideo=frame_rate;
  
  fname=[pn fn];
  if findstr(fname,'/')
    slashes = findstr(fname,'/');
  else
    slashes = findstr(fname,'\');
  end
  datecode=fname(slashes(end-3)+1:slashes(end-2)-1);
  bat_name = fname(slashes(end-2)+1:slashes(end-1)-1);
  trial_num = fname(slashes(end)+6:slashes(end)+7);
  d3_analysed.trialcode = [bat_name '.' datecode '.' ...
      num2str(trial_num,'%1.2d')];
  
  label_ratings.rating = rate_all(d3_analysed);
  label_ratings.d3_analysed = d3_analysed;
  
  save([pn fn],'label_ratings');
end

% --------------------------------------------------------------------
function close_menu_Callback(hObject, eventdata, handles)
% hObject    handle to close_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function crop_points()
global c3d_trial
all_points=cell2mat(c3d_trial.unlabeled_bat);
figure(4); clf; 
h=plot3(all_points(:,1),all_points(:,2),all_points(:,3),...
  '.k');
grid on;
brush on;
axis vis3d;
fprintf(['Select points that are not the bat.',...
  '\nHold SHIFT to select multiple points.',...
  '\nHit DELETE to remove points.\n']);

while 1
  reply=input('Press enter when done: ','s');
  if isempty(reply)
    break;
  end
  pause(.01);
end
  
plotted_points=[get(h,'XData')' get(h,'YData')' get(h,'ZData')'];
removed_points = all_points(isnan(plotted_points(:,3)),:);
remaining_points = all_points(~isnan(plotted_points(:,3)),:);

disp('removing deleted points, this can take a while...');
if length(removed_points)<length(remaining_points)
  UB=cellfun(@(c) setdiff(c,removed_points,'rows'),unlabeled_bat,...
    'uniformoutput',0);
else
  UB=cellfun(@(c) intersect(c,remaining_points,'rows'),unlabeled_bat,...
    'uniformoutput',0);
end

c3d_trial.cropped_unlabeled_bat=UB;
