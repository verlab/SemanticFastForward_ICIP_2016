classdef SequenceProducer < handle
    %SequenceExporter connects all the pieces together
    
    properties
        cfg; % ConfigWrapper
        sd;  % SequenceData
        Frame_indices;
    end
    
    methods
        function obj = SequenceProducer(sd, cfg)
            obj.cfg = cfg;
            obj.sd = sd;
            obj.Frame_indices = [];
        end
        
        
        function run(obj)    
            
            obj.PreProcess();
            
            obj.PrepareCostTerms();
            
            obj.Solve();
            
            obj.PostProcess();
            
            if obj.cfg.get('SkipVideoOutput')~=1
                obj.ExportVideo();
            else
                fprintf('%Skipping Video output (''SkipVideoOutput''==%d)\n',log_line_prefix, obj.cfg.get('SkipVideoOutput'));
            end        
        end

        
        function PreProcess(obj)
        end;
        
        
        function PrepareCostTerms(obj)
        end
        
        function Solve(obj)
        end
        
        function PostProcess(obj)
        end;
        
        function ExportVideo(obj)
            vss = VideoSubSampler (obj.sd, obj.cfg);
            fprintf('%sWriting %d frames to output video ...\n%s\n',log_line_prefix, length(obj.Frame_indices), obj.cfg.get('outputVideoFileName'));
            vss.subSampleVideo(obj.Frame_indices);
            fprintf('%sDone exporting\n',log_line_prefix);
        end
        
        
        
    end
    
end


