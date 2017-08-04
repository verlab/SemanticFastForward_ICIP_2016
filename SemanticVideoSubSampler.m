%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   This file is part of ICIP.
%
%    ICIP is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    ICIP is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with ICIP.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Class Name: SemanticVideoSubSampler
% 
% This class is an adaptation of the VideoSubSampler class present
% in the EgoSampling code. It subsamples the video according to   
% list of frame indices.
%
% $Date: July 26, 2017
% ____________________________________________________________________
classdef SemanticVideoSubSampler < handle
    %SemanticVideoSubSampler subsamples video according to list of frame indices
    
    properties
        sd;
        cfg;
        SemanticData;
    end
    
    methods
        function obj = SemanticVideoSubSampler(sd, cfg, SemanticData)
            obj.sd = sd;
            obj.cfg = cfg;
            obj.SemanticData = SemanticData;
        end
        
        function subSampleStereoVideo(obj, pairs)
            switch obj.cfg.get('OutputStablizer')
                case 'None'
                    stabilizer=NullVideoStabilizer(obj.sd,obj.cfg,pairs);
                case 'StereoStabilizer'
                    stabilizer=StereoVideoStabilizer(obj.sd,obj.cfg,pairs);
            end
            
            alpha = obj.cfg.get('ShakinessTermWeight');
            beta = obj.cfg.get('VelocityTermWeight');
            gamma = obj.cfg.get('AppearanceTermWeight');
            eta = obj.cfg.get('SemanticTermWeight');
            
            if(size(alpha, 2) > 1)
                writer = VideoWriter([obj.cfg.get('outputVideoFileName'), '/', obj.cfg.get('FileName'),...
                    '_S(', alpha(1,1), ',', alpha(1,2), ')_V(', beta(1,1), ',', beta(1,2),...
                    ')_A(', gamma(1,1), ',', gamma(1,2), ')_M(', eta(1,1), ',', eta(1,2), ')']);
            else
                writer = VideoWriter([obj.cfg.get('outputVideoFileName'), '/', obj.cfg.get('FileName'),...
                    '_S', obj.cfg.get('ShakinessTermWeight'), '_V', obj.cfg.get('VelocityTermWeight'),...
                    '_A', obj.cfg.get('AppearanceTermWeight'), '_M', obj.cfg.get('SemanticTermWeight')]);
            end
            writer.FrameRate = obj.cfg.get('FPS');
            
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
        
        function subSampleVideo (obj, frame_indices, foe_locations, output_video_filename)
            
            fprintf('%sLoading the input video to memory...\n',log_line_prefix);
            reader = VideoReader(obj.cfg.get('inputVideoFileName'));
            if max(frame_indices) > reader.NumberOfFrames
                error('output frame index %d exceded input video size %d',max(frame_indices),reader.NumberOfFrames);
            end
            
            fprintf('%sStarting to export frames...\n',log_line_prefix);
            
            alpha = obj.cfg.get('ShakinessTermWeight');
            beta = obj.cfg.get('VelocityTermWeight');
            gamma = obj.cfg.get('AppearanceTermWeight');
            eta = obj.cfg.get('SemanticTermWeight');
            
            if(size(alpha, 2) > 1)
                writer = VideoWriter([output_video_filename, '/', obj.cfg.get('FileName'),...
                    '_S(', num2str(alpha(1,1)), ',', num2str(alpha(1,2)), ')_V(', num2str(beta(1,1)), ',', num2str(beta(1,2)),...
                    ')_A(', num2str(gamma(1,1)), ',', num2str(gamma(1,2)), ')_M(', num2str(eta(1,1)), ',', num2str(eta(1,2)), ')']);
            else
                writer = VideoWriter([output_video_filename, '/', obj.cfg.get('FileName'),...
                    '_S', obj.cfg.get('ShakinessTermWeight'), '_V', obj.cfg.get('VelocityTermWeight'),...
                    '_A', obj.cfg.get('AppearanceTermWeight'), '_M', obj.cfg.get('SemanticTermWeight')]);
            end
            writer.FrameRate = reader.FrameRate;
            
            baseFileName = obj.cfg.get('baseDumpFrameFileName');
            
            %if no dump exists, reading the frames from the video
            %if ~exist(sprintf(baseFileName,frame_indices(1)),'file')
            %    readVideo = true;
            %    reader = VideoReader(obj.cfg.get('inputVideoFileName'));
            %else
            %    readVideo = false;
            %end
            
            writer.open();
            
            %Object access are high computational cost, therefore assigning
            %them outside loops is better than inside.
            showOutputWhileDumpling = obj.cfg.get('ShowOutputWhileDumping');
            saveFramesWhileDumping = obj.cfg.get('SaveFramesWhileDumping');
            outputOriginalFrameNum = obj.cfg.get('OutputOriginalFrameNum');
            outputOriginalTimestamp = obj.cfg.get('OutputOriginalTimestamp');
            outputTheoreticalSpeedup = obj.cfg.get('OutputTheoreticalSpeedup');
            outputFOEMovements = obj.cfg.get('OutputFOEMovements');
            outputSemanticBoxes = obj.cfg.get('OutputSemanticBoxes');
            outputSemanticWeight = obj.cfg.get('OutputSemanticWeight');
            %facesWeight = obj.cfg.get('SemanticWeight');
            
            if outputFOEMovements
                %Creating video OF adders
                foe_movements_frame = zeros(reader.height, reader.width, 3, 'uint8');
                
                %Adding the first difference of FOE OFs (it should be [x=0 y=0]
                foe_locations = vertcat([0 0], foe_locations);
                base_x = (size(foe_movements_frame, 2)/2);
                base_y = (size(foe_movements_frame, 1)/2);
                center_to_corner_distance = norm([base_x base_y] - [0 0]);
                amplifier_factor = min(center_to_corner_distance./max(foe_locations));
            end
            
            if outputTheoreticalSpeedup
                RangesAndSpeedups = obj.cfg.get('RangesAndSpeedups');
                Speedups = obj.cfg.get('Speedups');
                non_semantic_speedup = Speedups(1,2);
            end
            k = 1;
            for i = 1:length(frame_indices)
                %if readVideo
                %    frame = read(reader,frame_indices(i));
                %else
                %    frame = imread(sprintf(baseFileName,frame_indices(i)));
                %end
                
                %if read doesn't work, use readframe instead
                frame = read(reader,frame_indices(i));
                
                if outputOriginalFrameNum==1 || outputOriginalTimestamp==1 || outputSemanticWeight
                    embedText  = '';
                    
                    if outputOriginalTimestamp==1
                        embedText = sprintf('[%s]',datestr((frame_indices(i)/reader.FrameRate)/86400,'HH:MM:SS'));
                    end
                    
                    if outputOriginalFrameNum==1
                        embedText = sprintf('%s Frame #%d',embedText,frame_indices(i));
                    end
                    
                    if outputSemanticWeight
                        embedText = sprintf('%s SemanticWeight=%.3f', embedText, FrameSemanticValue(obj.SemanticData{frame_indices(i)}));
                    end
                    
                    if outputTheoreticalSpeedup
                        if frame_indices(i) >= RangesAndSpeedups(2,k)
                            while k < size(RangesAndSpeedups, 2) && frame_indices(i) > RangesAndSpeedups(2,k)
                                k = k+1;
                            end
                        end
                        
                        if frame_indices(i) < RangesAndSpeedups(1, k) || frame_indices(i) > RangesAndSpeedups(2, k)
                            speedupText = [num2str(non_semantic_speedup) 'x'];
                            frame = insertObjectAnnotation(frame,'rectangle',[size(frame,2),size(frame,1),5,5],speedupText,'FontSize',40);
                        else
                            speedupText = [num2str(RangesAndSpeedups(3, k)) 'x'];
                            frame = insertObjectAnnotation(frame,'rectangle',[size(frame,2),size(frame,1),5,5],speedupText,'FontSize',40);
                        end                     
                        
                    end
                    
                    frame = insertObjectAnnotation(frame,'rectangle',[20,20,5,5],embedText,'FontSize',20);
                end
                
                if outputSemanticBoxes
                    df_dts_i = obj.SemanticData{frame_indices(i)};
                    for j=1:length(df_dts_i)
                        face_score = sprintf('Sc=%.3f Gs=%.3f Sz=%.3f Total=%.3f',...
                        df_dts_i(j).score, df_dts_i(j).gaussianWeight, df_dts_i(j).faceSizeValue,...
                        df_dts_i(j).score * df_dts_i(j).gaussianWeight * df_dts_i(j).faceSizeValue);
                        %face_id = sprintf('Face %d scoring %.3f', j, df_dts_i(j).score);
                        frame = insertObjectAnnotation(frame, 'rectangle',...
                            [df_dts_i(j).col, df_dts_i(j).row, df_dts_i(j).width, df_dts_i(j).height],...
                            face_score, 'Color', 'r', 'FontSize', 22);
                    end
                end
                
                if outputFOEMovements
                    x = floor(base_x + foe_locations(i,2) * amplifier_factor);
                    y = floor(base_y + foe_locations(i,1) * amplifier_factor);
                    
                    %Inserting a line on movements image
                    foe_movements_frame = insertShape(foe_movements_frame, 'line',...
                        [base_x base_y x y], 'LineWidth', 3);
                    
                    composed_frame = frame + foe_movements_frame;
                    writer.writeVideo(composed_frame);
                else
                    writer.writeVideo(frame);
                end
                
                if showOutputWhileDumpling==1
                    if i==1
                        f=figure;
                    end
                    figure(f);
                    
                    if outputSemanticBoxes
                        for j=1:size(obj.SemanticData{frame_indices(i)}, 1)
                            face_id = sprintf('Face %d', j);
                            frame = insertObjectAnnotation(frame, 'rectangle', obj.SemanticData{frame_indices(i)}(j,:), face_id, 'Color', 'r');
                        end
                    end
                    
                    if outputFOEMovements
                        imshow(composed_frame);
                        title(sprintf('FOE = %d --- Frame %d',foe_locations(i), frame_indices(i)));
                    else
                        imshow(frame);
                        title(sprintf('Frame %d',frame_indices(i)));
                    end
                    drawnow;
                end
                
                if saveFramesWhileDumping==1
                    imwrite(frame, sprintf(baseFileName,frame_indices(i)));
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

