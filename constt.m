function [D,thickness] = constt(elem)

global MAT STATE

D = zeros(3,3);

young = MAT(elem,1);
poisson = MAT(elem,2);
thickness = MAT(elem,3);

switch STATE
    case 'planeStress'
        C = young*thickness/(1-poisson^2);
        D(1,1) = 1;
        D(1,2) = poisson;
        D(2,1) = poisson;
        D(2,2) = 1;
        D(3,3) = 0.5*(1-poisson);
        D = C*D;
    case 'planeStrain'
        C = young*thickness*(1-poisson)/((1+poisson)*(1-2*poisson));
        D(1,1) = 1;
        D(1,2) = poisson/(1-poisson);
        D(2,1) = D(1,2);
        D(2,2) =1;
        D(3,3) = 0.5*(1-2*poisson)/(1-2*poisson);
        D = C*D;
    otherwise
        error('Unknown STATE\n')
end


end