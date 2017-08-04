classdef CandidateFrameSelector 
    %CandidateFrameSelector selects output frames 
    
    properties
        cfg;%ConfigWrapper
    end
    
    methods
        
        function obj = CandidateFrameSelector (cfg)
            obj.cfg = cfg;
        end
        
        function frame_indices = selectFrames (obj, interFrameCost)
            
        end
    end
    
end

