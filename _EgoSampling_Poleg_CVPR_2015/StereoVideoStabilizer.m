classdef StereoVideoStabilizer < VideoStabilizer
    %StereoVideoStabilizer stablize stereo sequence.
    
    properties
       currentPairInd;
       prev_left;
       prev_left_pts;
       prev_left_features;
       prev_left_inliners_bbox;
       prev_prev_next_tform;
    end
    
    
    methods
        function obj = StereoVideoStabilizer(sd, cfg,pairs)
            obj = obj@VideoStabilizer(sd,cfg,pairs);
            obj.currentPairInd=1;
            
            obj.prev_left_pts=[];
            obj.prev_left_features=[];
            obj.prev_left_inliners_bbox=struct('top',0,'bot',0,'left',0,'right',0);
            obj.prev_prev_next_tform = affine2d(eye(3));
        end
        
        function res = HasNext(obj)
            res = obj.currentPairInd<=size(obj.frame_inds,1);
        end
        
        function [stable_left,stable_right] = StabilizeNextPair(obj)
            if obj.HasNext()==0
                error('No next frame to process!');
            end
            
            fprintf('%sStabilizing pair [%d,%d]...\n',log_line_prefix,obj.frame_inds(obj.currentPairInd,1),obj.frame_inds(obj.currentPairInd,2));
            
            if obj.useVideo==1
                % Read from video reader..
                right = read(obj.vreader,obj.frame_inds(obj.currentPairInd,1));
                left = read(obj.vreader,obj.frame_inds(obj.currentPairInd,2));
            else
                % Read from dump dir..
                f = obj.cfg.get('baseDumpFrameFileName');
                right = imread(sprintf(f,obj.frame_inds(obj.currentPairInd,1)));
                left = imread(sprintf(f,obj.frame_inds(obj.currentPairInd,2)));
            end
            
            right = rgb2gray(right);
            left = rgb2gray(left);
            
            stable_left=left;
            switch obj.cfg.get('StereoStabilizerLRWarp')
                case 'None'
                    % Do nothing..
                    ptsLeft  = detectSURFFeatures(left);
                    [left_features,   left_pts]  = extractFeatures(left,  ptsLeft);
                    right_to_left_tform = affine2d(eye(3));
                    left_inliners_bbox.top = 1;
                    left_inliners_bbox.left = 1;
                    left_inliners_bbox.bot = size(left,1);
                    left_inliners_bbox.right = size(left,2);
                    
                case 'RansacSimilarity'
                    [right_to_left_tform,left_inliners_bbox,left_pts,left_features]=obj.StabilizeLeftRightBySimilarity(left,right);
                    
                otherwise
                    error('Unknown value "%s" for StereoStabilizerLRWarp.',obj.cfg.get('StereoStabilizerLRWarp'));
            end
            
            
            if obj.currentPairInd>1 && strcmp(obj.cfg.get('StereoStabilizerPrevNextWarp'),'None')~=1
                [stable_left, stable_right] = obj.StabilizeNextLeft(left, right, left_pts, left_features, right_to_left_tform);
            else
                outputView = imref2d(size(left));
                stable_right  = imwarp(right,right_to_left_tform,'OutputView',outputView);
            end
            
            obj.prev_left = left;
            obj.prev_left_inliners_bbox = left_inliners_bbox;
    
            bbtop = obj.prev_left_inliners_bbox.top;
            bbbot = obj.prev_left_inliners_bbox.bot;
            bbleft = obj.prev_left_inliners_bbox.left;
            bbright = obj.prev_left_inliners_bbox.right;

            mask = logical((left_pts.Location(:,1)>=bbleft) .* (left_pts.Location(:,1)<=bbright) .* ...
                           (left_pts.Location(:,2)>=bbtop) .* (left_pts.Location(:,2)<=bbbot));
            
            %fprintf('Box size is [%g,%g], got %d features in it\n',floor(bbright-bbleft),floor(bbbot-bbtop),sum(mask));
            
            obj.prev_left_pts = left_pts(mask);
            obj.prev_left_features = left_features(mask,:);

            obj.currentPairInd = obj.currentPairInd+1;
        end
      
        function [stable_left, stable_right] = StabilizeNextLeft(obj,...
                current_left, current_right, current_left_pts, current_left_features, right_to_left_tform)
                
            indexPairs = matchFeatures(current_left_features, obj.prev_left_features);
            
            matchedCurrent  = current_left_pts(indexPairs(:,1));
            matchedPrev =  obj.prev_left_pts(indexPairs(:,2));
            outputView = imref2d(size(obj.prev_left));
            
            switch obj.cfg.get('StereoStabilizerPrevNextWarp')
                case 'RansacSimilarity'
            
                    [curr_prev_tform, inlierCurrent, inlierPrev] = estimateGeometricTransform(...
                        matchedCurrent, matchedPrev, 'similarity');

                    s = sqrt((curr_prev_tform.T(1,1)^2) + (curr_prev_tform.T(1,2)^2));
                    curr_prev_tform.T(1:2,1:2) = curr_prev_tform.T(1:2,1:2) ./ s;
                    %curr_prev_tform.T(3,1:2) = curr_prev_tform.T(3,1:2) .* s;
                    curr_prev_tform.T(3,1:2) = curr_prev_tform.T(3,1:2) .* 0;
                    
                    %fprintf('%sScale change is: %.5f\n',log_line_prefix,s);
                    display(obj.prev_prev_next_tform.T');
                    
                    right_tform =  affine2d(obj.prev_prev_next_tform.T * (curr_prev_tform.T * right_to_left_tform.T));
                    
                    left_tform = affine2d(obj.prev_prev_next_tform.T * curr_prev_tform.T);
                    stable_left  = imwarp(current_left,left_tform,'OutputView',outputView);
                    stable_right = imwarp(current_right,right_tform,'OutputView',outputView);
               
                    obj.prev_prev_next_tform = left_tform;
                    
                case 'RansacRigid'
            
                    [rigid_tform_mat, inlierCurrent] = estimateRigidTransformation(matchedCurrent.Location, matchedPrev.Location,500,10);
                    curr_prev_tform = affine2d(rigid_tform_mat');
                    
                    %fprintf('%sScale change is: %.5f\n',log_line_prefix,s);
                   %display(obj.prev_prev_next_tform.T');
                    
                    right_tform =  affine2d(obj.prev_prev_next_tform.T * (curr_prev_tform.T * right_to_left_tform.T));
                    
                    left_tform = affine2d(obj.prev_prev_next_tform.T * curr_prev_tform.T);
                    stable_left  = imwarp(current_left,left_tform,'OutputView',outputView);
                    stable_right = imwarp(current_right,right_tform,'OutputView',outputView);
               
                    obj.prev_prev_next_tform = left_tform;
                    
                case 'Asap'
                    [height,width,~] = size(current_left);
                    %3x3 mesh
                    quadWidth = width/(2^3);
                    quadHeight = height/(2^3);
                    
                    [current_left_featueres,prev_left_features]=SURF(current_left,obj.prev_left);
                    
                    lamda = 1; %mesh more rigid if larger value. [0.2~5]
                    asap = AsSimilarAsPossibleWarping(height,width,quadWidth,quadHeight,lamda);
                    asap.SetControlPts(current_left_featueres,prev_left_features);%set matched features
                    asap.Solve();            %solve Ax=b for as similar as possible
                    homos = asap.CalcHomos();% calc local hommograph transform
                    
                    gap = 0;
                    temp_right = imwarp(current_right,right_to_left_tform,'OutputView',outputView);
                    try 
                        stable_left = asap.Warp(current_left,gap);  
                        stable_right = asap.Warp(temp_right,gap);  
                    catch
                        fprintf('%sFailed to use ASAP warper, not stabilizing frames [%d,%d]!',log_line_prefix,obj.frame_inds(obj.currentPairInd,1),obj.frame_inds(obj.currentPairInd,2));
                        stable_left = current_left;
                        stable_right = temp_right;
                    end

                    
                otherwise
                    error('Unknown value "%s" for ''StereoStabilizerPrevNextWarp''.',obj.cfg.get('StereoStabilizerPrevNextWarp'));
            end
            
        end
        
        function [right_to_left_tform,left_inliners_bbox,validPtsLeft,featuresLeft] = ...
                StabilizeLeftRightBySimilarity(obj,Ileft,Iright)
            

            ptsLeft  = detectSURFFeatures(Ileft);
            ptsRight = detectSURFFeatures(Iright);
            %Extract feature descriptors.

            [featuresLeft,   validPtsLeft]  = extractFeatures(Ileft,  ptsLeft);
            [featuresRight, validPtsRight]  = extractFeatures(Iright, ptsRight);
            %Match features by using their descriptors.

            indexPairs = matchFeatures(featuresLeft, featuresRight);
            %Retrieve locations of corresponding points for each image.

            matchedLeft  = validPtsLeft(indexPairs(:,1));
            matchedRight = validPtsRight(indexPairs(:,2));
            %Show point matches. Notice the presence of outliers.

%             figure;
%             showMatchedFeatures(Ileft,Iright,matchedLeft,matchedRight);
%             title('Putatively matched points (including outliers)');


            %% Estimate a transform

            [right_to_left_tform, inlierRight, inlierLeft] = estimateGeometricTransform(...
                matchedRight, matchedLeft, 'similarity');

%             figure;
%             showMatchedFeatures(Ileft,Iright, inlierLeft, inlierRight);
%             title('Matching points (inliers only)');
%             legend('ptsLeft','ptsRight');

            %% Register
%             outputView = imref2d(size(Ileft));
%             right_warper_towards_left  = imwarp(Iright,right_to_left_tform,'OutputView',outputView);
% 
%             figure;
%             imshowpair(Ileft(Hcrop:end-Hcrop,Wcrop:end-Wcrop),...
%                        right_warper_towards_left(Hcrop:end-Hcrop,Wcrop:end-Wcrop),...
%                        'ColorChannels','red-cyan');


           left_inliners_bbox.top=min(inlierLeft.Location(:,2));
           left_inliners_bbox.bot=max(inlierLeft.Location(:,2));
           left_inliners_bbox.left=min(inlierLeft.Location(:,1));
           left_inliners_bbox.right=max(inlierLeft.Location(:,1)); 


        end
    end
    
end

