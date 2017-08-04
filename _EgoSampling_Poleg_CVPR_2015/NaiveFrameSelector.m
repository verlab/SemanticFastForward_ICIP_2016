classdef NaiveFrameSelector < CandidateFrameSelector 
    %NaiveFrameSelector selects output frames based on uniform sampling
    
    properties
    end
    
    methods
        function obj = NaiveFrameSelector (cfg)
            obj = obj@CandidateFrameSelector (cfg);
        end
        
        function frame_indices = selectFrames (obj, ~, ~, ~)
            number_of_frames = obj.cfg.get('endInd')-obj.cfg.get('startInd')+1;
            frame_indices = 1 : obj.cfg.get('FastForwardSkipRatio') : number_of_frames;
        end
        
    end
    
end

