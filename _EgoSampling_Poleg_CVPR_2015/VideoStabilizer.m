classdef VideoStabilizer < handle
    %VideoStabilizer abstract video stabilizer class.
    
    properties
        sd;
        cfg;
        frame_inds;
        useVideo;
        vreader;
    end
    
    methods
        function obj = VideoStabilizer(sd, cfg,frame_inds)
            obj.sd = sd;
            obj.cfg = cfg;
            obj.frame_inds = frame_inds;
            
            obj.useVideo=0;
            obj.vreader=[];
            
            f = obj.cfg.get('baseDumpFrameFileName');
            if ~exist(sprintf(f,1),'file')
                fprintf('%sVideoStabilizer is using original videos for frame source\n',log_line_prefix);
                obj.useVideo=1;    
                obj.vreader = VideoReader(obj.cfg.get('inputVideoFileName'));
            else
                fprintf('%sVideoStabilizer is using frame dumps for frame source\n',log_line_prefix);
            end
        end
        
        function res = HasNext(obj)
            error('Not implemented');
        end
        
        
        function stableFrame = StabilizeNext(obj)
            stableFrame = [];
            error('Not implemented');
        end
                
    end
    
end

