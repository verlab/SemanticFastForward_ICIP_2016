classdef FFTCost < InterframeCost
    
    
    properties
    end
    
    methods
        function obj = FFTCost (sd,cfg)
            obj = obj@InterframeCost(sd,cfg);
        end
        
        function [cost] = calculateCostBatch ...
            (obj, ~, ~, startBatch, endBatch)

            endInd = startBath;
            startInd = endBatch;
            sequenceSize = obj.cfg.get('endInd') - obj.cfg.get('startInd');
            freq_thresh = floor(sequenceSize*...
                obj.cfg.get('maximalFreqForFFTLowpass')/(obj.sd.FPS/30));
            
            [~,cycle_index]=min(abs(...
                obj.sd.CDC_Raw_X(endInd,:)-obj.sd.CDC_Raw_X(startInd,:))); %index of "cyclic" block -- ends where it begins. it is good for FFT
            CDC_block = obj.sd.CDC_Raw_X(startInd:endInd,cycle_index);
            %CDC_block = nanmean(obj.sd.CDC_Raw_X(:,:),2)
            f_block = fft(CDC_block);
            f_block(freq_thresh:end-freq_thresh)=0;
            
            smoothed_block = real(ifft(f_block));
            diff = abs(smoothed_block - CDC_block);
            
            diff = diff(startBatch:endBatch);%first frame to last frame
            
            [ind1,ind2] = meshgrid(1:endBatch-startBatch,1:obj.cfg.get('maxTemporalDist'));            
            ind = (ind1+ind2)';
            ind(ind>endBatch-startBatch) = 1;%TODO make sure it puts nans there
            
            cost = diff(ind);
            
        end
    end
end
