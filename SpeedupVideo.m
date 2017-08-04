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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a fast forward video based on the arguments
%
% video_dir -> Video Directory
% experiment -> Experiment Name
%
% Other arguments (see function parser)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpeedupVideo(video_dir, experiment, SN, SNS, shakiness_weights, velocity_weights, appearance_weights, semantic_weights, varargin)
close all
warning ('off', 'images:initSize:adjustingMag');
addpath(genpath(pwd));

%% Parsing input parameters
p = inputParser;

addOptional(p, 'SaveGeneralResults', true, @islogical);
addOptional(p, 'ExportOutputVideo', true, @islogical);
addOptional(p, 'ForwardnessWeights', [0, 0], @isrow);
addOptional(p, 'HigherOrderWeights', [0, 0], @isrow);
addOptional(p, 'Speedup', 10, @isnumeric);

validAlgorithm = {'Naive', 'NaiveSemantic', 'EgoSampling', 'FFSE'};
checkAlgorithm = @(x) any(validatestring(x,validAlgorithm));
addOptional(p, 'Algorithm', 'FFSE', checkAlgorithm); %'Naive', 'NaiveSemantic', 'EgoSampling', 'FFSE'

parse(p, varargin{:});

%% Assignments
save_general_results_to_file = p.Results.SaveGeneralResults;
skip_video_output = ~p.Results.ExportOutputVideo;
forwardness_weights = p.Results.ForwardnessWeights;
high_order_weights = p.Results.HigherOrderWeights;
required_speedup = p.Results.Speedup;
algorithm = p.Results.Algorithm;

%% Getting the experiment details
fprintf('%sGetting ''%s'' details...\n', log_line_prefix, experiment);
cfg = SemanticSequenceLibrary.GetFFExperimentDetails(video_dir, experiment, algorithm, required_speedup, skip_video_output);

startInd = cfg.get('startInd');
endInd = cfg.get('endInd');

[~, fname, ~] = fileparts(cfg.get('inputVideoFileName'));

% Load the video .mat file
fpstereo = [video_dir '/' fname 'fpstereo.mat'];
if ~exist(fpstereo, 'file')
    fprintf('%sPreprocess file not found...\n', log_line_prefix);
    optical_flow_csv = [video_dir '/' fname '.csv'];
    if exist(optical_flow_csv, 'file') == 0
        fprintf('%sOptical Flow CSV file not found...\n', log_line_prefix);
        error('Please run Vid2OpticalFlowCSV first!');
    end
    fprintf('%sPreprocessing optical flow data...\n', log_line_prefix);
    Util.PrepreocessSequences(cfg.get('inputVideoFileName'), '');
    fprintf('%sDone preprocessing optical flow data...\n', log_line_prefix);
end

sd = Util.LoadVidDataFromMat(cfg.get('inputVideoFileName'),'fpstereo','returnonly');

% End index treatment
if endInd > size(sd.CDC_Raw_X,1) + sd.StartFrame-1
    endInd = size(sd.CDC_Raw_X,1) + sd.StartFrame-1;
end

if save_general_results_to_file
    general_results = [video_dir '/out/' fname '_GeneralResults.csv'];
    
    if ( exist(general_results, 'file') == 2 )
        results_csv = fopen(general_results, 'a');
    else
        if ~exist([video_dir '/out/'], 'dir')
            mkdir(video_dir, 'out')
        end
        [results_csv, msg] = fopen(general_results, 'a');
        if (results_csv < 0)
            error('Could not open/create file.\nReason: %s', msg);
        end
        fprintf(results_csv, 'Experiment ID,Algorithm,Required Speedup,Achieved Speedup,Alphas,Betas,Gammas,Etas,# Selected Frames,# Faces in Selected Frames,Avg. Skip Frames,Median Skip Frames,Faces Value,Jitter\n');
    end
end

%% Satisfying the semantic requirements
semantic_filename = [video_dir '/' fname '_face_extracted.mat'];

fprintf('%sAttaching the semantic extraction information...\n', log_line_prefix);
if exist(semantic_filename, 'file')
    load(semantic_filename);
    SemanticData = Rects;
    clear Rects;
    clear total_values;
else
    error('Please, run ExtractAndSave to extract the semantic information first!');
end

