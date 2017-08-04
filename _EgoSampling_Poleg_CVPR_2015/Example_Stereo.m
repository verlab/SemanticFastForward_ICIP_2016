addpath('FOE');
addpath('BundledCamPathsStabilizer');
addpath('BundledCamPathsStabilizer/mesh');
addpath('BundledCamPathsStabilizer/RANSAC');
addpath('RigidEstimator');

%% Preprocess videos
% Util.PrepreocessSequences('D:\samples\hyperlapse\gl02.mp4','');


%%
% Perfect example #1 (just take care for cropping)
%videoFile = 'D:\samples\huji\fpstereo-tavi\me_indoor_4.mp4';
%baseDumpFrameFileName='D:/samples/huji/fpstereo-tavi/dump/me_indoor_4/frame_%05d.png';
%startInd=180;
%endInd=0;
%StereoOutputWCropPercent=0.2;
%StereoOutputHCropPercent=0.1;
  
%%
% Perfect example #2 (just take care for cropping)
% videoFile = 'D:\samples\huji\fpstereo-tavi\me_givat_ram_north.mp4';
% baseDumpFrameFileName='D:/samples/huji/fpstereo-tavi/dump/me_givat_ram_north/frame_%06d.png';
% startInd=130;
% endInd=3000;
% StereoOutputWCropPercent=0.1;
% StereoOutputHCropPercent=0;

%%
% Perfect example #3 (just take care for cropping)
% videoFile = 'G:\samples\fpstereo\gl02.mp4';
% baseDumpFrameFileName='G:/samples/fpstereo/gl02_frames_undist/frame_%06d.png';
% startInd=1;
% endInd=0;
% StereoOutputWCropPercent=0.1;
% StereoOutputHCropPercent=0;








%% Stereo video output
video_dir = 'G:/samples/fpstereo';

experiment= 'Walking5'; %{'Walking1','Walking4','Walking5'};

if ~iscell(experiment)
    experiment={experiment};
end

for i=1:numel(experiment)
    
    cfg = SequenceLibrary.GetStereoExperimentDetails(experiment{i},video_dir);
    
    % Load the video .mat file
    sd = Util.LoadVidDataFromMat(cfg.get('inputVideoFileName'),'fpstereo','returnonly');

    ssp = StereoSequenceProducer(sd,cfg);
    
    ssp.run();

    exp_fname = [cfg.get('outputVideoFileName') '.mat'];
    fprintf('%sSaving experiment %d to "%s"..\n',log_line_prefix, cfg.get('ID'),exp_fname);
    save(exp_fname,'-v7.3','ssp','sd','cfg','exp_fname');
    fprintf('%sDone experiment %d\n',log_line_prefix,cfg.get('ID'));
end