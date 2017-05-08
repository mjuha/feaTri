function [fe] = computeSideLoad(el,xe,thickness)

global sideLoad

fe = zeros(6,1);

% Gauss - Legendre rule. 1 point in [0,1]
gp = 0.5;
w = 1.0;

% compute residual: side loads
edge = sideLoad(el,2);
p = sideLoad(el,5); % pressure

% loop over gauss points
if edge == 1 % local nodes 1-2
    r = gp;
    % s = 0
    Nshape = [ 1-r, r, 0 ];
    N_r = [ -1, 1, 0 ];
elseif edge == 2 % local nodes 2-3
    r = gp;
    % s = 1-r
    Nshape = [ 0, r, 1-r ];
    N_r = [ 0 ,1, -1 ];
elseif edge == 3 % local nodes 3-1
    % r = 0
    s = gp;
    Nshape = [ 1-s, 0, s ];
    N_r = [ -1, 0, 1 ];
else
    error('Wrong edge, check input!');
end
% compute unit normal vector to edge
x_r = N_r * xe(:,1);
y_r = N_r * xe(:,2);
jac = sqrt(x_r^2 + y_r^2);
if jac < 1.0e-12
    error('Jacobian less than zero, check input or element too distorted!');
end
n_hat = (1/jac) * [ -y_r; x_r ];
% check normal orientation. It should point outward.
if edge == 1 % local nodes 1-2
    v = xe(3,1:2) - xe(1,1:2);
elseif edge == 2 % local nodes 2-3
    v = xe(2,1:2) - xe(1,1:2);
else % local nodes 3-1
    v = xe(1,1:2) - xe(3,1:2);
end
orientation = dot(v,n_hat);
if orientation > 0.0
    n_hat = -n_hat;
end
pressure = p * n_hat;
% fill in N
N = zeros(2,6);
for j=1:3 % loop over local nodes
    N(1,2*j-1) = Nshape(j);
    N(2,2*j) = Nshape(j);
end
fe = fe + N' * pressure * w * jac;
fe = thickness * fe;

end