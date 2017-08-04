close all
addpath('FOE');
warning ('off', 'images:initSize:adjustingMag');

%videoFile = 'D:\samples\huji\egocentric\Huji_Yair_5.mp4';
%videoFile = 'G:\dataset\Huji_Yair_5.mp4';

%% Preprocess videos
% Util.PrepreocessSequences('C:\Users\tavih\Desktop\Microsoft videos\*.mp4','');
% Util.PrepreocessSequences({'G:\samples\fpstereo\*.avi';
%                             'G:\samples\fpstereo\*.mp4';},'');
%                             'G:\samples\fpstereo\Youtube_Ayala Triangle Run with GoPro Hero 3+ Black Edition - YouTube [720p].mp4';
%                             'G:\samples\fpstereo\Huji_Yair_9_part1.MP4';
%                             'G:\samples\fpstereo\Youtube_GoPro Trucking! - Yukon to Alaska 1080p.mp4'},'');





%% Create fast forward video
%select one cfg example from below
%see ConfigWrapper for default values

video_dir = 'G:/samples/fpstereo';

experiment= {'Walking3'}; %'Walking2','Driving1',,'Driving2','Running1'
%experiment =  {'Walking1','Bike1','Bike2','Bike3','Climbing','Scrambling'};
if ~iscell(experiment)
    experiment={experiment};
end

for i=1:numel(experiment)
    
    cfg = SequenceLibrary.GetFFExperimentDetails(experiment{i},video_dir);
    
    % Load the video .mat file
    sd = Util.LoadVidDataFromMat(cfg.get('inputVideoFileName'),'fpstereo','returnonly');

    se = FastForwardSequenceProducer(sd,cfg);
    %this will write the output video in \'input_video_dir'\out\'output_file_name'
    se.run();

    exp_fname = [cfg.get('outputVideoFileName') '.mat'];
    fprintf('%sSaving experiment %d to "%s"..\n',log_line_prefix, cfg.get('ID'),exp_fname);
    save(exp_fname,'-v7.3','se','sd','cfg','exp_fname');
    fprintf('%sDone experiment %d\n',log_line_prefix,cfg.get('ID'));
end
