filename = 'bike07.mp4';

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



writer = VideoWriter('just_testing_the_epipole');
writer.open();

first = 350;
skip = 10;
last = 11000;

frame = imread(sprintf(framesDumpFormat,first));
sz = size(frame);
sz = sz(1:2);
p1 = detectSURFFeatures(rgb2gray(frame));
[f1,v1] = extractFeatures(rgb2gray(frame),p1);
for i = first+skip:skip:last
    prev = frame;
    
    frame = imread(sprintf(framesDumpFormat,i));
    p2 = detectSURFFeatures(rgb2gray(frame));
    if size(p2) == 0
        warning('%d: no feature points detected', i);
        continue;
    end
    [f2,v2] = extractFeatures(rgb2gray(frame),p2);
    match = matchFeatures(f1,f2,'Prenormalized',true);%,'MaxRatio',.3);
    if numel(match)/2 < 30
        warning('%d -> %d: only %d matches',i-10,i,numel(match)/2);
    else
        [f, inliers, status] = estimateFundamentalMatrix(v1.Location(match(:,1),:),v2.Location(match(:,2),:), 'ReportRuntimeError', false);
      
        [is, ep] = isEpipoleInImage(f,sz);
        
         f1=f2;
        v1=v2;
        ep = round(ep);

        if ~is
            fprintf('%d -> %d: epipole outside of image\n',i-10,i);
        else
            fprintf('%d -> %d: epipole location is (%d, %d)\n',i-10, i, ep(1), ep(2));
            min_x = max(ep(1)-10,1);
            max_x = min(ep(1)+10,sz(2));
            min_y = max(ep(2)-10,1);
            max_y = min(ep(2)+10,sz(1));

            prev(min_y+7 : max_y-7,min_x     : max_x,       2) =255;
            prev(min_y    : max_y    ,min_x+7 : max_x-7   ,2) = 255;
        end
    end
    
    
    [is2, ep2] = isEpipoleInImage(sd.Fundamental{i-10,10},sz);
    ep2 = round(ep2);
%         [is2, ep2] = isEpipoleInImage(f',sz);


    if ~is2
        fprintf('%d -> %d: preprocessed epipole outside of image\n',i-10,i);
    else
        fprintf('%d -> %d: preprocessed epipole location is (%d, %d)\n',i-10, i, ep2(1), ep2(2));
        min_x = max(ep2(1)-10,1);
        max_x = min(ep2(1)+10,sz(2));
        min_y = max(ep2(2)-10,1);
        max_y = min(ep2(2)+10,sz(1));

        prev(min_y+7 : max_y-7,min_x     : max_x,       1) =255;
        prev(min_y    : max_y    ,min_x+7 : max_x-7   ,1) = 255;
    end
        
    
    writer.writeVideo(prev);
    figure(1);imshow(prev);title(sprintf('frame No. %d, epipole location is (%d, %d)', i-10, ep(1), ep(2)));
%     figure(2);imshow(frame);title(sprintf('frame No. %d (target frame)', i));
%     pause
    
end
writer.close();


% %% Create fast forward video
% %select one cfg example from below
% %see ConfigWrapper for default values
% experiment='Bike1';
% experiments = {'Walking2','Walking3','Running1','Driving1','Driving2'};
% for i = 1:length(experiments)
% 
% experiment = experiments{i};
% fprintf('%sStarting experiment No. %d, %s\n', log_line_prefix, i, experiment);
% video_dir = 'G:\samples\fpstereo';
% close all;
% switch experiment
%     case 'Bike1'
%         filename = 'bike07.mp4';
%         startInd=350;
%         endInd=11136;
%     case 'Bike2'
%         filename = 'bike07.mp4';
%         startInd=16150;
%         endInd=23199;
%     case 'Bike3'
%         filename = 'bike08.mp4';
%         startInd=5800;
%         endInd=29500;
%     case 'Climbing'
%         filename = 'climbing08.mp4';
%         startInd=1;
%         endInd=6494;
%     case 'Scrambling'
%         filename = 'climbing03.mp4';
%         startInd=24800;
%         endInd=41199;
%     case 'Walking1'
%         filename = 'gl02.mp4';
%         startInd=2800;
%         endInd=20049;
%     case 'Walking2'
%         filename = 'Alireza_Day2_001.avi';
%         startInd=700;
%         endInd=7600;
%     case 'Walking3'
%         filename = 'Huji_Yair_5.mp4';
%         startInd=1;
%         endInd=8000;
%     case 'Running1'
%         filename = 'Youtube_Ayala Triangle Run with GoPro Hero 3+ Black Edition - YouTube [720p].mp4';
%         startInd=2100;
%         endInd=15000;
%     case 'Driving1'
%         filename = 'Huji_Yair_9_part1.MP4';
%         startInd=1800;
%         endInd=10000;
%     case'Driving2'
%         filename = 'Youtube_GoPro Trucking! - Yukon to Alaska 1080p.mp4';
%         startInd=1800;
%         endInd=12000;
% end
% 
% videoFile = fullfile(video_dir,filename);
% 
% 
% cfg = ConfigWrapper({'inputVideoFileName',videoFile;...
%                     % 'ShakenessCostFunction','None';
%                     'ShaknessTermWeight',1;...
%                     %'VelocityCostFunction','None';
%                     'VelocityTermWeight',1;...
%                     'AppearanceCostFunction','ColorHistogram';
%                     'AppearanceTermWeight',1;...
%                     'VelocityManualTargetValue', 4; ...
%                     'maxTemporalDist',100;
%                     'FOE_Reference','Absolute';...
%                     'startInd',startInd;
%                     'endInd',endInd;
%                     'SkipVideoOutput',0;
%                     'CostWeightMethod','Clamped';
%                     'ShaknessTermBinaryThreshold',5;
%                     'VelocityTermBinaryThreshold',1;
%                     'AppearanceTermBinaryThreshold',2;
%                     'ShakenessTermClampedValue',1000;
%                     'VelocityTermClampedValue',1000;
%                     'AppearanceTermClampedValue',1000; 
%                     'NaiveFastForwardSkipRatio',10;
%                     'FrameSelector','Naive';
%                     });
% 
% cfg.set('outputVideoFileName',[cfg.get('outputVideoFileName') '_x10']);
% 
% 
% % Load the video .mat file
% sd = Util.LoadVidDataFromMat(videoFile,'fpstereo','returnonly');
% 
% se = FastForwardSequenceProducer(sd,cfg);
% %this will write the output video in \'input_video_dir'\out\'output_file_name'
% se.run();
% 
% exp_fname = [cfg.get('outputVideoFileName') '.mat'];
% fprintf('%sSaving experiment %d to "%s"..\n',log_line_prefix, cfg.get('ID'),exp_fname);
% save(exp_fname,'-v7.3','se','sd','cfg','exp_fname');
% fprintf('%sDone experiment %d\n',log_line_prefix,cfg.get('ID'));
% 
% end