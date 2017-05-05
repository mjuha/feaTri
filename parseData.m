function parseData(DBCSet, NBCSet, PFCSet, nodeSet, sideSet)

% global variables
global coordinates elements nn nel pointNode lineNode ID

% post-process boundary conditions
[m,~] = size(pointNode);
numericCell = nodeSet(:,1);
numericVector = cell2mat(numericCell);
% ===============
% ID array
% ===============
ID = ones(2,nn);
%================
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
    found = false;
    for j=1:length(row)
        %value = DBCSet{row(j),3};
        if strcmp(DBCSet{row(j),2},'X')
            ID(1,pointNode(i,2)) = 0; % X
        else
            ID(2,pointNode(i,2)) = 0; % Y
        end
        found = true;
    end
    if found
        continue
    end
end

[m,~] = size(lineNode);
% check nodeSet
numericCell = nodeSet(:,1);
numericVector = cell2mat(numericCell);
for i=1:m
    phytag = lineNode(i,1);
    % search in nodeSet
    [row,~] = find(numericVector==phytag);
    if  isempty(row)
        continue
    end
    % find in DBCSet first
    row = size(DBCSet,1);
    found = false;
    for j=1:row
        if strcmp(DBCSet{j,2},'X')
            ID(1,lineNode(i,2)) = 0; % X
            ID(1,lineNode(i,3)) = 0; % X
        else
            ID(2,lineNode(i,2)) = 0; % Y
            ID(2,lineNode(i,3)) = 0; % Y
        end
        found = true;
    end
    if found
        continue
    end
end

ID

end