if strcmp(algorithm, 'FFSE')%Only our algorithm requires speedup calculation
    fprintf('%sCalculating speedup rates...\n', log_line_prefix);

    [Speedups, SemanticRanges, RangesAndSpeedups, ~] = CalculateSpeedupRates(semantic_filename, required_speedup, SN, SNS,...
        'InputRange', [startInd endInd]);
    
    [RangesAndSpeedups] = AddNonSemanticRanges(RangesAndSpeedups, Speedups, startInd, endInd, 50);

    fprintf('-----------------------------------------------------------------------------------------------\n');
    fprintf('%sChosen ranges and speedups:\n', log_line_prefix);
    for i=1:size(RangesAndSpeedups,2)
        fprintf('%sRange[%d-%d]\t@ (%dx)\t-- Length(%d)\t-- Semantic? %d\n', log_line_prefix,...
            RangesAndSpeedups(1,i), RangesAndSpeedups(2,i),RangesAndSpeedups(3,i),...
            RangesAndSpeedups(2,i)-RangesAndSpeedups(1,i),RangesAndSpeedups(4,i));
    end
    fprintf('-----------------------------------------------------------------------------------------------\n');
    fprintf('\n');
    
    %     fprintf('From     -> [ %s]\n', sprintf('%d ', RangesAndSpeedups(1,:)));
    %     fprintf('To       -> | %s|\n', sprintf('%d ', RangesAndSpeedups(2,:)));
    %     fprintf('Speedup  -> | %s|\n', sprintf('%d ', RangesAndSpeedups(3,:)));
    %     fprintf('Semantic -> [ %s]\n', sprintf('%d ', RangesAndSpeedups(4,:)));
    cfg.set('Speedups', Speedups);
    cfg.set('SemanticRanges', SemanticRanges);
    cfg.set('RangesAndSpeedups', RangesAndSpeedups);
else
    RangesAndSpeedups = [startInd; endInd; required_speedup; 0];
    cfg.set('RangesAndSpeedups', RangesAndSpeedups);
end

%% More assignments
cfg.set('ShakinessTermWeight', [shakiness_weights(1), shakiness_weights(2)]);
cfg.set('VelocityTermWeight', [velocity_weights(1), velocity_weights(2)]);
cfg.set('AppearanceTermWeight', [appearance_weights(1), appearance_weights(2)]);
cfg.set('SemanticTermWeight', [semantic_weights(1), semantic_weights(2)]);
cfg.set('ForwardnessTermWeight', [forwardness_weights(1), forwardness_weights(2)]);
cfg.set('HighOrderTermWeight', [high_order_weights(1), high_order_weights(2)]);

se = SemanticFastForward(sd,cfg, SemanticData, strcmp(algorithm, 'FFSE'),true);

fprintf('%sRunning Experiment...\n', log_line_prefix);
se.run();

shakiness_weights = cfg.get('ShakinessTermWeight');
velocity_weights = cfg.get('VelocityTermWeight');
appearance_weights = cfg.get('AppearanceTermWeight');
semantic_weights = cfg.get('SemanticTermWeight');
forwardness_weights = cfg.get('ForwardnessTermWeight');
high_order_weights = cfg.get('HighOrderTermWeight');

if save_general_results_to_file
        fprintf(results_csv, '%d,%s,%d,%.3f,[%.3f %.3f],[%.3f %.3f],[%.3f %.3f],[%.3f %.3f],%d, %d, %.3f, %.3f, %.4f, %.4f\n',...
                cfg.get('ID'),algorithm,required_speedup,se.ResultsMetaData.achieved_speedup,shakiness_weights(1),shakiness_weights(2),velocity_weights(1),velocity_weights(2),appearance_weights(1),appearance_weights(2),...
                semantic_weights(1),semantic_weights(2), size(se.ResultsMetaData.frames,1), se.ResultsMetaData.total_semantic_in_frames, se.ResultsMetaData.avarage_skip,...
                se.ResultsMetaData.median_skip, se.ResultsMetaData.semantic_value, se.ResultsMetaData.jitter);
end

% Creating semantic cost csv for stabilizer
video_speedup = cfg.get('FastForwardSkipRatio');
cost_path = [video_dir '/' experiment '_SemanticCosts_' num2str(video_speedup) 'x.csv'];
if exist(cost_path, 'file') == 0
    csvwrite(cost_path, startInd);
    dlmwrite(cost_path, se.Semantic_cost, 'delimiter' , ',' , '-append');
end

fprintf('%sDone! Experiment #%d finished\n',log_line_prefix,cfg.get('ID'));

if save_general_results_to_file
    fclose(results_csv);
end
end
