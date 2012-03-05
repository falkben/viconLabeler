function d3_analysed = load_trial
if ispref('vicon_labeler','d3path') && ...
    exist(getpref('vicon_labeler','d3path'),'dir')
  pn=getpref('vicon_labeler','d3path');
else
  pn=[];
end
[filename pathname] = uigetfile('*.mat','Pick c3d file to label',pn);
if isequal(filename,0)
  return;
end
setpref('vicon_labeler','d3path',pathname);

fname=[pathname filename];
load(fname);