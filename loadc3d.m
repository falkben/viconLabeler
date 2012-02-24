function [Markers,VideoFrameRate,AnalogSignals,AnalogFrameRate,Event,ParameterGroup,CameraInfo,ResidualError] = loadc3d(FullFileName)
% LOADC3D - Read 3D coordinates and/or analog sensor data from a C3D file 
%
% INPUT:
% FullFileName       file (including path) to be read
%
% OUTPUTS:
% Markers            3D-marker data [Nmarkers x NvideoFrames x Ndim(=3)]
% VideoFrameRate     Frames/sec
% AnalogSignals      Analog signals [Nsignals x NanalogSamples ]
% AnalogFrameRate    Samples/sec
% Event              Event(Nevents).time ..value  ..name
% ParameterGroup     ParameterGroup(Ngroups).Parameters(Nparameters).data ..etc.
% CameraInfo         Marker Related Camera Info [Nmarkers x NvideoFrames]
% ResidualError      Marker Related Error Info  [Nmarkers x NvideoFrames]
%
% Last update, Chris Bregler, December 2011

% AUTHORS AND VERSION HISTORY:
% Ver. 1.0 Creation (Alan Morris, Toronto, October 1998) [originally named "getc3d.m"]
% Ver. 2.0 Revision (Jaap Harlaar, Amsterdam, april 2002)
% Ver. 3.0 Revision to speed up (Noel Keijsers, Nijmegen, February 2007)
% Ver. 3.1 Revision to correct some errors when loading analog data (Davide Conte, Verona, Italy, October 2008 | davide.conte@univr.it)
% Ver. 3.1.1 Bug fix (Chris Bregler, NYU, December 2011) [changed dimensions of ParameterGroup to load in uint8 (instead of int8)]


Markers=[];
VideoFrameRate=0;
AnalogSignals=[];
AnalogFrameRate=0;
Event=[];
ParameterGroup=[];
CameraInfo=[];
ResidualError=[];


% ###############################################
% ##                                           ##
% ##    (A) open the file                      ##
% ##                                           ##
% ###############################################

