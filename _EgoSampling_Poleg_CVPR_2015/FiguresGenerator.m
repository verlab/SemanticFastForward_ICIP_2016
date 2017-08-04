classdef FiguresGenerator < handle

properties 
%some style constants here
    experiments;
    video_dir;
    data_sources;
end

methods

function obj = FiguresGenerator(data_basedir)
    if  isempty(data_basedir )
        switch lower(getComputerName())
            case 'vision-34'
                data_basedir = 'G:/samples/fpstereo';
            case 'taj'
                data_basedir = 'D:/samples/';
            otherwise
                error ('no default data dir');
        end
    end
    obj.video_dir = data_basedir;
    addpath('FOE'); 
   
    
    global GEN_FIG_FONTSIZE;
    GEN_FIG_FONTSIZE = 32;
    
    obj.data_sources = containers.Map();
    
    % Init the datasource
   obj.data_sources('Fmat_decay') = struct('exp_name','Fmat_decay',...
                                               'sequences',{{'Bike1','Bike2','Bike3'}},...
                                               'skipstart',500,...
                                               'max_frames',5000,...
                                               'max_temporal_dist',60,...
                                               'export_formats',{{'png','pdf'}},...
                                               'special_config',{{'something',0}});
                                           
                                           
   obj.data_sources('FOE_overview') = struct('exp_name','FOE_overview',...
                                               'sequences',{{'Walking1'}},...
                                               'straight1',16375,...
                                               'straight2',16430,...
                                               'rightview1',17173,...
                                               'rightview2',17245,...
                                               'hcrop', 100,...
                                               'wcrop',200,...
                                               'export_formats',{{'png','pdf'}},...
                                               'special_config',{{'something',0}});             
                                           
   obj.data_sources('Epipole_smoothness') = struct('exp_name','Epipole_smoothness',...
                                               'sequences',{{'Bike1','Bike2','Bike3','Walking1'}},...
                                               'experiments',{{{'G:\samples\fpstereo\out\bike07_840gsm-01_ExpID384.mat',... %% Bike1 second order
                                                                      'G:\samples\fpstereo\out\bike07_vision-34_ExpID147.mat'},... % Bike1 first order
                                               
                                                                      {'G:\samples\fpstereo\out\bike07_gsm-01_ExpID385.mat',... %% Bike2 second order
                                                                      'G:\samples\fpstereo\out\bike07_vision-34_ExpID148.mat'},... % Bike2 first order
                                               
                                                                        {'G:\samples\fpstereo\out\bike08_gsm-01_ExpID386.mat',... %% Bike3 second order
                                                                        'G:\samples\fpstereo\out\bike08_vision-34_ExpID144.mat'},... % Bike3 first order
                                                                        
                                                                        {'G:\samples\fpstereo\out\gl02_gsm-01_ExpID383.mat',... %% Walking1 second order
                                                                        'G:\samples\fpstereo\out\gl02_vision-34_ExpID149.mat'},... % Walking1 first order
                                                                      }},...
                                               'skipstart',500,...
                                               'max_frames',6000,...
                                               'export_formats',{{'png','pdf'}},...
                                               'special_config',{{'something',0}});             

                                           
