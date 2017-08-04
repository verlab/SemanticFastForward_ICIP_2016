classdef FOEDistanceCost < InterframeCost
    %FOEDistanceCost calculates FOE distance between two OF fields
    
    properties
        foeFinder;
    end

    methods
        function obj = FOEDistanceCost (sd, cfg)
            obj = obj@InterframeCost(sd, cfg);
            obj.foeFinder = FOEFinder(obj.sd, obj.cfg); 
        end
        
        function [cost] = calculateTriFrameCostBatch...
                (obj, ~,~, startBatch, endBatch)
            
            firstImgNum = startBatch;%obj.cfg.get('startInd');
            lastImgNum  = endBatch;%obj.cfg.get('endInd');
          
            temporal_dist = obj.cfg.get('maxTemporalDist');
            %hack to have some more OF 
            OFEstimator = CumulativeLKEstimator(obj.sd,obj.cfg);
            [estimated_OF_X, estimated_OF_Y,~,~] = OFEstimator.estimateBatch(startBatch, min(endBatch+temporal_dist,obj.cfg.get('endInd')));
            
            %indices inside cost: 
            % cost(i,j,k) :  
            % i -- frame number
            % j -- dist to second frame
            % k -- dist from i+j to third frame           

            fprintf('%sCalculating higher order FOE cost term\n',log_line_prefix);
            last = min(lastImgNum + temporal_dist, obj.cfg.get('endInd'));

            foe = inf(last-firstImgNum+1, size(estimated_OF_X,3), 2);
            for i = 1:last-firstImgNum
                if mod(i,50) == 0                    
                    fprintf('%sCalculating FOE for Higher order shakness cost frame %d, (%d/%d in this batch)\n',log_line_prefix,i + firstImgNum-1,i, (last-firstImgNum+1));
                end
                for j = 1:size(estimated_OF_X,3)
                    [foe_x, foe_y] = obj.foeFinder.FOEfromOF(estimated_OF_X(i,:,j),estimated_OF_Y(i,:,j));
                    foe(i,j,:)  = [foe_x/obj.numBlocks(1),foe_y/obj.numBlocks(2)];                    
                end
            end

            foe = cat(1, foe, nan(lastImgNum-firstImgNum+1+temporal_dist-size(foe,1), size(foe,2),2));
            
            cost = ones(lastImgNum-firstImgNum+1, temporal_dist, temporal_dist)*inf;
            for i = 1:lastImgNum-firstImgNum+1
                if mod(i,50) == 0   
                    fprintf('%sFilling Higher order shakness FOE cost matrix %d, (%d/%d in this batch)\n',log_line_prefix,i + firstImgNum-1,i, (lastImgNum-firstImgNum+1));
                end
                for j = 1:temporal_dist 
                    for k =1:temporal_dist 
                        cost (i,j,k) = sqrt(sum((foe(i+j,k,:) - foe(i,j,:)).^2)); 
                    end
                end
            end                            
        end
        
           
        function [cost] = calculateCostBatch ...
                    (obj, estimated_OF_X, estimated_OF_Y, startBatch, endBatch)

            firstImgNum = startBatch;%obj.cfg.get('startInd');
            lastImgNum  = endBatch;%obj.cfg.get('endInd');

            foe_diff = zeros(size(estimated_OF_X,1),size(estimated_OF_X,3));

            %profile on;
            for i = 1:lastImgNum-firstImgNum+1  %size(estimated_OF_X,1)
                if mod(i,50) == 0
                    
                    fprintf('%sCalculating FOE shakness cost frame %d, (%d/%d in this batch)\n',log_line_prefix,i + firstImgNum-1,i, (lastImgNum-firstImgNum+1));
                    %profile viewer;
                    %display([]);
                end
                
                % TODO: move code from 'find_foe_from_flow_field_block' into this class 
                switch obj.cfg.get('FOE_Reference')
                    case 'Absolute'
                        baseline_x=0;
                        baseline_y=0;
                    case 'SmoothedCDC'
                        [baseline_x, baseline_y] = obj.foeFinder.FOE(i+firstImgNum-1);
                    otherwise
                        error('Invalid ''FOE_Reference'' values "%s".');
                end
                baseline_x = (baseline_x/obj.numBlocks(1));
                baseline_y = (baseline_y/obj.numBlocks(2));
           
                for j = 1:size(estimated_OF_X,3)
                    [foe_x, foe_y] = obj.foeFinder.FOEfromOF(estimated_OF_X(i,:,j),estimated_OF_Y(i,:,j));
                    foe_x = foe_x/obj.numBlocks(1);
                    foe_y = foe_y/obj.numBlocks(2);
                    foe_diff(i,j) = norm([foe_x-baseline_x foe_y-baseline_y]);
                end
            end
            
            cost = foe_diff;

        end
        
        function foe = getFoe (obj, index1, index2)
            if index2 <= index1 || index2 > index1 + obj.cfg.get('maxTemporalDist')
                error('second index should greater than the first index (and not too much greater)');
            end
            OF_x = obj.sd.CDC_Raw_X(index2,:) - obj.sd.CDC_Raw_X(index1,:);
            OF_y = obj.sd.CDC_Raw_Y(index2,:) - obj.sd.CDC_Raw_Y(index1,:);
            [foe_x, foe_y] = obj.foeFinder.FOEfromOF(OF_x, OF_y);
            foe = [foe_x/obj.numBlocks(1), foe_y/obj.numBlocks(2)] ;
        end
    end
end
            
            

