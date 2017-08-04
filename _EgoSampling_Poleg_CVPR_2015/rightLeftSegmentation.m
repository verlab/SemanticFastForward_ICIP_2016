function rightLeftSegmentation(fileName)
    
    fprintf('%sSegmenting video to right and left parts...\n',log_line_prefix);
    reader = VideoReader(fileName);
    rightWriter = VideoWriter([fileName(1:end-4) '_right']);
    leftWriter = VideoWriter([fileName(1:end-4) '_left']);

    rightWriter.open();
    leftWriter.open();

    lastFrame = read(reader,1);
    curFrame = read(reader,2);
    rightWriter.writeVideo(lastFrame);
    leftWriter.writeVideo(curFrame);
    
    fprintf('Writing %d frames\n',reader.NumberOfFrames);
    for i = 2:reader.NumberOfFrames-1
    %    lastFrame = curFrame;
        curFrame = read(reader,i+1);
        if mod(i,10) == 0
            fprintf('%d ',i);
        end
        if mod(i,100) == 0
            fprintf('\n');
        end
        if mod(i,2) == 0
           rightWriter.writeVideo(curFrame);
  %         leftWriter.writeVideo(lastFrame);
        else
   %         rightWriter.writeVideo(lastFrame);
            leftWriter.writeVideo(curFrame);            
        end        
    end

    disp('\ndone!!');
    disp('Your left and right videos are:');
    disp([fileName(1:end-4) '_right']);
    disp([fileName(1:end-4) '_left']);

    rightWriter.close();
    leftWriter.close();
    fprintf('%s\n',log_line_prefix);