function rate_files(pn)
%rates all the points in a series of d3_analysed mat files and saves them

if nargin < 1
  if ispref('vicon_labeler','d3path') && ...
      exist(getpref('vicon_labeler','d3path'),'dir')
    pn=getpref('vicon_labeler','d3path');
  else
    pn=uigetdir([],'Set the path for the vicon labeler');
    if ~isequal(pn,0)
      setpref('vicon_labeler','d3path',pn);
    end
  end
else
  setpref('vicon_labeler','d3path',pn);
end

files=dir([pn '\*.mat']);
fnames={files.name};

rated_files = dir([pn '\..\vicon_label_ratings_from_automated\*.mat']);
rated_fnames = {rated_files.name}';

fnames = setdiff(fnames,rated_fnames);

for k=1:length(fnames)
  d3_analysed = [];
  load([pn '\' fnames{k}]);
  label_ratings.rating = rate_all(d3_analysed.unlabeled_bat);
  label_ratings.d3_analysed = d3_analysed;
  save([pn '\..\vicon_label_ratings_from_automated\' fnames{k}],'label_ratings');
end

system('shutdown -s');