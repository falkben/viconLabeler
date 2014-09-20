%from vicon trialcode
function[audio_path,audio_fname]=determine_audio_fname(trialcode,rootdir)

audio_dir = '..\audio\';

dots = strfind(trialcode,'.');

bat = trialcode(1:dots(1)-1);
date = datevec(trialcode(dots(1)+1:dots(2)-1),'yyyymmdd');
num=trialcode(dots(2)+1:end);

audio_path=[rootdir audio_dir bat '\'];

load([rootdir 'data_sheet.mat']);

bat_indx=~cellfun(@isempty,strfind(data_sheet(:,2),bat));
date_indx=~cellfun(@isempty,strfind(data_sheet(:,1),...
  [num2str(date(2)) '/' num2str(date(3)) '/' num2str(date(1))]));
num_indx=cellfun(@ (c) isequal(str2double(num),c),data_sheet(:,4));

indx=bat_indx&date_indx&num_indx;
if ~isempty(find(indx,1))
  audio_num=data_sheet{indx,3};
  audio_fname=[datestr(date,'dd-mmm-yyyy') '_' num2str(audio_num,'%02d') '.mat'];
else
  audio_fname=0;
end