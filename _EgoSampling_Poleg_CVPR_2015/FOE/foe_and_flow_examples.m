%% Simple forward motion, no rotation
[FlowX, FlowY,p0_x,p0_y,p1_x,py_1] = gen_flow_pattern(10,5,0,0,0.5,[0 0 1],0); 
figure; 
subplot(1,2,1); quiver(p0_x, p0_y, FlowX(:),FlowY(:),'r');

[foe_x, foe_y, est_err, all_scores] = find_foe_from_flow_field_block(FlowX,FlowY,0);
subplot(1,2,2); imagesc(all_scores);
title(sprintf('FOE Location is [%.1f,%.1f] (est_err=%.4f)',foe_x,foe_y,est_err),'interpreter','none');



%% Rotation about the Z axis
[FlowX, FlowY,p0_x,p0_y,p1_x,py_1] = gen_flow_pattern(21,11,0,0,0.5,[0 0 1],0.05); 
figure; 
subplot(1,2,1); quiver(p0_x, p0_y, FlowX(:),FlowY(:),'r');

[foe_x, foe_y, est_err, all_scores] = find_foe_from_flow_field(FlowX,FlowY,0);
subplot(1,2,2); imagesc(all_scores);
title(sprintf('FOE Location is [%.1f,%.1f] (est_err=%.4f)',foe_x,foe_y,est_err),'interpreter','none');


%% Forward, foe somewhere on top, with a bit of rotation 
[FlowX, FlowY,p0_x,p0_y,p1_x,py_1] = gen_flow_pattern(10,5,0,0.5,0.5,[0 0.3 1],0.1); 
figure; 
subplot(1,2,1); quiver(p0_x, p0_y, FlowX(:),FlowY(:),'r');

[foe_x, foe_y, est_err, all_scores] = find_foe_from_flow_field(FlowX,FlowY,0);
subplot(1,2,2); imagesc(all_scores);
title(sprintf('FOE Location is [%.1f,%.1f] (est_err=%.4f)',foe_x,foe_y,est_err),'interpreter','none');


%% Sharp rotation about the Y axis ('head turn left') and forward motion
[FlowX, FlowY,p0_x,p0_y,p1_x,py_1] = gen_flow_pattern(10,5,0,0,0.5,[0 1 0],0.3); 
figure; 
subplot(1,2,1); quiver(p0_x, p0_y, FlowX(:),FlowY(:),'r');

[foe_x, foe_y, est_err, all_scores] = find_foe_from_flow_field(FlowX,FlowY,0);
subplot(1,2,2); imagesc(all_scores);
title(sprintf('FOE Location is [%.1f,%.1f] (est_err=%.4f)',foe_x,foe_y,est_err),'interpreter','none');


%% CPU vs GPU comparison
%% Simple forward motion, no rotation
[FlowX, FlowY,p0_x,p0_y,p1_x,py_1] = gen_flow_pattern(10,5,0,0,0.5,[0 0 1],0); 
figure; 

tic;
[foe_x, foe_y, est_err, all_scores] = find_foe_from_flow_field_block(FlowX,FlowY,0);
cputime=toc;


tic;
[foe_x, foe_y, est_err, all_scores] = find_foe_from_flow_field_gpu(FlowX,FlowY,0);
gputime=toc;

fprintf('CPU Time = %.3f seconds\n',cputime);
fprintf('GPU Time = %.3f seconds\n',gputime);


%% Test with smooth CDC
% NOTE: YOU NEED SOME SequenceData instance for this!


[mx, my] = meshgrid(1:10,1:5);
figure;
smooth_size = 20;
Hsmooth = fspecial('average',[smooth_size 1]);
X_smooth = imfilter(sd.LK_X_raw,Hsmooth,'same',0);
Y_smooth = imfilter(sd.LK_Y_raw,Hsmooth,'same',0);

for i=1:10:size(sd.LK_X_smoothed,1)
    fx=reshape(X_smooth(i,:),10,5)';
    fy=reshape(Y_smooth(i,:),10,5)';
    subplot(1,2,1); 
    quiver(mx,my,fx,fy);
    
    
    [foe_x, foe_y, est_err, all_scores] = find_foe_from_flow_field_block(fx,fy,0); 
    
    subplot(1,2,2);
    imagesc(all_scores); 
    
    title(sprintf('Frame %d FOE Location is [%.1f,%.1f] (est_err=%.4f)',i,foe_x,foe_y,est_err),'interpreter','none');
    
    drawnow;
    pause(0.1);
end

