classdef ConfigWrapper < handle
    
    properties
        argsmap;
        
        
        % Put all default values here.
        defaults = {
            'maxBatchMemory', 3e5;
            'FastForwardSkipRatio' , 10; % wished ratio between number of frames in input and output (used for naive frame selector)
            'maxTemporalDist', 30; %maximum temporal distance between two frames in the output
            'inputVideoFileName', 'no_default';
            'startInd', 1;
            'endInd', 0; %config wrapper will automaticaly update it with the last frame of the video
            'baseDumpFrameFileName','';% will default with: strrep([dir '/dump/' inputVideoFileName '/frame_%06d.png'],'\','/');
            
			%%preprocess secssion
            'PreProcessFilter_RemoveGaze',0;      
            'PreProcessFilter_RemoveNoneWalking',0; 
            'gazeMinBlocks', 0.6; %part of the blocks that indicate about a gaze
			'gazeRawSmoothDist', 0.15; %distance between cumulative OF and smoothed cumulative OF to indicate gaze
            %%
			
            'OFEstimator', 'Cumulative'; % Options: 'None','Cumulative'
            
            % The following is a weight for third-order terms in
            % DynamicProgamming frame selector:
            'SecondNeighbourTermWeight', 100;
            
            'ShakenessCostFunction', 'FOE'; %other options: 'None','FOE','AngleDiff','Epipole.vs.FOE','FFT'
            'ShaknessTermWeight', 1; % This was alpha
            'ShaknessTermBinaryThreshold',0.5;
            'ShaknessTermClampedValue',1000;
            'ShaknessTermInvalidValue',1000;
            'FOE_Reference','SmoothedCDC'; % Options: 'Absolute' or 'Smoothed'
            'findFOEMagThresh', 0; 
            'maximalFreqForFFTLowpass', 0; % default freq will be calculated to be one cycle per two seconds
      
            'ForwardnessCostFunction', 'FOE';
            'ForwardnessTermWeight', 1; % This is delta            
            'ForwardnessTermClampedValue', 1000;
            'ForwardnessTermBinaryThreshold',0.5;
            'ForwardnessMergeWithShaknessCoef',4;
            
            'VelocityCostFunction','OFMagnitudeCost'; % Options: 'None','OFMagnitudeCost'
            'VelocityTarget','Manual'; % Options: 'Manual' or  'CumulativeMean'
            'VelocityTermWeight', 1; % This was alpha
            'VelocityManualTargetValue', 2.5; 
            'VelocityTermBinaryThreshold',0.5;
            'VelocityTermClampedValue',1000;
            
            'AppearanceCostFunction','ColorHistogram'; % Options: 'None','ColorHistogram'
            'AppearanceTermWeight',1;
            'AppearanceTermBinaryThreshold',0.5;
            'AppearanceTermClampedValue',1000;
           
            'UseHigherOrder',false;
            'HighOrderTermWeight', 1000;
            
            'FrameSelector', 'ShortestPath'; %Naive ShortestPath DynamicProgramming
            'terminalConnectionDegree', 200;
            
            'CostWeightMethod', 'Sum'; % Other options: 'Sum', 'SumSquares', 'SumOfLogs', 'Multiplied', 'Binarized', 'Clamped'
                  
            'SkipVideoOutput',0; % Set to 1 to skip video output
            
            'AutoOutputPostfix',1;
            'OutputDirRelativeToInput',1;
            'OutputDir','out';
            'ShowOutputWhileDumping',1;
            'OutputOriginalFrameNum',1;
            'OutputOriginalTimestamp',1;
            
            %% Stabilization
            'OutputStablizer','None'; % Options: 'None','StereoStabilizer'
            
            %%stereo secssion
            'StereoCostFunction', 'OFPeaks';
            'StereoTermWeight', 1;
            'StereoTermInvalidValue', 1e6;
            'StereoTermBinaryThreshold',0.5;
            'StereoTermClampedValue',1000;
            'StereoFrameOrdering','RedCyan'; % Options: 'SideBySide','Interleaving', 'RedCyan'
            'StereoOutputWCropPercent',0.2;
            'StereoOutputHCropPercent',0.2;
            'StereoStabilizerLRWarp','None'; % Options: 'None','RansacSimilarity'
            'StereoStabilizerPrevNextWarp','None'; % Options: 'None','RansacSimilarity','Asap','RansacRigid'
			%%
            };
                
    end
    
    methods
        % Argument 'args' should be key-value pairs. Each pair is one row
        % in a 2D cell array.
        function obj = ConfigWrapper(args)

            obj.argsmap = containers.Map();

            for i=1:size(obj.defaults,1)
                obj.argsmap(obj.defaults{i,1}) = obj.defaults{i,2};
            end
        
            if nargin>0
                for i=1:size(args,1)
                    obj.argsmap(args{i,1}) = args{i,2};
                end
            end
            
            if exist('ConfigWrapperIncrementalID.mat','file')
                load('ConfigWrapperIncrementalID.mat','ConfigWrapperIncrementalID');
            else
                ConfigWrapperIncrementalID=0;
            end

            ConfigWrapperIncrementalID = ConfigWrapperIncrementalID + 1;
            
            obj.argsmap('ID') = ConfigWrapperIncrementalID;
            obj.argsmap('HOSTNAME') = getComputerName();
            
            save('ConfigWrapperIncrementalID.mat','ConfigWrapperIncrementalID');

			if strcmp(obj.argsmap('inputVideoFileName'),'no_default')
				error ('please add default input video file name');
			end
			
            if ~obj.argsmap.isKey('endInd') || obj.argsmap('endInd') == 0
                reader = VideoReader (obj.argsmap('inputVideoFileName'));
                obj.argsmap('endInd') = reader.numberOfFrames;
            end
            
            [dir, name, ~] = fileparts(obj.argsmap('inputVideoFileName'));
            if ~obj.argsmap.isKey('outputVideoFileName')
                obj.argsmap('outputVideoFileName') = [dir '/out/' name];
            else
                obj.argsmap('outputVideoFileName') = [dir '/out/' obj.argsmap('outputVideoFileName')];
            end
            
            if strcmp(obj.argsmap('baseDumpFrameFileName'),'')      
                 if obj.argsmap('endInd') > 1e4
                    obj.argsmap('baseDumpFrameFileName') = strrep([dir '/dump/' name '/frame_%06d.png'],'\','/');
                 else
                    obj.argsmap('baseDumpFrameFileName') = strrep([dir '/dump/' name '/frame_%05d.png'],'\','/');                     
                 end
            end
            obj.argsmap('baseDumpFrameFileName')  = strrep(obj.argsmap('baseDumpFrameFileName'),'\','/');
            
            if obj.argsmap('AutoOutputPostfix')==1
                obj.argsmap('outputVideoFileName') = [obj.argsmap('outputVideoFileName') '_' obj.argsmap('HOSTNAME') '_ExpID' num2str(ConfigWrapperIncrementalID)];
            end
            
            if obj.argsmap('maximalFreqForFFTLowpass') == 0
                obj.argsmap('maximalFreqForFFTLowpass') = 1 / 60; %this value means one cycle every two seconds
            end
            
        end

        function set(obj,arg,value)
            obj.argsmap(arg) = value;
        end
        
        function val = get(obj,arg)
            if ~obj.argsmap.isKey(arg)
                error('ConfigWrapper doesn''t have a key named ''%s''.',arg);
            end
            
            val = obj.argsmap(arg);
        end
        
        
        function carray = ToKeyValCellArray(obj)
            k = obj.argsmap.keys;
            
            carray = cell(numel(k),2);
            for i=1:numel(k)
                carray{i,1} = k{i};
                carray{i,2} = obj.Cell2StrRecursive(obj.argsmap(k{i}));
            end
            
        end
    end
        
    methods (Access = private)
        function s = Cell2StrRecursive(obj,c)
            if  isnumeric(c) || islogical(c)
                s = mat2str(c); 
                return
            elseif ischar(c)
                s = c;
                return;
            end
            
            if ~iscell(c)
                error('RecCell2Str expecting c to be a cell array here.');
            end
            
            s = '{';
            for i=1:numel(c)
                if i>1
                    s = sprintf('%s,',s);
                end
                
                s = sprintf('%s%s',s,obj.Cell2StrRecursive(c{i}));
            end
            
            s = sprintf('%s}',s);
        end

    end
      
    
end
