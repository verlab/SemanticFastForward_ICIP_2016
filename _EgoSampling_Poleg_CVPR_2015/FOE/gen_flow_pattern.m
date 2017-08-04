function [FlowX, FlowY,p0_x,p0_y,p1_x,py_1] = gen_flow_pattern(Xblocks,Yblocks,Tx,Ty,Tz, Raxis,Rmagnitude)



% Create a bunch of synthetic points on the plane z=5.
z = 5;
[px,py] = meshgrid(linspace(-4.5,4.5,Xblocks),linspace(-4.5,4.5,Yblocks));
P = [px(:) py(:) repmat(z,size(px(:)),1)];

 
% Camera 0 is at the origin, looking along the Z axis.
M0 = [eye(3), [0 0 0]'];
% "Take a photo" form camera 0 
p_M0 = M0*[P(:,:), ones(size(P,1),1)]';
p_M0 = [p_M0(1,:) ./ p_M0(3,:); p_M0(2,:) ./ p_M0(3,:)]';

% Now move the camera
% Camera 1 is rotated by Rmagnitude along Raxis and translated by Tx,Ty,Tz.
M1 = [rotationmat3D(Rmagnitude,Raxis), M0(:,4)+[Tx Ty -Tz]'];
%M1 = [eye(3), M0(:,4)+[Tx Ty -Tz]'];
% Take another photo
p_M1 = M1*[P(:,:), ones(size(P,1),1)]';
p_M1 = [p_M1(1,:) ./ p_M1(3,:); p_M1(2,:) ./ p_M1(3,:)]';

%scatter(p_M1(:,1),p_M1(:,2),'r'); 

% Estimate optical from in the image plane
Flow_M0M1 = p_M1 - p_M0;

% Return the flow field
FlowX = reshape(Flow_M0M1(:,1),Yblocks,Xblocks);
FlowY = reshape(Flow_M0M1(:,2),Yblocks,Xblocks);

% Return the projected 2d points in image 0
p0_x = p_M0(:,1);
p0_y = p_M0(:,2);
p1_x = p_M1(:,1);
py_1 = p_M1(:,2);





