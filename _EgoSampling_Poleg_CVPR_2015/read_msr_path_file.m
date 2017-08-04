function cameras = read_msr_path_file(fname)


fileID = fopen(fname,'r','n','US-ASCII');

numRecords = cell2mat(textscan(fileID,'%d',1,'delimiter','\n'));

cameras = struct();

for i=1:numRecords
    cameras.id(i) = cell2mat(textscan(fileID,'%d',1,'delimiter','\n'));
    
    fov = cell2mat(textscan(fileID,'%f64 %f64',1,'delimiter','\n'));
    cameras.fovh(i) = fov(1);
    cameras.fovv(i) = fov(2);

    % x,y,z
    cameras.pos(:,i) = cell2mat(textscan(fileID,'%f64 %f64 %f64',1,'delimiter','\n'));
    % x,y,z
    cameras.front(:,i) = cell2mat(textscan(fileID,'%f64 %f64 %f64',1,'delimiter','\n'));
    % x,y,z
    cameras.up(:,i) = cell2mat(textscan(fileID,'%f64 %f64 %f64',1,'delimiter','\n'));    
end


fclose(fileID);