classdef OpticalFlowEstimator < handle
    
    %OpticalFlowEstimator general optical flow estimator between two frames
    
    
    properties
        sequenceData;
        numBlocks;
        cfg;
    end
    
    methods

        function obj = OpticalFlowEstimator(sd,cfg)
            obj.sequenceData = sd;
            obj.numBlocks = sd.num_x_cells*sd.num_y_cells;   
            obj.cfg = cfg;
        end
        
        function [x,y] = estimate(obj, img1, img2)
            
            
        end
        % x is a vector that holds OF for all blocks
        % same for y
        function [x,y] = estimateFiles(obj, imgNum1, imgNum2, fileNameTemplate)
        end
        
        
        function [cumulative_OF_X, cumulative_OF_Y, source_frame_indices, dest_frame_indices] = estimateBatch (obj)
            % This function returns 4 empty matrices.
            [cumulative_OF_X, cumulative_OF_Y, source_frame_indices, dest_frame_indices] = ndgrid([],0,0,0);
        end
            
    end
    
end

