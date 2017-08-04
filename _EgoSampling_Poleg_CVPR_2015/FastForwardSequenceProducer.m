classdef FastForwardSequenceProducer < SequenceProducer
    
    properties
%         OF_X;
%         OF_Y;
        OF_ind_source;
        OF_ind_dest;
        Frame_selector;
        Shakeness_cost;
        Forwardness_cost;
        Velocity_cost;
        Appearance_cost;
        Total_cost;
        
        Higher_order_forwardness_cost;
        Higher_order_shakeness_cost;
        gaze_frames;
        non_walk;

        ResultsMetaData ;
    end
    
    methods
        function obj = FastForwardSequenceProducer(sd, cfg)
            obj = obj@SequenceProducer(sd, cfg);
%             obj.OF_X = [];
%             obj.OF_Y = [];
            obj.OF_ind_source = [];
            obj.OF_ind_dest = [];
            obj.Shakeness_cost = [];
            obj.Forwardness_cost =[];
            obj.Velocity_cost = [];
            obj.Appearance_cost = [];
            obj.Total_cost = [];
            obj.gaze_frames = [];
            obj.non_walk = [];
            
            obj.Higher_order_shakeness_cost = [];
            obj.Higher_order_forwardness_cost = [];
            
            obj.ResultsMetaData = struct();
            
            obj.OF_ind_source = 0; obj.OF_ind_dest = 0;
            if obj.cfg.get('endInd') > size(obj.sd.CDC_Raw_X,1)+ obj.sd.StartFrame-1
                obj.cfg.set('endInd', size(obj.sd.CDC_Raw_X,1) + obj.sd.StartFrame-1)
            end
            
            switch obj.cfg.get('FrameSelector')
                case 'DynamicProgramming'
                    obj.Frame_selector = DynamicProgrammingFrameSelector(obj.cfg);
                    obj.cfg.set('UseHigherOrder',true);
                case 'ShortestPath'
                    obj.Frame_selector = ShortestPathFrameSelector(obj.cfg);
                case 'Naive'
                    obj.Frame_selector = NaiveFrameSelector(obj.cfg);
                    % Cripple all the OF and other estimators
                    obj.cfg.set('OFEstimator','None');
                    obj.cfg.set('VelocityCostFunction','None');
                    obj.cfg.set('AppearanceCostFunction','None');
                    obj.cfg.set('ShakenessCostFunction','None');
                    obj.cfg.set('ForwardnessCostFunction','None');
                    
                otherwise
                    error('Unknown ''frame selector'' value "%s"',obj.cfg.get('FrameSelector'));
            end

        end
        
        
        function PreProcess(obj)
%                 
%             startInd = obj.cfg.get('startInd');
%             endInd = obj.cfg.get('endInd');
%             
%             blocks = obj.sd.num_x_cells*obj.sd.num_y_cells;
%             rx = obj.sd.CDC_Raw_X;
% 
%             if obj.cfg.get('PreProcessFilter_RemoveGaze') == 1
%                 ry = obj.sd.CDC_Raw_Y;
%                 sx = obj.sd.CDC_Smoothed_X;
%                 sy = obj.sd.CDC_Smoothed_Y;
%                 
%                 dY = abs(ry-sy);
%                 dX = abs(rx-sx);
% 
%                 erode_kernel = strel('line',10,90);
% 
%                 gaze_dist_threshold = obj.cfg.get('gazeRawSmoothDist'); 
%                 gaze_min_blocks = obj.cfg.get('gazeMinNumBlocks')*blocks;
% 
%                 % right-left gaze
%                 dX(dX > gaze_dist_threshold) = 0;
%                 dX(dX > 0)   = 1;
%                 dX           = sum(dX,2);
%                 dX(dX < gaze_min_blocks)  = 0;
%                 dX(dX > 0)   = 1;
%                 dX           = imerode(dX,erode_kernel);
% 
%                 % up-down gaze
%                 dY(dY > gaze_dist_threshold) = 0;
%                 dY(dY > 0)   = 1;
%                 dY           = sum(dY,2);
%                 dY(dY < gaze_min_blocks)  = 0;
%                 dY(dY > 0)   = 1;
%                 dY           = imerode(dY,erode_kernel );
% 
%                 obj.gaze_frames = dX.*dY;
%                 
%             end
%             
%             if obj.cfg.get('PreProcessFilter_RemoveNoneWalking') == 1
%                 min_frames_non_walking = 100;
%                 max_frames_non_walking = 1000;
%                 non_walk_frames = zeros(size(rx,1));
%                 for i = startInd:endInd
%                     from = startInd+i+min_frames_non_walking;
%                     to = startInd+i+max_frames_non_walking;
%                     diff = sum(abs(rx(from:to,:) - rx(startInd+i-1,:)),2);
%                     non_walk_i = find(diff < 0.5);
%                     if size(non_walk_i) > 0
%                         non_walk_frames(i+startInd-1:i+startInd+non_walk_i(end)) = 1;
% %                         i = i+non_walk(end);
%                     end
%                 end
%                 obj.non_walk = non_walk_frames;
%             end
        end;
        
        
        
        function PrepareCostTerms(obj)
            
