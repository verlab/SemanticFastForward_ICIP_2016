classdef Util < handle

   properties(Constant)
       GROUNDTRUTH_ELAN_TIER_NAME = 'Event'
   end
    
    
   methods(Static)
      
       
        function PrepreocessSequences(fname_mask,suffix)
            % PrepreocessSequences
            %
            % This function will read the CSV files produces by
            % Vid2OpticalFlowCSV, process them and create .mat files with
            % process data.
            % Arguments:
            %
            % fname_mask - filename or wildcard of the CSV file(s) to
            % process. Can also be a cell array of filenames or wildcards.
            % 
            % suffix - a suffix to add to the .mat files. Can be an empty
            % string.
            %
            
            fullnames = Util.ExpandFileList(fname_mask);
            
            fprintf('%s Found %d sequences to processs..\n',log_line_prefix,numel(fullnames));
            
            for i=1:numel(fullnames)
                fullname = fullnames{i};
                [fpath, fname, fext] = fileparts(fullname);
                
                fprintf('%s Processing %s%s..\n',log_line_prefix,fname,fext);

                tstart = tic;
            
                try
            
                    csvfilename = [fpath '/' fname suffix '.csv'];
                    % Look for CSVs named <curseq>suffix.csv
                    viddata = Util.ReadLoadLKFromVid2OpticalFlowCSV(csvfilename);

                    % Create sequence data:
                    seqdata = SequenceData(viddata,fullname,1);
                    
                    % Save matfile
                    matfilename = [fpath '/' fname 'fpstereo.mat'];
                    save(matfilename,'seqdata');
                catch exception
                    msg = sprintf('Caught exception: %s.\nDetails:%s\n',exception.message,getReport(exception));
                    fprintf('%s%s\n',log_line_prefix,msg);
                    
                    err_filename = [fpath '/' fname suffix '_err.txt'];
                    err_file = fopen(err_filename,'w');
                    fprintf(err_file,msg);
                    fclose(err_file);

                end
                
                totalsec = toc(tstart);
                fprintf('%sDone with %s%s in %02d:%02d minutes.\n',log_line_prefix,fname,fext,floor(totalsec/60),mod(uint32(totalsec),60));

            end
            
        end
       
        function fullnames = ExpandFileList(fname_mask)
           
            if isstr(fname_mask)
                % Convert to cell array.
                temp_fnamemask = fname_mask;
                fname_mask = cell(1,1);
                fname_mask{1} = temp_fnamemask;
            else
                if ~iscell(fname_mask)
                    error('%s fname_mask variable should be either string with file mask or a cell array of strings with file mask.',log_line_prefix);
                end
            end


            totalfiles = 0;
            fullnames = {};
            for i=1:numel(fname_mask)
                dirprefix = fileparts(fname_mask{i});
                if numel(dirprefix) > 0
                    dirprefix = [dirprefix '/'];
                end

                templist = dir(fname_mask{i});

                for j=1:numel(templist)
                    if ~templist(j).isdir

                        cur_filename = templist(j).name;
                        fullnames{end+1} = sprintf('%s%s',dirprefix,cur_filename);
                        
                        totalfiles = totalfiles+1;
                    end
                end
            end

        end
       
     
        function seqdata = LoadVidDataFromMat(fullname,varargin)

            do_assign_in_base=1;
            
            suffix='';
            if nargin>1
                suffix = varargin{1};
                if nargin>2
                    if strcmpi('returnonly',varargin{2})
                        do_assign_in_base=0;
                    end
                end

            end


            [filepath filename filext] = fileparts(fullname);
            mat_filename = sprintf('%s/%s%s.mat',filepath,filename,suffix);


            load(mat_filename);

            filename = strrep(filename,'-','_'); % remove invalid chars from var name
            filename = strrep(filename,' ','_'); % remove invalid chars from var name
            filename = strrep(filename,'[','_'); % remove invalid chars from var name
            filename = strrep(filename,']','_'); % remove invalid chars from var name

            suffix = strrep(suffix,'-','_'); % remove invalid chars from var name
            suffix = strrep(suffix,' ','_'); % remove invalid chars from var name
            suffix = strrep(suffix,'[','_'); % remove invalid chars from var name
            suffix = strrep(suffix,']','_'); % remove invalid chars from var name

            new_var_name = sprintf('%s%s_seqdata',filename,suffix);

            if do_assign_in_base
                assignin('base',new_var_name,seqdata);
            end


        end
        
        
         % Loads a CSV file of with LK info that were produced using Vid2OpticalFlowCSV (C++ code).
        function viddata = ReadLoadLKFromVid2OpticalFlowCSV(vid_csv_filename)
            
            metadata = Util.ReadVid2OpticalFlowMetadata(vid_csv_filename);

            lkcsv=csvread(vid_csv_filename,1,0);
            numFrames = size(lkcsv,1);
            xblocks = str2double(metadata('NUM_BLOCKS_X'));
            yblocks = str2double(metadata('NUM_BLOCKS_Y'));
            blockwidth = str2double(metadata('BLOCK_WIDTH'));
            blockheight = str2double(metadata('BLOCK_HEIGHT'));

            processing_width = str2double(metadata('PROCESSING_WIDTH'));
            processing_height = str2double(metadata('PROCESSING_HEIGHT'));

            numBlocks = xblocks*yblocks;
            sframe = str2double(metadata('START_FRAME'));
            eframe = str2double(metadata('END_FRAME'));
            skip = str2double(metadata('FRAME_SKIP'))+1;
            frame_range = sframe:skip:eframe;
            frame_range = frame_range(1:numFrames); 

            X = zeros(numBlocks,numFrames);
            Y = zeros(numBlocks,numFrames);
            tracking_valid = zeros(numBlocks,numFrames);
            cannysum = zeros(numBlocks,numFrames);
            fpcount = zeros(numBlocks,numFrames);
            backprojerr = zeros(numBlocks,numFrames);


            t=0;
            for yb=1:yblocks
                for xb=1:xblocks
                    t=t+1;

                    if mod(t,10)==0
                        fprintf('%sLoading block %d/%d...\n',log_line_prefix,t,numBlocks);
                    end

                    % Each LK block data is composed of six elements: valid,x,y,sum_canny,num_fpoints,backproj_err. The valid
                    % vector is 0 if the result is invalid and 1 if it is valid.
                    ind = 1+(t-1)*6; % Ind to the first column of the current block (Matlab is 1 based).

                    valid = lkcsv(:,ind);
                    x = lkcsv(:,ind+1);
                    y = lkcsv(:,ind+2);
                    block_canny = lkcsv(:,ind+3);
                    block_num_fpoints = lkcsv(:,ind+4);
                    block_backproj_err = lkcsv(:,ind+5);


                    % suppress large motions that dont make sense
                    max_valid_x = min([blockwidth 50]);
                    max_valid_y = min([blockheight 50]);
                    valid = valid .* (abs(x)<max_valid_x);
                    valid = valid .* (abs(y)<max_valid_y);

                    % Need at least two points to interpolate missing data...
                    if sum(valid) > 2

                        % Set invalid points to nan
                        invalid_logical = valid==0;

                        if sum(invalid_logical)>0

                            x(invalid_logical) = interp1(frame_range(~invalid_logical),x(~invalid_logical),frame_range(invalid_logical));
                            y(invalid_logical) = interp1(frame_range(~invalid_logical),y(~invalid_logical),frame_range(invalid_logical));

                             % Handle nans on boundaries...
                            if isnan(x(1)) || isnan(x(end))
                                temp=find(~isnan(x));
                                if numel(temp)>0
                                    first_not_nan=temp(1);
                                    x(1:first_not_nan-1) = x(first_not_nan);
                                    y(1:first_not_nan-1) = y(first_not_nan);
                                    last_not_nan=temp(end);
                                    x(last_not_nan+1:end) = x(last_not_nan);
                                    y(last_not_nan+1:end) = y(last_not_nan);
                                else
                                    % Entire block is nan??
                                end
                            end
                        end
                    else
                        % This block is entirely invalid.
                        valid(:) = 0;
                        x(:) = 0;
                        y(:) = 0;
                    end

                    tracking_valid(t,:) = valid;
                    X(t,:) = x;
                    Y(t,:) = y;
                    cannysum(t,:) = block_canny;
                    fpcount(t,:) = block_num_fpoints;
                    backprojerr(t,:) = block_backproj_err;

                end
            end

            viddata.num_frames = numFrames;
            viddata.width = processing_width;
            viddata.height = processing_height;
            viddata.num_x_cells = xblocks;
            viddata.num_y_cells = yblocks;
            viddata.skip = skip;
            viddata.csv_fname = vid_csv_filename;
            viddata.frame_range = frame_range;
            viddata.num_blocks = numBlocks;
            viddata.LK_X = X ./ viddata.width; % Normalize to image size.
            viddata.LK_Y = Y ./ viddata.height;
            viddata.LK_valid = tracking_valid;
            viddata.cannysum = cannysum ./ (blockwidth*blockheight);
            viddata.fpcount = fpcount ./ (blockwidth*blockheight);
            viddata.backprojerr = backprojerr;
            viddata.fps = str2double(metadata('FPS'));

        end


        function [metadata] = ReadVid2OpticalFlowMetadata(lk_csv_filename)

            fileID = fopen(lk_csv_filename);
            line = textscan(fileID, '%s',1,'Delimiter','\n');
            fclose(fileID);

            line = cell2mat(line{1});
            [pairs] = textscan(line,'%s','Delimiter',',');

            metadata = containers.Map();

            for i=1:numel(pairs{1})
                [kvpair] = textscan(pairs{1}{i},'%s','Delimiter','=');
                metadata(kvpair{1}{1}) = kvpair{1}{2};
            end
        end
        
        
        
   end
    
    
end