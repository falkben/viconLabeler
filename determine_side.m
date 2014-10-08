%returns left or right side of bat for the given points
%-1 for right, +1 for left
function side=determine_side(bat,pts,frms,useline,DIAG)

side=nan(size(pts,1),1);

%using a plane
%plane doesn't work well - points that create the plane tend to be in a
%line - thus the plane can rotate, and finding left from right becomes
%difficult
if nargin<4 || useline==0
  %3 points
  p1=bat(frms(1),:);
  p2=bat(frms(round(length(frms)/2)),:);  
  p3=bat(frms(end),:);
  
  %fit to plane
  points2fit=[bat(max(1,frms(1)-10):min(length(bat),frms(1)+10),:);...
    pts];
  [n,~,p]=affine_fit(points2fit);
  offset=n(1)*p(1)+n(2)*p(2)+n(3)*p(3);
  %points on plane (diff. because of fitting)
  pp1=[p1(1) p1(2) (offset-n(1)*p1(1)-n(2)*p1(2))/n(3)];
  pp3=[p3(1) p3(2) (offset-n(1)*p3(1)-n(2)*p3(2))/n(3)];
  
  %direction vector of 2 points on plane
  p1p3=pp3-pp1;
  
  %normal to the plane
  dn=cross(p1p3,n);
  
  %finding the plane's offset value in scalar notation
  doffset=dn(1)*pp1(1)+dn(2)*pp1(2)+dn(3)*pp1(3);
  dp2=[p2(1) p2(2) (doffset-dn(1)*p2(1)-dn(2)*p2(2))/dn(3)];
  
  
  side = -sign((pts - repmat(pp1,length(pts),1))*dn');
  
%   for k=1:length(pts)
% %     side(k) = sign(dot( pp3-pp1 - pts(k,:), dn ) );
%     
%     %3 points on desired plane are pp1, pp3, and dp2
%     %determinant
%     side(k)=sign(det([dp2-pp1;...
%       pp3-pp1;...
%       pts(k,:)-pp1]));
%   end
else
  %using a line
  for fr=1:length(frms)
    f=frms(fr);
    
    side(fr)= sign( (bat(f+1,1)-bat(f,1))*(pts(fr,2)-bat(f,2)) -...
      (bat(f+1,2)-bat(f,2))*(pts(fr,1)-bat(f,1)) ) ;
  end
end

if nargin>4 && DIAG
  figure(1), clf;
  plot3(bat(frms,1),bat(frms,2),bat(frms,3),'.k');
  hold on;
  plot3(pts(:,1),pts(:,2),pts(:,3),'or');
  grid on;
  text(bat(frms(1),1),bat(frms(1),2),bat(frms(1),3),'start')
  text(bat(frms(end),1),bat(frms(end),2),bat(frms(end),3),'end')
  if useline
    view(2);
  else
    plot3(pp3(1),pp3(2),pp3(3),'og')
    plot3(pp1(1),pp1(2),pp1(3),'om')
    plot3(dp2(1),dp2(2),dp2(3),'oy','markerfacecolor','y')
%     plot3(p(1),p(2),p(3),'oc','markerfacecolor','c')
    
    %plot plane
    x = [pp1(1) dp2(1) pp3(1)];  
    y = [pp1(2) dp2(2) pp3(2)];
    z = [pp1(3) dp2(3) pp3(3)];
    A = dn(1); B = dn(2); C = dn(3);
    D = -dot(dn,pp1);
    xLim = [min(x) max(x)];
    zLim = [min(z) max(z)];
    [X,Z] = meshgrid(xLim,zLim);
    Y = (A * X + C * Z + D)/ (-B);
    reOrder = [1 2  4 3];
    patch(X(reOrder),Y(reOrder),Z(reOrder),'b');
    alpha(.3)
    
    %plot plane
    x = [pp1(1) p(1) pp3(1)];  
    y = [pp1(2) p(2) pp3(2)];
    z = [pp1(3) p(3) pp3(3)];
    A = n(1); B = n(2); C = n(3);
    D = -dot(n,pp1);
    xLim = [min(x) max(x)];
    zLim = [min(z) max(z)];
    [X,Z] = meshgrid(xLim,zLim);
    Y = (A * X + C * Z + D)/ (-B);
    reOrder = [1 2  4 3];
    patch(X(reOrder),Y(reOrder),Z(reOrder),'y');
    alpha(.3)
    view(3);
  end
  axis equal;
end