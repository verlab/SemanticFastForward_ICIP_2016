classdef StereoSequenceProducer < SequenceProducer
    
properties
%     OF_X;
%     OF_Y;
    OF_ind_source;
    OF_ind_dest;
    stereo_cost;
    Velocity_cost;
    Appearance_cost;
    Total_cost;
    pairs;
    Frame_selector;
end

methods

function obj = StereoSequenceProducer (sd, cfg)
    obj = obj@SequenceProducer(sd, cfg);
%         obj.OF_X = [];
%         obj.OF_Y = [];
    obj.OF_ind_source = [];
    obj.OF_ind_dest = [];
    obj.stereo_cost = [];
    obj.Velocity_cost = [];
    obj.Appearance_cost = [];
    obj.Total_cost = [];
    obj.pairs = [];

    obj.OF_ind_source = 0; obj.OF_ind_dest = 0;
    if obj.cfg.get('endInd') > size(obj.sd.CDC_Raw_X,1)+ obj.sd.StartFrame-1
        obj.cfg.set('endInd', size(obj.sd.CDC_Raw_X,1) + obj.sd.StartFrame-1)
    end

    spp = StereoPairsPicker(obj.sd, obj.cfg);
    obj.pairs = spp.findPairs();

    switch obj.cfg.get('FrameSelector')
        case 'ShortestPath'
            obj.Frame_selector = ShortestPathFrameSelector(obj.cfg);
        case 'Naive'
            obj.Frame_selector = NaiveFrameSelector(obj.cfg);
            % Cripple all the OF and other estimators, except the stereo
            % estimator
            obj.cfg.set('OFEstimator','None');
            obj.cfg.set('VelocityCostFunction','None');
            obj.cfg.set('AppearanceCostFunction','None');
%                     obj.cfg.set('StereoCostFunction','None');

        otherwise
            error('Unknown ''frame selector'' value "%s"',obj.cfg.get('frame_selector'));
    end

end

function PreProcess(obj)
    warning('no preprocessing implemented in stereo sequence exporter');
end

function PrepareCostTerms(obj)
%% prepare functions
        
    switch obj.cfg.get('OFEstimator')
        case 'Cumulative'
            OFEstimator = CumulativeLKEstimator(obj.sd,obj.cfg);
        case 'None'
            % Cripple the optical flow estimator 
            OFEstimator = OpticalFlowEstimator(obj.sd,obj.cfg); 
        otherwise
            error('Unknown ''OFEstimator'' value "%s"',obj.cfg.get('OFEstimator'));
    end

    switch obj.cfg.get('StereoCostFunction')
        case 'OFPeaks'
            StereoCostEstimator = OFPeaksCost(obj.sd,obj.cfg);
%                case 'None'
%                     StereoCostEstimator = StereoZeroCost(obj.sd,obj.cfg,obj.pairs);
        otherwise
            error('Unknown ''StereoCostEstimator'' value "%s"',obj.cfg.get('StereoCostEstimator '));
    end
    
    switch obj.cfg.get('VelocityCostFunction')
        case 'OFMagnitudeCost'
            velocityCostEstimator = OFMagnitudeCost(obj.sd,obj.cfg);
        case 'None'
            velocityCostEstimator = ZeroCost(obj.sd,obj.cfg);                        
        otherwise
            error('Unknown ''VelocityCostFunction'' value "%s"',obj.cfg.get('VelocityCostFunction'));
    end


    switch obj.cfg.get('AppearanceCostFunction')
        case 'ColorHistogram'
            appearanceCostEstimator = ColorHistogramCost(obj.sd,obj.cfg);
        case 'None'
            appearanceCostEstimator = ZeroCost(obj.sd,obj.cfg);                        
        otherwise
            error('Unknown ''AppearanceCostFunction'' value "%s"',obj.cfg.get('AppearanceCostFunction'));
    end

 %% calculate batches of cost functions
 
    startInd = obj.cfg.get('startInd');
    endInd = obj.cfg.get('endInd');
    tempDist = obj.cfg.get('maxTemporalDist');

    lastSparseInd =1;
    batchSize = min(obj.cfg.get('maxBatchMemory')/tempDist, endInd-startInd);
    numberOfBatches = ceil((endInd-startInd)/batchSize);

    obj.stereo_cost         = zeros(endInd-startInd,tempDist);
    obj.Velocity_cost       = zeros(endInd-startInd,tempDist);
    obj.Appearance_cost = zeros(endInd-startInd,tempDist);

    for batch = 1:numberOfBatches

        startBatch = startInd + batchSize*(batch-1);
        endBatch = min(startBatch + batchSize-1, endInd);
        fprintf('\n\n%sStarting batch No. %d from frame %d to frame %d\n\n',log_line_prefix, batch, startBatch, endBatch);


        fprintf('%sEstimating optical flow between pairs of frames...\n',log_line_prefix);
        [OF_X,OF_Y,OF_ind_source_batch,OF_ind_dest_batch] = OFEstimator.estimateBatch(startBatch, endBatch);


        fprintf('%sCalculating stereo cost...\n',log_line_prefix);
        [Stereo_cost_batch] = StereoCostEstimator.calculateCostBatch (OF_X, OF_Y, startBatch, endBatch, obj.pairs);

        fprintf('%sCalculating velocity cost...\n',log_line_prefix);
        [Velocity_cost_batch] = velocityCostEstimator.calculateCostBatch(OF_X, OF_Y,startBatch, endBatch);

        fprintf('%sCalculating appearance cost...\n',log_line_prefix);
        [Appearance_cost_batch] = appearanceCostEstimator.calculateCostBatch(OF_X, OF_Y, startBatch, endBatch);
        %if the first version takes too long it can be switched to
        %the following line, to read appearance cost only for the
        %relevant frames