obj.data_sources('FOE_smoothness') = struct('exp_name','FOE_smoothness',...
                                               'sequences',{{'Driving2','Running1','Walking2','Walking3'}},...
                                               'experiments',{{{'G:\samples\fpstereo\out\Alireza_Day2_001_gsm-01_ExpID396.mat',... %% Walking2 second order
                                                                      'G:\samples\fpstereo\out\Alireza_Day2_001_vision-34_ExpID422.mat'},... % Walking2 first order
                                               
                                                                      {'G:\samples\fpstereo\out\Huji_Yair_5_gsm-01_ExpID393.mat',... %% Walking3 second order
                                                                      'G:\samples\fpstereo\out\Huji_Yair_5_vision-34_ExpID428.mat'},... % Walking3 first order
                                               
                                                                        {'G:\samples\fpstereo\out\Youtube_GoPro Trucking! - Yukon to Alaska 1080p_^[omgsm-01_ExpID395.mat',... %% Driving second order
                                                                        'G:\samples\fpstereo\out\Youtube_GoPro Trucking! - Yukon to Alaska 1080p_vision-34_ExpID416.mat'},... % Driving first order
                                                                        
                                                                        {'G:\samples\fpstereo\out\Youtube_Ayala Triangle Run with GoPro Hero 3+ Black Edition - YouTube [720p]_gsm-01_ExpID394.mat',... %% Running second order
                                                                        'G:\samples\fpstereo\out\Youtube_Ayala Triangle Run with GoPro Hero 3+ Black Edition - YouTube [720p]_vision-34_ExpID427.mat'},... % Running first order
                                                                      }},...
                                               'skipstart',500,...
                                               'max_frames',6000,...
                                               'export_formats',{{'png','pdf'}},...
                                               'special_config',{{'something',0}});             

    obj.data_sources('extract_stereo_pairs') = struct('exp_name','extract_stereo_pairs',...
                                               'sequences',{{'Walking1'}},...
                                               'straight1',16375,...
                                               'straight2',16430,...
                                               'rightview1',17173,...
                                               'rightview2',17245,...
                                               'hcrop', 100,...
                                               'wcrop',200,...
                                               'export_formats',{{'png','pdf'}},...
                                               'special_config',{{'something',0}});                                              
end

function save_fig(obj,h,fname,formats)
    output_dir='figures/';
    for i=1:numel(formats)
        print(h,[output_dir 'fig_' fname '.' formats{i}],['-d' formats{i}]);
        %print(h,[output_dir 'fig_' fname '.emf'],'-dmeta');
        %print(h,[output_dir 'fig_' fname '.eps'],'-depsc');
        %print(h,[output_dir 'fig_' fname '.pdf'],'-dpdf');
    end
end

function GenerateEpipoleSmoothFig(obj,ds_key )
   
    ds = obj.data_sources(ds_key);
    sequences = ds.sequences;
    
    % Save results in a cell array. First row for headers.
    % Then the columns: SeqName,x5, x10, 1st Ord, 2nd Ord  which contain the mean
    % change in the epipole throught the first ds.max_frames frames.
    res_table = cell(1+numel(sequences),5);
    
    res_table(1,:) = {'SeqName','x5','x10', '1st Ord', '2nd Ord'};
    
    for seq=1:numel(sequences)
        cfg = SequenceLibrary.GetFFExperimentDetails(sequences{seq},obj.video_dir);
        vidFile = cfg.get('inputVideoFileName');
        cfg.set('startInd',cfg.get('startInd')+ds.skipstart);
        cfg.set('endInd',cfg.get('startInd')+ds.skipstart+ds.max_frames);
        
        if exist(['Epipole_smoothness_fig_meta_data_' sequences{seq} '.mat'] ,'file')
            ex = true;
        else
            ex = false;
        end
        
        if ex
            meta_data = load(['Epipole_smoothness_fig_meta_data_' sequences{seq} '.mat'] );
            meta_data = meta_data.meta_data;
        end
          
        if ~ex
            meta_data = struct;%
            mat = matfile([vidFile(1:end-4) 'fpstereo.mat']);
            sd = mat.seqdata;
            meta_data.epipole = generateEpipole(obj,sd,cfg);
        
            %second order
            mat = matfile(ds.experiments{seq}{1});    %
            s1= mat.se;%
            meta_data.second = s1.ResultsMetaData;%
        end

        second_order_frame_indices  = meta_data.second.frames;
        second_order_frame_indices = second_order_frame_indices(second_order_frame_indices > cfg.get('startInd')  & second_order_frame_indices <= cfg.get('endInd'));  
        second_order_frame_indices = second_order_frame_indices - cfg.get('startInd') +1;
        
        if ~ex
        %first order
            mat = matfile(ds.experiments{seq}{2});%
            s2= mat.se;        %
            meta_data.first.frames = s2.Frame_indices;%
            meta_data.first.avarage_skip =   floor(nanmean(s2.Frame_indices(2:end)- s2.Frame_indices(1:end-1)));%
            meta_data.first.median_skip = nanmedian((s2.Frame_indices(2:end)-  s2.Frame_indices(1:end-1)));%
        end

        first_order_frame_indices  = meta_data.first.frames;
        first_order_frame_indices = first_order_frame_indices(first_order_frame_indices > cfg.get('startInd') & first_order_frame_indices <=cfg.get('endInd'));  
        first_order_frame_indices = first_order_frame_indices - cfg.get('startInd') +1;
             
        if ~ex
            save(['Epipole_smoothness_fig_meta_data_' sequences{seq} '.mat'] ,'meta_data');%
        end
        %naive
        x10_smooth_frame_indices = 1:10 :cfg.get('endInd')-cfg.get('startInd') ;        
        x5_smooth_frame_indices = 1:5 :cfg.get('endInd')-cfg.get('startInd') ;
        
        %each and every frame
        all_indices = 1:cfg.get('endInd')-cfg.get('startInd') ;
        
        [first_order_smooth_weights, new_first_order_frame_indices] = obj.SmoothWeightsForIndices (first_order_frame_indices,meta_data.epipole);
        [second_order_smooth_weights,second_order_frame_indices ] = obj.SmoothWeightsForIndices (second_order_frame_indices ,meta_data.epipole);
        [x10_smooth_weights ,x10_smooth_frame_indices] = obj.SmoothWeightsForIndices (x10_smooth_frame_indices,meta_data.epipole);
        [x5_smooth_weights,x5_smooth_frame_indices ] = obj.SmoothWeightsForIndices (x5_smooth_frame_indices,meta_data.epipole);
        [all_weights, all_indices] = obj.SmoothWeightsForIndices (all_indices,meta_data.epipole);
        
        res_table(seq+1,:) = {sequences{seq}, mean(x5_smooth_weights), ...
            mean(x10_smooth_weights), mean(first_order_smooth_weights), mean(second_order_smooth_weights)};
        
