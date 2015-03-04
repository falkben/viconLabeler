%returns a smoothed centroid where the smoothed window corresponds to the
%number of points present in each frame of unlabeled_bat
function interpcentr=weighted_smooth_centroid(centroid,sm_amnt,UB,interp_on,DIAG)

interpcentr=nan(length(centroid),3);

weight_amnt=cellfun(@length,UB);

val_ind = find(~isnan(centroid(:,1)));

sm_centroid=nan(length(centroid),3);
for k=val_ind'
  f1=max(1,k-round(sm_amnt/2));
  f2=min(length(centroid),k+round(sm_amnt/2));
  windw=weight_amnt(f1:f2);
  sm_centroid(k,:)=nansum([centroid(f1:f2,1)...
    centroid(f1:f2,2)...
    centroid(f1:f2,3)] .* repmat(windw,1,3) )...
    ./nansum(windw);
end

% xval = smooth(interpcentr(:,1),sm_amnt);
% yval = smooth(interpcentr(:,2),sm_amnt);
% zval = smooth(interpcentr(:,3),sm_amnt);

% sm_centroid = [xval yval zval];

if ~interp_on
  interpcentr=sm_centroid;
  nan_indx= isnan(centroid(:,1));
  interpcentr(nan_indx,:)=nan;
else
  warning('off','MATLAB:interp1:NaNstrip');
  interpcentr(val_ind(1):val_ind(end),:)=interp1(val_ind,...
    sm_centroid(val_ind,:),val_ind(1):val_ind(end),'spline');
  warning('on','MATLAB:interp1:NaNstrip');
end

if nargin > 4 && DIAG
  figure(12), clf, set(gcf, 'pos', [30 30 600 600])
  plot3(centroid(:,1),centroid(:,2),centroid(:,3),'.k')
  
  ii=1:50:length(centroid);
  text(centroid(ii,1),centroid(ii,2),centroid(ii,3),num2str(ii'),...
    'fontsize',14);
  
  hold on;
  
  plot3(interpcentr(:,1),interpcentr(:,2),interpcentr(:,3),'.g');
  
  plot3(sm_centroid(:,1),sm_centroid(:,2),sm_centroid(:,3),'.r')
  
  grid on;
  axis equal
  
end