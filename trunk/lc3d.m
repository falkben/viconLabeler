function [point_array, frame_rate, trig_rt, trig_sig, start_f, end_f] = lc3d( filename )
%[point_array, frame_rate, trig_rt, trig_sig, start_f, end_f] = lc3d( filename )
%
% Wraps some functionality of loadc3d, but further organizes the points
% into a tidy cell array. Note that we scan through the ParameterGroup
% structure returned by loadc3d in order to organize point names; this may
% be slow for datasets with many points.
%
% frame_rate is (presumably... this should be verified) in units of
% frames/second (or "fps").
%
% trig_rt is the first rise time of the trigger signal. This is hopefully a
% stand-in until triggering synchronization can be done in hardware. Note
% that all data is referenced to begin at time 0; hence this trigger time
% is with respect to beginning of this trajectory data). If no such trigger
% (rising edge) is found, then trig_rt := NaN.
%
% trig_sig is an Nx2 matrix, where N is the number of samples to the analog
% channel. The first column is time (always begins at 0), and the second
% column is voltage. We may then determine trigger times by a simple
% threshold routine.
% Note that the sampling rate of the trigger channel is immediate. In
% particular, if d_t is the (mean) time between consecutive time points in
% trig_sig(:,1) (i.e. d_t = mean(diff(trig_sig(:,1))), then the sampling
% rate is 1/d_t.
% Note further that we assume the trigger signal is on channel 1 (but this
% might not matter... I don't have time to check tech specs at the moment).
%
%
% Scott Livingston   <slivingston@caltech.edu>
% July 2010.


point_array = [];
frame_rate = nan; % in case we abort early
if nargin < 1 % no file indicated, open a "find file" dialog
    if ispref('Vicon','Dir')
        DefaultName = getpref('Vicon','Dir');
        if ~exist(DefaultName,'dir')
            DefaultName=[];
        end
    else
        DefaultName = [];
    end
    [fname,pname] = uigetfile( '*.c3d', 'Select a C3D file, or bust' ,DefaultName);
    if isequal(fname,0)
        return
    end
    filename = [pname fname];
    setpref('Vicon','Dir',pname);
else % else, verify existence of file with given name
    D = dir(filename);
    if isempty(D)
        fprintf( 'Error: cannot find file %s\n', filename );
        return
    end
    clear D
end

fprintf( 'Reading c3d file... ' );
[Markers, VideoFrameRate, AnalogSignals, AnalogFrameRate, Event, ParameterGroup, CameraInfo, ResidualError] = loadc3d( filename );
fprintf( 'Done.\n' );

frame_rate = VideoFrameRate; % simple; I generally dislike CamelCase.

% Look for "POINT" parameter group. We assume case insensitivity for names.
use_autoname_flag = 0;
pg_num = 1;
while pg_num <= length(ParameterGroup)
    if strcmpi( ParameterGroup(pg_num).name, 'POINT' )
        break
    end
    pg_num = pg_num + 1;
end
if pg_num > length(ParameterGroup)
    use_autoname_flag = 1;
end

if ~use_autoname_flag
    p_num = 1;
    while p_num <= length(ParameterGroup(pg_num).Parameter)
        if strcmpi( ParameterGroup(pg_num).Parameter(p_num).name, 'LABELS' )
            break
        end
        p_num = p_num + 1;
    end
    if p_num > length(ParameterGroup(pg_num).Parameter)
        use_autoname_flag = 1;
    end
end

% Determine number of tracked points
point_count = size(Markers,2);

if ~use_autoname_flag && point_count ~= length(ParameterGroup(pg_num).Parameter(p_num).data) % quick error-check
    fprintf( 'Error: mismatch in number of markers and length of point name list. Aborting.\n' );
    return
end

% Build the damn name list
point_array = cell(point_count,1);
if use_autoname_flag
    fprintf( 'Could not find point name list. Using automatic sequential naming.\n' );
    for k = 1:point_count
        point_array{k}.name = num2str(k);
    end
else
    for k = 1:point_count
        point_array{k}.name = ParameterGroup(pg_num).Parameter(p_num).data{k};
    end
end

% And add trajectories to it (i.e., the climax of this m-function)
num_samples = size(Markers,1);
for k = 1:point_count
    point_array{k}.traj = reshape(Markers(:,k,:), num_samples, 3 );
end

% The trigger signal should be organized a little and returned
trig_sig = zeros(length(AnalogSignals(:,1)),2);
trig_sig(:,1) = [(0:length(AnalogSignals(:,1))-1)/AnalogFrameRate(1)]';
trig_sig(:,2) = AnalogSignals(:,1);

% Finally, find first significant rising edge of trigger signal, and return
% that time as trig_rt
I = find(diff(trig_sig(:,2))>1,1);
if isempty(I)
    I = find(diff(trig_sig(:,2))>0.2,1); % lower threshold
end
if isempty(I)
    trig_rt = nan; % give-up
else
    trig_rt = trig_sig(I,1);
end

%start and end frames
start_f = ParameterGroup(1).Parameter(1).data(1);
end_f = ParameterGroup(1).Parameter(2).data(1);