ind=findstr(FullFileName,'\');
if ind>0
    FileName=FullFileName(ind(length(ind))+1:length(FullFileName)); 
else FileName=FullFileName; 
end

fid=fopen(FullFileName,'r','n'); % native format (PC-intel)

if fid==-1,
    h=errordlg(['File: ',FileName,' could not be opened'],'application error');
    uiwait(h)
    return
end

NrecordFirstParameterblock = fread(fid,1,'int8');     % Reading record number of parameter section
key=fread(fid,1,'int8');                              % key = 80;
if key~=80,
    h=errordlg(['File: ',FileName,' does not comply to the C3D format'],'application error');
    uiwait(h)
    fclose(fid)
    return
end

fseek(fid,512*(NrecordFirstParameterblock-1)+3,'bof'); % jump to processortype - field
proctype=fread(fid,1,'int8')-83;                       % proctype: 1(INTEL-PC); 2(DEC-VAX); 3(MIPS-SUN/SGI)
if proctype==2,
    fclose(fid);
    fid=fopen(FullFileName,'r','d');                   % DEC VAX D floating point and VAX ordering
end
    


% ###############################################
% ##                                           ##
% ##    (B) read header                        ##
% ##                                           ##
% ###############################################

%NrecordFirstParameterblock=fread(fid,1,'int8');     % Reading record number of parameter section
%key1=fread(fid,1,'int8');                           % key = 80;

fseek(fid,2,'bof');

Nmarkers=fread(fid,1,'int16');		        %number of markers
NanalogSamplesPerVideoFrame=fread(fid,1,'int16');			%number of analog channels x #analog frames per video frame
StartFrame=fread(fid,1,'int16');		        %# of first video frame

EndFrame=fread(fid,1,'int16');			        %# of last video frame

MaxInterpolationGap=fread(fid,1,'int16');		%maximum interpolation gap allowed (in frame)

Scale=fread(fid,1,'float32');			        %floating-point scale factor to convert 3D-integers to ref system units

NrecordDataBlock=fread(fid,1,'int16');		%starting record number for 3D point and analog data

NanalogFramesPerVideoFrame=fread(fid,1,'int16');
if NanalogFramesPerVideoFrame > 0,
    NanalogChannels=NanalogSamplesPerVideoFrame/NanalogFramesPerVideoFrame;	
else
    NanalogChannels=0;
end


VideoFrameRate=fread(fid,1,'float32');
AnalogFrameRate=VideoFrameRate*NanalogFramesPerVideoFrame;



% ###############################################
% ##                                           ##
% ##    (C) read events                        ##
% ##                                           ##
% ###############################################

fseek(fid,298,'bof');
EventIndicator=fread(fid,1,'int16');	
if EventIndicator==12345,
    Nevents=fread(fid,1,'int16');	
    fseek(fid,2,'cof'); % skip one position/2 bytes
    if Nevents>0,
        for i=1:Nevents,
            Event(i).time=fread(fid,1,'float');
        end
        fseek(fid,188*2,'bof');
        for i=1:Nevents,
            Event(i).value=fread(fid,1,'int8');
        end
         fseek(fid,198*2,'bof');
        for i=1:Nevents,
            Event(i).name=cellstr(char(fread(fid,4,'char')'));
        end
    end
end


% ###############################################
% ##                                           ##
% ##    (D) read parameter block               ##
% ##                                           ##
% ###############################################

% Reading parameter header:
fseek(fid, 512 * (NrecordFirstParameterblock - 1), 'bof');
dat1 = fread(fid, 1, 'int8');                   % 1-st byte 
key2 = fread(fid, 1, 'int8');                   % 2-nd byte: key = 80;
NparameterRecords = fread(fid, 1, 'int8');      % 3-rd byte: Number of parameter blocks to follow
proctype = fread(fid, 1, 'int8')-83;            % 4-th byte: proctype: 1(INTEL-PC); 2(DEC-VAX); 3(MIPS-SUN/SGI)

% Reading group/parameter records:

% Parameter data section ends when when index to the next item is zero --> puntatore is 'false'
puntatore = true;

Ncharacters = fread(fid, 1, 'int8');    	% 1-st byte: characters in group/parameter name; can be <0 with locked group/parameter
Ncharacters = abs(Ncharacters);
GroupNumber = fread(fid, 1, 'int8');	    % 2-nd byte: id number -ve=group / +ve=parameter


while (puntatore == true) && (Ncharacters > 0) % The end of the parameter record is indicated by <0 characters for group/parameter name
% double check to avoid problems...

    if GroupNumber < 0                                                              % GROUP DATA
        GroupNumber = abs(GroupNumber); 
        GroupName = fread(fid, [1, Ncharacters], '*char');	
        ParameterGroup(GroupNumber).name = cellstr(GroupName);                              % group name
        % offset in bytes pointing to the start of the next group/parameter:
        offset = fread(fid, 1, 'int16');
        % Number of characters in the group description:
        deschars = fread(fid, 1, 'int8');				                			
        GroupDescription = fread(fid, [1, deschars], 'char');                       
        ParameterGroup(GroupNumber).description = cellstr(char(GroupDescription));  % group description
        ParameterNumberIndex(GroupNumber) = 0;
        if offset ~= 0
            fseek(fid, offset - 3 - deschars, 'cof');                               % Set file position indicator to next record
        else puntatore = false;
        end %if
        
    else                                                                            % PARAMETER DATA
        clear dimension;
        ParameterNumberIndex(GroupNumber) = ParameterNumberIndex(GroupNumber) + 1;
        ParameterNumber = ParameterNumberIndex(GroupNumber);                        % index all parameters within a group
        ParameterName = fread(fid, [1, Ncharacters], '*char');               		% name of parameter
        
        % read parameter name
        if size(ParameterName) > 0
            ParameterGroup(GroupNumber).Parameter(ParameterNumber).name = cellstr(ParameterName);	% save parameter name
        end
        
        % offset in bytes pointing to the start of the next group/parameter:
        offset = fread(fid, 1, 'int16');							% offset in bytes
        filepos = ftell(fid);										% present file position
        nextrec = filepos + offset(1) - 2;							% position of beginning of next record
                
        % read type
        type = fread(fid, 1, 'int8');                               % type of data: -1=char/1=byte/2=integer*2/4=real*4
        ParameterGroup(GroupNumber).Parameter(ParameterNumber).datatype = type;
                
        % read number of dimensions
        dimnum = fread(fid, 1, 'int8');
        if dimnum == 0 
            datalength = abs(type);		    						% length of data record
        else
            mult = 1;
            for j = 1:dimnum
                dimension(j) = fread(fid, 1, 'uint8');
                mult = mult * dimension(j);
                ParameterGroup(GroupNumber).Parameter(ParameterNumber).dim(j) = dimension(j);  % save parameter dimension data
            end
            datalength = abs(type) * mult;						    % length of data record for multi-dimensional array
        end
               
        if type == -1                                               % datatype=='char'  
            
            wordlength=dimension(1);	                            % length of character word
            if dimnum == 2 & datalength > 0                         % & parameter(idnumber, index,2).dim > 0            
                for j= 1 : dimension(2)
                    data = fread(fid, [1, wordlength], 'char');     %character word data record for 2-D array
                    ParameterGroup(GroupNumber).Parameter(ParameterNumber).data(j) = cellstr(char(data));
                end
            elseif dimnum == 1 & datalength > 0
                data = fread(fid, [1, wordlength], 'char'); 		% numerical data record of 1-D array
                ParameterGroup(GroupNumber).Parameter(ParameterNumber).data = cellstr(char(data));
            end
            
        elseif type == 1                                            %1-byte for boolean
            
            Nparameters=datalength/abs(type);		
            data = fread(fid,Nparameters,'int8');
            ParameterGroup(GroupNumber).Parameter(ParameterNumber).data = data;
            
        elseif type == 2 & datalength > 0	                		%integer
            
            Nparameters = datalength / abs(type);		
            data = fread(fid, Nparameters, 'int16');
            if dimnum > 1
                ParameterGroup(GroupNumber).Parameter(ParameterNumber).data = reshape(data, dimension);
            else
                ParameterGroup(GroupNumber).Parameter(ParameterNumber).data = data;
            end
            
        elseif type == 4 & datalength > 0
            
            Nparameters = datalength / abs(type);
            data = fread(fid, Nparameters, 'float');
            if dimnum > 1
                ParameterGroup(GroupNumber).Parameter(ParameterNumber).data = reshape(data,dimension);
            else
                ParameterGroup(GroupNumber).Parameter(ParameterNumber).data = data;
            end
        else
            % error
        end
        
        deschars = fread(fid, 1, 'int8');							% description characters
        if deschars > 0
            description = fread(fid, [1, deschars], 'char');
            ParameterGroup(GroupNumber).Parameter(ParameterNumber).description = cellstr(char(description));
        end
        
        if offset ~= 0
            fseek(fid, nextrec, 'bof');                             % Set file position indicator to next record
        else puntatore = false;
        end 
        
        % Storing parameters necessary to rescale analog data:
        if strcmpi(GroupName, 'ANALOG')        % parameters needed are in ANALOG group
            switch upper(ParameterName)
                case 'GEN_SCALE'
                    analogGenScale = ParameterGroup(GroupNumber).Parameter(ParameterNumber).data;
                case 'SCALE'
                    analogScale = ParameterGroup(GroupNumber).Parameter(ParameterNumber).data;
                case 'OFFSET'
                    analogOffset = ParameterGroup(GroupNumber).Parameter(ParameterNumber).data;
            end %switch
        end %if-strcmpi
        clear nomeGruppo NomeParametro            
        
        
    end %if GROUP/PARAMETER DATA    
   
    Ncharacters = fread(fid, 1, 'int8');    	% 1-st byte: characters in group/parameter name; can be <0 with locked group/parameter
    Ncharacters = abs(Ncharacters);
    GroupNumber = fread(fid, 1, 'int8'); 		% 2-nd byte: id number -ve=group / +ve=parameter
    
    
end %while-puntatore

clear Ncharacters GroupNumber




% ###############################################
% ##                                           ##
% ##    (E) read data block                    ##
% ##                                           ##
% ###############################################

%  Get the coordinate and analog data

fseek(fid,(NrecordDataBlock-1)*512,'bof');

% h = waitbar(0,[FileName,' is loading...']);

NvideoFrames=EndFrame - StartFrame + 1;			

if Scale<0,
    % Negative scale factor: Float32-data
    Nanalog=NanalogFramesPerVideoFrame*NanalogChannels;
    Ntotaal=4*Nmarkers+Nanalog;
    alles=fread(fid,[Ntotaal NvideoFrames],'float32')';
else
    % Positive scale factor: Int-data
    Nanalog=NanalogFramesPerVideoFrame*NanalogChannels;
    Ntotaal=4*Nmarkers+Nanalog;
    alles=fread(fid,[Ntotaal NvideoFrames],'int16')';
end  

if Nmarkers > 0
    Markers=alles(:,floor(1.1:4/3:(Nmarkers*4)));
    %reshape 3D signals... make it work with 2D signals in the future...
    Markers = reshape(Markers, NvideoFrames, 3, Nmarkers);
    Markers = permute(Markers, [1,3,2]);
end

AnalogSignals=alles(:,Nmarkers*4+1:end);
AnalogSignals=reshape(AnalogSignals',NanalogChannels,NanalogFramesPerVideoFrame*NvideoFrames)'; %reshape Analog signals
fixa=fix(alles(:,4:4:Nmarkers*4)); %  rounds the elements toward zero, resulting in an array of integers
CameraInfo=fix(fixa/256);
ResidualError=(fixa-CameraInfo*256)*abs(Scale);

% Davide: rescaling correctly AnalogSignals:
analogScaleFactors = analogScale*analogGenScale'; % array NanalogChannels x 1
for col = 1:NanalogChannels
    AnalogSignals(:,col) = (AnalogSignals(:,col) - analogOffset(col))*analogScaleFactors(col);
end


% close(h) % waitbar

fclose(fid);

return

end % function readC3Ddavide


% ======================



%%%%% Previous version...
% if Scale < 0
%     disp('3D Data- Floating-point format') % controle
%     for i=1:NvideoFrames
%         for j=1:Nmarkers
%             Markers(i,j,1:3)=fread(fid,3,'float32')'; 
%             a=fix(fread(fid,1,'float32'));  
%             highbyte=fix(a/256);
%             lowbyte=a-highbyte*256; 
%             CameraInfo(i,j)=highbyte; 
%             ResidualError(i,j)=lowbyte*abs(Scale); 
%         end
%         waitbar(i/NvideoFrames)
%         for j=1:NanalogFramesPerVideoFrame,
%             AnalogSignals(j+NanalogFramesPerVideoFrame*(i-1),1:NanalogChannels)=...
%                 fread(fid,NanalogChannels,'float32')';  %%%% Aanpassing Brenda 
%             %fread(fid,NanalogChannels,'int16')'; 
%         end
%     end
% else
%     disp('3D Data- Floating-point format') % Controle
%     for i=1:NvideoFrames
%         for j=1:Nmarkers
%             Markers(i,j,1:3)=fread(fid,3,'int16')'.*Scale;
%             ResidualError(i,j)=fread(fid,1,'int8');
%             CameraInfo(i,j)=fread(fid,1,'int8');
%         end
%         waitbar(i/NvideoFrames)
%         for j=1:NanalogFramesPerVideoFrame,
%             AnalogSignals(j+NanalogFramesPerVideoFrame*(i-1),1:NanalogChannels)=...
%                 fread(fid,NanalogChannels,'int16')'; %%% moet dit ook aangepast worden?, Brenda
%         end
%     end
% end

