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

%% Class Name: SemanticSequenceLibrary
% 
% This class is an adaptation of the SequenceLibrary class present
% in the EgoSampling code. It contains configuration details to run  
% the Semantic Fast-Forward code.
%
% $Date: July 26, 2017
% ________________________________________
classdef SemanticSequenceLibrary
    methods(Static)
        
        function [videoFile, startInd, endInd, filename, fps] = GetVideoDetails(video_dir,exp_name)
            switch exp_name
                %% Semantic_Dataset
                case 'Bike1'
                    filename = 'bike07.mp4';
                    startInd=350;
                    endInd=11136;
                    fps = 30;
                case 'Bike2'
                    filename = 'bike07.mp4';
                    startInd=16150;
                    endInd=23199;
                    fps = 30;
                case 'Bike3'
                    filename = 'bike08.mp4';
                    startInd=5800;
                    endInd=29500;
                    fps = 30;
                case 'Climbing'
                    filename = 'climbing08.mp4';
                    startInd=1;
                    endInd=6494;
                case 'Scrambling'
                    filename = 'climbing03.mp4';
                    startInd=24800;
                    endInd=41199;
                case 'Walking1'
                    filename = 'gl02.mp4';
                    startInd=2800;
                    endInd=20049;
                    fps = 30;
                case 'Walking2'
                    filename = 'Alireza_Day2_001.avi';
                    startInd=700;
                    endInd=7600;
                    fps = 30;
                case 'Walking3'
                    %warning('failure case example');
                    filename = 'Huji_Yair_5.MP4';
                    startInd=1;
                    endInd=8000;
                    fps = 30;
                case 'Walking4'
                    filename = 'Huji_Yair_6.MP4';
                    startInd=1;
                    endInd=15568;
                    fps = 30;
                case 'Running1'
                    filename = 'Ayala_Triangle_Run_with_GoPro_Hero_3_Black_Edition.mp4';
                    startInd=2100;
                    endInd=15000;
                    fps = 24;
                case 'Driving1'
                    filename = 'Huji_Yair_9_part1.MP4';
                    startInd=1800;
                    endInd=10000;
                    fps = 30;
                case 'Driving2'
                    filename = 'Youtube_GoPro_Trucking_Yukon_to_Alaska_1080p.mp4';
                    startInd=1800;
                    endInd=12000;
                    fps = 30;
                %% An Example for usage
                case 'Example'
                    filename = 'example.mp4';
                    startInd = 1;
                    endInd   = 884;
                    fps      = 30;
                otherwise
                    error(['ERROR: You have specified a non-existent experiment (' exp_name ')']);
            end
            
            videoFile = fullfile(video_dir,filename);
        end
        
        function [cfg] = GetFFExperimentDetails(video_dir, exp_name, algorithm, required_speedup, skip_video_output)
            
            [videoFile, startInd, endInd, filename, fps] = SemanticSequenceLibrary.GetVideoDetails(video_dir,exp_name);
            
            [~, fname ,~] = fileparts(filename);
            
            framesDumpDir = strrep(fullfile(video_dir,['/dump/' fname]),'\','/');
            framesDumpFormat = strrep(fullfile(framesDumpDir,'/frame_%06d.png'),'\','/');
            
            if ~exist(sprintf(framesDumpFormat,startInd),'file')
                framesDumpFormat = strrep(fullfile(framesDumpDir,'/frame_%05d.png'),'\','/');
            end
            if ~exist(sprintf(framesDumpFormat,startInd),'file')
                framesDumpDir = strrep(fullfile(video_dir,[fname '_frames_undist']),'\','/');
                framesDumpFormat = [framesDumpDir '/frame_%05d.png'];
            end
            if ~exist(sprintf(framesDumpFormat,startInd),'file')
                framesDumpFormat = [framesDumpDir '/frame_%06d.png'];
            end
            
            
            % Generally, this is the config. For certain types of experiments,
            % we have a switch statement below to adjust stuff.
            cfg = ConfigWrapper({'inputVideoFileName',videoFile;...
                'FileName', fname;...
                'ExpName', exp_name;...
                'VelocityTarget','CumulativeMean';...
                'FastForwardSkipRatio', required_speedup;...
                'terminalConnectionDegree', 1;...
                
                'baseDumpFrameFileName',framesDumpFormat;
                'ShakinessCostFunction','FOE';
                'ShakinessTermWeight',10;...
                'ShakinessTermInvalidValue',100000;...
                
                'VelocityTermWeight',10;...
                'AppearanceCostFunction','ColorHistogram';
                'AppearanceTermWeight',2;...
                
                'SemanticCostFunction','Semantic';
                'SemanticTermWeight',1;...
                'SemanticEpsilon', 1;...
                
                'ForwardnessTermWeight',4;...
                'ForwardnessMergeWithShakinessCoef', 0;...
                'ForwardnessCostFunction','None';...
                
                'FrameSelector', 'ShortestPath';
                'UseHigherOrder',false;
                'maxTemporalDist',100;
                'FOE_Reference','Absolute';...
                'startInd',startInd;
                'endInd',endInd;
                'SkipVideoOutput',skip_video_output;
                'CostWeightMethod','Sum';
                
                'SaveFramesWhileDumping', 0;
                'ShowOutputWhileDumping', 0;
                'OutputFOEMovements', 0;
                'OutputFOEPoints', 0;
                'OutputSemanticBoxes', 0;
                'OutputSemanticWeight', 0;
                'OutputInstabilityValues', 0;
                'OutputOriginalTimestamp', 0;
                'OutputOriginalFrameNum', 0;
                'OutputTheoreticalSpeedup', 0;
                
                % Weights from semantic ranges
                'ShakinessTermWeight', [];
                'VelocityTermWeight', [];
                'AppearanceTermWeight', [];
                'SemanticTermWeight', [];
                'ForwardnessTermWeight', [];
                'HighOrderTermWeight', [];
                
                % Semantic ranges
                'SemanticRanges', [];
                'FPS', fps;
                
                %SemanticFunction
                'SemanticFunction', 'NormScore';
                
                %Charts
                'PlotCharts', 0;
                'SaveCharts', 0;

                });
            
            switch algorithm
                case 'Naive'
                    cfg.set('FrameSelector', 'Naive');
                case 'NaiveSemantic'
                    cfg.set('FrameSelector', 'NaiveSemantic');
                case 'EgoSampling'
                    cfg.set('SemanticCostFunction','None');
                case 'FFSE'
                    cfg.set('FrameSelector', 'ShortestPath');
                otherwise
            end
            
        end
    end        
end