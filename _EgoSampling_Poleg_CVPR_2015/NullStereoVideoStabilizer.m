classdef NullStereoVideoStabilizer < VideoStabilizer
    %StereoVideoStabilizer stablize stereo sequence.
    
    properties
       currentPairInd;
       
    end
    
    
    methods
        function obj = NullStereoVideoStabilizer(sd, cfg,pairs)
            obj = obj@VideoStabilizer(sd,cfg,pairs);
            obj.currentPairInd=1;
            
        end
        
        function res = HasNext(obj)
            res = obj.currentPairInd<=size(obj.frame_inds,1);
        end
        
        function [stable_left,stable_right] = StabilizeNextPair(obj)
            if obj.HasNext()==0
                error('No next frame to process!');
            end
            
            if obj.useVideo==1
                % Read from video reader..
                right = read(obj.reader,obj.frame_inds(obj.currentPairInd,1));
                left = read(obj.reader,obj.frame_inds(obj.currentPairInd,2));
            else
                % Read from dump dir..
                f = obj.cfg.get('baseDumpFrameFileName');
                right = imread(sprintf(f,obj.frame_inds(obj.currentPairInd,1)));
                left = imread(sprintf(f,obj.frame_inds(obj.currentPairInd,2)));
            end
            
            stable_right = rgb2gray(right);
            stable_left = rgb2gray(left);
            
        end
      
    end
    
end

