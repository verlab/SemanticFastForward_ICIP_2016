classdef  OFPeaksCost < InterframeCost
    %OFPeaksCost Assigns zero cost to peaks candidates, and infinite 
    %cost to all other frames
    
    properties 
    end
    
    methods

        %% constructor 
        function obj = OFPeaksCost (sd, cfg)
            obj = obj@InterframeCost(sd, cfg);

        end

        function [cost] = calculateCostBatch ...
                (obj, estimated_OF_X, ~, startBatch, endBatch , peaks)
   
            %in case of pairs we only use the first of every pair
            if size(peaks,2) > 1
                peaks = peaks(:,1);
            end
            tempDist = obj.cfg.get('maxTemporalDist');

            endInd = min(endBatch + tempDist, obj.cfg.get('endInd'));
            startInd = startBatch;%obj.cfg.get('startInd');

            peaks = peaks(peaks >= startInd & peaks <= endInd);

            [ind1,ind2] = meshgrid(1:size(estimated_OF_X,1),1:size(estimated_OF_X,3));            
            ind = (ind1+ind2)';
            
            per_frame_cost = [ones(endInd-startInd+1,1)*inf; ones(endBatch + tempDist - endInd,1)*nan];
            per_frame_cost (peaks - startInd +1) = -.001;
            cost = per_frame_cost(ind);
        end
    end
end

