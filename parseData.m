function parseData(DBCSet, NBCSet, PFCSet, nodeSet, sideSet)

% global variables
global coordinates elements nn nel pointNode lineNode ID LM sideLoad
global U

% post-process boundary conditions
[m,~] = size(pointNode);
numericCell = nodeSet(:,1);
numericVector = cell2mat(numericCell);
% ===============
% ID array
% ===============
ID = ones(2,nn);
%================

% solution vector
U = zeros(2,nn);
for i=1:m
    phytag = pointNode(i,1);
    % search in nodeSet
    [row,~] = find(numericVector==phytag);
    if isempty(row)
        continue
    end
    name = nodeSet{row,2};
    % find in DBCSet first
    [row,~] = find(strcmp(DBCSet,name),3);
    for j=1:length(row)
        value = DBCSet{row(j),3};
        if strcmp(DBCSet{row(j),2},'X')
            ID(1,pointNode(i,2)) = 0; % X
            U(1,pointNode(i,2)) = value;
        else
            ID(2,pointNode(i,2)) = 0; % Y
            U(2,pointNode(i,2)) = value;
        end
    end
end

[m,~] = size(lineNode);
% sideLoad
sideLoad = zeros(m,4); % later to be resized
% check nodeSet
numericCell = nodeSet(:,1);
numericVector = cell2mat(numericCell);
count = 0;
for i=1:m
    phytag = lineNode(i,1);
    % search in nodeSet
    [row,~] = find(numericVector==phytag);
    if  isempty(row)
        continue
    end
    % find in DBCSet first
    name = nodeSet{row,2};
    % find in DBCSet first
    [row,~] = find(strcmp(DBCSet,name),3);
    found = false;
    for j=1:length(row)
        value = DBCSet{row(j),3};
        if strcmp(DBCSet{row(j),2},'X')
            ID(1,lineNode(i,2)) = 0; % X
            ID(1,lineNode(i,3)) = 0; % X
            U(1,lineNode(i,2)) = value;
            U(1,lineNode(i,3)) = value;
        else
            ID(2,lineNode(i,2)) = 0; % Y
            ID(2,lineNode(i,3)) = 0; % Y
            U(2,lineNode(i,2)) = value;
            U(2,lineNode(i,3)) = value;
        end
        found = true;
    end
    if found
        count = count + 1;
    end
end

% for pressure BCs
[m,~] = size(lineNode);
sideLoad = zeros(m-count,4);
% check sideSet
numericCell = sideSet(:,1);
numericVector = cell2mat(numericCell);
count = 1;
for i=1:m
    phytag = lineNode(i,1);
    % search in sideSet
    [row,~] = find(numericVector==phytag);
    if  isempty(row)
        continue
    end
    % find in NBCSet first
    name = sideSet{row,2};
    % find in NBCSet first
    [row,~] = find(strcmp(NBCSet,name),3);
    found = false;
    for j=1:length(row)
        value = NBCSet{row(j),2};
        sideLoad(count,2:3) = lineNode(i,2:3);
        sideLoad(count,4) = value;
        found = true;
    end
    if found
        count = count + 1;
    end
end

% find element where pressure is applied
[m,~] = size(sideLoad);
for i=1:m
    A = sideLoad(i,2:3);
    for j=1:nel
        B = elements(j,2:4);
        C = ismember(A,B);
        if sum(C) == 2
            sideLoad(i,1) = j;
            break
        end
    end
end

% Fill ID array
count = 0;
for j=1:nn
  for i=1:2
    if ID(i,j) ~= 0
      count = count + 1;
      ID(i,j) = count;
    end
  end
end

% =================
% Generate LM array
% =================
LM = zeros(6,nel);
for k=1:nel
  for j=1:3
    for i =1:2
      p = 2*(j-1) + i;
      LM(p,k) = ID(i,elements(k,j+1));
    end
  end
end



end

