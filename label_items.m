function varargout = label_items(varargin)
% LABEL_ITEMS MATLAB code for label_items.fig
%      LABEL_ITEMS, by itself, creates a new LABEL_ITEMS or raises the existing
%      singleton*.
%
%      H = LABEL_ITEMS returns the handle to a new LABEL_ITEMS or the handle to
%      the existing singleton*.
%
%      LABEL_ITEMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABEL_ITEMS.M with the given input arguments.
%
%      LABEL_ITEMS('Property','Value',...) creates a new LABEL_ITEMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before label_items_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to label_items_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help label_items

% Last Modified by GUIDE v2.5 09-Mar-2012 16:40:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @label_items_OpeningFcn, ...
                   'gui_OutputFcn',  @label_items_OutputFcn, ...
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


% --- Executes just before label_items is made visible.
function label_items_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to label_items (see VARARGIN)

% Choose default command line output for label_items
global label_items
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
label_items = [];


% UIWAIT makes label_items wait for user response (see UIRESUME)
% uiwait(handles.label_items);


% --- Outputs from this function are returned to the command line.
function varargout = label_items_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function initialize(handles)
global label_items
set(handles.label_model_name,'enable','on');
set(handles.marker_name,'enable','on');
set(handles.marker_color_popup,'enable','on');
set(handles.delete,'enable','on');
set(handles.previous,'enable','on');
set(handles.next,'enable','on');
set(handles.markers_listbox,'enable','on');
label_items.cur_marker_num = 1;

function update(handles)
global label_items

cur_marker = label_items.cur_marker_num;

set(handles.label_model_name,'string',label_items.name);
set(handles.marker_name,'string',label_items.markers(cur_marker).name);

marker_color = label_items.markers(cur_marker).color;
indx = strfind('bgrcmykw',marker_color);
set(handles.marker_color_popup,'value',indx);

set(handles.marker_num,'string',num2str(cur_marker));
set(handles.tot_markers,'string',num2str(length(label_items.markers)));

list_box_items={};
for k=1:length(label_items.markers)
  list_box_items{k}=[label_items.markers(k).name ', ' label_items.markers(k).color];
end
set(handles.markers_listbox,'string',list_box_items);
set(handles.markers_listbox,'value',cur_marker);


function initialize_new_marker()
global label_items
label_items.markers(end+1).name='';
label_items.markers(end).color='b';


function change_marker_num(d)
global label_items
n = label_items.cur_marker_num + d;
if n < 1
  n=1;
end
if n > length(label_items.markers)
  initialize_new_marker();
end
label_items.cur_marker_num = n;

function empty = test_if_empty(label_items)
empty = 1;
if ~isempty(label_items) && ( ~isempty(label_items.name) || ...
    length(label_items.markers) > 1 || ...
    ~isempty(label_items.markers(1).name) || ...
    ~strcmp(label_items.markers(1).color,'b') )
  empty = 0;
end


function save_label_items()
global label_items
if ispref('vicon_labeler','label_items') && ...
    exist(getpref('vicon_labeler','label_items'),'dir')
  pn=getpref('vicon_labeler','label_items');
else
  pn=uigetdir([],'Set the directory for your label items');
  if pn~=0
    setpref('vicon_labeler','label_items',pn);
  end
end
[fn, pn] = uiputfile([pn '*.mat'],'Save label items',label_items.name);
if isequal(fn,0) || isequal(pn,0)
  return;
else
  setpref('vicon_labeler','label_items',pn);
  save([pn fn],'label_items');
  disp('Saved');
end


function label_model_name_Callback(hObject, eventdata, handles)
% hObject    handle to label_model_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of label_model_name as text
%        str2double(get(hObject,'String')) returns contents of label_model_name as a double
global label_items
label_items.name = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function label_model_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to label_model_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function marker_name_Callback(hObject, eventdata, handles)
% hObject    handle to marker_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of marker_name as text
%        str2double(get(hObject,'String')) returns contents of marker_name as a double
global label_items
label_items.markers(label_items.cur_marker_num).name = get(hObject,'String');
update(handles);


% --- Executes during object creation, after setting all properties.
function marker_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in marker_color_popup.
function marker_color_popup_Callback(hObject, eventdata, handles)
% hObject    handle to marker_color_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns marker_color_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from marker_color_popup

global label_items
contents = cellstr(get(hObject,'String'));
label_items.markers(label_items.cur_marker_num).color = contents{get(hObject,'Value')};
update(handles);


% --- Executes during object creation, after setting all properties.
function marker_color_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to marker_color_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in next.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_marker_num(1);
update(handles);

% --- Executes on button press in previous.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
change_marker_num(-1);
update(handles);

% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)
% hObject    handle to delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%deletes the current marker
%changes the current marker number
%resets the form
global label_items
label_items.markers(label_items.cur_marker_num)=[];
change_marker_num(-1);
update(handles);

% --------------------------------------------------------------------
function new_menu_Callback(hObject, eventdata, handles)
% hObject    handle to new_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check if previous data
%prompt for save if there is
%clear previous data
global label_items

if ~test_if_empty(label_items)
  %prompt for save if there is data
  choice = questdlg('Would you like to save the current label items?', ...
	'Save?', ...
	'Yes','No','Cancel','Yes');
  % Handle response
  switch choice
    case 'Yes'
      save_label_items();
    case 'Cancel'
      return;
  end
end

label_items = [];
label_items.name = '';
label_items.markers(1).name = '';
label_items.markers(1).color = 'b';
initialize(handles);
update(handles);


% --------------------------------------------------------------------
function open_menu_Callback(hObject, eventdata, handles)
% hObject    handle to open_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%check if previous data
%clear previous data
%open data
global label_items
if ~test_if_empty(label_items)
  %prompt for save if there is data
  choice = questdlg('Would you like to save the current label items?', ...
	'Save?', ...
	'Yes','No','Cancel','Yes');
  % Handle response
  switch choice
    case 'Yes'
      save_label_items();
    case 'Cancel'
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
  LI = load([pn fn]);
  label_items = LI.label_items;
else
  return;
end
initialize(handles);
update(handles);

% --------------------------------------------------------------------
function save_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_label_items();


% --- Executes on selection change in markers_listbox.
function markers_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to markers_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global label_items
value = get(hObject,'Value');
change_marker_num(value - label_items.cur_marker_num);
update(handles);


% Hints: contents = cellstr(get(hObject,'String')) returns markers_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from markers_listbox


% --- Executes during object creation, after setting all properties.
function markers_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markers_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function close_label_items(hObject)
global label_items
if ~test_if_empty(label_items)
  %prompt for save if there is data
  choice = questdlg('Would you like to save the current label items?', ...
	'Save?', ...
	'Yes','No','Cancel','Yes');
  % Handle response
  switch choice
    case 'Yes'
      save_label_items();
    case 'Cancel'
      return;
  end
end
delete(hObject);


% --------------------------------------------------------------------
function close_menu_Callback(hObject, eventdata, handles)
% hObject    handle to close_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close_label_items(handles.label_items);


% --- Executes when user attempts to close label_items.
function label_items_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to label_items (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
close_label_items(hObject);

% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
%file menu... nothing