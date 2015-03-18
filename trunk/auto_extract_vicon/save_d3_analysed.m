function [PathName,FileName] = save_d3_analysed(d3_analysed,autosave)
[PathName,FileName]=deal([]);
if ispref('vicon_labeler','processed_vicon') && ...
    exist(getpref('vicon_labeler','processed_vicon'),'dir')
  pn=getpref('vicon_labeler','processed_vicon');
else
  pn=uigetdir([],'Set the directory for your d3_analysed file');
  if pn~=0
    setpref('vicon_labeler','processed_vicon',pn);
  end
end
if ~isequal(pn,0)
  setpref('vicon_labeler','processed_vicon',pn);
  if autosave==0
    [FileName,PathName] = uiputfile('.mat','Save ratings file',[pn '\' d3_analysed.trialcode '.mat']);
    setpref('vicon_labeler','processed_vicon',PathName(1:end-1));
  else
    PathName=[pn '\'];
    FileName=[d3_analysed.trialcode '.mat'];
  end

  if ~isequal(FileName,0) && ~isequal(PathName,0)
    save([PathName FileName],'d3_analysed');
    disp(['Saved File: ' [PathName FileName]]);
  end
end