%% prepare functions
            %OF estimator
            switch obj.cfg.get('OFEstimator')
                case 'Cumulative'
                    OFEstimator = CumulativeLKEstimator(obj.sd,obj.cfg);
                case 'None'
                    % Cripple the optical flow estimator 
                    OFEstimator = OpticalFlowEstimator(obj.sd,obj.cfg); 
                otherwise
                    error('Unknown ''OFEstimator'' value "%s"',obj.cfg.get('OFEstimator'));
            end

            %shakeness cost function
            switch obj.cfg.get('ShakenessCostFunction')
                case 'FOE'
                    shakenessCostEstimator = FOEDistanceCost(obj.sd,obj.cfg);
                case 'Epipole.vs.FOE'
                    shakenessCostEstimator = EpipoleFOEDistanceCost(obj.sd,obj.cfg);
                case 'AngleDiff'
                    shakenessCostEstimator = AngleDiffrenceCost(obj.sd,obj.cfg,80);
                case 'FFT'
                    shakenessCostEstimator = FFTCost(obj.sd,obj.cfg);
                case 'None'
                    shakenessCostEstimator = ZeroCost(obj.sd,obj.cfg);
                otherwise
                    error('Unknown ''ShakenessCostFunction'' value "%s"',obj.cfg.get('ShakenessCostFunction'));
            end
            
            %forwardness cost function
            switch obj.cfg.get('ForwardnessCostFunction')
                case 'FOE'
                    forwardnessCostEstimator = FOEDistanceCost(obj.sd,obj.cfg);
                case 'None'
                    forwardnessCostEstimator = ZeroCost(obj.sd,obj.cfg);
                otherwise
                    error('Unknown ''ForwardnessCostFunction'' value "%s"',obj.cfg.get('ForwardnessCostFunction'));
            end
            

            %velocity cost function
            switch obj.cfg.get('VelocityCostFunction')
                case 'OFMagnitudeCost'
                    velocityCostEstimator = OFMagnitudeCost(obj.sd,obj.cfg);
                case 'None'
                    velocityCostEstimator = ZeroCost(obj.sd,obj.cfg);                        
                otherwise
                    error('Unknown ''VelocityCostFunction'' value "%s"',obj.cfg.get('VelocityCostFunction'));
            end
            
            %appearance cost function
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
                        
            obj.Shakeness_cost     = zeros(endInd-startInd,tempDist);
            obj.Velocity_cost         = zeros(endInd-startInd,tempDist);
            obj.Appearance_cost   = zeros(endInd-startInd,tempDist);
            obj.Forwardness_cost = zeros(endInd-startInd,tempDist);
            
            if obj.cfg.get('UseHigherOrder')
                obj.Higher_order_shakeness_cost = zeros(endInd-startInd,tempDist,tempDist);
                if strcmp(obj.cfg.get('ForwardnessCostFunction'),'FOE')
                    obj.Higher_order_forwardness_cost = zeros(endInd-startInd,tempDist,tempDist);
                end
            end
            
            for batch = 1:numberOfBatches
                
                startBatch = startInd + batchSize*(batch-1);
                endBatch = min(startBatch + batchSize-1, endInd);
                fprintf('\n\n%sStarting batch No. %d from frame %d to frame %d\n\n',log_line_prefix, batch, startBatch, endBatch);

                fprintf('%sEstimating optical flow between pairs of frames...\n',log_line_prefix);
                [OF_X,OF_Y,OF_ind_source_batch,OF_ind_dest_batch] = OFEstimator.estimateBatch(startBatch, endBatch);

                fprintf('%sCalculating shakness cost...\n',log_line_prefix);
                if obj.cfg.get('UseHigherOrder')
                    [Higher_order_shakeness_cost_batch] = shakenessCostEstimator.calculateTriFrameCostBatch (OF_X, OF_Y, startBatch, endBatch);                
                    if strcmp(obj.cfg.get('ForwardnessCostFunction'),'FOE')
                        [Higher_order_forwardness_cost_batch] = forwardnessCostEstimator.calculateTriFrameCostBatch (OF_X, OF_Y, startBatch, endBatch);                
                    end
                end
                [Shakeness_cost_batch] = shakenessCostEstimator.calculateCostBatch (OF_X, OF_Y, startBatch, endBatch);
                
                fprintf('%sCalculating forwardness cost...\n',log_line_prefix);
                [Forwardness_cost_batch] = forwardnessCostEstimator.calculateCostBatch (OF_X, OF_Y, startBatch, endBatch);
                
                fprintf('%sCalculating velocity cost...\n',log_line_prefix);
                [Velocity_cost_batch] = velocityCostEstimator.calculateCostBatch(OF_X, OF_Y,startBatch, endBatch);

                fprintf('%sCalculating appearance cost...\n',log_line_prefix);
                [Appearance_cost_batch] = appearanceCostEstimator.calculateCostBatch(OF_X, OF_Y, startBatch, endBatch);

                
                numSparseInd = numel(OF_ind_source_batch);
                obj.OF_ind_source(lastSparseInd : lastSparseInd + numSparseInd-1) = OF_ind_source_batch + startBatch-1;
                obj.OF_ind_dest   (lastSparseInd : lastSparseInd + numSparseInd-1) = OF_ind_dest_batch + startBatch-1;
                lastSparseInd = lastSparseInd + numSparseInd;

                obj.Shakeness_cost    (startBatch-startInd+1 : endBatch-startInd+1, :) = Shakeness_cost_batch;
                obj.Velocity_cost        (startBatch-startInd+1 : endBatch-startInd+1, :) = Velocity_cost_batch;
                obj.Appearance_cost  (startBatch-startInd+1 : endBatch-startInd+1, :) = Appearance_cost_batch;
                obj.Forwardness_cost(startBatch-startInd+1 : endBatch-startInd+1, :) = Forwardness_cost_batch;

                if obj.cfg.get('UseHigherOrder')
                    obj.Higher_order_shakeness_cost(startBatch-startInd+1 : endBatch-startInd+1, :, :) = Higher_order_shakeness_cost_batch;
                    if strcmp(obj.cfg.get('ForwardnessCostFunction'),'FOE')
                        obj. Higher_order_forwardness_cost(startBatch-startInd+1 : endBatch-startInd+1, :, :) = Higher_order_forwardness_cost_batch;
                    end
                end
            end
            
        end
        
        
        function Solve(obj)
            alpha = obj.cfg.get('ShaknessTermWeight');
            beta  = obj.cfg.get('VelocityTermWeight');
            gama  = obj.cfg.get('AppearanceTermWeight');
            delta = obj.cfg.get('ForwardnessTermWeight');
            eta    = obj.cfg.get('HighOrderTermWeight');
            
