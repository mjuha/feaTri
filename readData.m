function readData(filename)

% global variables
global coordinates elements nn nel pointNode lineNode

% Open file
fileID = fopen(filename,'r');

% get first three lines and discard them
for i=1:3
    fgetl(fileID);
end
% get mesh input file
tline = fgetl(fileID);
tmp = strsplit(tline);
mshfile = tmp{4};
% get output file location
tline = fgetl(fileID);
tmp = strsplit(tline);
outfile = tmp{3};
% get side set association
tline = fgetl(fileID);
tmp = strsplit(tline);
nss = str2double(tmp(4)); % number of side sets to read
sideSet = cell(nss,2);
for i=1:nss
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    phyN = str2double(tmp(1)); % physical entity number
    sideSet(i,:) = {phyN, tmp{2}};
end
% get node set association
tline = fgetl(fileID);
tmp = strsplit(tline);
nns = str2double(tmp(4)); % number of node sets to read
nodeSet = cell(nns,2);
for i=1:nns
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    phyN = str2double(tmp(1)); % physical entity number
    nodeSet(i,:) = {phyN, tmp{2}};
end
% read Dirichlet BCs
tline = fgetl(fileID);
tmp = strsplit(tline);
ndbc = str2double(tmp(3)); % number of DBC to read
DBCSet = cell(ndbc,3);
for i=1:ndbc
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    name = tmp{4};
    dof = sscanf(tmp{7},'%[XY]');
    value = str2double(tmp(8)); % value to assign
    if strcmp(dof,'X')
        DBCSet(i,:) = {name, 'X' ,value};
    elseif strcmp(dof,'Y')
        DBCSet(i,:) = {name, 'Y' ,value};
    else
        error('DOF must be X,Y or Z, please check')
    end
    % check that association is correct (input file only)
    found = false;
    for j=1:nns
        if strcmp(name,nodeSet{j,2})
            found = true;
            break;
        end
    end
    if ~found
        error('Verify node set association, name not found')
    end
end
% read Neumann BCs
tline = fgetl(fileID);
tmp = strsplit(tline);
nnbc = str2double(tmp(3)); % number of NBC to read
NBCSet = cell(nnbc,2);
for i=1:nnbc
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    name = tmp{4};
    dof = sscanf(tmp{6},'%[press]');
    if ~strcmp(dof,'press')
        error('NBC must be force or press, please check')
    end
    value = str2double(tmp(7)); % value to assign
    NBCSet(i,:) = {name, value};
    % check that association is correct (input file only)
    found = false;
    for j=1:nss
        if strcmp(name,sideSet{j,2})
            found = true;
            break;
        end
    end
    if ~found
        error('Verify side set association, name not found')
    end
end

% read point force BCs
tline = fgetl(fileID);
tmp = strsplit(tline);
npfc = str2double(tmp(3)); % number of point force to read
PFCSet = cell(npfc,3);
for i=1:npfc
    tline = fgetl(fileID);
    tmp = strsplit(tline);
    name = tmp{4};
    dof = sscanf(tmp{6},'%[force]');
    if ~strcmp(dof,'force')
        error('FPC must be force, please check')
    end
    comp = sscanf(tmp{7},'%[XY]');
    if ~strcmp(comp,'X')
        if ~strcmp(comp,'Y')
            error('DOF must be X or Y, please check')
        end
    end
    value = str2double(tmp(8)); % value to assign
    PFCSet(i,:) = {name, comp, value};
    % check that association is correct (input file only)
    found = false;
    for j=1:nns
        if strcmp(name,nodeSet{j,2})
            found = true;
            break;
        end
    end
    if ~found
        error('Verify node set association, name not found')
    end
end

%Read material properties
% get next two lines and discard them
for i=1:2
    fgetl(fileID);
end
MAT = zeros(2,1);
tline = fgetl(fileID);
tmp = strsplit(tline);
MAT(1) = str2double(tmp(3)); % Elastic modulus
tline = fgetl(fileID);
tmp = strsplit(tline);
MAT(2) = str2double(tmp(3)); % Poisson ratio
% get state
tline = fgetl(fileID);
tmp = strsplit(tline);
if tmp{3}
    STATE = 'planeStress';
else
    STATE = 'PlaneStrain';
end

fclose(fileID);

% ====================
% Open file msh file
% ====================

fileID = fopen(mshfile,'r');

% get first three lines and discard them
for i=1:3
    fgetl(fileID);
end
% Get physical names (mandatory)
tline = fgetl(fileID);
if ~strcmp(tline,'$PhysicalNames')
    error('Input data MUST declare PhysicalNames. Please check.');