%         close
% %         plot(all_indices,all_weights,'b');
%         
%         hold on
%         plot( new_first_order_frame_indices,first_order_smooth_weights,'r');
%         plot(second_order_frame_indices ,second_order_smooth_weights,'b');
%         plot(x10_smooth_frame_indices,x10_smooth_weights,'k' );
%         plot(x5_smooth_frame_indices ,x5_smooth_weights,'m');
%         legend('first order', 'second order', 'x10','x5');
    end
    disp('Epipole')
    res_table
end

function GenerateFOESmoothFig(obj,ds_key )
   
    ds = obj.data_sources(ds_key);
    sequences = ds.sequences;
    
    % Save results in a cell array. First row for headers.
    % Then the columns: SeqName,x5, x10, 1st Ord, 2nd Ord  which contain the mean
    % change in the FOE throught the first ds.max_frames frames.
    res_table = cell(1+numel(sequences),5);
    
    res_table(1,:) = {'SeqName','x5','x10', '1st Ord', '2nd Ord'};
    
    for seq=1:numel(sequences)
        cfg = SequenceLibrary.GetFFExperimentDetails(sequences{seq},obj.video_dir);
        vidFile = cfg.get('inputVideoFileName');
        cfg.set('startInd',cfg.get('startInd')+ds.skipstart);
        cfg.set('endInd',cfg.get('startInd')+ds.skipstart+ds.max_frames);
        
        if exist(['FOE_smoothness_fig_meta_data_' sequences{seq} '.mat'] ,'file')
            ex = true;
        else
            ex = false;
        end
        
        if ex
            meta_data = load(['FOE_smoothness_fig_meta_data_' sequences{seq} '.mat'] );
            meta_data = meta_data.meta_data;
        end
          
        if ~ex
            meta_data = struct;%
            mat = matfile([vidFile(1:end-4) 'fpstereo.mat']);
            sd = mat.seqdata;
            meta_data.FOE = generateFOE(obj,sd,cfg);
        
            %second order
            mat = matfile(ds.experiments{seq}{1});    %
            s1= mat.se;%
            meta_data.second = s1.ResultsMetaData;%
        end

        second_order_frame_indices  = meta_data.second.frames;
        second_order_frame_indices = second_order_frame_indices(second_order_frame_indices > cfg.get('startInd')  & second_order_frame_indices <= cfg.get('endInd'));  
        second_order_frame_indices = second_order_frame_indices - cfg.get('startInd') +1;
        
        if ~ex
        %first order
            mat = matfile(ds.experiments{seq}{2});%
            s2= mat.se;        %
            meta_data.first.frames = s2.Frame_indices;%
            meta_data.first.avarage_skip =   floor(nanmean(s2.Frame_indices(2:end)- s2.Frame_indices(1:end-1)));%
            meta_data.first.median_skip = nanmedian((s2.Frame_indices(2:end)-  s2.Frame_indices(1:end-1)));%
        end

        first_order_frame_indices  = meta_data.first.frames;
        first_order_frame_indices = first_order_frame_indices(first_order_frame_indices > cfg.get('startInd') & first_order_frame_indices <=cfg.get('endInd'));  
        first_order_frame_indices = first_order_frame_indices - cfg.get('startInd') +1;
             
        if ~ex
            save(['FOE_smoothness_fig_meta_data_' sequences{seq} '.mat'] ,'meta_data');%
        end
        %naive
        x10_smooth_frame_indices = 1:10 :cfg.get('endInd')-cfg.get('startInd') ;        
        x5_smooth_frame_indices = 1:5 :cfg.get('endInd')-cfg.get('startInd') ;
        
        %each and every frame
        all_indices = 1:cfg.get('endInd')-cfg.get('startInd') ;
        
        [first_order_smooth_weights, new_first_order_frame_indices] = obj.SmoothWeightsForIndices (first_order_frame_indices,meta_data.FOE);
        [second_order_smooth_weights,second_order_frame_indices ] = obj.SmoothWeightsForIndices (second_order_frame_indices ,meta_data.FOE);
        [x10_smooth_weights ,x10_smooth_frame_indices] = obj.SmoothWeightsForIndices (x10_smooth_frame_indices,meta_data.FOE);
        [x5_smooth_weights,x5_smooth_frame_indices ] = obj.SmoothWeightsForIndices (x5_smooth_frame_indices,meta_data.FOE);
        [all_weights, all_indices] = obj.SmoothWeightsForIndices (all_indices,meta_data.FOE);
        
        res_table(seq+1,:) = {sequences{seq}, mean(x5_smooth_weights), ...
            mean(x10_smooth_weights), mean(first_order_smooth_weights), mean(second_order_smooth_weights)};
        
