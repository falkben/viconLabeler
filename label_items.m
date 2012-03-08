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

% Last Modified by GUIDE v2.5 08-Mar-2012 15:32:29

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
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes label_items wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = label_items_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function label_model_name_Callback(hObject, eventdata, handles)
% hObject    handle to label_model_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of label_model_name as text
%        str2double(get(hObject,'String')) returns contents of label_model_name as a double


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


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
% hObject    handle to cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function marker_name_Callback(hObject, eventdata, handles)
% hObject    handle to marker_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of marker_name as text
%        str2double(get(hObject,'String')) returns contents of marker_name as a double


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


% --- Executes on button press in previous.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in delete.
function delete_Callback(hObject, eventdata, handles)
% hObject    handle to delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
