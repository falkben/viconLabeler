function D = distance(A,B)
D = sqrt((A(:,1)-B(:,1)).^2 + (A(:,2)-B(:,2)).^2 + (A(:,3)-B(:,3)).^2);