%         close
% %         plot(all_indices,all_weights,'b');
%         
%         hold on
%         plot( new_first_order_frame_indices,first_order_smooth_weights,'r');
%         plot(second_order_frame_indices ,second_order_smooth_weights,'b');
%         plot(x10_smooth_frame_indices,x10_smooth_weights,'k' );
%         plot(x5_smooth_frame_indices ,x5_smooth_weights,'m');
%         legend('first order', 'second order', 'x10','x5');
    end
    disp('FOE')
    res_table
end

function [weights, indices] = SmoothWeightsForIndices (obj, indices, epipole)
    weights  = zeros(numel(indices)-2,1);
    for i = 1:numel(indices)-2
         weights(i) = norm(squeeze(epipole(indices(i),indices(i+1)-indices(i),:)-epipole(indices(i+1),indices(i+2)-indices(i+1),:)));
    end
    nan_elements = isnan(weights) | abs(weights) > 2;
    weights  = weights  (~nan_elements);
    indices = indices(1:end-2);
    indices = indices   (~nan_elements);
end

function GenerateFundamentalMatDecay(obj,ds_key )
    
    ds = obj.data_sources(ds_key);
    sequences = ds.sequences;
    
    tempDist = ds.max_temporal_dist;
    dist = zeros(tempDist ,numel(sequences));
    percentFinite = zeros(tempDist ,numel(sequences));
    
    for seq=1:numel(sequences)
        cfg = SequenceLibrary.GetFFExperimentDetails(sequences{seq},obj.video_dir);
        fprintf('%sgenerating data for epipole vs. foe distance for sequence %s',log_line_prefix,sequences{seq});
        if strcmp(cfg.get('ShakenessCostFunction'),'Epipole.vs.FOE')==0
            warning('shakeness function should be epipole in order to evaluate it against foe');
            disp('nothing to show here');
            continue
        end
        %cfg.get('maxTemporalDist');
        %FOE(i,j,:) = foe between frame i and i+j. same for epipole
        vidFile = cfg.get('inputVideoFileName');
        cfg.set('startInd',cfg.get('startInd')+ds.skipstart);
        cfg.set('endInd',cfg.get('startInd')+ds.max_frames);
        mat = matfile([vidFile(1:end-4) 'fpstereo.mat']);
        sd = mat.seqdata;
        FOE = obj.generateFOE(sd,cfg);

        epipole = obj.generateEpipole(sd,cfg);

        for i = 1:tempDist 
            finiteShakeness = epipole(:,i,1) < .5 & epipole(:,i,2)  < .5 & abs(FOE(:,i,1)) < .5 & abs(FOE(:,i,2)) < .5;
            dist(i,seq) = nanmean(sqrt(sum((epipole(finiteShakeness,i,:)-FOE(finiteShakeness,i,:)).^2,3)));
            percentFinite(i,seq) = sum(epipole(:,i,1) < inf)/size(epipole,1);
        end
    end
    
    
     w=800;
     h=w/(1920/1080);
     
     hs=figure; 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);   
    
    % Show both recovery rate and diff
