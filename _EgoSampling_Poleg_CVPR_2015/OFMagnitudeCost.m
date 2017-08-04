classdef  OFMagnitudeCost < InterframeCost
    %OFMagnitudeCost Assigns a penalty for deviating from the required
    %velocity, expressed as optical flow magnitude.
    
    properties 
        
    end
    
    methods
        
        
        function obj = OFMagnitudeCost (sd, cfg)
            obj = obj@InterframeCost(sd, cfg);
            
        end
           
        function [cost] = calculateCostBatch ...
                (obj, estimated_OF_X, estimated_OF_Y, startBatch, endBatch)

            switch obj.cfg.get('VelocityTarget')
                case 'Manual'                    
                    reference_velocity = obj.cfg.get('VelocityManualTargetValue');
                case 'CumulativeMean'
                    wished_skip = obj.cfg.get('FastForwardSkipRatio'); %this is the speed we want to fast forward to
                    square_velocity_x = (obj.sd.CDC_Raw_X(obj.cfg.get('startInd')+wished_skip:obj.cfg.get('endInd'),:)...
                        -obj.sd.CDC_Raw_X(obj.cfg.get('startInd'):obj.cfg.get('endInd')-wished_skip,:)).^2;
                    square_velocity_y = (obj.sd.CDC_Raw_Y(obj.cfg.get('startInd')+wished_skip:obj.cfg.get('endInd'),:)...
                        -obj.sd.CDC_Raw_Y(obj.cfg.get('startInd'):obj.cfg.get('endInd')-wished_skip,:)).^2;
                    reference_velocity = nanmean(sum(sqrt(square_velocity_x + square_velocity_y),2));
                
                otherwise
                    error('Unknown ''VelocityTarget'' value "%s"',obj.cfg.get('VelocityTarget'));
            end
            
            cost = abs(...
                    squeeze(sum(sqrt(estimated_OF_X.^2 + estimated_OF_Y.^2),2))...
                  - reference_velocity);
        end    
    end
    
end

