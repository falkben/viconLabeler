%from kaushik's function
%2 dimensional velocity vector (when bat is moving in 3D)
function [thetavel] = bat_velocity_direction(bat)

[thetavel r] =...
  cart2pol(diff(bat(:,1)), diff(bat(:,2)) );
index = (r < 4.2e-4) ;  %bats don't fly that slow....
thetavel(index) = 0 ;

thetavel = [thetavel(1); thetavel];
% thetavel = unwrap(thetavel);