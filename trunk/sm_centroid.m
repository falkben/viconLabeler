function sm_c = sm_centroid(centroid,sm_length,DIAG)

val_ind = find(~isnan(centroid(:,1)));
all_ind = 1:length(centroid);

interp_xval = smooth(interp1(val_ind,centroid(val_ind,1),all_ind),sm_length);
interp_yval = smooth(interp1(val_ind,centroid(val_ind,2),all_ind),sm_length);
interp_zval = smooth(interp1(val_ind,centroid(val_ind,3),all_ind),sm_length);

interp_xval(interp_xval==0)=nan;
interp_yval(interp_yval==0)=nan;
interp_zval(interp_zval==0)=nan;

sm_c = [interp_xval interp_yval interp_zval];

if nargin >= 3 && DIAG
  figure(12); clf;
  plot3(centroid(:,1),centroid(:,2),centroid(:,3),'.-r','linewidth',2);
  axis equal; grid on;
  hold on;
  plot3(sm_c(:,1),sm_c(:,2),sm_c(:,3),'.-g','linewidth',2);
  hold off;
end