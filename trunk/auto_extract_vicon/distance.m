function D = distance(A,B)

if size(A,2)==3 && size(B,2)==3
  D = sqrt((A(:,1)-B(:,1)).^2 + (A(:,2)-B(:,2)).^2 + (A(:,3)-B(:,3)).^2);
else
  D = sqrt((A(:,1)-B(:,1)).^2 + (A(:,2)-B(:,2)).^2);
end