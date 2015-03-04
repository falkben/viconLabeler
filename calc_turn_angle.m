%2d turn angle on smoothed centroid
function turn_angle=calc_turn_angle(sm_C,frm_len,DIAG)

dir_vec=diff(sm_C(:,1:2));
turn_angle=unwrap(cart2pol(dir_vec(:,1),dir_vec(:,2))) .*180/pi;
turn_angle(end+1)=turn_angle(end);
turn_angle=smooth(turn_angle,frm_len);

if nargin > 1 && DIAG
  
  figure(13);clf;
  plot(sm_C(:,1),sm_C(:,2),'r','linewidth',2);
  
  ii=1:50:length(sm_C);
  text(sm_C(ii,1),sm_C(ii,2),num2str(turn_angle(ii)));
  
end