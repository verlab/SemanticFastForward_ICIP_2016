classdef ZeroCost < InterframeCost
    %ZeroCost returns just zero cost without doing and processing.
    
    
    methods

        function obj = ZeroCost(sd,cfg)
            obj = obj@InterframeCost(sd,cfg);
        end

        function [cost] = calculateCostBatchListFrames ...
                (obj,OF_X,OF_Y, frame_indices) 
        
            cost = calculateCostBatch (OF_X,OF_Y);
        end
        
        function [cost] = calculateCostBatch ...
                 (obj,~,~,startBatch, endBatch)
            
            temperal_dist =  obj.cfg.get('maxTemporalDist');
            firstImgNum = startBatch; %obj.cfg.get('startInd');
            lastImgNum  = endBatch; %obj.cfg.get('endInd');
          
            % Return zero cost.
            cost = zeros(lastImgNum-firstImgNum+1,temperal_dist);
            
        end
       
    end
    
end

