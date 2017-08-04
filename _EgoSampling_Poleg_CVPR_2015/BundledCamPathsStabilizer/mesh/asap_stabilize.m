function [I1warped,I2warped] = asap_stabilize(Ifixed, I1est_and_warp, I2warp_only)
% Estimate a warp field between Ifixed and I1est_and_warp. It then warps
% I1est_and_warp towards Ifixed. If I2warp_only is not empty, it warps
% I2warp_only towards Ifixed using the same warp field between Ifixed and
% I1est_and_warp.

%Partial Matlab code for "Bundled Camera Paths for Video Stabilization" (SIGGRAPH 2013)
%Implementation of motion model estimation.
%1. As-similar-as-possible warping.
%2. Local homography estimation on mesh quads.
%require vision tool box for detectSURFFeatures, or you may want to use
%your own features. (N x 2)
%

clear all;
clc;

addpath('mesh');
addpath('RANSAC');

I1est_and_warp = imread('../temp/test1_frame_010745_right.png');
Ifixed = imread('../temp/test1_frame_010754_left.png');
fprintf('detect surf features...');
[I1_features,I2_features]=SURF(I1est_and_warp,Ifixed);
fprintf('[DONE]');

if length(I1_features) < 20
    error('not enough matched features');
    return;
end

[height,width,~] = size(I1est_and_warp);
%3x3 mesh
quadWidth = width/(2^3);
quadHeight = height/(2^3);

% %4x4 mesh
% quadWidth = width/(2^4);
% quadHeight = height/(2^4);

lamda = 1; %mesh more rigid if larger value. [0.2~5]
asap = AsSimilarAsPossibleWarping(height,width,quadWidth,quadHeight,lamda);
asap.SetControlPts(I1_features,I2_features);%set matched features
asap.Solve();            %solve Ax=b for as similar as possible
homos = asap.CalcHomos();% calc local hommograph transform

% 
% gap = 100;
% I1warp = asap.Warp(I1,gap);                     %warp source image to target image
% I1warpmesh = asap.destin.drawMesh(I1warp,gap);  %draw mesh on the warped source image
% imshow(I1warpmesh);

gap = 0;
I1warped = asap.Warp(I1est_and_warp,gap);                     

I2warped = [];
if ~isempty(I2warp_only)
    I2warped = asap.Warp(I2warp_only,gap);
end