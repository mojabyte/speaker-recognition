function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 18-Jan-2018 13:58:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname = uigetdir();
if pathname
    set(handles.path, 'String', pathname);
end


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname = get(handles.path, 'String');
sizes = eval(get(handles.sizes, 'String'));
iterations = eval(get(handles.iterations, 'String'));
rate = eval(get(handles.rate, 'String'));
readDir(1, pathname, sizes, iterations, rate);
set(handles.message, 'String', 'training completed!');


% --- Executes on button press in browse_file.
function browse_file_Callback(hObject, eventdata, handles)
% hObject    handle to browse_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.wav');
if pathname
    set(handles.file, 'String', [pathname, filename]);
end


% --- Executes on button press in recognize.
function recognize_Callback(hObject, eventdata, handles)
% hObject    handle to recognize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pathname = get(handles.file, 'String');
sizes = eval(get(handles.sizes, 'String'));
out = readDir(3, pathname, sizes);

recognize(out, handles);


% --- Executes on button press in record.
function record_Callback(hObject, eventdata, handles)
% hObject    handle to record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
recorder = audiorecorder(44100, 16, 1, -1);

for i=3:-1:1
    set(handles.recognized, 'String', sprintf('speak in %d ...', i));
    pause(1);
end

set(handles.recognized, 'String', 'recording ...');

record(recorder, 5);

pause(8);
sizes = eval(get(handles.sizes, 'String'));
a = readDir(2, {getaudiodata(recorder), 44100}, sizes);

recognize(a, handles);


function recognize(a, handles)
% hObject    handle to record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load('names.mat');
[acc, index] = max(a);

if (acc > 0.2)
    out = sprintf('speaker: %s\n\n', names{index});
else
    out = sprintf('speaker: not recognized\n\n');
end

set(handles.recognized, 'String', out);

namesString = '';
percentages = '';

for s = 1:length(names)
    namesString = [namesString, sprintf('%s\n', names{s})];
    percentages = [percentages, sprintf('%%%2.2f\n', a(s)*100)];
end

set(handles.names, 'String', namesString);
set(handles.percentages, 'String', percentages);