%     [Appearance_cost_batch] = appearanceCostEstimator.calculateCostBatch(OF_X, OF_Y,  obj.pairs(:,1), startBatch, endBatch);


        numSparseInd = numel(OF_ind_source_batch);
        obj.OF_ind_source(lastSparseInd : lastSparseInd + numSparseInd-1) = OF_ind_source_batch + startBatch-1;
        obj.OF_ind_dest   (lastSparseInd : lastSparseInd + numSparseInd-1) = OF_ind_dest_batch + startBatch-1;
        lastSparseInd = lastSparseInd + numSparseInd;

        obj.stereo_cost         (startBatch-startInd+1 : endBatch-startInd+1, :) = Stereo_cost_batch;
        obj.Velocity_cost       (startBatch-startInd+1 : endBatch-startInd+1, :) = Velocity_cost_batch;
        obj.Appearance_cost (startBatch-startInd+1 : endBatch-startInd+1, :) = Appearance_cost_batch;

    end
end

function Solve(obj)

    alpha = obj.cfg.get('StereoTermWeight');
    beta  = obj.cfg.get('VelocityTermWeight');
    gama  = obj.cfg.get('AppearanceTermWeight');

    obj.stereo_cost  (obj.stereo_cost    == inf) = obj.cfg.get('StereoTermInvalidValue');

    
    switch obj.cfg.get('CostWeightMethod')
        case 'Sum'
            Sterm=(alpha * obj.stereo_cost); 
            Vterm=(beta * obj.Velocity_cost);
            Aterm=(gama * obj.Appearance_cost);
            obj.Total_cost = Sterm+Vterm+Aterm;

        case 'SumSquares'
            Sterm=(alpha * (obj.stereo_cost).^2);
            Vterm=(beta * (obj.Velocity_cost).^2);
            Aterm=(gama * (obj.Appearance_cost).^2);
            obj.Total_cost = Sterm+Vterm+Aterm;

        case 'SumOfLogs'
            Sterm=(alpha * log(obj.stereo_cost+1));
            Vterm=(beta * log(obj.Velocity_cost+1));
            Aterm=(gama * log(obj.Appearance_cost+1));
            obj.Total_cost = Sterm+Vterm+Aterm;

        case 'Multiplied'
            Sterm=(alpha * obj.stereo_cost); 
            Vterm=(beta * obj.Velocity_cost );
            Aterm=(gama * obj.Appearance_cost );
            obj.Total_cost = Vterm.*(Sterm+Aterm);% + (Sterm-min(Sterm(:)));

        case 'Binarized' 
            Sterm=alpha * (obj.stereo_cost>obj.cfg.get('ShaknessTermBinaryThreshold'));
            Vterm=beta * (obj.Velocity_cost>obj.cfg.get('VelocityTermBinaryThreshold'));
            Aterm=gama * (obj.Appearance_cost>obj.cfg.get('AppearanceTermBinaryThreshold'));
            obj.Total_cost = Sterm+Vterm+Aterm;

        case 'Clamped'
            Sterm=obj.stereo_cost;
            Sterm(obj.stereo_cost>obj.cfg.get('StereoTermBinaryThreshold'))=obj.cfg.get('StereoTermClampedValue');
            Sterm=alpha * Sterm;

            Vterm=obj.Velocity_cost;
            Vterm(obj.Velocity_cost>obj.cfg.get('VelocityTermBinaryThreshold'))=obj.cfg.get('VelocityTermClampedValue');
            Vterm=beta * Vterm;

            Aterm=obj.Appearance_cost;
            Aterm(obj.Appearance_cost>obj.cfg.get('AppearanceTermBinaryThreshold'))=obj.cfg.get('AppearanceTermClampedValue');
            Aterm=gama * Aterm;
            obj.Total_cost = Sterm+Vterm+Aterm;
        otherwise 
            error('Unknown ''CostWeightMethod'' value "%s"',obj.cfg.get('CostWeightMethod'));
    end


    fprintf('%sSelecting frames for output...\n',log_line_prefix);
    frame_indices = obj.Frame_selector.selectFrames (...
        obj.Total_cost);

    frame_indices = frame_indices + obj.cfg.get('startInd')-1;
    if size(frame_indices,2)>1
        frame_indices=frame_indices';
    end

    obj.Frame_indices = frame_indices;

    newPairs = zeros(numel(frame_indices),2);
    fprintf('%sSelected %d pairs: ',log_line_prefix,numel(frame_indices));
    for i=1:numel(frame_indices)
        [~,k] = min(abs(frame_indices(i)-obj.pairs(:,1)));
        fprintf('(%d,%d), ',frame_indices(i), obj.pairs(k,2));
        newPairs(i,:) = obj.pairs(k,:);
        if mod(i,100)==0
            fprintf('\n');
        end
    end
    obj.pairs = newPairs;
    fprintf('\n');


    costcols = imfilter(frame_indices,[-1 1]')-1;
    fprintf('%sVisualizing Cost Terms..\n',log_line_prefix);
    startInd = obj.cfg.get('startInd');
    endInd = obj.cfg.get('endInd');
    tempDist = obj.cfg.get('maxTemporalDist');

    avgskip = floor(mean(costcols(1:end-1)));
    medskip = median(costcols(1:end-1));

    figure; 
    subplot(2,2,1); imagesc(1:tempDist,startInd:endInd,Sterm); title('Shakeness Cost'); colorbar; ylabel('Frame Num');  xlabel('Jump Dist');
    hold on;
    scatter(costcols(1:end-1),frame_indices(1:end-1),'y','LineWidth',2);

    subplot(2,2,2); imagesc(1:tempDist,startInd:endInd,Vterm); title('Velocity Cost'); colorbar; ylabel('Frame Num');xlabel('Jump Dist');
    hold on;
    scatter(costcols(1:end-1),frame_indices(1:end-1),'y','LineWidth',2);

    subplot(2,2,3); imagesc(1:tempDist,startInd:endInd,Aterm); title('Appearance Cost'); colorbar; ylabel('Frame Num');xlabel('Jump Dist');
    hold on;
    scatter(costcols(1:end-1),frame_indices(1:end-1),'y','LineWidth',2);

    subplot(2,2,4); imagesc(1:tempDist,startInd:endInd,obj.Total_cost); title('Total Cost'); colorbar; ylabel('Frame Num');xlabel('Jump Dist');
    hold on;
    scatter(costcols(1:end-1),frame_indices(1:end-1),'y','LineWidth',2);

    maintitle=sprintf('Frame Selection Over Cost Terms. Avg skip=%d frames. Median skip=%.1f frames\n',avgskip,medskip);
    suplabel(maintitle  ,'y');

    selectedFrameCostInds = sub2ind(size(obj.Total_cost),frame_indices(1:end-1)-startInd+1,costcols(1:end-1));

    figure; plot(frame_indices(1:end-1),Sterm(selectedFrameCostInds),...
                      frame_indices(1:end-1),Vterm(selectedFrameCostInds),...
                      frame_indices(1:end-1),Aterm(selectedFrameCostInds),...
                      frame_indices(1:end-1),obj.Total_cost(selectedFrameCostInds),'LineWidth',2);
     xlabel('Frame # In Orig Video');
     ylabel('Cost');
     legend('Shakeness','Velocity','Appearance','Total');


%             figure; 
%             imagesc(1:tempDist,startInd:endInd,Sterm); colorbar;  ylabel('Frame Num');  xlabel('Jump Dist'); 
%             title(sprintf('Selected Frames over Shakeness Term (avg skip=%d frames, median skip=%.1f frames)',avgskip,medskip)); 
%             figure; 
%             imagesc(1:tempDist,startInd:endInd,Vterm); colorbar;  ylabel('Frame Num');  xlabel('Jump Dist'); hold on;
%             scatter(costcols(1:end-1),frame_indices(1:end-1)-obj.cfg.get('startInd')+1,'y','LineWidth',2);
%             title(sprintf('Selected Frames over Velocity Term (avg skip=%d frames, median skip=%.1f frames)',avgskip,medskip)); 
%             figure; 
%             imagesc(1:tempDist,startInd:endInd,Aterm); colorbar;  ylabel('Frame Num');  xlabel('Jump Dist'); hold on;
%             scatter(costcols(1:end-1),frame_indices(1:end-1)-obj.cfg.get('startInd')+1,'y','LineWidth',2);
%             title(sprintf('Selected Frames over Appearance Term (avg skip=%d frames, median skip=%.1f frames)',avgskip,medskip)); 
%             figure; 
%             imagesc(1:tempDist,startInd:endInd,obj.Total_cost); colorbar;  ylabel('Frame Num');  xlabel('Jump Dist'); hold on;
%             scatter(costcols(1:end-1),frame_indices(1:end-1)-obj.cfg.get('startInd')+1,'y','LineWidth',2);
%             title(sprintf('Selected Frames over Total Cost Function (avg skip=%d frames, median skip=%.1f frames)',avgskip,medskip)); 

    fprintf('%sAverage skip=%d frames. Median skip=%.1f frames\n',log_line_prefix,avgskip,medskip);



end
 
function ExportVideo(obj)
    vss = VideoSubSampler (obj.sd, obj.cfg);
    fprintf('%sWriting %d stereo pairsto output video ...\n%s\n',log_line_prefix, length(obj.Frame_indices), obj.cfg.get('outputVideoFileName'));
    vss.subSampleStereoVideo(obj.pairs);
    fprintf('%sDone exporting\n',log_line_prefix);
end

end
end