end
% get number of names
nNames = str2double(fgetl(fileID));
% get names
phyNames = zeros(nNames,2);
% each row contains: physical-dimension physical-number
for i=1:nNames
    tline = fgetl(fileID);
    phyNames(i,:) = sscanf(tline,'%d %d %*s');
end
fgetl(fileID); % discard this line
% Read nodes
fgetl(fileID); % discard this line
tline = fgetl(fileID);
nn = str2double(tline);
%
coordinates = zeros(nn,3);
for i=1:nn
    tline = fgetl(fileID);
    coordinates(i,:) = sscanf(tline,'%*d %f %f %f');
end
fgetl(fileID); % discard this line
%
% read elements
fgetl(fileID); % discard this line
tline = fgetl(fileID);
nelT = str2double(tline);
elementsT = cell(nelT,7);
% count number of 1-node point
pointCount = 0;
% count number of 2-node line
lineCount = 0;
% count number of 3-node triangle
triCount = 0;
for i=1:nelT
    tline = fgetl(fileID);
    C = str2double(strsplit(tline));
    switch C(2)
        case 15
            pointCount = pointCount + 1;
        case 1
            lineCount = lineCount + 1;
        case 2
            triCount = triCount + 1;
        otherwise
            error('Unknown element type. Please check.')
    end
    elementsT(i,:) = {C};
end
%close file
fclose(fileID);
% post-process data
nel = triCount;
elements = zeros(nel,4); % store number of physical entity, element tag
pointNode = zeros(pointCount,2);
lineNode = zeros(lineCount,3);
%
% count number of 1-node point
pointCount = 0;
% count number of 2-node line
lineCount = 0;
% count number of 3-node triangle
triCount = 0;
for i=1:nelT
    % get array
    v = elementsT{i};
    switch v(2)
        case 15
            pointCount = pointCount + 1;
            pointNode(pointCount,1) = v(4);
            pointNode(pointCount,2) = v(6);
        case 1
            lineCount = lineCount + 1;
            lineNode(lineCount,1) = v(4);
            lineNode(lineCount,2:3) = v(6:7);
        case 2
            triCount = triCount + 1;
            elements(triCount,1) = v(4);
            elements(triCount,2:4) = v(6:8);
        otherwise
            error('Unknown element type. Please check.')
    end
end
%
clearvars elementsT

% post-process boundary conditions
% [m,~] = size(pointNode);
% numericCell = nodeSet(:,1);
% numericVector = cell2mat(numericCell);
% for i=1:m
%     phytag = pointNode(i,1);
%     % search in nodeSet
%     [row,~] = find(numericVector==phytag);
%     if row == 0
%         continue
%     end
%     name = nodeSet{row,2};
%     % find in DBCSet first
%     [row,~] = find(strcmp(DBCSet,name),3);
%     found = false;
%     for j=1:length(row)
%         value = DBCSet{row(j),3};
%         if strcmp(DBCSet{row(j),2},'X')
%             pointNode(i,4) = 0; % X
%         else
%             pointNode(i,4) = 1; % Y
%         end
%         pointNode(i,5) = value;
%         found = true;
%     end
%     if found
%         continue
%     end
%     % find in PFCSet next
%     [row,~] = find(strcmp(PFCSet,name),3);
%     for j=1:length(row)
%         value = PFCSet{row(j),2};
%         pointNode(i,3) = 1; % is a force
%         pointNode(i,5) = value;
%         if strcmp(PFCSet{row(j),2},'X')
%             pointNode(i,4) = 0; % X
%         else
%             pointNode(i,4) = 1; % Y
%         end
%     end
% end
% [m,~] = size(lineNode);
% numericCell = sideSet(:,1);
% sideSet
% numericVector = cell2mat(numericCell);
% for i=1:m
%     phytag = lineNode(i,1);
%     % search in nodeSet
%     [row,~] = find(numericVector==phytag);
%     if row == 0
%         continue
%     end
%     name = nodeSet{row,2};
%     % find in DBCSet first
%     [row,~] = find(strcmp(DBCSet,name),3);
%     found = false;
%     for j=1:length(row)
%         value = DBCSet{row(j),2};
%         lineNode(i,5) = value;
%         lineNode(i,4) = value;
%         found = true;
%     end
%     if found
%         continue
%     end
%     % find in PFCSet next
%     [row,~] = find(strcmp(PFCSet,name),3);
%     for j=1:length(row)
%         value = PFCSet{row(j),2};
%         pointNode(i,3) = 1; % is a force
%         pointNode(i,4) = value;
%     end
% end

parseData(DBCSet, NBCSet, PFCSet, nodeSet, sideSet)

WriteVTKFile(outfile,0)

end