%             tempShakeness = obj.Shakeness_cost;
%             tempShakeness(obj.Shakeness_cost==inf) = obj.cfg.get('ShaknessTermInvalidValue');
%             obj.Velocity_cost      (obj.Velocity_cost       == inf) = 1e6;
%             obj.Appearance_cost (obj.Appearance_cost == inf) = 1e6;
            
            switch obj.cfg.get('CostWeightMethod')
                case 'Sum'
                    Sterm=(alpha * obj.Shakeness_cost); 
%                     Sterm(obj.Shakeness_cost == inf)= obj.cfg.get('ShaknessTermInvalidValue');
                    Vterm=(beta * obj.Velocity_cost);
                    Aterm=(gama * obj.Appearance_cost);
                    Fterm=(delta * obj.Forwardness_cost);
                    if obj.cfg.get('UseHigherOrder') 
                        Hterm = (eta * obj.Higher_order_shakeness_cost);
                    end
                    if obj.cfg.get('ForwardnessMergeWithShaknessCoef')>0
                        Sterm(obj.Shakeness_cost == inf) = Fterm(obj.Shakeness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShaknessCoef');
                        obj.Total_cost = Sterm+Vterm+Aterm;
                        if obj.cfg.get('UseHigherOrder') 
                            Hterm(obj.Higher_order_shakeness_cost == inf) = ...
                                obj.Higher_order_forwardness_cost(obj.Higher_order_shakeness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShaknessCoef') *eta;
                        end
                        
                    else                    
                        Sterm(obj.Shakeness_cost == inf)= obj.cfg.get('ShaknessTermInvalidValue');
                        obj.Total_cost = Sterm+Vterm+Aterm+Fterm;
                    end
                
                case 'SumSquares'
                    Sterm=(alpha * (obj.Shakeness_cost).^2);
                    Sterm(obj.Shakeness_cost == inf)= obj.cfg.get('ShaknessTermInvalidValue');
                    Vterm=(beta * (obj.Velocity_cost).^2);
                    Aterm=(gama * (obj.Appearance_cost).^2);
                    Fterm=(delta * (obj.Forwardness_cost).^2);
                    obj.Total_cost = Sterm+Vterm+Aterm+Fterm;
                
                case 'SumOfLogs'
                    Sterm=(alpha * log(obj.Shakeness_cost+1));
                    Sterm(obj.Shakeness_cost == inf)= obj.cfg.get('ShaknessTermInvalidValue');
                    Vterm=(beta * log(obj.Velocity_cost+1));
                    Aterm=(gama * log(obj.Appearance_cost+1));
                    Fterm=(delta * log(obj.Forwardness_cost+1));
                    obj.Total_cost = Sterm+Vterm+Aterm+Fterm;
                
                case 'Multiplied'
                    Sterm=(alpha * obj.Shakeness_cost); 
%                     Sterm(obj.Shakeness_cost == inf)= obj.cfg.get('ShaknessTermInvalidValue');
                    Vterm=(beta * obj.Velocity_cost );
                    Aterm=(gama * obj.Appearance_cost );
                    Fterm=(delta * obj.Forwardness_cost);
                    if obj.cfg.get('UseHigherOrder') 
                        Hterm = (eta * obj.Higher_order_shakeness_cost);
                    end
                    if obj.cfg.get('ForwardnessMergeWithShaknessCoef')>0
                        Sterm(obj.Shakeness_cost == inf) = Fterm(obj.Shakeness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShaknessCoef');
                        obj.Total_cost = Vterm.*(Sterm+Aterm);
                        if obj.cfg.get('UseHigherOrder') 
                            Hterm(obj.Higher_order_shakeness_cost == inf) = ...
                                obj.Higher_order_forwardness_cost(obj.Higher_order_shakeness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShaknessCoef') *eta;
                        end                        
                    else                    
                        Sterm(obj.Shakeness_cost == inf)= obj.cfg.get('ShaknessTermInvalidValue');
                        obj.Total_cost = Vterm.*(Sterm+Aterm+Fterm) ;
                    end
                
                case 'Binarized' 
                    Sterm=alpha * (obj.Shakeness_cost>obj.cfg.get('ShaknessTermBinaryThreshold'));
                    Sterm(obj.Shakeness_cost == inf)= obj.cfg.get('ShaknessTermInvalidValue');
                    Vterm=beta * (obj.Velocity_cost>obj.cfg.get('VelocityTermBinaryThreshold'));
                    Aterm=gama * (obj.Appearance_cost>obj.cfg.get('AppearanceTermBinaryThreshold'));
                    Fterm=(delta * obj.Forwardness_cost);
                    obj.Total_cost = Sterm+Vterm+Aterm+Fterm;
                
                case 'Clamped'
                    Sterm=obj.Shakeness_cost;
                    Sterm(obj.Shakeness_cost>obj.cfg.get('ShaknessTermBinaryThreshold'))=obj.cfg.get('ShakenessTermClampedValue');
                    Sterm(obj.Shakeness_cost == inf)= obj.cfg.get('ShaknessTermInvalidValue');
                    Sterm=alpha * Sterm;
                    
                    Vterm=obj.Velocity_cost;
                    Vterm(obj.Velocity_cost>obj.cfg.get('VelocityTermBinaryThreshold'))=obj.cfg.get('VelocityTermClampedValue');
                    Vterm=beta * Vterm;
                    
                    Aterm=obj.Appearance_cost;
                    Aterm(obj.Appearance_cost>obj.cfg.get('AppearanceTermBinaryThreshold'))=obj.cfg.get('AppearanceTermClampedValue');
                    Aterm=gama * Aterm;

                    Fterm=obj.Forwardness_cost;
                    Fterm(obj.Forwardness_cost>obj.cfg.get('ForwardnessTermBinaryThreshold'))=obj.cfg.get('ForwardnessTermClampedValue');
                    Fterm=delta * Fterm;
                    obj.Total_cost = Sterm+Vterm+Aterm+Fterm;
                otherwise 
                    error('Unknown ''CostWeightMethod'' value "%s"',obj.cfg.get('CostWeightMethod'));
            end

        
            
            fprintf('%sSelecting frames for output...\n',log_line_prefix);
            if strcmp(obj.cfg.get('FrameSelector'),'DynamicProgramming')
                frame_indices = obj.Frame_selector.selectFrames (...
                    obj.Total_cost, Hterm);
            else
                if obj.cfg.get('UseHigherOrder')
                    frame_indices = obj.Frame_selector.selectFramesThirdDegree (...
                        obj.Total_cost, Hterm);
                else
                    frame_indices = obj.Frame_selector.selectFrames (...
                        obj.Total_cost);
                end
            end
            frame_indices = frame_indices + obj.cfg.get('startInd')-1;
            if size(frame_indices,2)>1
                frame_indices=frame_indices';
            end

            obj.Frame_indices = frame_indices;
            
            fprintf('%sSelected %d frames: ',log_line_prefix,numel(frame_indices));
            for i=1:numel(frame_indices)
                fprintf('%d,',frame_indices(i));
                if mod(i,100)==0
                    fprintf('\n');
                end
            end
            fprintf('\n');
            
%             if obj.cfg.get('PreProcessFilter_RemoveNoneWalking') == 1
%                 fprintf('removing non walking frames...\n');
%                 non_walking_frames = find(obj.non_walk);
%                 for i=1:numel(non_walking_frames )
%                     fprintf('%d,',non_walking_frames (i));
%                     if mod(i,100)==0
%                         fprintf('\n');
%                     end
%                 end
%                 temp = zeros(size(obj.non_walk));
%                 temp(frame_indices) = 1;
%                 temp = temp*obj.non_walk;
%                 frame_indices = find(temp);
%             end
%             
%             if obj.cfg.get('PreProcessFilter_RemoveGaze') == 1
%                 fprintf('removing gaze frames...\n');
%                 gaze = find(obj.gaze_frames);
%                 for i=1:numel(gaze )
%                     fprintf('%d,',gaze (i));
%                     if mod(i,100)==0
%                         fprintf('\n');
%                     end
%                 end
%                 temp = zeros(size(obj.gaze_frames));
%                 temp(frame_indices) = 1;
%                 temp = temp*obj.gaze_frames;
%                 frame_indices = find(temp);
%             end
%             
            costcols = imfilter(frame_indices,[-1 1]');
            fprintf('%sVisualizing Cost Terms..\n',log_line_prefix);
            startInd = obj.cfg.get('startInd');
            endInd = obj.cfg.get('endInd');
            tempDist = obj.cfg.get('maxTemporalDist');
            
            avgskip = floor(mean(costcols(1:end-1)));
            medskip = median(costcols(1:end-1));
            
            obj.ResultsMetaData.avarage_skip = avgskip;
            obj.ResultsMetaData.median_skip = medskip;
            obj.ResultsMetaData.frames = frame_indices;
            
            figure; 
            subplot(2,2,1); imagesc(1:tempDist,startInd:endInd-1,Sterm); title('Shakeness Cost'); colorbar; ylabel('Frame Num');  xlabel('Jump Dist');
            hold on;
            scatter(costcols(1:end-1),frame_indices(1:end-1),'y','LineWidth',2);
            
            subplot(2,2,2); imagesc(1:tempDist,startInd:endInd-1,Vterm); title('Velocity Cost'); colorbar; ylabel('Frame Num');xlabel('Jump Dist');
            hold on;
            scatter(costcols(1:end-1),frame_indices(1:end-1),'y','LineWidth',2);
            
            subplot(2,2,3); imagesc(1:tempDist,startInd:endInd-1,Aterm); title('Appearance Cost'); colorbar; ylabel('Frame Num');xlabel('Jump Dist');
            hold on;
            scatter(costcols(1:end-1),frame_indices(1:end-1),'y','LineWidth',2);
            
            subplot(2,2,4); imagesc(1:tempDist,startInd:endInd-1,obj.Total_cost); title('Total Cost'); colorbar; ylabel('Frame Num');xlabel('Jump Dist');
            hold on;
            scatter(costcols(1:end-1),frame_indices(1:end-1),'y','LineWidth',2);
            
            maintitle=sprintf('Frame Selection Over Cost Terms. Avg skip=%d frames. Median skip=%.1f frames\n',avgskip,medskip);
%             suplabel(maintitle  ,'y');
            
            selectedFrameCostInds = sub2ind(size(obj.Total_cost),frame_indices(1:end-1)-startInd+1,costcols(1:end-1));
            
            figure; plot(frame_indices(1:end-1),Sterm(selectedFrameCostInds),...
                              frame_indices(1:end-1),Vterm(selectedFrameCostInds),...
                              frame_indices(1:end-1),Aterm(selectedFrameCostInds),...
                              frame_indices(1:end-1),obj.Total_cost(selectedFrameCostInds),'LineWidth',2);
             xlabel('Frame # In Orig Video');
             ylabel('Cost');
             title(maintitle,'Interpreter','None');
             legend('Shakeness','Velocity','Appearance','Total');
          
            fprintf('%sAverage skip=%d frames. Median skip=%.1f frames\n',log_line_prefix,avgskip,medskip);
            
            

        end
        
        function ShowSelectedFramesFOE(obj)

             figure;
             %FOECostEstimator = FOEDistanceCost(obj.sd,obj.cfg);
             EpipoleCostEstimator = EpipoleFOEDistanceCost(obj.sd,obj.cfg);
            
            baseFileName = obj.cfg.get('baseDumpFrameFileName');
            firstImgNum = obj.cfg.get('startInd');
            sz = size(rgb2gray(imread(sprintf(baseFileName, firstImgNum))));
  
%              foeLocations = nan(numel(frame_indices(1:end-1)),2);
%              epipoleLocations = nan(numel(frame_indices(1:end-1)),2);
%              for i=1:numel(frame_indices(1:end-1))
%                  foeLocations(i,:) = FOECostEstimator.getFoe(frame_indices(i),frame_indices(i+1));
%                  epipoleLocations(i,:) = EpipoleCostEstimator.getEpipole(frame_indices(i),frame_indices(i+1),sz);
%              end
%              o=zeros(size(foeLocations,1),2);
%              xlabel('Frame#'); ylabel('X coord'); zlabel('Y coord');            
%              scatter3(frame_indices(1:end-1),o(:,1),o(:,2),'b');            
%              hold on; scatter3(frame_indices(1:end-1),epipoleLocations(:,1),epipoleLocations(:,2),'g');
%              zlim([-2  2]); ylim([-2 2]);
%              hold on; scatter3(frame_indices(1:end-1),foeLocations(:,1),foeLocations(:,2),'r');
%              epipole_variance = nanvar(epipoleLocations)
%              num_of_nans = sum(isnan(epipoleLocations(:)))
             
             %figure;
%              frame_indices = obj.cfg.get('startInd'):10:obj.cfg.get('endInd');   
            % foeLocations = nan(numel(obj.Frame_indices(1:end-1)),2);
             epipoleLocations = nan(numel(obj.Frame_indices(1:end-1)),2);
             for i=1:numel(obj.Frame_indices(1:end-1))
                % foeLocations(i,:) = FOECostEstimator.getFoe(obj.Frame_indices(i),obj.Frame_indices(i+1));
                 epipoleLocations(i,:) = EpipoleCostEstimator.getEpipole(obj.Frame_indices(i),obj.Frame_indices(i+1),sz);
%                  if max(abs(foeLocations(i,:)) ) > .5 || isnan(epipoleLocations(i,1) )
%                      %foeLocations(i,:) = nan;
%                      epipoleLocations(i,:) = nan;
%                  end
             end
             o=zeros(size(epipoleLocations,1),2);
             xlabel('Frame#'); ylabel('X coord'); zlabel('Y coord');            
             plot3(obj.Frame_indices(1:end-1)',o(:,1),o(:,2),'b','LineWidth',2);            
             hold on; scatter3(obj.Frame_indices(1:end-1)',epipoleLocations(:,1),epipoleLocations(:,2),'g','LineWidth',2);
             %hold on; scatter3(frame_indices(1:end-1)',foeLocations(:,1),foeLocations(:,2),'r');
             naive_epipole_variance = nanvar(epipoleLocations);
             num_of_nans_naive = sum(isnan(epipoleLocations(:)));
             
            
        end
 
    end
end