%     plot(1:tempDist , [nanmean(dist,2), mean(percentFinite,2)],'LineWidth',2);
%     legend('F-Mat Recovery Rate','Avg Diff between FEO and Epipole');
%     
    % Show just recovery rate and diff
    plot(1:tempDist , [ mean(percentFinite,2)],'LineWidth',2);
    legend('F-Mat Recovery Rate');
    
    hold on;    
    %ylim([-2.2 2.2]);
    %set(gca,'Position',[0.08 0.1 0.89 0.8]);
    grid on;  set(gca,'LineWidth',2);
    
    % Fix font sizes.
    global GEN_FIG_FONTSIZE; set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);

    xlabel('Temporal Distance Between Frames');
    ylabel('F-Mat Recovery Rate');
    
    
    obj.save_fig(hs,['fmat_decay'],ds.export_formats); 
end

function GenerateFOEOverviewFig(obj,ds_key )
    
    ds = obj.data_sources(ds_key);
    
    cfg = SequenceLibrary.GetFFExperimentDetails(ds.sequences{1},obj.video_dir);
    baseFileName = cfg.get('baseDumpFrameFileName');
    if ~exist(sprintf(baseFileName,ds.straight1),'file')
        reader = VideoReader(cfg.get('inputVideoFileName'));

        I1_straight = read(reader, ds.straight1);
        I2_straight = read(reader, ds.straight2);
        
        I1_rightview = read(reader, ds.rightview1);
        I2_rightview = read(reader, ds.rightview2);
        
    else

        I1_straight = imread(sprintf(baseFileName, ds.straight1)); 
        I2_straight = imread(sprintf(baseFileName, ds.straight2));
        
        I1_rightview = imread(sprintf(baseFileName, ds.rightview1));
        I2_rightview = imread(sprintf(baseFileName, ds.rightview2)); 

    end
 
    vidFile = cfg.get('inputVideoFileName');
    mat = matfile([vidFile(1:end-4) 'fpstereo.mat']);
    sd = mat.seqdata;
    
    OFEstimator = CumulativeLKEstimator(sd,cfg);
    foeFinder = FOEFinder(sd, cfg); 

    [OF_straight_X,OF_straight_Y,~,~] = OFEstimator.estimateBatch(ds.straight1,ds.straight2);
    [foe_straight_x, foe_straight_y] = foeFinder.FOEfromOF(...
        OF_straight_X(1,:,ds.straight2-ds.straight1),...
        OF_straight_Y(1,:,ds.straight2-ds.straight1));

    [OF_right_X,OF_right_Y,~,~] = OFEstimator.estimateBatch(ds.rightview1,ds.rightview2);
    [foe_right_x, foe_right_y] = foeFinder.FOEfromOF(...
        OF_right_X(1,:,ds.rightview2-ds.rightview1),...
        OF_right_Y(1,:,ds.rightview2-ds.rightview1));


    h=figure; %qu(OF_straight_X(1,:,ds.straight2-ds.straight1), OF_straight_Y(1,:,ds.straight2-ds.straight1));
    [FlowX, FlowY,p0_x,p0_y,~,~] = gen_flow_pattern(10,5,0,0,0.5, [0 1 0],0.02);
    quiver(p0_x*5, p0_y*2.5, FlowX(:),FlowY(:),'r','LineWidth',3);
    hold on; 
    scatter(-1, 0,10,'k+','LineWidth',15);
    obj.save_fig(h,['foe_overview_straight1_OF'],ds.export_formats); 
    close(h);
    
    
    h=figure; imshow(I1_straight(ds.hcrop:end-ds.hcrop,ds.wcrop:end-ds.wcrop,:));
    obj.save_fig(h,['foe_overview_straight1'],ds.export_formats); 
    close(h);
    
    h=figure; imshow(I2_straight(ds.hcrop:end-ds.hcrop,ds.wcrop:end-ds.wcrop,:));
    obj.save_fig(h,['foe_overview_straight2'],ds.export_formats); 
    close(h);
    
    h=figure; qu(OF_right_X(1,:,ds.rightview2-ds.rightview1), OF_right_Y(1,:,ds.rightview2-ds.rightview1));
    hold on; 
    scatter(-4.5, 1,10,'k+','LineWidth',15);
    obj.save_fig(h,['foe_overview_rightview1_OF'],ds.export_formats); 
    close(h);
    
    h=figure; imshow(I1_rightview(ds.hcrop:end-ds.hcrop,ds.wcrop:end-ds.wcrop,:));
    obj.save_fig(h,['foe_overview_rightview1'],ds.export_formats); 
    close(h);
    
    h=figure; imshow(I2_rightview(ds.hcrop:end-ds.hcrop,ds.wcrop:end-ds.wcrop,:));
    obj.save_fig(h,['foe_overview_rightview2'],ds.export_formats); 
    close(h);
    
    
    
    
