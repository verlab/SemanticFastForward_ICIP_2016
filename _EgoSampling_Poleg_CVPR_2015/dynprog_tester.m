close all
addpath('FOE');
warning ('off', 'images:initSize:adjustingMag');


%% Create fast forward video
%select one cfg example from below
%see ConfigWrapper for default values

video_dir = 'G:/samples/fpstereo';

experiment= {'Bike1'};

if ~iscell(experiment)
    experiment={experiment};
end

for i=1:numel(experiment)
    switch experiment{i}
        case 'Bike1'
            filename = 'bike07.mp4';
            startInd=350;
       
            endInd=11136;
        case 'Bike2'
            filename = 'bike07.mp4';
            startInd=16150;
            endInd=23199;
        case 'Bike3'
            filename = 'bike08.mp4';
            startInd=5800;
            endInd=29500;
        case 'Climbing'
            filename = 'climbing08.mp4';
            startInd=1;
            endInd=6494;
        case 'Scrambling'
            filename = 'climbing03.mp4';
            startInd=24800;
            endInd=41199;
        case 'Walking1'
            filename = 'gl02.mp4';
            startInd=2800;
            endInd=3500;
            %endInd=20049;
        case 'Walking2'
            filename = 'Alireza_Day2_001.avi';
            startInd=700;
            endInd=7600;
        case 'Walking3'
            filename = 'Huji_Yair_5.mp4';
            startInd=1;
            endInd=8000;
        case 'Running1'
            filename = 'Youtube_Ayala Triangle Run with GoPro Hero 3+ Black Edition - YouTube [720p].mp4';
            startInd=2100;
            endInd=15000;
        case 'Driving1'
            filename = 'Huji_Yair_9_part1.MP4';
            startInd=1800;
            endInd=10000;
        case'Driving2'
            filename = 'Youtube_GoPro Trucking! - Yukon to Alaska 1080p.mp4';
            startInd=1800;
            endInd=12000;
    end

    videoFile = fullfile(video_dir,filename);
    [~, fname ,~] = fileparts(filename);

    framesDumpDir = strrep(fullfile(video_dir,['/dump/' fname]),'\','/');
    framesDumpFormat = strrep(fullfile(framesDumpDir,'/frame_%06d.png'),'\','/');

    if ~exist(sprintf(framesDumpFormat,startInd),'file')
        framesDumpFormat = strrep(fullfile(framesDumpDir,'/frame_%05d.png'),'\','/');
    end
    if ~exist(sprintf(framesDumpFormat,startInd),'file')
        framesDumpDir = strrep(fullfile(video_dir,[fname '_frames_undist']),'\','/');
        framesDumpFormat = [framesDumpDir '/frame_%05d.png'];
    end
    if ~exist(sprintf(framesDumpFormat,startInd),'file')
        framesDumpFormat = [framesDumpDir '/frame_%06d.png'];
    end


    % Generally, this is the config. For certain types of experiments,
    % we have a switch statement below to adjust stuff.
    cfg = ConfigWrapper({'inputVideoFileName',videoFile;...
                        'VelocityTarget','CumulativeMean';...
                        'FastForwardSkipRatio',5;...
                        'terminalConnectionDegree', 22;...
                        
                        'baseDumpFrameFileName',framesDumpFormat;
                        'ShakenessCostFunction','Epipole.vs.FOE';
                        'ShaknessTermWeight',10;...
                        'ShaknessTermInvalidValue',100000;...

                        'VelocityTermWeight',10;...
                        'AppearanceCostFunction','ColorHistogram';
                        'AppearanceTermWeight',2;...
                        
                        'ForwardnessTermWeight',5;...
                        
                        'HighOrderTermWeight', 10;
                        'ForwardnessMergeWithShaknessCoef', 5000;
                        'FrameSelector', 'DynamicProgramming';
                        'maxTemporalDist',30;
                        'FOE_Reference','Absolute';...
                        'startInd',startInd;
                        'endInd',endInd;
                        'SkipVideoOutput',1;
                        'CostWeightMethod','Sum';
                        });


   % Cfg adjuments per experiment type 
   switch experiment{i}
        case {'Walking1','Bike1','Bike2','Bike3','Climbing','Scrambling'}
            % Experiments with lens correction, we are using the epipole
            % method.
            cfg.set('ShakenessCostFunction','Epipole.vs.FOE');
            cfg.set('ShaknessTermWeight',1000);
            cfg.set('VelocityTermWeight',200);    
            cfg.set('AppearanceTermWeight',3);    
            cfg.set('ForwardnessTermWeight',5);
            
        case {'Walking2','Walking3','Driving1','Driving2','Running1'}
            % Expirements without lens correction, hense, can't use
            % epipole..
            cfg.set('ShakenessCostFunction','FOE');
            cfg.set('ShaknessTermWeight',3);
            cfg.set('VelocityTermWeight',10);
            cfg.set('AppearanceTermWeight',3);    
            cfg.set('ForwardnessTermWeight',0);
            
            
   end

    cfg.set(     'FrameSelector', 'ShortestPath');
    cfg.set('UseHigherOrder', true);
    
    % Load the video .mat file
    sd = Util.LoadVidDataFromMat(videoFile,'fpstereo','returnonly');

    se = FastForwardSequenceProducer(sd,cfg);
    %this will write the output video in \'input_video_dir'\out\'output_file_name'
    se.run();

%     exp_fname = [cfg.get('outputVideoFileName') '.mat'];
%     fprintf('%sSaving experiment %d to "%s"..\n',log_line_prefix, cfg.get('ID'),exp_fname);
%     save(exp_fname,'-v7.3','se','sd','cfg','exp_fname');
%     fprintf('%sDone experiment %d\n',log_line_prefix,cfg.get('ID'));
end
