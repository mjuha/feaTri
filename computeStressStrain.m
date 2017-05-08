function computeStressStrain

global coordinates elements nel U stress strain

% 1 point formula
gp =  [ 1/3, 1/3 ];

[D,~] = constt(1);

% loop over elements
for i=1:nel
    xe = coordinates(elements(i,2:4),:);
    de = U(:,elements(i,2:4));
    ue = zeros(6,1);
    % stress-strain displacement matrix
    B = zeros(3,6);
    % compute at gauss point
    [~,dN,~] = shape(gp,xe);
    for k=1:3 % loop over local nodes
        B(1,2*k-1) = dN(k,1);
        B(2,2*k) = dN(k,2);
        B(3,2*k-1) = dN(k,2);
        B(3,2*k) = dN(k,1);
        ue(2*k-1) = de(1,k);
        ue(2*k) = de(2,k);
    end
    % compute strain at Gauss points
    estrain = B*ue;
    % compute stress at Gauss points
    estress = D*estrain;
    % fill stress and strain
    stress(:,i) = estress;
    strain(:,i) = estrain;
end

end