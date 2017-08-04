classdef StereoPairsPicker < PeakPicker
    % StereoPairsPicker finds pairs of right and left images from monocular
    % video, to create stereo video
   
    properties 
    end
    
    methods
        function obj = StereoPairsPicker(sd, cfg)
            obj = obj@PeakPicker(sd,cfg);
        end
        
        function pairs = findPairs(obj)
            startInd = obj.cfg.get('startInd');
            endInd = obj.cfg.get('endInd');
            mean_rawX = mean(obj.sd.CDC_Raw_X(startInd:endInd,:),2);
            [~, right_loc] = findpeaks(mean_rawX,'MINPEAKDISTANCE',12);

%             plot (up_idx(up_idx<1000), rawY(up_idx(up_idx<1000),block),'--rs','MarkerSize',3,'LineWidth',1)
%             plot (right_loc, right_peaks,'--rs','MarkerSize',3,'LineWidth',1)
            left_loc = zeros(size(right_loc));
            for i = 1:size(right_loc)-1
                [~, left_loc(i)] = min (mean_rawX(right_loc(i):right_loc(i+1)));
            end
            left_loc = left_loc + right_loc -1; %the min in the loop gave loc relative to the right loc
            
            pairs = [right_loc(1:end-1) , left_loc(1:end-1)] + startInd -1;
        end
    end
end