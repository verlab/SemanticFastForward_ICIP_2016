classdef SequenceLibrary
    
    
    methods(Static)
        
        
        function [cfg] = GetFFExperimentDetails(exp_name,video_dir)
            
        switch exp_name
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
                endInd=20049;
            case 'Walking2'
                filename = 'Alireza_Day2_001.avi';
                startInd=700;
                endInd=7600;
            case 'Walking3'
                warning('failure case example');
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
                            'FastForwardSkipRatio',10;...
                            'terminalConnectionDegree', 90;...

                            'baseDumpFrameFileName',framesDumpFormat;
                            'ShakenessCostFunction','Epipole.vs.FOE';
                            'ShaknessTermWeight',10;...
                            'ShaknessTermInvalidValue',100000;...

                            'VelocityTermWeight',10;...
                            'AppearanceCostFunction','ColorHistogram';
                            'AppearanceTermWeight',2;...

                            'ForwardnessTermWeight',4;...

                            'FrameSelector', 'ShortestPath';
                            'UseHigherOrder',false;
                            'maxTemporalDist',100;
                            'FOE_Reference','Absolute';...
                            'startInd',startInd;
                            'endInd',endInd;
                            'SkipVideoOutput',0;
                            'CostWeightMethod','Sum';
                            });


           % Cfg adjuments per experiment type 
           switch exp_name
                case {'Walking1','Bike1','Bike2','Bike3','Climbing','Scrambling'}
                    % Experiments with lens correction, we are using the epipole
                    % method.
                    cfg.set('ShakenessCostFunction','Epipole.vs.FOE');
                    cfg.set('ShaknessTermWeight',1000);
                    cfg.set('VelocityTermWeight',200);    
                    cfg.set('AppearanceTermWeight',3);    
                    cfg.set('ForwardnessTermWeight',5);
                    cfg.set('ForwardnessMergeWithShaknessCoef',4);
                    cfg.set('UseHigherOrder',true);

                    if cfg.get('UseHigherOrder')
                        cfg.set('ShaknessTermWeight',1000);
                        cfg.set('VelocityTermWeight',200);    
                        cfg.set('AppearanceTermWeight',3);    
                        cfg.set('ForwardnessTermWeight',5);
                        cfg.set('ForwardnessMergeWithShaknessCoef',4);
                        cfg.set('HighOrderTermWeight',500);
                    end

                case {'Walking2','Walking3','Driving1','Driving2','Running1'}
                    % Expirements without lens correction, hense, can't use
                    % epipole..
                    cfg.set('ShakenessCostFunction','FOE');
                    cfg.set('ShaknessTermWeight',3);
                    cfg.set('VelocityTermWeight',10);
                    cfg.set('AppearanceTermWeight',3);    
                    cfg.set('ForwardnessTermWeight',0); 

                    if cfg.get('UseHigherOrder')
                        cfg.set('ShaknessTermWeight',3);
                        cfg.set('VelocityTermWeight',10);
                        cfg.set('AppearanceTermWeight',3);    
                        cfg.set('ForwardnessTermWeight',0);
                        cfg.set('HighOrderTermWeight',500);
                    end


            end
            
            
        end
        
        
        function [cfg] = GetStereoExperimentDetails(exp_name,video_dir)
            
        switch exp_name
            case 'Walking1'
                filename = 'gl02.mp4';
                startInd=19080;
                endInd=19410;
                StereoOutputWCropPercent=0.2344;
                StereoOutputHCropPercent=0.2062;
            case 'Walking4'
                filename = 'me_givat_ram_north.mp4';
                startInd=130;
                endInd=3000;
                StereoOutputWCropPercent=0.3;
                StereoOutputHCropPercent=0.2;
            case 'Walking5'
                filename = 'me_indoor_4.mp4';
                startInd=180;
                endInd=0;
                StereoOutputWCropPercent=0.2;
                StereoOutputHCropPercent=0.1;
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
                                        'baseDumpFrameFileName',framesDumpFormat;...
                                        'startInd',startInd;...
                                        'endInd',endInd;...
                                        'StereoCostFunction','OFPeaks';...
                                        'AutoOutputPostfix',1;...
                                        'maxTemporalDist',300;...
                                        'AppearanceTermWeight',0;...
                                        'VelocityTermWeight',0;...
                                        'OutputStablizer','StereoStabilizer';
                                        'StereoStabilizerLRWarp','RansacSimilarity';
                                        'StereoStabilizerPrevNextWarp','RansacRigid';
                                        'StereoOutputWCropPercent',StereoOutputWCropPercent;
                                        'StereoOutputHCropPercent',StereoOutputHCropPercent;
                                        'StereoFrameOrdering','RedCyan'});
            
            
        end
    end
    
    
end