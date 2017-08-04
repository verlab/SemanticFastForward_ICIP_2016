classdef InterframeCost < handle
    %InterframeCost evaluates the cost of succesive frames in the output
    %video
    
    
    properties
        sd;
        numBlocks;
        cfg;
    end
    
    methods

        function obj = InterframeCost(sd,cfg)
            obj.cfg = cfg;
            obj.sd = sd;
            obj.numBlocks = [sd.num_x_cells,sd.num_y_cells];   
        end
        
        function [cost] = calculateCostBatch ...
            (obj, ~, ~, startBatch, endBatch)
            
            temperal_dist = obj.cfg.get('maxTemporalDist');
            firstImgNum = startBatch;%obj.cfg.get('startInd');
            lastImgNum  = endBatch;%obj.cfg.get('endInd');
          
            % Return zero cost.
            cost = zeros(lastImgNum-firstImgNum+1,temperal_dist);
            
        end
       
    end
    
end

