classdef ColorHistogramCost < InterframeCost
    %ColorHistogramCost calculates cost to be the difference between
    %two histograms
    properties
    end
    
    methods

        function obj = ColorHistogramCost(sd,cfg)
            obj = obj@InterframeCost(sd,cfg);
        end
        
        function cost = calculateCostBatchListFrames...
                (obj, ~, ~, frame_indices, startBatch, endBatch)

%             firstImgNum = obj.cfg.get('startInd');
            temporal_dist = obj.cfg.get('maxTemporalDist');
            cost = ones(endBatch-startBatch+1,temporal_dist)*nan;
            
            lastFullEstimation = min(endBatch+ temporal_dist, obj.cfg.get('endInd') );
%             if endBatch == obj.cfg.get('endInd');
%                 hist = obj.sd.FramesHistogram(startBatch:endBatch);
%                 for i = 1:temporal_dist %just to make index not out of bounds later... it does not affect anything
%                    hist{numel(frame_indices)+i} = zeros(size(hist{1}));
%                 end
%             else
                hist = obj.sd.FramesHistogram(startBatch:lastFullEstimation );
%                 for i = 1:endBatch + temporal_dist - lastFullEstimation; %just to make index not out of bounds later... it does not affect anything
%                    hist{numel(frame_indices)+i} = zeros(size(hist{1}));
%                 end
% %             end
            
            for i = 1:numel(frame_indices)
                if mod(i,50) == 0
                    fprintf('%sCalculating histogram cost frame %d (%d/%d for this batch)\n',log_line_prefix,frame_indices(i),i,numel(frame_indices));
                end
                
%                 found = 0;
                last = min (temporal_dist, lastFullEstimation-frame_indices(i));
                for j = 1:last
                    cost(frame_indices(i)-startBatch+1,j) = ...
                        sum(sum(abs(cumsum(hist{i}) - cumsum(hist{i+j}))));
                
                    %if frame_indices(i)+j is also one of the indices we
                    %are looking for... otherwise the cost is inf
%                     [m,k] = min(abs(frame_indices(i)+j-frame_indices));
%                     if m == 0
%                         cost(frame_indices(i)-startBatch+1,j) = ...
%                             sum(sum(abs(cumsum(hist{i}) - cumsum(hist{k}))));
%                         found = 1;
%                     end
                end
                
%                 if found == 0 && i < numel(frame_indices)
%                     warning('frame %d has inf color histogram cost to all out edges!',frame_indices(i));
%                 end
            end
            
        end

        
        function [cost] = calculateCostBatch ...
                (obj, ~, ~, startBatch, endBatch)

            firstImgNum = startBatch; %obj.cfg.get('startInd');
            lastImgNum  = endBatch; %obj.cfg.get('endInd');
            
            frame_indices = firstImgNum : lastImgNum;
%                 min(lastImgNum + obj.cfg.get('maxTemporalDist'), obj.cfg.get('endInd'));

%             if lastImgNum + obj.cfg.get('maxTemporalDist') >= obj.cfg.get('endInd')
%                 frame_indices = firstImgNum : obj.cfg.get('endInd');
%             else 
%                 frame_indices = firstImgNum : lastImgNum + obj.cfg.get('maxTemporalDist');
%             end
            
            cost = obj.calculateCostBatchListFrames([], [], frame_indices, startBatch, endBatch);
%             cost = cost(1 : lastImgNum - firstImgNum +1, :);
        end
    end
end
