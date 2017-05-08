function [fe,ke] = weakform(el,xe,de)

global sideLoad

% 1 point formula - degree of precision 1
gp =  [ 1/3, 1/3;];
w =  1;

ngp = size(gp,1);

[D,thickness] = constt(1);

% initialize stiffness matrix
ke = zeros(6,6);
% stress-strain displacement matrix
B = zeros(3,6);
% loop over gauss points
for i=1:ngp
    [~,dN,jac] = shape(gp(i,:),xe);
    for j=1:3 % loop over local nodes
        B(1,2*j-1) = dN(j,1);
        B(2,2*j) = dN(j,2);
        B(3,2*j-1) = dN(j,2);
        B(3,2*j) = dN(j,1);
    end
    ke = ke + B'*D*B*w(i)*jac;
end

ue = zeros(6,1);
for i=1:3 % loop over local nodes
    ue(2*i-1) = de(1,i);
    ue(2*i) = de(2,i);
end

fe = zeros(6,1);
if size(sideLoad,1) > 0
    index = find(sideLoad(:,1)==el,3); % up to three edges
    flag = size(index,1);
    % compute side load
    if flag > 0
        edges = size(index,1);
        for i=1:edges
            [fe1] = computeSideLoad(index(i),xe,thickness);
            fe = fe1;
        end
    end
end
fe = fe - ke * ue;

end
