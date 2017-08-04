classdef EpipoleFOEDistanceCost < InterframeCost
    %EpipoleFOEDistanceCost calculates cost to be the distance between the
    %epipole of the further frame as a pixel in the earlier frame, and the
    %FOE of the estimated OF
    
    properties
    end
    
    methods

        function obj = EpipoleFOEDistanceCost(sd,cfg)
            obj = obj@InterframeCost(sd,cfg);
        end
        
        function [cost] = calculateTriFrameCostBatch...
                (obj, ~, ~, startBatch, endBatch)
            
            firstImgNum = startBatch;%obj.cfg.get('startInd');
            lastImgNum  = endBatch;%obj.cfg.get('endInd');
          
            temporal_dist = obj.cfg.get('maxTemporalDist');
            %indices inside cost: 
            % cost(i,j,k) :  
            % i -- frame number
            % j -- dist to second frame
            % k -- dist from i+j to third frame           

            baseFileName = obj.cfg.get('baseDumpFrameFileName');
            if ~exist(sprintf(baseFileName,firstImgNum),'file')
                reader = VideoReader(obj.cfg.get('inputVideoFileName'));
                sz = size(rgb2gray(read(reader, firstImgNum)));
            else
                sz = size(rgb2gray(imread(sprintf(baseFileName, firstImgNum))));
            end
            
            fprintf('%sGetting epipole for high order cost term\n',log_line_prefix);
            last = min(lastImgNum + 2*temporal_dist, obj.cfg.get('endInd'));
            
            [isin , epipole] = cellfun(@safeIsEpipoleInImage, ...
                obj.sd.Fundamental(firstImgNum:last,:), repmat({sz},[last-firstImgNum+1 size(obj.sd.Fundamental,2)]),...
                'UniformOutput',false);
            
            epipole = cell2mat(epipole);
            epipole = cat(3,epipole(:,1:2:end), epipole(:,2:2:end));
            
            %change units to percent of the image size
            epipole(:,:,1) = epipole(:,:,1) / sz(2);
            epipole(:,:,2) = epipole(:,:,2) / sz(1);
            
            invalid = repmat(~cell2mat(isin),[1 1 2]) & epipole == 0;
            epipole(invalid) = inf;
            epipole = cat(1, epipole, nan(lastImgNum-firstImgNum+1+temporal_dist-size(epipole,1), size(epipole,2),2));
            %% take 1
            cost = ones(lastImgNum-firstImgNum+1, temporal_dist, temporal_dist)*inf;
            for i = 1:lastImgNum-firstImgNum+1
                if mod(i,50) ==0   
                    fprintf('%sFilling Higher order shakness epipole cost matrix %d, (%d/%d in this batch)\n',log_line_prefix,i + firstImgNum-1,i, (lastImgNum-firstImgNum+1));
                end               
                for j = 1 : temporal_dist
                    for k = 1 : temporal_dist
                        cost (i,j,k) = sqrt(sum((epipole(i+j,k,:) - epipole(i,j,:)).^2)); 
                    end
                end
            end            
            
%%           take 2
%             [ind_second, ind_third] = meshgrid(...
%                 1:temporal_dist, ...
%                 1:temporal_dist);
%             
%             cost = ones(lastImgNum-firstImgNum+1, temporal_dist, temporal_dist)*inf;
%             for i = 1:lastImgNum-firstImgNum+1
%                 second_third1 = sub2ind(size (epipole), i+ind_second, ind_third, ones(size(ind_third)));
%                 second_third2 = sub2ind(size (epipole), i+ind_second, ind_third, ones(size(ind_third))*2);
%                 cost (i,:,:) = sqrt((epipole(second_third1) - reshape(epipole(i,ind_second,1),[100 100])).^2+...
%                                          (epipole(second_third2) - reshape(epipole(i,ind_second,2),[100 100])).^2);
%             end
%             
            %% take 3
%             [ind_first, ind_second, ind_third] = meshgrid(...
%                 1: lastImgNum-firstImgNum+1,...
%                 1: temporal_dist,...
%                 1: temporal_dist);
            