end

function foe = generateFOE(obj,sd,cfg)
    OFEstimator = CumulativeLKEstimator(sd,cfg);
    foeFinder = FOEFinder(sd, cfg); 
    
    startInd = cfg.get('startInd');
    endInd = cfg.get('endInd');

    fprintf('%sEstimating optical flow between pairs of frames...\n',log_line_prefix);
    [OF_X,OF_Y,~,~] = OFEstimator.estimateBatch(startInd, endInd);
    
    fprintf('%sCalculating foe...\n',log_line_prefix);

    foe = inf(endInd-startInd+1, size(OF_X,3), 2);
    for i = 1:endInd-startInd
        if mod(i,50) == 0                    
            fprintf('%sCalculating FOE for frame %d\n',log_line_prefix,i + startInd-1);
        end
        for j = 1:size(OF_X,3)
            [foe_x, foe_y] = foeFinder.FOEfromOF(OF_X(i,:,j),OF_Y(i,:,j));
            foe(i,j,:)  = [foe_x/sd.num_x_cells,foe_y/sd.num_y_cells];                    
        end
    end

end

function epipole = generateEpipole(obj,sd,cfg)
    firstImgNum = cfg.get('startInd');
    lastImgNum  = cfg.get('endInd');

    baseFileName = cfg.get('baseDumpFrameFileName');
    if ~exist(sprintf(baseFileName,firstImgNum),'file')
        reader = VideoReader(cfg.get('inputVideoFileName'));
        sz = size(rgb2gray(read(reader, firstImgNum)));
    else
        sz = size(rgb2gray(imread(sprintf(baseFileName, firstImgNum))));
    end

    fprintf('%sGetting epipole.. \n',log_line_prefix);

    [isin , epipole] = cellfun(@isEpipoleInImage, ...
        sd.Fundamental(firstImgNum:lastImgNum,:), repmat({sz},[lastImgNum-firstImgNum+1 size(sd.Fundamental,2)]),...
        'UniformOutput',false);

    epipole = cell2mat(epipole);
    epipole = cat(3,epipole(:,1:2:end), epipole(:,2:2:end));

    %change units to percent of the image size
    epipole(:,:,1) = epipole(:,:,1) / sz(2);
    epipole(:,:,2) = epipole(:,:,2) / sz(1);

    invalid = repmat(~cell2mat(isin),[1 1 2]) & epipole == 0;
    epipole(invalid) = nan;
end

function GenerateAllFigures(obj)
    close all
    warning ('off', 'images:initSize:adjustingMag');

%     obj.GenerateFundamentalMatDecay('Fmat_decay');
%     obj.GenerateFOEOverviewFig('FOE_overview')
%      obj.GenerateEpipoleSmoothFig('Epipole_smoothness'    );
    obj.GenerateFOESmoothFig('FOE_smoothness');
end

    
    
end

end

