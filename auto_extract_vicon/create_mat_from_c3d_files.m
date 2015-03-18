clear;
c3dfnames=grab_c3d_names();

processed_files = dir('../../processed_vicon_automated/*.mat');
processed_fnames = {processed_files.name}';

select_start=1;

for k=843:length(c3dfnames)
  
  fname=c3dfnames{k};
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
  DN=datenum(fname_corr(slashes(end-3)+1:slashes(end-2)-1),'mmmddyyyy');
  datecode=datestr(DN,'yyyymmdd');
  bat_name = fname(slashes(end-2)+1:slashes(end-1)-1);
  trial_num = fname(slashes(end)+6:slashes(end)+7);
  trialcode = [bat_name '.' datecode '.' ...
    num2str(trial_num,'%1.2d')];

  if isempty(find(strcmp(processed_fnames,[trialcode '.mat']),1))
    c3d2batmat_manual(1,c3dfnames{k});
  end
  
  disp([ num2str( k/length(c3dfnames)*100,'%2.2f') '% done'  ])
end

% system('shutdown -s');