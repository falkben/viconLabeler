function c3dfnames=grab_c3d_names(bats,vicon_dir)
c3dfnames={};

if nargin < 2
  vicon_dir=uigetdir([],...
    'Select start path, eg. ''Eptesicus Wing Hair Forest 2010_nobackup''');
  if isequal(vicon_dir,0)
    return;
  end
end
vicon_subdirs = dir(vicon_dir);
vicon_folders={vicon_subdirs(cellfun(@(c) c==1,{vicon_subdirs.isdir})).name};
vicon_folders=vicon_folders(~(strcmp(vicon_folders,'.') | strcmp(vicon_folders,'..'))); % removing the . & ..

if nargin < 1
  bats={'BK59','P72','P75','P77','P79','PR45','PR46'};
end
for f=1:length(vicon_folders) %start with 8/31
  
%   in_date=dir([vicon_dir '\' vicon_folders{f}]);
%   bats_in_date = {in_date(4:end).name};
%   bats_in_date = bats_in_date(cellfun(@isempty,(regexpi(bats_in_date,'[static]'))));
  
  for b=1:length(bats)
    trials=dir([vicon_dir '\' vicon_folders{f} '\' bats{b} '\Session 1\*.c3d']);
    
    trl_names={trials.name};
    
    
    %remove last10/cropped/DEMO
    incl_indx=cellfun(@isempty,strfind(trl_names,'last10')) &...
      cellfun(@isempty,strfind(trl_names,'cropped')) & ...
      cellfun(@isempty,strfind(trl_names,'DEMO'));
    trial_names={trials(incl_indx).name};
    
    trial_fnames = cellfun(@(c) ...
      [vicon_dir '\' vicon_folders{f} '\' bats{b} '\Session 1\' c],trial_names,...
      'uniformoutput',0)';
    
    c3dfnames = [c3dfnames; trial_fnames];
    
  end
  
end
c3dfnames = c3dfnames';
