%returns non-negative angle betwen two vectors between 0 and pi
function angle=vector_angle(a,b)
angle = atan2(norm(cross(a,b)), dot(a,b));
% angle2 = 2 * atan(norm(a*norm(b) - norm(a)*b) / norm(a * norm(b) + norm(a) * b));

%in order to calculate across a vector
function NN=norm(v)
NN=sqrt(v(1,:).^2 + v(2,:).^2 + v(3,:).^2);