%             ind_second = ind_second + ind_first;
%             ind_third = ind_third + ind_second;
%             third_second = sub2ind(size(epipole), ind_second, ind_third,ones(size(ind_third));
%             cost = sqrt ((epipole(ind_second(:), ind_third(:), 1) - epipole1(ind_first(:), ind_second(:),1)).^2 + ...
%                               (epipole(ind_second(:), ind_third(:), 1) - epipole1(ind_first(:), ind_second(:),1)).^2);
            %%  
%              cost (isnan(cost)) = inf;
                
        end
        
        function [cost] = calculateCostBatch ...
                (obj, ~, ~, startBatch, endBatch)
            last_time_extra_calculation_was_ = -10;
            
            firstImgNum = startBatch;%obj.cfg.get('startInd');
            lastImgNum  = endBatch;%obj.cfg.get('endInd');
          
            temporal_dist = obj.cfg.get('maxTemporalDist');
            cost = ones(lastImgNum-firstImgNum+1,temporal_dist)*inf;

%             fprintf('%sReading video frames,',log_line_prefix);
%             fprintf(' Detecting and extracting features\n');
            baseFileName = obj.cfg.get('baseDumpFrameFileName');
%             miniBatchFrameSize = 100;
%             frames = cell(miniBatchFrameSize ,1);
%             features = cell(lastImgNum-firstImgNum+1,1);
%             valid = cell(lastImgNum-firstImgNum+1,1);
            
            %if no dump exists, reading the frames from the video
            if ~exist(sprintf(baseFileName,firstImgNum),'file')
                readVideo = true;
                reader = VideoReader(obj.cfg.get('inputVideoFileName'));
            else
                readVideo = false;    
            end
            
            %read the frames in batches of 100 and extract features
%             for i = 1:miniBatchFrameSize:lastImgNum-firstImgNum+1
%                 last = min (obj.cfg.get('endInd')-firstImgNum+1-i, miniBatchFrameSize-1);
%                 if readVideo
%                     for j = 0:last
%                         frames{j+1} = rgb2gray(read(reader,i+j+firstImgNum-1));
%                     end
%                 else
%                     for j = 0:last
%                         frames{j+1} = rgb2gray(imread(sprintf(baseFileName, i+j+firstImgNum-1)));
%                     end
%                 end
%                 points = cellfun(@detectSURFFeatures,frames(1:last+1),'UniformOutput',false);
%                 [features(i:i+last), valid(i:i+last)] = ...
%                     cellfun(@extractFeatures,frames(1:last+1), points,'UniformOutput',false);
%             end
%             
            if readVideo
                sz = size(rgb2gray(read(reader, firstImgNum)));
            else
                sz = size(rgb2gray(imread(sprintf(baseFileName, firstImgNum))));
            end
            center = round(sz/2);
            sz = repmat({sz}, [1 temporal_dist]);
            
            foefinder = FOEFinder(obj.sd, obj.cfg); 
%             profile on 
%             fprintf('%sMatching Feature Points', log_line_prefix);
            for i = firstImgNum:lastImgNum
                if mod(i,50) == 0
                    fprintf ('%sCalculating epipole distances for frames %d-%d\n',log_line_prefix,i,i+49);
                end
                
                switch obj.cfg.get('FOE_Reference')
                    case 'Absolute'
                        baseline_x=0;
                        baseline_y=0;
                    case 'SmoothedCDC'
                        [baseline_x, baseline_y] = foefinder.FOE(i);
                    otherwise
                        error('Invalid ''FOE_Reference'' values "%s".');
                end

                %changing FOE coordinates to pixel coordintes with 
                %center of the image as (0,0)
                baseline_x = (baseline_x/obj.numBlocks(1)) ;
                baseline_y = (baseline_y/obj.numBlocks(2)) ;
                
                F = obj.sd.Fundamental(i,:);
                preCalculatedFundamentalNum = min(size(F,2), obj.cfg.get('endInd')-i);
                
                if preCalculatedFundamentalNum==0
                    continue;
                end
                
                last = i + min(temporal_dist, preCalculatedFundamentalNum );
                
%                 base_features = repmat(features(i),[last-i 1]);
%                 comp_features = features(i+1:last);
%                 base_valid    = repmat(valid(i),[last-i 1]);
%                 comp_valid    = valid(i+1:last);
                
%                 [F, ~, status] = cellfun(@fundamental, ...
%                     base_features, comp_features, base_valid, comp_valid ,... 
%                     'UniformOutput',false);

                [isin,epipole] = cellfun(@safeIsEpipoleInImage,F(1:last-i),sz(1:last-i),...
                     'UniformOutput',false);
                epipole = reshape(cell2mat(epipole),2,length(epipole))';

                invalid = ~cell2mat(isin) & (epipole(:,1)' == 0);%| cell2mat(status) ~= 0 
    
                %changing coordinates of the epipole to center of frame
                epipole(:,1) = (epipole (:,1) - center(2)) / sz{1}(2);
                epipole(:,2) = (epipole (:,2) - center(1)) / sz{1}(1);

                cost(i-firstImgNum+1,1:last-i) = sqrt(...
                    (epipole(:,1) - baseline_x).^2 +(epipole(:,2) - baseline_y).^2);
                cost(i-firstImgNum+1,invalid) = Inf;

%% from here an option:
%                    if from frame t the fundamental matrix was calculated in preprocess to the last frame (t+100),
%                    with enough matches,
%                    maybe we should try and calculate it further until max
%                    temporal distance with jumps of 10
                if 1==0 && cost(i-firstImgNum+1,last-i) ~= inf && last_time_extra_calculation_was_ + 10 < i
                        
                        last_time_extra_calculation_was_ = i;
                        jump  = 10;
                        
                        fprintf('%sframe No. %d has fundamental matrix calculated to %d frames, calculating until %d with skip of %d\n', ...
                            log_line_prefix, i, preCalculatedFundamentalNum, temporal_dist, jump);
                        
                        indices_to_jump = preCalculatedFundamentalNum+1: jump : min(temporal_dist,obj.cfg.get('endInd')-i);
                        
                        
                        %read the frames
                        frames = cell(numel(indices_to_jump )+1,1);
                        if readVideo
                            frames{1}= rgb2gray(read(reader,i));
                            for j = 1:numel(indices_to_jump)
                                frames{j+1} = rgb2gray(read(reader,i+indices_to_jump(j)));
                            end
                        else
                            frames{1}= rgb2gray(imread(sprintf(baseFileName, i)));
                            for j = 1:numel(indices_to_jump)
                                frames{j+1} = rgb2gray(imread(sprintf(baseFileName, i+indices_to_jump(j))));
                            end
                        end
                        %extractig features
                        points = cellfun(@detectSURFFeatures,frames,'UniformOutput',false);
                        [features, valid] = ...
                            cellfun(@extractFeatures,frames, points,'UniformOutput',false);

                        base_features = features{1};%repmat(features(i),[last-i 1]);
                        base_valid    = valid{1};%repmat(valid(i),[last-i 1]);
                        newF = cell(numel(indices_to_jump),1);
                        
                        parfor j = 1:numel(indices_to_jump)
                            [newF{j}, ~, ~] = fundamental(base_features, features{j+1}, base_valid, valid{j+1} );
                        end
                        
                        [isin,epipole] = cellfun(@isEpipoleInImage,newF,sz(1:numel(indices_to_jump))',...
                            'UniformOutput',false);
                        invalid = ~cell2mat(isin) ;%| cell2mat(status) ~= 0 
                       epipole = reshape(cell2mat(epipole),2,length(epipole))';

                        %changing coordinates of the epipole to center of frame
                        epipole(:,1) = (epipole (:,1) - center(2)) / sz{1}(2);
                        epipole(:,2) = (epipole (:,2) - center(1)) / sz{1}(1);

                        cost(i-firstImgNum+1,indices_to_jump) = sqrt(...
                            (epipole(:,1) - baseline_x).^2 +(epipole(:,2) - baseline_y).^2);
                        invalid_indices = zeros(1,temporal_dist);
                        invalid_indices(indices_to_jump) = invalid;
                        invalid_indices(invalid_indices == 1) = inf;
                        cost(i-firstImgNum+1,:) = cost(i-firstImgNum+1,:) + invalid_indices; %adds zero or inf to every cost
                end
%% until here                
            end
%             profile viewer
        end
        
        function epipole = getEpipole (obj, index1, index2,sz)
            if index2 <= index1 
                error('second index should greater than the first index (and not too much greater)');
            end
            if  index2 > index1 + size(obj.sd.Fundamental,2)
                epipole = [nan, nan];
                return;
            end
          
            center = round(sz/2);
            
            
            [isin, epipole] = safeIsEpipoleInImage(obj.sd.Fundamental{index1,index2-index1},sz);
            if epipole(1) == -inf || ~isin
                epipole(:) = nan;
            else
                epipole(:,1) = (epipole (:,1) - center(2)) / sz(2);
                epipole(:,2) = (epipole (:,2) - center(1)) / sz(1);
            end
        end
    end
end

function [isin,epipole] = safeIsEpipoleInImage(F,sz)
    if isempty(F)
        isin = false ;
        epipole = [inf inf];
        warning('if you got here, some wrong calculations were done');
        return
    end
    
    [isin,epipole] = isEpipoleInImage(F,sz);
end


function [F, inliers, status] = fundamental(features1, features2, valid1, valid2)

    matchedindices = matchFeatures(features1,features2,...
        'Prenormalized',true,'MaxRatio',.6);

    %need at least 100 pairs between images
    if (size(matchedindices,1)) < 100
        status = int32(-1);
        F = zeros(3);
        inliers = zeros(2);
        return
    end
    
    matchedPoints1 = valid1 (matchedindices(:,1),:);
    matchedPoints2 = valid2 (matchedindices(:,2),:);
    [F,inliers,status] = estimateFundamentalMatrix (...
        matchedPoints1, matchedPoints2,...
        'Method', 'RANSAC', 'NumTrials', 500, 'DistanceThreshold', 1e-1, ...
        'ReportRuntimeError', false);

    if status ~= 0 
        F = zeros(3);
    end
                                
end