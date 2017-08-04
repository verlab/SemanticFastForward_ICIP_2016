%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   This file is part of SemanticFastForward_ICIP.
%
%    SemanticFastForward_ICIP is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    SemanticFastForward_ICIP is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with SemanticFastForward_ICIP.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Class Name: SemanticFastForward
% 
% This class is an adaptation of the FastForwardSequenceProducer class present
% in the EgoSampling code. It contains the implementation of the SequenceProducer  
% in order to perform the creation of the Semantic Fast-Forward video.
%
% $Date: July 26, 2017
% ________________________________________
classdef SemanticFastForward < SemanticSequenceProducer
    
    properties
        %OF_X;
        %OF_Y;
        OF_ind_source;
        OF_ind_dest;
        Frame_selector;
        Shakiness_cost;
        Forwardness_cost;
        Velocity_cost;
        Appearance_cost;
        Semantic_cost;
        
        Total_cost;
        
        Higher_order_forwardness_cost;
        Higher_order_shakiness_cost;
        gaze_frames;
        non_walk;
        
        ResultsMetaData;
    end
    
    methods
        function obj = SemanticFastForward(sd, cfg, SemanticData, use_range, store_results)
            obj = obj@SemanticSequenceProducer(sd, cfg, SemanticData, use_range, store_results);
            %obj.OF_X = [];
            %obj.OF_Y = [];
            obj.OF_ind_source = [];
            obj.OF_ind_dest = [];
            obj.Shakiness_cost = [];
            obj.Forwardness_cost =[];
            obj.Velocity_cost = [];
            obj.Appearance_cost = [];
            
            obj.Semantic_cost = [];
            
            obj.Total_cost = [];
            obj.gaze_frames = [];
            obj.non_walk = [];
            
            obj.Higher_order_shakiness_cost = [];
            obj.Higher_order_forwardness_cost = [];
            
            obj.ResultsMetaData = struct();
            
            obj.OF_ind_source = 0; obj.OF_ind_dest = 0;
            if obj.cfg.get('endInd') > size(obj.sd.CDC_Raw_X,1) + obj.sd.StartFrame-1
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
                    obj.cfg.set('ShakinessCostFunction','None');
                    obj.cfg.set('ForwardnessCostFunction','None');
                    obj.cfg.set('SemanticCostFunction','None');
                    obj.cfg.set('UseHigherOrder',false);
                case 'NaiveSemantic'
                    obj.Frame_selector = NaiveSemanticFrameSelector(obj.cfg, obj.SemanticData);
                    % Cripple all the OF and other estimators
                    obj.cfg.set('OFEstimator','None');
                    obj.cfg.set('VelocityCostFunction','None');
                    obj.cfg.set('AppearanceCostFunction','None');
                    obj.cfg.set('ShakinessCostFunction','None');
                    obj.cfg.set('ForwardnessCostFunction','None');
                    obj.cfg.set('SemanticCostFunction','None');
                    obj.cfg.set('UseHigherOrder',false);
                otherwise
                    error('Unknown ''frame selector'' value "%s"',obj.cfg.get('FrameSelector'));
            end
            
        end
        
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
            
            %shakiness cost function
            switch obj.cfg.get('ShakinessCostFunction')
                case 'FOE'
                    shakinessCostEstimator = FOEDistanceCost(obj.sd,obj.cfg);
                case 'Epipole.vs.FOE'
                    shakinessCostEstimator = EpipoleFOEDistanceCost(obj.sd,obj.cfg);
                case 'AngleDiff'
                    shakinessCostEstimator = AngleDiffrenceCost(obj.sd,obj.cfg,80);
                case 'FFT'
                    shakinessCostEstimator = FFTCost(obj.sd,obj.cfg);
                case 'ImpulseJitter'
                    shakinessCostEstimator = ImpulseJitterCost(obj.sd,obj.cfg);                    
                case 'SequenceNet'
                    shakinessCostEstimator = SequenceNetCost(obj.sd,obj.cfg);
                case 'None'
                    shakinessCostEstimator = ZeroCost(obj.sd,obj.cfg);
                otherwise
                    error('Unknown ''ShakinessCostFunction'' value "%s"',obj.cfg.get('ShakinessCostFunction'));
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
            
            %Semantic cost function
            switch obj.cfg.get('SemanticCostFunction')
                case 'Semantic'
                    semanticCostEstimator = SemanticCost(obj.sd,obj.cfg, obj.SemanticData);
                case 'None'
                    semanticCostEstimator = ZeroCost(obj.sd,obj.cfg);
                otherwise
                    error('Unknown ''SemanticCostFunction'' value "%s"', obj.cfg.get('SemanticCostFunction'));
            end
            
            %% Calculate batches of cost functions
            startInd = obj.cfg.get('startInd');
            endInd = obj.cfg.get('endInd');
            tempDist = obj.cfg.get('maxTemporalDist');
            skipRatio = obj.cfg.get('FastForwardSkipRatio');
            
            lastSparseInd =1;
            batchSize = min(obj.cfg.get('maxBatchMemory')/tempDist, endInd-startInd+1);
            numberOfBatches = ceil((endInd-startInd)/batchSize);
            
            [video_dir, fname, ~] = fileparts(obj.cfg.get('inputVideoFileName'));
            
            fname_costs = [video_dir '/' obj.cfg.get('ExpName') '_Costs_' num2str(skipRatio) 'x.mat'];%Costs_Bkp_MScExperiments/
            
            if (exist(fname_costs, 'file') == 2 )
                load(fname_costs);
                fprintf('%sCosts loaded from "%s"...\n',log_line_prefix, fname_costs);
                                
                if(strcmp(obj.cfg.get('ShakinessCostFunction'), 'ImpulseJitter'))
                    if(~any(strcmp(who,'shakiness_cost_by_cumultive_shifts')))
                        cumulative_shifts_filename = [video_dir '/' fname '_cumulativeShifts.mat'];
                        temporal_dist = obj.cfg.get('maxTemporalDist');
                        shakiness_cost_by_cumultive_shifts = genJitterCosts(cumulative_shifts_filename, temporal_dist);
                        shakiness_cost_by_cumultive_shifts = shakiness_cost_by_cumultive_shifts(1:end-4,:);
                    end
                    obj.Shakiness_cost = shakiness_cost_by_cumultive_shifts(startInd:endInd);
                elseif(strcmp(obj.cfg.get('ShakinessCostFunction'), 'SequenceNet'))
                    if(~any(strcmp(who,'shakiness_cost_sequence_net')))
                        [dir, fname, ~] = fileparts(obj.cfg.get('inputVideoFileName'));
                        sequence_net_filename = [dir '/sequenceNet_' fname '.csv'];
                        shakiness_cost_sequence_net = csvread(sequence_net_filename);
                        shakiness_cost_sequence_net = shakiness_cost_sequence_net(startInd:endInd,:);
                    end
                    obj.Shakiness_cost = shakiness_cost_sequence_net;
                else
                    obj.Shakiness_cost = shakiness_cost(startInd:endInd,:);
                end
                
                % The velocity term needs to be recalculated if the required speed is different
                if exist('required_speedup', 'var') && obj.cfg.get('FastForwardSkipRatio') ~= required_speedup ||...
                        obj.cfg.get('FastForwardSkipRatio') ~= 10 %The default speedup is 10 (if different it should recalculate)
                    for batch = 1:numberOfBatches
                        startBatch = startInd + batchSize*(batch-1);
                        endBatch = min(startBatch + batchSize-1, endInd);
                        fprintf('%sEstimating optical flow between pairs of frames...\n',log_line_prefix);
                        [OF_X,OF_Y,OF_ind_source_batch,OF_ind_dest_batch] = OFEstimator.estimateBatch(startBatch, endBatch);
                        
                        fprintf('%sRecalculating velocity cost...\n',log_line_prefix);
                        [Velocity_cost_batch] = velocityCostEstimator.calculateCostBatch(OF_X, OF_Y,startBatch, endBatch);
                        
                        numSparseInd = numel(OF_ind_source_batch);
                        obj.OF_ind_source(lastSparseInd : lastSparseInd + numSparseInd-1) = OF_ind_source_batch + startBatch-1;
                        obj.OF_ind_dest   (lastSparseInd : lastSparseInd + numSparseInd-1) = OF_ind_dest_batch + startBatch-1;
                        lastSparseInd = lastSparseInd + numSparseInd;
                        
                        obj.Velocity_cost(startBatch-startInd+1 : endBatch-startInd+1, :) = Velocity_cost_batch;
                    end
                else
                    obj.Velocity_cost = velocity_cost(startInd:endInd,:);
                end
                
                obj.Appearance_cost = appearance_cost(startInd:endInd,:);
                obj.Semantic_cost = semantic_cost(startInd:endInd,:);
                if obj.cfg.get('UseHigherOrder')
                    obj.Forwardness_cost = forwardness_cost(startInd:endInd,:);
                    obj.Higher_order_shakiness_cost = higher_order_shakiness_cost(startInd:endInd,:);
                    obj.Higher_order_forwardness_cost = higher_order_forwardness_cost(startInd:endInd,:);
                end
            else
                obj.Shakiness_cost      = zeros(endInd-startInd,tempDist);
                obj.Velocity_cost       = zeros(endInd-startInd,tempDist);
                obj.Appearance_cost     = zeros(endInd-startInd,tempDist);
                obj.Forwardness_cost    = zeros(endInd-startInd,tempDist);
                obj.Semantic_cost       = zeros(endInd-startInd,tempDist);
                
                if obj.cfg.get('UseHigherOrder')
                    obj.Higher_order_shakiness_cost = zeros(endInd-startInd,tempDist,tempDist);
                    if strcmp(obj.cfg.get('ForwardnessCostFunction'),'FOE')
                        obj.Higher_order_forwardness_cost = zeros(endInd-startInd,tempDist,tempDist);
                    end
                end
                
                for batch = 1:numberOfBatches
                    
                    startBatch = startInd + batchSize*(batch-1);
                    endBatch = min(startBatch + batchSize-1, endInd);
                    fprintf('\n%sStarting batch No. %d from frame %d to frame %d\n',log_line_prefix, batch, startBatch, endBatch);
                    
                    fprintf('%sEstimating optical flow between pairs of frames...\n',log_line_prefix);
                    [OF_X,OF_Y,OF_ind_source_batch,OF_ind_dest_batch] = OFEstimator.estimateBatch(startBatch, endBatch);
                    
                    fprintf('%sCalculating shakiness cost...\n',log_line_prefix);
                    if obj.cfg.get('UseHigherOrder')
                        [Higher_order_shakiness_cost_batch] = shakinessCostEstimator.calculateTriFrameCostBatch (OF_X, OF_Y, startBatch, endBatch);
                        if strcmp(obj.cfg.get('ForwardnessCostFunction'),'FOE')
                            [Higher_order_forwardness_cost_batch] = forwardnessCostEstimator.calculateTriFrameCostBatch (OF_X, OF_Y, startBatch, endBatch);
                        end
                    end
                    [Shakiness_cost_batch] = shakinessCostEstimator.calculateCostBatch (OF_X, OF_Y, startBatch, endBatch);
                    
                    fprintf('%sCalculating forwardness cost...\n',log_line_prefix);
                    [Forwardness_cost_batch] = forwardnessCostEstimator.calculateCostBatch (OF_X, OF_Y, startBatch, endBatch);
                    
                    fprintf('%sCalculating velocity cost...\n',log_line_prefix);
                    [Velocity_cost_batch] = velocityCostEstimator.calculateCostBatch(OF_X, OF_Y,startBatch, endBatch);
                    
                    fprintf('%sCalculating appearance cost...\n',log_line_prefix);
                    [Appearance_cost_batch] = appearanceCostEstimator.calculateCostBatch(OF_X, OF_Y, startBatch, endBatch);
                    
                    fprintf('%sCalculating semantic cost...\n',log_line_prefix);
                    [Semantic_cost_batch] = semanticCostEstimator.calculateCostBatch (OF_X, OF_Y, startBatch, endBatch);
                    
                    numSparseInd = numel(OF_ind_source_batch);
                    obj.OF_ind_source(lastSparseInd : lastSparseInd + numSparseInd-1) = OF_ind_source_batch + startBatch-1;
                    obj.OF_ind_dest   (lastSparseInd : lastSparseInd + numSparseInd-1) = OF_ind_dest_batch + startBatch-1;
                    lastSparseInd = lastSparseInd + numSparseInd;
                    
                    obj.Shakiness_cost(startBatch-startInd+1 : endBatch-startInd+1, :) = Shakiness_cost_batch;
                    obj.Velocity_cost(startBatch-startInd+1 : endBatch-startInd+1, :) = Velocity_cost_batch;
                    obj.Appearance_cost(startBatch-startInd+1 : endBatch-startInd+1, :) = Appearance_cost_batch;
                    obj.Forwardness_cost(startBatch-startInd+1 : endBatch-startInd+1, :) = Forwardness_cost_batch;                    
                    obj.Semantic_cost(startBatch-startInd+1 : endBatch-startInd+1, :) = Semantic_cost_batch;
                    
                    if obj.cfg.get('UseHigherOrder')
                        obj.Higher_order_shakiness_cost(startBatch-startInd+1 : endBatch-startInd+1, :, :) = Higher_order_shakiness_cost_batch;
                        if strcmp(obj.cfg.get('ForwardnessCostFunction'),'FOE')
                            obj.Higher_order_forwardness_cost(startBatch-startInd+1 : endBatch-startInd+1, :, :) = Higher_order_forwardness_cost_batch;
                        end
                    end
                end
                fprintf('%sSaving costs to "%s"...\n',log_line_prefix, fname_costs);
                
                shakiness_cost = obj.Shakiness_cost;
                velocity_cost = obj.Velocity_cost;
                appearance_cost = obj.Appearance_cost;
                semantic_cost = obj.Semantic_cost;
                forwardness_cost = obj.Forwardness_cost;
                higher_order_shakiness_cost = obj.Higher_order_shakiness_cost;
                higher_order_forwardness_cost = obj.Higher_order_forwardness_cost;
                required_speedup = obj.cfg.get('FastForwardSkipRatio');
                
                save(fname_costs, '-v7.3','shakiness_cost','velocity_cost','appearance_cost', 'higher_order_shakiness_cost',...
                    'higher_order_forwardness_cost','forwardness_cost','semantic_cost');
                
                fprintf('%sCosts file saved to "%s"...\n',log_line_prefix, fname_costs);
            end
        end
        
        function GetTopSemanticValue(obj)
        % Get the semantic value of the video with the max values naïvely
            number_of_frames = obj.cfg.get('endInd')-obj.cfg.get('startInd')+1;
            
            %Sort detected semantic in descend order
            Semantic_Value = cell(obj.cfg.get('endInd')-obj.cfg.get('startInd')+1, 1);
            ds_dts = obj.SemanticData(obj.cfg.get('startInd'):obj.cfg.get('endInd'));
            Semantic_Value(:) = {0};%Initializes the cell
            for i=1:size(ds_dts,1)
                Semantic_Value{i} = FrameSemanticValue(ds_dts{i});
            end
            [dummy, Index] = sort(cellfun(@double, Semantic_Value(:)), 'descend');
            %Select the frames which contain the most semantic
            frame_indices = sort(Index(1:round(number_of_frames/obj.cfg.get('FastForwardSkipRatio')+1)));
            
            total_semantic_values_in_frames = 0.;
            for i=1:numel(frame_indices)
                aux = obj.Filter_Semantics(ds_dts{frame_indices(i)});
                frame_value = FrameSemanticValue(aux);
                
                % Total Semantic values
                total_semantic_values_in_frames = total_semantic_values_in_frames + frame_value;
            end
            
            obj.TopSemanticValue = total_semantic_values_in_frames;
        end
        
        function SolveSemantic(obj)
            %% Setting up values
            startInd = obj.cfg.get('startInd');
            %endInd = obj.cfg.get('endInd');
            alphas = obj.cfg.get('ShakinessTermWeight');
            betas  = obj.cfg.get('VelocityTermWeight');
            gamas  = obj.cfg.get('AppearanceTermWeight');
            etas = obj.cfg.get('SemanticTermWeight');
            if obj.cfg.get('UseHigherOrder')
                deltas = obj.cfg.get('ForwardnessTermWeight');
                zetas = obj.cfg.get('HighOrderTermWeight');
            end
            
            alpha = alphas(1);
            beta  = betas(1);
            gama  = gamas(1);
            eta = etas(1);
            if obj.cfg.get('UseHigherOrder')
                delta = deltas(1);
                zeta = zetas(1);
            end
            
            %delta = obj.cfg.get('ForwardnessTermWeight');
            
            semantic_alpha = alphas(2);
            semantic_beta  = betas(2);
            semantic_gama  = gamas(2);
            semantic_eta = etas(2);
            if obj.cfg.get('UseHigherOrder')
                semantic_delta = deltas(2);
                semantic_zeta = zetas(2);
            end
            
            RangesAndSpeedups = obj.cfg.get('RangesAndSpeedups');
            
            Sterm = zeros(size(obj.Shakiness_cost));
            Vterm = zeros(size(obj.Velocity_cost));
            Aterm = zeros(size(obj.Appearance_cost));
            Mterm = zeros(size(obj.Semantic_cost));
            Fterm = zeros(size(obj.Forwardness_cost));
            if obj.cfg.get('UseHigherOrder')
                Hterm = zeros(size(obj.Higher_order_shakiness_cost));
            else
                Hterm = [];
            end
            
            % Removing inconsistencies (It should not reach the last frame)
            %RangesAndSpeedups(2,end) = RangesAndSpeedups(2,end)-1;
                        
            %% Getting total costs for all graph edges
            for r=1:size(RangesAndSpeedups,2)
                range_start = RangesAndSpeedups(1,r);
                range_end = RangesAndSpeedups(2,r);
                is_semantic = RangesAndSpeedups(4,r);
                
                if(is_semantic)
                    %% Getting total cost for patch (semantic)
                    Sterm((range_start:range_end)-startInd+1,:)=(semantic_alpha * obj.Shakiness_cost((range_start:range_end)-startInd+1,:));
                    Vterm((range_start:range_end)-startInd+1,:)=(semantic_beta * obj.Velocity_cost((range_start:range_end)-startInd+1,:));
                    Aterm((range_start:range_end)-startInd+1,:)=(semantic_gama * obj.Appearance_cost((range_start:range_end)-startInd+1,:));
                    Mterm((range_start:range_end)-startInd+1,:)=(semantic_eta * obj.Semantic_cost((range_start:range_end)-startInd+1,:));
                    if obj.cfg.get('UseHigherOrder')
                        Fterm((range_start:range_end)-startInd+1,:)=(semantic_delta * obj.Forwardness_cost((range_start:range_end)-startInd+1,:));
                        Hterm((range_start:range_end)-startInd+1,:,:)=(semantic_zeta * obj.Higher_order_shakiness_cost((range_start:range_end)-startInd+1,:,:));
                    end
                else
                    %% Getting total cost for patch (non-semantic)
                    Sterm((range_start:range_end)-startInd+1,:)=(alpha * obj.Shakiness_cost((range_start:range_end)-startInd+1,:));
                    Vterm((range_start:range_end)-startInd+1,:)=(beta * obj.Velocity_cost((range_start:range_end)-startInd+1,:));
                    Aterm((range_start:range_end)-startInd+1,:)=(gama * obj.Appearance_cost((range_start:range_end)-startInd+1,:));
                    Mterm((range_start:range_end)-startInd+1,:)=(eta * obj.Semantic_cost((range_start:range_end)-startInd+1,:));
                    if obj.cfg.get('UseHigherOrder')
                        Fterm((range_start:range_end)-startInd+1,:)=(delta * obj.Forwardness_cost((range_start:range_end)-startInd+1,:));
                        Hterm((range_start:range_end)-startInd+1,:,:)=(zeta * obj.Higher_order_shakiness_cost((range_start:range_end)-startInd+1,:,:));
                    end
                end
            end
            
            
            if obj.cfg.get('ForwardnessMergeWithShakinessCoef')>0
                Sterm(obj.Shakiness_cost == inf) = Fterm(obj.Shakiness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShakinessCoef');
                obj.Total_cost = Sterm+Vterm+Aterm+Mterm;
                %obj.Total_cost = Mterm;
                if obj.cfg.get('UseHigherOrder')
                    Hterm(obj.Higher_order_shakiness_cost == inf) = ...
                        obj.Higher_order_forwardness_cost(obj.Higher_order_shakiness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShakinessCoef') * zeta;
                end
            else
                Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
                obj.Total_cost = Sterm+Vterm+Aterm+Mterm;
                %obj.Total_cost = Mterm;
            end
            
            %% Selecting frames
            %fprintf('%sSelecting frames for output...\n',log_line_prefix);
            obj.Frame_indices = obj.SelectFramesByRange(RangesAndSpeedups, Hterm);
            
            %Gridterm = meshgrid(1:size(Mterm,2),1:size(Mterm,1));
            %obj.Total_cost = obj.Total_cost.*Gridterm;
            %obj.Frame_indices = obj.SelectFrames(obj.Total_cost, startInd, 1, Hterm);
            
            %% Writing results
            if obj.store_results
                obj.StoreResults(alphas, betas, gamas, etas, Sterm, Vterm, Aterm, Mterm);
            end
        end
        
        function frame_indices = SelectFrames(obj, total_cost, offset, use_high_order, Hterm)
            %fprintf('Selecting frames from %d to %d...\n', offset, offset+length(total_cost));
            %if strcmp(obj.cfg.get('FrameSelector'),'DynamicProgramming')
            %    frame_indices = obj.Frame_selector.selectFrames (total_cost, Hterm);
            %else
            if use_high_order
                frame_indices = obj.Frame_selector.selectFramesThirdDegree (total_cost, Hterm);
            else
                frame_indices = obj.Frame_selector.selectFrames (total_cost);
            end
            %end
            
            frame_indices = frame_indices + (offset-1);%If offset == startInd == 1, we should not offset the indices
            if size(frame_indices,2)>1
                frame_indices=frame_indices';
            end
        end
        
        function frame_indices = SelectFramesByRange(obj, RangesAndSpeedups, Hterm)
            startInd = obj.cfg.get('startInd');
            endInd = obj.cfg.get('endInd');
            
            frame_indices = [];
            
            Speedups = obj.cfg.get('Speedups');
            non_semantic_speedup = Speedups(1,2);
            
            use_high_order = obj.cfg.get('UseHigherOrder');
            
            %Gridterm = ((ceil(meshgrid(1:size(obj.Total_cost,2),1:size(obj.Total_cost,1))/speedUp)-1) * speedUp)+1;
            %Gridterm = ceil(meshgrid(1:size(obj.Total_cost,2),1:size(obj.Total_cost,1))/speedUp);
            
            for r=1:size(RangesAndSpeedups,2)
                range_start = RangesAndSpeedups(1,r);
                range_end = RangesAndSpeedups(2,r);
                semantic_speedup = RangesAndSpeedups(3,r);
                is_semantic = RangesAndSpeedups(4,r);
                
                %Gridterm = ceil(meshgrid(1:size(obj.Total_cost,2),1:range_end-range_start+1)/speedUp_semantic);
                %The bellow code is the correct one. It makes higher skips to be penalized in semantic segments
                
                if(is_semantic)
                    Gridterm = ((ceil(meshgrid(1:size(obj.Total_cost,2),1:range_end-range_start+1)/semantic_speedup)-1) * semantic_speedup) + 1;
                else
                    Gridterm = ceil(meshgrid(1:size(obj.Total_cost,2),1:range_end-range_start+1)/non_semantic_speedup);
                end
                
                obj.Total_cost((range_start:range_end)-startInd+1,:) = obj.Total_cost((range_start:range_end)-startInd+1,:).*Gridterm;
                frame_indices = [frame_indices; obj.SelectFrames(obj.Total_cost((range_start:range_end)-startInd+1,:), range_start, use_high_order, Hterm)];
            end
        end
        
        function Solve(obj)
            alphas = obj.cfg.get('ShakinessTermWeight');
            betas  = obj.cfg.get('VelocityTermWeight');
            gamas  = obj.cfg.get('AppearanceTermWeight');
            etas = obj.cfg.get('SemanticTermWeight');
            
            alpha = alphas(2);
            beta  = betas(2);
            gama  = gamas(2);
            eta = etas(2);
            
            if obj.cfg.get('UseHigherOrder')
                deltas = obj.cfg.get('ForwardnessTermWeight');
                zetas  = obj.cfg.get('HighOrderTermWeight');
                delta = deltas(2);
                zeta = zetas(2);
            else
                Hterm = [];
            end
            
            %             tempShakiness = obj.Shakiness_cost;
            %             tempShakiness(obj.Shakiness_cost==inf) = obj.cfg.get('ShakinessTermInvalidValue');
            %             obj.Velocity_cost      (obj.Velocity_cost       == inf) = 1e6;
            %             obj.Appearance_cost (obj.Appearance_cost == inf) = 1e6;
            
            switch obj.cfg.get('CostWeightMethod')
                case 'Sum'
                    Sterm=(alpha * obj.Shakiness_cost);
                    %                     Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
                    Vterm=(beta * obj.Velocity_cost);
                    Aterm=(gama * obj.Appearance_cost);
                    if obj.cfg.get('UseHigherOrder')
                        Fterm=(delta * obj.Forwardness_cost);
                    end
                    Mterm=(eta * obj.Semantic_cost);
                    
                    %Gridterm = meshgrid(1:size(Mterm,2),1:size(Mterm,1));
                    
                    if obj.cfg.get('UseHigherOrder')
                        Hterm = (zeta * obj.Higher_order_shakiness_cost);
                    end
                    if obj.cfg.get('ForwardnessMergeWithShakinessCoef')>0
                        Sterm(obj.Shakiness_cost == inf) = Fterm(obj.Shakiness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShakinessCoef');
                        obj.Total_cost = Sterm+Vterm+Aterm+Mterm;
                        %obj.Total_cost = Mterm;
                        if obj.cfg.get('UseHigherOrder')
                            Hterm(obj.Higher_order_shakiness_cost == inf) = ...
                                obj.Higher_order_forwardness_cost(obj.Higher_order_shakiness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShakinessCoef') *zeta;
                        end
                        
                    else
                        Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
                        obj.Total_cost = Sterm+Vterm+Aterm+Mterm;
                        %obj.Total_cost = Mterm;
                    end
                    %obj.Total_cost = obj.Total_cost.*Gridterm;
                case 'SumSquares'
                    Sterm=(alpha * (obj.Shakiness_cost).^2);
                    Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
                    Vterm=(beta * (obj.Velocity_cost).^2);
                    Aterm=(gama * (obj.Appearance_cost).^2);
                    Fterm=(delta * (obj.Forwardness_cost).^2);
                    obj.Total_cost = Sterm+Vterm+Aterm+Fterm;
                    
                case 'SumOfLogs'
                    Sterm=(alpha * log(obj.Shakiness_cost+1));
                    Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
                    Vterm=(beta * log(obj.Velocity_cost+1));
                    Aterm=(gama * log(obj.Appearance_cost+1));
                    Fterm=(delta * log(obj.Forwardness_cost+1));
                    obj.Total_cost = Sterm+Vterm+Aterm+Fterm;
                    
                case 'Multiplied'
                    Sterm=(alpha * obj.Shakiness_cost);
                    %                     Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
                    Vterm=(beta * obj.Velocity_cost );RangesAndSpeedups
                    Aterm=(gama * obj.Appearance_cost );
                    Fterm=(delta * obj.Forwardness_cost);
                    if obj.cfg.get('UseHigherOrder')
                        Hterm = (zeta * obj.Higher_order_shakiness_cost);
                    end
                    if obj.cfg.get('ForwardnessMergeWithShakinessCoef')>0
                        Sterm(obj.Shakiness_cost == inf) = Fterm(obj.Shakiness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShakinessCoef');
                        obj.Total_cost = Vterm.*(Sterm+Aterm);
                        if obj.cfg.get('UseHigherOrder')
                            Hterm(obj.Higher_order_shakiness_cost == inf) = ...
                                obj.Higher_order_forwardness_cost(obj.Higher_order_shakiness_cost == inf) * obj.cfg.get('ForwardnessMergeWithShakinessCoef') *zeta;
                        end
                    else
                        Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
                        obj.Total_cost = Vterm.*(Sterm+Aterm+Fterm) ;
                    end
                    
                case 'Binarized'
                    Sterm=alpha * (obj.Shakiness_cost>obj.cfg.get('ShakinessTermBinaryThreshold'));
                    Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
                    Vterm=beta * (obj.Velocity_cost>obj.cfg.get('VelocityTermBinaryThreshold'));
                    Aterm=gama * (obj.Appearance_cost>obj.cfg.get('AppearanceTermBinaryThreshold'));
                    Fterm=(delta * obj.Forwardness_cost);
                    obj.Total_cost = Sterm+Vterm+Aterm+Fterm;
                    
                case 'Clamped'
                    Sterm=obj.Shakiness_cost;
                    Sterm(obj.Shakiness_cost>obj.cfg.get('ShakinessTermBinaryThreshold'))=obj.cfg.get('ShakinessTermClampedValue');
                    Sterm(obj.Shakiness_cost == inf)= obj.cfg.get('ShakinessTermInvalidValue');
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
            
            obj.Frame_indices = SelectFrames(obj, obj.Total_cost, obj.cfg.get('startInd'), obj.cfg.get('UseHigherOrder'), Hterm);
            
            %OFEstimator = CumulativeLKEstimator(obj.sd,obj.cfg);
            %[OF_X,OF_Y,OF_ind_source_batch,OF_ind_dest_batch] = OFEstimator.estimateBatch(obj.cfg.get('startInd'), obj.cfg.get('endInd'));
            if obj.store_results
                obj.StoreResults(alpha, beta, gama, eta, Sterm, Vterm, Aterm, Mterm);
            end
        end
        
        function [avgskip, medskip, jitter, jitter_ceil,...
                total_semantic_in_frames, total_semantic_values_in_frames] = GetResults(obj)
            
            frame_indices = obj.Frame_indices;
            costcols = imfilter(frame_indices,[-1 1]');
            
            % Average Skip
            avgskip = floor(mean(costcols(1:end-1)));
            
            %Median Skip
            medskip = median(costcols(1:end-1));
            
            if strcmp(obj.cfg.get('ShakinessCostFunction'), 'Epipole.vs.FOE')
                epipole_locations = getEpipoleLocations(obj);
                % epipole_locations are always between -0.5 and 0.5 (see [isIn,epipole] = algIsEpipoleInImage(f,imageSize))
                epipole_max_diff = sqrt((0.5)^2 + (0.5)^2);
                % Jitter
                jitter = mean(sqrt(nansum(epipole_locations.^2,2)));
                jitter_ceil = epipole_max_diff;
            else
                obj.FOE_locations = getFoeLocations(obj);
                foe_diffs = obj.FOE_locations(2:end,:) - obj.FOE_locations(1:end-1,:);
                foe_max_diff = sqrt((obj.sd.Raw_Video_Data.num_x_cells/2)^2 + (obj.sd.Raw_Video_Data.num_y_cells/2)^2);
                % Jitter
                jitter = mean(sqrt(sum(foe_diffs.^2,2)));
                jitter_ceil = foe_max_diff;
            end
            
            total_semantic_in_frames = 0;
            total_semantic_values_in_frames = 0;
            for i=1:numel(frame_indices)
                aux = obj.Filter_Semantics(obj.SemanticData{frame_indices(i)});
                frame_value = FrameSemanticValue(aux);
                num_semantic_bboxes = size(aux,2);
                
                % Total semantic and Semantic values
                total_semantic_in_frames = total_semantic_in_frames + num_semantic_bboxes;
                total_semantic_values_in_frames = total_semantic_values_in_frames + frame_value;
            end
            
            % Treat stuffs to avoid errors
            if isempty(frame_indices)
                avgskip = 0;
                medskip = 0;
                jitter = 0;
                return;
            end
        end
        
        function StoreResults(obj, alpha, beta, gama, eta, Sterm, Vterm, Aterm, Mterm)
            frame_indices = obj.Frame_indices;
            RangesAndSpeedups = obj.cfg.get('RangesAndSpeedups');
            speedups_for_indices = RangesAndSpeedups(1,1):RangesAndSpeedups(2,end);
            for i=1:size(RangesAndSpeedups,2)
                speedups_for_indices(RangesAndSpeedups(1,i):RangesAndSpeedups(2,i)) = RangesAndSpeedups(3,i);
            end
            
            selected_frames_and_speedups = [frame_indices, speedups_for_indices(frame_indices)'];
            
            %% Selected Frames and Speedups File
            mkdir(obj.cfg.get('outputVideoFileName'));
            selected_frames_and_speedups_filename = [obj.cfg.get('outputVideoFileName') '/selected_frames_and_speedups.csv'];
            
            % Writing the Selected Frames and Speedups file
            fprintf('%sStoring the selected frames in file: %s\n', log_line_prefix, selected_frames_and_speedups_filename);
            csvwrite(selected_frames_and_speedups_filename, selected_frames_and_speedups);
            
            %% Getting the Results
            costcols = imfilter(obj.Frame_indices,[-1 1]');
            [avgskip, medskip, jitter, ~,...
                total_semantic_in_frames, total_semantic_values_in_frames] = obj.GetResults();
            
            original_num_frames = obj.cfg.get('endInd') - obj.cfg.get('startInd') + 1;
            num_frames = numel(obj.Frame_indices);
            achieved_speedup = original_num_frames/num_frames;
            
            fprintf('%sResults [Jitter: %.3f -- Speedup: %.3fx -- SemanticValue: %.3f]\n',log_line_prefix,...
                jitter, achieved_speedup,total_semantic_values_in_frames);
            
            fprintf('%sSelected %d of %d frames\n',log_line_prefix,num_frames,original_num_frames);
            
            %% Charts stuffs (Plot and Save)
            plotCharts = obj.cfg.get('PlotCharts');
            saveCharts = obj.cfg.get('SaveCharts');
            
            if plotCharts
                fprintf('%sVisualizing Cost Terms...\n',log_line_prefix);
                experiment_folder = obj.cfg.get('outputVideoFileName');
                if ~exist(experiment_folder, 'dir')
                    mkdir(experiment_folder);
                end
                
                fprintf('%sPlotting/Saving Charts...\n',log_line_prefix);
                
                startInd = obj.cfg.get('startInd');
                endInd = obj.cfg.get('endInd');
                tempDist = obj.cfg.get('maxTemporalDist');
                
                obj.PlotScatter(frame_indices, costcols, 'Shakiness Cost', startInd, endInd, tempDist, Sterm, saveCharts);
                obj.PlotScatter(frame_indices, costcols, 'Velocity Cost', startInd, endInd, tempDist, Vterm, saveCharts);
                obj.PlotScatter(frame_indices, costcols, 'Appearance Cost', startInd, endInd, tempDist, Aterm, saveCharts);
                obj.PlotScatter(frame_indices, costcols, 'Semantic Cost', startInd, endInd, tempDist, Mterm, saveCharts);
                obj.PlotScatter(frame_indices, costcols, 'Total Cost', startInd, endInd, tempDist, obj.Total_cost, saveCharts);
                
                figure;
                subplot(3,2,1); imagesc(startInd:endInd-1,1:tempDist,Sterm'); set(gca,'YDir','normal');
                title('Shakiness Cost'); colormap jet; colorbar; xlabel('Frame Num'); ylabel('Jump Dist');
                hold on;
                scatter(frame_indices(1:end-1),costcols(1:end-1),'r','LineWidth',2);
                
                subplot(3,2,2); imagesc(startInd:endInd-1,1:tempDist,Vterm'); set(gca,'YDir','normal');
                title('Velocity Cost'); colormap jet; colorbar; xlabel('Frame Num'); ylabel('Jump Dist');
                hold on;
                scatter(frame_indices(1:end-1),costcols(1:end-1),'r','LineWidth',2);
                
                subplot(3,2,3); imagesc(startInd:endInd-1,1:tempDist,Aterm'); set(gca,'YDir','normal');
                title('Appearance Cost'); colormap jet; colorbar; xlabel('Frame Num'); ylabel('Jump Dist');
                hold on;
                scatter(frame_indices(1:end-1),costcols(1:end-1),'r','LineWidth',2);
                
                subplot(3,2,4); imagesc(startInd:endInd-1,1:tempDist,Mterm'); set(gca,'YDir','normal');
                title('Semantic Cost'); colormap jet; colorbar; xlabel('Frame Num'); ylabel('Jump Dist');
                hold on;
                scatter(frame_indices(1:end-1),costcols(1:end-1),'r','LineWidth',2);
                
                subplot(3,2,5); imagesc(startInd:endInd-1,1:tempDist,obj.Total_cost'); set(gca,'YDir','normal');
                title('Total Cost'); colormap jet; colorbar; xlabel('Frame Num'); ylabel('Jump Dist');
                hold on;
                scatter(frame_indices(1:end-1),costcols(1:end-1),'r','LineWidth',2);
                
                title1='Frame Selection Over Cost Terms';
                title2=sprintf('Avg skip=%.1f frames --- Median skip=%d frames --- Epsilon=%.3f', avgskip, medskip, obj.cfg.get('SemanticEpsilon'));
                title3=sprintf('Total Semantic in Selected Frames: %d semantic -- Total Semantic Value in Selected Frames: %.3f semantic',...
                    total_semantic_in_frames, total_semantic_values_in_frames);
                if obj.use_range
                    title4=sprintf('Selector: %s - TermWeights: Shakiness(%d/%d), Velocity(%d/%d), Appearance(%d/%d), Semantic(%d/%d)\n',...
                        obj.cfg.get('FrameSelector'), alpha(1), alpha(2), beta(1), beta(2), gama(1), gama(2), eta(1), eta(2));
                else
                    title4=sprintf('Selector: %s - TermWeights: Shakiness(%d), Velocity(%d), Appearance(%d), Semantic(%d)\n',...
                        obj.cfg.get('FrameSelector'), alpha, beta, gama, eta);
                end
                
                maintitle = {title1, title2, title3, title4};
                
                if saveCharts
                    obj.SaveChart('Subplots.png');
                end
                set(gcf, 'Visible', 'off');
                
                %Temporal distance must not interfere on plot of NaiveSemantic!
                if ~strcmp(obj.cfg.get('FrameSelector'),'NaiveSemantic')
                    selectedFrameCostInds = sub2ind(size(obj.Total_cost), frame_indices(1:end-1)-startInd+1, costcols(1:end-1));
                    
                    obj.PlotChart(frame_indices(1:end-1), Sterm(selectedFrameCostInds), '-b', maintitle, 'Shakiness', saveCharts);
                    obj.PlotChart(frame_indices(1:end-1), Vterm(selectedFrameCostInds), '-r', maintitle, 'Velocity', saveCharts);
                    obj.PlotChart(frame_indices(1:end-1), Aterm(selectedFrameCostInds), '-c', maintitle, 'Appearance', saveCharts);
                    obj.PlotChart(frame_indices(1:end-1), Mterm(selectedFrameCostInds), '-k', maintitle, 'Semantic', saveCharts);
                    obj.PlotChart(frame_indices(1:end-1), obj.Total_cost(selectedFrameCostInds), '-g', maintitle, 'Total', saveCharts);
                    
                    %Plot Complete Chart
                    figure;
                    h = plot(frame_indices(1:end-1), Sterm(selectedFrameCostInds),...
                        frame_indices(1:end-1), Vterm(selectedFrameCostInds),...
                        frame_indices(1:end-1), Aterm(selectedFrameCostInds),...
                        frame_indices(1:end-1), Mterm(selectedFrameCostInds),...
                        frame_indices(1:end-1), obj.Total_cost(selectedFrameCostInds), '--');
                    set(h(1), 'linewidth', 2);
                    set(h(2), 'linewidth', 2);
                    set(h(3), 'linewidth', 2);
                    set(h(4), 'linewidth', 2);
                    set(h(5), 'linewidth', 2);
                    xlabel('Frame # In Orig Video');
                    ylabel('Cost');
                    title(maintitle,'Interpreter','None');
                    legend('Shakiness', 'Velocity', 'Appearance', 'Semantic', 'Total');
                    
                    if saveCharts
                        obj.SaveChart('Plot.png');
                    end
                    set(gcf, 'Visible', 'off');
                end
                
                ShowSelectedFramesFOE(obj, saveCharts);
            end
            
            obj.ResultsMetaData.avarage_skip = avgskip;
            obj.ResultsMetaData.median_skip = medskip;
            obj.ResultsMetaData.frames = frame_indices;
            obj.ResultsMetaData.total_semantic_in_frames = total_semantic_in_frames;
            obj.ResultsMetaData.semantic_value = total_semantic_values_in_frames;
            obj.ResultsMetaData.jitter = jitter;
            obj.ResultsMetaData.achieved_speedup = achieved_speedup;
        end
        
        function SaveChart(obj, filename)
            matlab_version = strsplit(version);
            if strcmp(matlab_version(2), '(R2015a)')
                f1 = gcf;
                f1.PaperPositionMode = 'auto';
                set(f1, 'Position', get(0,'Screensize')); % Maximize figure.
                saveas(f1, [obj.cfg.get('outputVideoFileName'), '/', filename], 'png');
                %print(f1, '-dpng','-r500', [obj.cfg.get('outputVideoFileName'), 'subplots.png']);
            else
                set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
                saveas(gcf, [obj.cfg.get('outputVideoFileName'), '/', filename], 'png');
            end
        end
        
        function PlotScatter(obj, frame_indices, costcols, figure_title, startInd, endInd, tempDist, Term, save)
            figure;
            imagesc(startInd:endInd-1,1:tempDist,Term'); set(gca,'YDir','normal');
            title(figure_title); colorbar; xlabel('Frame Num'); ylabel('Jump Dist');
            hold on;
            scatter(frame_indices(1:end-1),costcols(1:end-1),'r','LineWidth',2);
            
            if save
                obj.SaveChart(strcat(figure_title, ' Scatter.png'));
            end
            set(gcf, 'Visible', 'off');
        end
        
        function PlotChart(obj, x, y, lineType, maintitle, chartLegend, save)
            figure;
            h = plot(x, y, lineType);
            set(h(1), 'linewidth', 2);
            xlabel('Frame # In Orig Video');
            ylabel('Cost');
            title(maintitle,'Interpreter','None');
            legend(chartLegend);
            
            if save
                obj.SaveChart(strcat(chartLegend, 'Plot.png'));
            end
            set(gcf, 'Visible', 'off');
        end
        
        function foe_locations = getFoeLocations(obj)
            FOECostEstimator = FOEDistanceCost(obj.sd,obj.cfg);
            foe_locations = nan(numel(obj.Frame_indices(1:end-1)),2);
            %disp(obj.Frame_indices');
            for i=1:numel(obj.Frame_indices(1:end-1))
                foe_locations(i,:) = FOECostEstimator.getFoe(obj.Frame_indices(i),obj.Frame_indices(i+1));
            end
        end
        
        function epipoleLocations = getEpipoleLocations(obj)
            EpipoleCostEstimator = EpipoleFOEDistanceCost(obj.sd,obj.cfg);
            baseFileName = obj.cfg.get('baseDumpFrameFileName');
            firstImgNum = obj.cfg.get('startInd');
            sz = size(rgb2gray(imread(sprintf(baseFileName, firstImgNum))));
            epipoleLocations = nan(numel(obj.Frame_indices(1:end-1)),2);
            for i=1:numel(obj.Frame_indices(1:end-1))
                epipoleLocations(i,:) = EpipoleCostEstimator.getEpipole(obj.Frame_indices(i),obj.Frame_indices(i+1),sz);
                %                  if max(abs(foeLocations(i,:)) ) > .5 || isnan(epipoleLocations(i,1) )
                %                      %foeLocations(i,:) = nan;
                %                      epipoleLocations(i,:) = nan;
                %                  end
            end
        end
        
        function ShowSelectedFramesFOE(obj, save)
            
            %foe_locations = obj.FOE_locations;
            foe_variance = nanvar(obj.FOE_locations);
            foe_diffs(:,1) = obj.FOE_locations(1:end-1,1) - obj.FOE_locations(2:end,1);
            foe_diffs(:,2) = obj.FOE_locations(1:end-1,2) - obj.FOE_locations(2:end,2);
            jitter = mean(sqrt(sum(foe_diffs.^2,2)));
            %o=zeros(size(epipoleLocations,1),2);
            o=zeros(size(foe_diffs,1),2);
            figure;
            %first_n_numbers= 1:size(obj.Frame_indices(1:end-1)', 2);
            plot3(obj.Frame_indices(2:end-1)',o(:,1),o(:,2),'b','LineWidth',2);
            xlabel('Frame#');
            ylabel('X coord');
            zlabel('Y coord');
            image_title = sprintf('Jitter = %.4f --- FOE Variance = (%.4f, %4f)', jitter, foe_variance);
            title(image_title,'Interpreter','None');
            legend('Perfect FOE Difference Between Consecutive Frames');
            
            %hold on; scatter3(obj.Frame_indices(1:end-1)',epipoleLocations(:,1),epipoleLocations(:,2),'g','LineWidth',2);
            
            hold on; scatter3(obj.Frame_indices(2:end-1)',foe_diffs(:,1),foe_diffs(:,2),'r');
            
            %f2 = gcf;
            %f2.PaperPositionMode = 'auto';
            %set(f2, 'Position', get(0,'Screensize')); % Maximize figure.
            set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
            if save
                %saveas(f2, [obj.cfg.get('outputVideoFileName'), '/FoeLocations.png'], 'png');
                saveas(gcf, [obj.cfg.get('outputVideoFileName'), '/FoeLocations.png'], 'png');
            end
            set(gcf, 'Visible', 'off');
            %naive_epipole_variance = nanvar(epipoleLocations);
            %num_of_nans_naive = sum(isnan(epipoleLocations(:)));
            
        end
        
        function rects = Filter_Semantics(obj, rects)
            detected_semantic_size = length(rects);
            j = 1;
            while j <= detected_semantic_size
                if rects(j).score <= 60
                    rects(j) = [];%Deletes the structure, once it's not a semantic
                    detected_semantic_size = detected_semantic_size - 1;
                else
                    j = j + 1;
                end
            end
        end
        
    end
end
