%using 10 second buffer
function c3d_trial = open_c3d(c3dfname)
c3d_trial=[];
try
  [point_array, frame_rate, trig_rt, trig_sig, start_f, end_f] = lc3d( c3dfname );
  
  if ~isnan(trig_rt)
    trial_s_frame=max(round((trig_rt-10)*frame_rate),1);
    frames=trial_s_frame:round(trig_rt*frame_rate);
  else
    disp('No trigger detected... skipping.');
    return
  end
catch
  disp('Failed to load c3d file... skipping.');
  return;
end

unlabeled_bat=cell(length(frames),1);
for f=1:length(frames)
  frame=frames(f);
  unlabeled_bat{f,:}=cell2mat(cellfun(@(c) c.traj(frame,:)./1e3,point_array,...
    'uniformoutput',0));
end
unlabeled_bat=cellfun(@(c) c(c(:,1)~=0,:),unlabeled_bat,'uniformoutput',0);

c3d_trial.unlabeled_bat_original = unlabeled_bat;
c3d_trial.unlabeled_bat = unlabeled_bat;
c3d_trial.frame_rate = frame_rate;
c3d_trial.start_f = frames(1)-round(trig_rt*frame_rate);
c3d_trial.end_f = frames(end)-round(trig_rt*frame_rate);
% c3d_trial.trig_frame = floor(trig_rt*frame_rate);
c3d_trial.fn = c3dfname;
