%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   This file is part of SemanticFastForward_ICIP.
%
%    SemanticFastForward_ICIP is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    SemanticFastForward_ICIP is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with SemanticFastForward_ICIP.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CreateOutputVideo(input_filename)
%Create an output video with detected faces

    addpath('../@NPDFaceDetector_Liao_PAMI_2016');

    [video_dir, fname, ext] = fileparts(input_filename);
    output_filename = [video_dir, '/', fname, '_face_extracted'];
    fname_values = [output_filename, '.mat'];

    if (exist(fname_values, 'file') == 2 )
        load(fname_values);
    else
        fprintf('Please run ExtractAndSave first');
        return;
    end

    %% Reading input and Creating the output
    fprintf('Reading input video...\n');
    reader = VideoReader(input_filename);
    num_frames = reader.NumberOfFrames;
    fprintf('Video loaded...\n');

    %% Video writer stuff
    writer = VideoWriter(output_filename);
    writer.FrameRate = reader.FrameRate;
    writer.open();

    %% Writing video
    WriteFacesVideo(writer, reader, num_frames, Rects);
    writer.close();
end

function WriteFacesVideo(writer, reader, num_frames, Rects)
    for i=1:num_frames
        
        frame = read(reader,i);
        
        %Inserts a top-left text with some information
        embedText = sprintf('[%s]',datestr((i/reader.FrameRate)/86400,'HH:MM:SS'));
        embedText = sprintf('%s Frame #%d',embedText,i);
        
        frame = insertObjectAnnotation(frame,'rectangle',[20,20,5,5],embedText,'FontSize',20);
        
        rects = Rects{i};
        
        %% Create Output video
        for j = 1:numel(rects)
            faceRect = [rects(j).row, rects(j).col, rects(j).width, rects(j).height];
            total = rects(j).score * rects(j).gaussianWeight * rects(j).faceSizeValue;
            
            %% Calculation of the face value.
            face_id = sprintf('ID=%d Sc=%.3f Gs=%.3f Sz=%.3f Total=%.3f', j, rects(j).score, rects(j).gaussianWeight, rects(j).faceSizeValue, total);
            frame = insertObjectAnnotation(frame, 'rectangle', faceRect, face_id, 'Color', 'r', 'FontSize', 22, 'linewidth', 12);
        end
        
        %imshow(frame);
        
        if mod(i, 100) == 0
            fprintf('Done with frame %d/%d...\n', i, num_frames);
        end
        
        writer.writeVideo(frame);
    end
end
