classdef CumulativeLKEstimator < OpticalFlowEstimator
    %CumulativeLKEstimator estimates optical flow between
    %two frames of a video using cumulative optical flow
    %between successive frames
    
    properties
    end
    
    methods
        %% constructor 
        function obj = CumulativeLKEstimator(sd, cfg)
            obj = obj@OpticalFlowEstimator(sd,cfg);
        end
        
        %% estimate cumulative optical flow for batch of frames
        %INPUT
        % starting firstImgNum and ending lastImgNum
        % maxTemporalDist is the maximal temporal distance (in frames) 
        % between two frames, that the function will calculate the OF for.
        %
        %OUTPUT 
        % cumulative_OF_X is a 3d array with size:
        %   [number of frames, number of blocks, maxTemporalDist]
        % cumulative_OF_X(i,j,k) corresponds to the estimated OF between
        % frame i and i+k in block j.
        % source and dest frame indices are indices to the sparse matrix
        % for the graph shortest path method.
        
        function [cumulative_OF_X, cumulative_OF_Y, source_frame_indices, dest_frame_indices] = ...
                estimateBatch (obj, startBatch, endBatch)
            firstImgNum = startBatch;%obj.cfg.get('startInd'); 
            lastImgNum = endBatch;%obj.cfg.get('endInd');
            temporalDist = obj.cfg.get('maxTemporalDist');
            
            batch_size = lastImgNum - firstImgNum +1;

            
            raw_x = obj.sequenceData.CDC_Raw_X(firstImgNum : lastImgNum ,:);
            raw_y = obj.sequenceData.CDC_Raw_Y(firstImgNum : lastImgNum ,:);
            
            [block_index,frame_index,temporal_dist_index] = ...
                    meshgrid(1 : obj.numBlocks, ...
                             1 : batch_size,... 
                             1 : temporalDist);
            
            index = frame_index + temporal_dist_index + ...
                              (block_index-1) * (batch_size + temporalDist);

            lastFullEstimation = min(lastImgNum + temporalDist, obj.cfg.get('endInd') );
%             if obj.cfg.get('endInd') == lastImgNum
%                 %the last indices (maxTemporalDist of them) are beyond lastImgNum
%                 %no optical flow should be calculated to them
%                 x_with_out_of_range_nans = cat(1,raw_x,zeros(temporalDist,obj.numBlocks)*nan);
%                 y_with_out_of_range_nans = cat(1,raw_y,zeros(temporalDist,obj.numBlocks)*nan);
%             else %%use frames beyond current batch to calculate OF
            x_raw_max = obj.sequenceData.CDC_Raw_X(firstImgNum : lastFullEstimation,:);
            y_raw_max = obj.sequenceData.CDC_Raw_Y(firstImgNum : lastFullEstimation, :);
            
            nans_to_pad = lastImgNum + temporalDist - lastFullEstimation;
            x_with_out_of_range_nans = cat(1,x_raw_max, zeros(nans_to_pad , obj.numBlocks)*nan);
            y_with_out_of_range_nans = cat(1,y_raw_max, zeros(nans_to_pad , obj.numBlocks)*nan);
%             end
            
            cumulative_OF_X = x_with_out_of_range_nans(index) - ...
                                repmat(raw_x, [1 1 temporalDist]);
            cumulative_OF_Y = y_with_out_of_range_nans(index) - ...
                                repmat(raw_y, [1 1 temporalDist]);

            out_of_range_indices = isnan(cumulative_OF_X (:,1,:));

            source_frame_indices = repmat( 1:batch_size, [1 temporalDist]);
            source_frame_indices(out_of_range_indices) = nan;
            %source_frame_indices = source_frame_indices(~out_of_range_indices(:));

            dest_frame_indices   = index(:,1,:);
            dest_frame_indices(out_of_range_indices) = nan;%   = dest_frame_indices(:)';
            %dest_frame_indices   = dest_frame_indices(~out_of_range_indices(:));

            end
        
    end
    
end

