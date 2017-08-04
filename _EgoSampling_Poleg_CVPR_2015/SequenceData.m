classdef SequenceData < handle
    
    properties (Constant)
        num_x_cells = 10;
        num_y_cells = 5;
        default_lk_smooth_kernel_size = 500;
        max_temporal_distance = 100;
        histogram_num_bins = 128;
        histogram_scale_factor = 0.5;
        
    end
    
    properties
        SmoothKernelSize;
        
        Raw_Video_Data;
        
        LK_X_raw;
        LK_Y_raw;
        CDC_Raw_X;
        CDC_Raw_Y;
        
        LK_X_smoothed;
        LK_Y_smoothed;
        CDC_Smoothed_X;
        CDC_Smoothed_Y;
   
        FramesHistogram;
        Features;
        InterestPoints;
        Fundamental;
        
        SequenceName;
        FPS;
        StartFrame;
    end
    
    
    methods
        function obj = SequenceData(rawdata,seqname,sframe,varargin)
            
            obj.Raw_Video_Data = rawdata;
            
            obj.LK_X_raw = [];
            obj.LK_Y_raw = [];
            obj.CDC_Raw_X = [];
            obj.CDC_Raw_Y = [];
            
            obj.LK_X_smoothed = [];
            obj.LK_Y_smoothed = [];
            obj.CDC_Smoothed_X = [];
            obj.CDC_Smoothed_Y = [];
            
            obj.FramesHistogram = {};
            obj.Features = {};
            obj.InterestPoints = {};
            
            obj.SequenceName = seqname;
            obj.FPS = rawdata.fps;
            obj.StartFrame = sframe;
            
            % TODO: Need to remove smoothing part from here because its
            % config dependent and not that heavy calc anyway...
            obj.SmoothKernelSize = obj.default_lk_smooth_kernel_size;

            %obj.ProcessRawData(rawdata,sframe:sframe+500);
            obj.ProcessRawData(rawdata,sframe:rawdata.num_frames);%should it end with sframe+rawdata.num_frames-1 ???
        end
        
        
                
        
            
        function ProcessRawData(obj,data,ind)
            
            
            
            obj.LK_X_raw = data.LK_X(:,ind)';
            obj.LK_Y_raw = data.LK_Y(:,ind)';
            
            obj.CDC_Raw_X = cumsum(obj.LK_X_raw);
            obj.CDC_Raw_Y = cumsum(obj.LK_Y_raw);
            
            
            Hsmooth = fspecial('average',[obj.SmoothKernelSize,1]);
            % Todo: Remove these variables.
            obj.LK_X_smoothed = imfilter(obj.LK_X_raw,Hsmooth,'same',0);
            obj.LK_Y_smoothed = imfilter(obj.LK_Y_raw,Hsmooth,'same',0);
            
            obj.CDC_Smoothed_X = cumsum(obj.LK_X_smoothed);
            obj.CDC_Smoothed_Y = cumsum(obj.LK_Y_smoothed);
            

            % Process the sequence's frames..
            fprintf('%Processing sequence frames..\n',log_line_prefix);
            [dir,file,~] = fileparts(obj.SequenceName);
            baseFileName = strrep([dir '/dump/' file '/frame_%06d.png'],'\','/');
            %second try (if the file name has one less '0')
            if ~exist(sprintf(baseFileName,ind(1)),'file')
                baseFileName  = strrep([dir '/dump/' file '/frame_%05d.png'],'\','/');
            end
            if ~exist(sprintf(baseFileName,ind(1)),'file')
                baseFileName  = strrep([dir '/' file '_frames_undist/' 'frame_%05d.png'],'\','/');
            end
            if ~exist(sprintf(baseFileName,ind(1)),'file')
                baseFileName  = strrep([dir '/' file '_frames_undist/' 'frame_%06d.png'],'\','/');
            end
            
            obj.FramesHistogram = cell(numel(ind),1);
            obj.Fundamental = cell(numel(ind),obj.max_temporal_distance);
            
            %if no dump exists, reading the frames from the video
            if ~exist(sprintf(baseFileName,ind(1)),'file')
            
                reader = VideoReader(obj.SequenceName);
                
                H = zeros(obj.histogram_num_bins ,3);
                for i = 1:numel(ind)
                    
                    if mod(i,50) == 0
                        fprintf('%sCalculating histogram for frame %d/%d\n',log_line_prefix,i,numel(ind));
                    end
                    
                    cur_frame = imresize(read(reader,ind(i)),obj.histogram_scale_factor);
                    cur_frame = rgb2ycbcr(cur_frame);
                    
                    H(:,1) = imhist(cur_frame(:,:,1),obj.histogram_num_bins); 
                    H(:,2) = imhist(cur_frame(:,:,2),obj.histogram_num_bins); 
                    H(:,3) = imhist(cur_frame(:,:,3),obj.histogram_num_bins);  
                    
                    obj.FramesHistogram{i} = H / numel(cur_frame(:,:,1));
                end
            %if there is dump, read it in parallel
            else
                baseFileNameCell = repmat({baseFileName},[obj.max_temporal_distance+1,1]);
                
                

%                 disp('reading frames and extracting features');
%                 if isempty(gcp('nocreate'))
%                         % No matlab pool...
%                         [obj.Features, obj.InterestPoints] = cellfun(@getFeatures, ...
%                                                                             baseFileName, ...
%                                                                             num2cell(ind,(size(ind))),...
%                                                                             'UniformOutput',false);
%                 else
%                     tempFeatures = cell(numel(ind),1);
%                     tempInterestPoints = cell(numel(ind),1);
%                     parfor j=1:numel(ind)
%                         [tempFeatures{j}, tempInterestPoints{j}]=getFeatures(baseFileName{j},j);
%                     end
%                     obj.Features = tempFeatures;
%                     obj.InterestPoints = tempInterestPoints;
%                 end
                
%                 tempFeatures = cell(obj.max_temporal_distance,1);
%                 tempInterestPoints = cell(obj.max_temporal_distance,1);

                 %calculate the features of the first frame and all the
                 %outgoing frames from it (max temporal dist of them)
                 [tempFeatures , tempInterestPoints ] = cellfun(@getFeatures, ...
                        baseFileNameCell(1:obj.max_temporal_distance+1)', ...
                        num2cell(ind(1:obj.max_temporal_distance+1),[obj.max_temporal_distance+1 1]),...
                        'UniformOutput',false);
       
                fprintf('%sCalculating fundamental matrices\n',log_line_prefix);
                t1=tic;
                for i = 1:numel(ind)
%                     if mod(i,10) == 0
%                         fprintf (' %d',ind(i));
%                     end

%                     emptyCellsInds = find(cellfun(@isempty,tempFeatures));
%                     for j=1:numel(emptyCellsInds)
%                              [tempFeatures{j}, tempInterestPoints{j}]=getFeatures(baseFileName{i+j-1},i+j-1);
%                              
%                     end
                    
                     last = min (ind(i)+obj.max_temporal_distance, ind(end));
%                     base_features = repmat(obj.Features(i),[last-i 1]);
%                      base_features = repmat(tempFeatures(1),[last-i 1]);
%                     comp_features = obj.Features(i+1:last)';
%                     comp_features = tempFeatures(i+1:last)';
%                     base_points    = repmat(obj.InterestPoints(i),[last-i 1]);
%                     base_points    = repmat(tempInterestPoints(1),[last-i 1]);
%                     comp_points    = obj.InterestPoints(i+1:last)';
%                     comp_points    = tempInterestPoints(i+1:last)';
%                     frame1_ind = repmat(i, [last-i 1]);
%                     frame2_ind = num2cell(frame1_ind + (1:(last-i))');
%                     frame1_ind = num2cell(frame1_ind);
                    if mod(i,1) == 0
                        elapsed=toc(t1);
                        avg_per_frame = elapsed/i;
                        eta_secs = ((numel(ind)-i)*avg_per_frame) / 86400;
                        eta_str = datestr(eta_secs,'HH:MM');
                        total_str = datestr(elapsed/86400,'HH:MM');
                        fprintf('%sCalculating fundamental matrices from frame %d (%d/%d) (avg of %.2f sec/frame, ETA is %s (hh:mm), Total runtime is %s)\n',log_line_prefix,ind(i),i,numel(ind),avg_per_frame,eta_str,total_str);
                    end
                    
%                     if isempty(gcp('nocreate'))
%                         % No matlab pool...
%                         obj.Fundamental(i,1:numel(base_features)) = cellfun(@fundamental, ...
%                             frame1_ind,frame2_ind,base_features, comp_features, base_points, comp_points ,... 
%                             'UniformOutput',false);
%                     else
                        tempFundamental = cell(obj.max_temporal_distance,1);
                        base_ind = ind(i);
                        base_features = tempFeatures{1};
                        base_interest_points = tempInterestPoints{1};
                        for j=2:last-ind(i)+1
                            tempFundamental{j-1} = fundamental(base_ind,-1,...
                                                                                    base_features, tempFeatures{j}, ....
                                                                                    base_interest_points, tempInterestPoints{j});
                        end
                        obj.Fundamental(i,:) = tempFundamental;
%                     end
                    
                    [newFeatures, newInterestPoints] = getFeatures(baseFileNameCell{1}, i+obj.max_temporal_distance+1); 
                    tempFeatures(1) = []; 
                    tempFeatures{end+1} = newFeatures;
                    
                    tempInterestPoints(1) = [];
                    tempInterestPoints{end+1} = newInterestPoints;
                    
                end
                  
                baseFileNameCell = repmat({baseFileName},[numel(ind),1])';
                
                obj.FramesHistogram(1:numel(ind)) = cellfun(@calc_frame_histogram,...
                                baseFileNameCell,...
                                num2cell(ind,(size(ind))),...
                                repmat({obj.histogram_num_bins}, size(ind)),...
                                'UniformOutput',false);
            end
        end
    end
end

function F = fundamental(frame1_ind,frame2_ind,features1, features2, points1, points2)

    if isempty(features1) || isempty(features2) || strcmp(class(features1),class(features2))==0
        fprintf('%sestimateFundamentalMatrix between frame %d and %d - one of the params is empty or not same class!\n',log_line_prefix,frame1_ind,frame2_ind);
        F = zeros(3);
        return
    end
    
    matchedindices = matchFeatures(features1,features2,...
        'Prenormalized',true,'MaxRatio',.3);

    %need at least 50 pairs between images
    if (size(matchedindices,1)) < 50
        %fprintf('%sestimateFundamentalMatrix between frame %d and %d - not enough matches (%d)\n',log_line_prefix,frame1_ind,frame2_ind,size(matchedindices,1));
        F = zeros(3);
        return
    end
    
    matchedPoints1 = points1 (matchedindices(:,1),:);
    matchedPoints2 = points2 (matchedindices(:,2),:);
    [F,inlierind,status] = estimateFundamentalMatrix (...
        matchedPoints1, matchedPoints2,...
        'Method', 'MSAC', 'NumTrials', 250, 'DistanceThreshold', 0.05, ...
        'ReportRuntimeError', false);

    if status ~= 0 
        %fprintf('%sestimateFundamentalMatrix between frame %d and %d return code is %d (should be 0)\n',log_line_prefix,frame1_ind,frame2_ind,status);
        F = zeros(3);
    else
        %fprintf('%sestimateFundamentalMatrix between frame %d and %d inliner count=%d\n',log_line_prefix,frame1_ind,frame2_ind,sum(inlierind));
    end
end
    
function [features, points] = getFeatures(baseFileName,frame_index)

    features = [];
    points = [];

    if mod(frame_index,50) == 0
        fprintf('%sCalculating feature points for frame %d\n',log_line_prefix,frame_index);
    end
    fileName = sprintf(baseFileName, frame_index);
    if ~exist (fileName,'file')
        return;
    end
    
    %I = imresize(rgb2gray(imread(fileName)),0.5);
    I = rgb2gray(imread(fileName));
    points = detectSURFFeatures(I);
    if numel(points)<=0
        points = [];        
        return;
    end
    
    points = points.selectStrongest(max(floor(points.size(1)/2),1));
    [features, valid] = extractFeatures(I, points);
    points = valid;
end

function hist = calc_frame_histogram(baseFileName,frame_index,num_bins)
    if mod(frame_index,50) == 0
        fprintf('%sCalculating histogram for frame %d\n',log_line_prefix,frame_index);
    end
    im = rgb2ycbcr(imresize(imread(sprintf(baseFileName,frame_index)),SequenceData.histogram_scale_factor));
    sz = numel(im(:,:,1));
    hist = zeros(num_bins ,3);
    hist(:,1) = cumsum(imhist(im(:,:,1),num_bins));
    hist(:,2) = cumsum(imhist(im(:,:,2),num_bins));
    hist(:,3) = cumsum(imhist(im(:,:,3),num_bins));
    hist = hist/sz;
end

