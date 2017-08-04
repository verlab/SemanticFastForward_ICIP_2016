classdef  AngleDiffrenceCost < InterframeCost
    %AngleDiffrenceCost calculates sum of angles between OF fields
    
    properties 
        smallAnglesPercentage;
    end
    
    methods
        %% constructor 
        %smallAnglesPercentage is the percentage of the diffrence in angles
        %between the two OF to take into count. It is between 0-100.
        %for example smallAnglesPercentage=80 means the biggest 20 percent
        %of the angle differences will be ingored. It is used so that the
        %cost will not suffer to much from moving objects (which the OF  
        %differs highly from the backgrounds OF)
        function obj = AngleDiffrenceCost (sd, cfg, smallAnglesPercentage)
            obj = obj@InterframeCost(sd, cfg);
            obj.smallAnglesPercentage = smallAnglesPercentage;
        end
           
        function [cost] = calculateCostBatch ...
                (obj, estimated_OF_X, estimated_OF_Y)

            
            firstImgNum = obj.cfg.get('startInd');
            lastImgNum  = obj.cfg.get('endInd');

            reference_OF_X = obj.sd.CDC_Smoothed_X(firstImgNum:lastImgNum,:);
            reference_OF_Y = obj.sd.CDC_Smoothed_Y(firstImgNum:lastImgNum,:);
            reference_OF_X = repmat(reference_OF_X, [1, 1, size(estimated_OF_X,3)]);
            reference_OF_Y = repmat(reference_OF_Y, [1, 1, size(estimated_OF_X,3)]);

            ang = abs(atan2(estimated_OF_X.*reference_OF_Y - estimated_OF_Y.*reference_OF_X,...
                estimated_OF_X.*reference_OF_X + estimated_OF_Y.*reference_OF_Y));

            %moving objects can give realy big angle changes, and they are
            %outliers, to try to avoid them only bigDifferencePercentage of
            %the angles is used
            sorted_ang = sort(ang,2);
            sorted_ang = sorted_ang(:,1:(obj.numBlocks(1)*obj.numBlocks(2)*obj.smallAnglesPercentage/100),:);
            
            sum_ang_diff = squeeze(sum(sorted_ang,2));
            cost = sum_ang_diff;
                
        end    
    end
    
end

