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

% Last Modified by GUIDE v2.5 28-Mar-2012 16:01:59

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
global c3d_file queue
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
queue={};
% close(4);
scrn_size=get(0,'ScreenSize');
movegui(hObject,[round(scrn_size(3)*.6),round(scrn_size(4)*.15)]);
% UIWAIT makes c3d_edit wait for user response (see UIRESUME)



% --- Outputs from this function are returned to the command line.
function varargout = c3d_edit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function Untitled_1_Callback(hObject, eventdata, handles)
% uiwait(handles.figure1);

function plot_unlabeled()
global c3d_trial

if isfield(c3d_trial,'plot_handle')
  plotted_points=[get( c3d_trial.plot_handle ,'XData')' ...
    get(c3d_trial.plot_handle,'YData')' ...
    get(c3d_trial.plot_handle,'ZData')'];
  remaining_points = plotted_points(~isnan(plotted_points(:,3)),:);
else
  remaining_points = cell2mat(c3d_trial.unlabeled_bat);
end


figure(4);[az,el]=view; clf; 
c3d_trial.plot_handle=plot3(remaining_points(:,1),...
  remaining_points(:,2),...
  remaining_points(:,3),...
  '.k');
grid on;
axis vis3d;
axis equal;
view(az,el);
brush on;

function crop_points(handles)
global c3d_trial
unlabeled_bat=c3d_trial.unlabeled_bat;
plotted_points=[get( c3d_trial.plot_handle ,'XData')' ...
  get(c3d_trial.plot_handle,'YData')' ...
  get(c3d_trial.plot_handle,'ZData')'];

remaining_points = plotted_points(~isnan(plotted_points(:,3)),:);
removed_points = setdiff(cell2mat(unlabeled_bat),...
  remaining_points,'rows');

disp('removing deleted points...');
if length(remaining_points) < length(removed_points)
  UB=cellfun(@(c) intersect(c,remaining_points,'rows'),unlabeled_bat,...
    'uniformoutput',0);
else
  UB=cellfun(@(c) setdiff(c,removed_points,'rows'),unlabeled_bat,...
    'uniformoutput',0);
end
disp('done.');

c3d_trial.unlabeled_bat=UB;

set(handles.num_points,'string',num2str(length(remaining_points)));
if isfield(c3d_trial,'plot_handle')
  c3d_trial=rmfield(c3d_trial,'plot_handle');
end
plot_unlabeled();


function clear_queue(handles)
global queue;
queue={};
set(handles.queue_listbox,'string','');




function open_menu_Callback(hObject, eventdata, handles)
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
  c3d_trial.unlabeled_bat_original = unlabeled_bat;
  c3d_trial.unlabeled_bat = unlabeled_bat;
  c3d_trial.frame_rate = frame_rate;
  c3d_trial.start_f = start_f;
  c3d_trial.end_f = end_f;
  c3d_trial.fn = fn;
  c3d_trial.pn = pn;
  scrn_size=get(0,'ScreenSize');
  figure(4);axis vis3d;
  set(gcf,'position',[30 60 scrn_size(3)/2 scrn_size(4)*.75]);
  plot_unlabeled();
  
  set(handles.num_points,'string',num2str(length(cell2mat(unlabeled_bat))));
end


function close_menu_Callback(hObject, eventdata, handles)



function replot_Callback(hObject, eventdata, handles)
plot_unlabeled();



function crop_Callback(hObject, eventdata, handles)
crop_points(handles);



function restart_Callback(hObject, eventdata, handles)
global c3d_trial
if isfield(c3d_trial,'plot_handle')
  c3d_trial=rmfield(c3d_trial,'plot_handle');
end
c3d_trial.unlabeled_bat=c3d_trial.unlabeled_bat_original;
plot_unlabeled()


function add_to_queue_Callback(hObject, eventdata, handles)
global c3d_trial queue

unlabeled_bat=c3d_trial.unlabeled_bat;
plotted_points=[get( c3d_trial.plot_handle ,'XData')' ...
  get(c3d_trial.plot_handle,'YData')' ...
  get(c3d_trial.plot_handle,'ZData')'];

remaining_points = plotted_points(~isnan(plotted_points(:,3)),:);
removed_points = setdiff(cell2mat(unlabeled_bat),...
  remaining_points,'rows');

if ~isempty(removed_points)
  %warning that you need to crop still
  choice = questdlg('Detected points that were deleted but not cropped.  Continue?', ...
    'Continue?', ...
    'OK','Cancel','Cancel');
  switch choice
    case 'Cancel'
      return;
  end
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
if ~isequal(pn,0)
  setpref('vicon_labeler','ratings',pn);
  
  fname=[c3d_trial.pn c3d_trial.fn];
  if findstr(fname,'/')
    slashes = findstr(fname,'/');
  else
    slashes = findstr(fname,'\');
  end
  datecode=fname(slashes(end-3)+1:slashes(end-2)-1);
  bat_name = fname(slashes(end-2)+1:slashes(end-1)-1);
  trial_num = fname(slashes(end)+6:slashes(end)+7);
  trialcode = [bat_name '.' datecode '.' ...
      num2str(trial_num,'%1.2d')];
  c3d_trial.trialcode = trialcode;
  [FileName,PathName] = uiputfile('.mat','Save ratings file',[pn trialcode '.mat']);
end

if ~isequal(FileName,0) && ~isequal(PathName,0)
  c3d_trial.save_fname=FileName;
  c3d_trial.save_pname=PathName;
  queue{end+1} = c3d_trial;
  set(handles.queue_listbox,'string',...
    cellfun(@(c) c.trialcode,queue,'uniformoutput',0));
  set(handles.queue_listbox,'value',length(queue));
  %add to queue listbox
  
end


function rate_queue_Callback(hObject, eventdata, handles)
global queue

choice = questdlg('Rating trials takes a long time.  Are you ready to continue?', ...
  'Continue?', ...
  'OK','Cancel','Cancel');
switch choice
  case 'Cancel'
    return;
end

% spawn new instance of matlab
for k=1:length(queue)
  label_ratings=[];
  
  label_ratings.origin = 'c3d';
  
  d3_analysed.fvideo=queue{k}.frame_rate;
  d3_analysed.trialcode = queue{k}.trialcode;
  d3_analysed.unlabeled_bat = queue{k}.unlabeled_bat;
  d3_analysed.startframe = -length(queue{k}.unlabeled_bat)+1;
  d3_analysed.endframe = 0;
  d3_analysed.ignore_segs=[];
  label_ratings.d3_analysed = d3_analysed;
  
  label_ratings.rating = rate_all(d3_analysed);
  
  save([queue{k}.save_pname queue{k}.save_fname],'label_ratings');
  
  disp(['Saved: ' queue{k}.trialcode ', trial ' num2str(k) ' of ' num2str(length(queue))])
end
clear_queue(handles);

function queue_listbox_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns queue_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from queue_listbox

%load the c3d_trial that is selected


function queue_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function clear_queue_Callback(hObject, eventdata, handles)
clear_queue(handles);


function remove_from_queue_Callback(hObject, eventdata, handles)
global queue

selected_item=get(handles.queue_listbox,'Value');
contents = cellstr(get(handles.queue_listbox,'String'));

queue(selected_item)=[];
contents(selected_item)=[];

set(handles.queue_listbox,'Value',selected_item-1);
set(handles.queue_listbox,'string',contents);
