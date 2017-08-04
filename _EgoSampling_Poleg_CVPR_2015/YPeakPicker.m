classdef YPeakPicker < PeakPicker
    %PeakPicker picks peaks in Y componenet of cumulative OF
    %Hopefully those peaks would correspond to smooth path in the 
    %real world, and a smooth subsampled video
   
    properties 
    end
    
    methods
        function obj = YPeakPicker (sd, cfg)
            obj = obj@PeakPicker(sd,cfg);
        end
        
        function peaks = findPeaks(obj)
            startInd = obj.cfg.get('startInd');
            endInd = obj.cfg.get('endInd');
            mean_rawX = mean(obj.sd.CDC_Raw_X(startInd:endInd,:),2);
            [~, peaks] = findpeaks(mean_rawX,'MINPEAKDISTANCE',12);

            peaks = peaks + startInd -1;
        end
    end
end
