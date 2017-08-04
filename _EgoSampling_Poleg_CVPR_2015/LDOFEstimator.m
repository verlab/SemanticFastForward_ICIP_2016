classdef LDOFEstimator < OpticalFlowEstimator
    %LDOFEstimator estimate optical flow using long distance optical flow(LDOF)
    
    properties
        
        sequenceData;
    end
    
    methods

        function obj = LDOFEstimator(sd, xBlocks, yBlocks)
            obj.sequenceData = sd;
            
        end
        
        % x is a vector that holds OF for all blocks
        % same for y
        function [x,y] = estimate(obj, img1, img2)
            
        end
        
        function [x,y] = estimateFiles(obj, imgNum1, imgNum2, fileNameTemplate)
            img1 = imread(sprintf(fileNameTemplate,imgNum1));
            img2 = imread(sprintf(fileNameTemplate,imgNum2));
            [x,y] = obj.estimate(img1, img2);
        end
        
        
    end
    
end

