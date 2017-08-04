classdef VideoSubSampler < handle
    %VideoSubSampler subsamples video according to list of frame indices
    
    properties
        sd;
        cfg;
    end
    
    methods
        function obj = VideoSubSampler(sd, cfg)
            obj.sd = sd;
            obj.cfg = cfg;
        end
                
        function subSampleStereoVideo(obj, pairs)
            

            switch obj.cfg.get('OutputStablizer')
                case 'None'
                    stabilizer=NullVideoStabilizer(obj.sd,obj.cfg,pairs);
                case 'StereoStabilizer'
                    stabilizer=StereoVideoStabilizer(obj.sd,obj.cfg,pairs);
            end
            
            writer = VideoWriter(obj.cfg.get('outputVideoFileName'));
            writer.FrameRate = 30;%obj.sd.FPS

            fprintf('%sStarting to and export frames from dump..\n',log_line_prefix);
            writer.open();
            for i = 1:size(pairs,1)
                if stabilizer.HasNext()==0
                    break;
                end
                
                [left,right] = stabilizer.StabilizeNextPair();
                
                
                if obj.cfg.get('StereoOutputWCropPercent')>0
                    Wcrop = ceil(obj.cfg.get('StereoOutputWCropPercent') * size(left,2));
                    if Wcrop>0
                        left = left(:,Wcrop:end-Wcrop);
                        right = right(:,Wcrop:end-Wcrop);
                    end
                end
                
                if obj.cfg.get('StereoOutputHCropPercent')>0
                    Hcrop = ceil(obj.cfg.get('StereoOutputHCropPercent') * size(left,1));
                    if Hcrop>0
                        left = left(Hcrop:end-Hcrop,:);
                        right = right(Hcrop:end-Hcrop,:);
                    end
                end
                
                switch obj.cfg.get('StereoFrameOrdering')
                    case 'Interleaving'
                        writer.writeVideo(right);
                        writer.writeVideo(left);
                    case 'SideBySide'
                        writer.writeVideo([left right]);
                    case 'RedCyan'
                        I=imfuse(left,right,'ColorChannel','red-cyan');
                        writer.writeVideo(I);
                end
                
                if obj.cfg.get('ShowOutputWhileDumping')==1
                    if i==1
                        f=figure;
                    end
                    figure(f);
                    imshowpair(left,right,'ColorChannels','red-cyan');
                    title(sprintf('Frames [%d,%d]',pairs(i,2),pairs(i,1)));
                    drawnow;
                end
                
                if mod(i,50) == 0
                    fprintf('%sExporting pair #%d..\n',log_line_prefix,i);
                end
            end
            writer.close();
            fprintf('%sDone exporting pairs..\n',log_line_prefix);
        end
        
        function subSampleVideo (obj, frame_indices)
            reader = VideoReader(obj.cfg.get('inputVideoFileName'));
            if max(frame_indices) > reader.NumberOfFrames 
                error('output frame index %d exceded input video size %d',max(frame_indices),reader.NumberOfFrames);
            end
            writer = VideoWriter(obj.cfg.get('outputVideoFileName'));
            writer.FrameRate = reader.FrameRate;

            fprintf('%sStarting to export frames..\n',log_line_prefix);

            baseFileName = obj.cfg.get('baseDumpFrameFileName');
            
            %if no dump exists, reading the frames from the video
            if ~exist(sprintf(baseFileName,frame_indices(1)),'file')
                readVideo = true;
                reader = VideoReader(obj.cfg.get('inputVideoFileName'));
            else
                readVideo = false;    
            end
            
            writer.open();            
            for i = 1:length(frame_indices)
                if readVideo
                    frame = read(reader,frame_indices(i));
                else
                    frame = imread(sprintf(baseFileName,frame_indices(i)));
                end
                
                if obj.cfg.get('OutputOriginalFrameNum')==1 || obj.cfg.get('OutputOriginalTimestamp')==1
                    embedText  = '';
                    
                    if obj.cfg.get('OutputOriginalTimestamp')==1 
                        embedText = sprintf('[%s]',datestr((frame_indices(i)/reader.FrameRate)/86400,'HH:MM:SS'));
                    end
                    
                    if obj.cfg.get('OutputOriginalFrameNum')==1 
                        embedText = sprintf('%s Frame #%d',embedText,frame_indices(i));
                    end
                    
                    frame = insertObjectAnnotation(frame,'rectangle',[20,20,5,5],embedText,'FontSize',20); 
                end
                
                writer.writeVideo(frame);
                
                if obj.cfg.get('ShowOutputWhileDumping')==1
                    if i==1
                        f=figure;
                    end
                    figure(f);
                    imshow(frame);
                    title(sprintf('Frame %d',frame_indices(i)));
                    drawnow;
                end
                

                
                
                if mod(i,50) == 0
                    fprintf('%sExporting frame #%d..\n',log_line_prefix,i);
                end
            end
            fprintf('%sDone exporting frames..\n',log_line_prefix);
            writer.close();
        end
    end
    
end

