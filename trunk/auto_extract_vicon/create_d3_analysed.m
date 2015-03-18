function d3_analysed=create_d3_analysed(c3d_trial, bat, UB, ignore_frames)

d3_analysed = struct;

d3_analysed.object(1).video = bat;
d3_analysed.object(1).name = 'bat';
d3_analysed.unlabeled_bat = UB;
d3_analysed.fvideo = c3d_trial.frame_rate;

fname=c3d_trial.fn;
if strfind(fname,'/')
  slashes = strfind(fname,'/');
else
  slashes = strfind(fname,'\');
end

if strfind(fname,'July') %fix for stupid naming
  fname_corr=regexprep(fname,'July','Jul');
else
  fname_corr=fname;
end
try
  DN=datenum(fname_corr(slashes(end-3)+1:slashes(end-2)-1),'mmmddyyyy');
  datecode=datestr(DN,'yyyymmdd');
catch %no consistent date naming...
%   DN=datenum(fname_corr(slashes(end-3)+1:slashes(end-2)-1),'mmddyyyy');
  datecode=fname_corr(slashes(end-3)+1:slashes(end-2)-1);
end
bat_name = fname(slashes(end-2)+1:slashes(end-1)-1);
trial_num = fname(slashes(end)+6:slashes(end)+7);

d3_analysed.trialcode = [bat_name '.' datecode '.' ...
  num2str(trial_num,'%1.2d')];

d3_analysed.startframe = c3d_trial.start_f;
d3_analysed.endframe = c3d_trial.end_f;

d3_analysed.ignore_segs = ignore_frames;