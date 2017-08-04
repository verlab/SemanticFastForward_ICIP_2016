function cameras = read_msr_camera_reconstruction_file(fname)


fileID = fopen(fname,'r','n','US-ASCII');

numRecords = cell2mat(textscan(fileID,'%d',1,'delimiter','\n'));

cameras = struct();

for i=1:numRecords
    id_frame = cell2mat(textscan(fileID,'%d %d',1,'delimiter','\n'));
    cameras.id(i) = id_frame(1);
    cameras.frame_num(i) = id_frame(2);
    
    cam_params = cell2mat(textscan(fileID,'%f64 %f64 %f64',1,'delimiter','\n'));
    cameras.focal(i) = cam_params(1);
    cameras.fovh(i) = cam_params(2);
    cameras.fovv(i) = cam_params(3);
    
    cameras.cam_rot_mat(:,:,i) = cell2mat(textscan(fileID,'%f64 %f64 %f64',3,'delimiter','\n'));
    
    cameras.cam_translation(:,i) = cell2mat(textscan(fileID,'%f64 %f64 %f64',1,'delimiter','\n'));
end


fclose(fileID);