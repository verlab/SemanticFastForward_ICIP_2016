%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   This file is part of SemanticFastForward_EPIC@ECCVW.
%
%    SemanticFastForward_EPIC@ECCVW is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    SemanticFastForward_EPIC@ECCVW is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with SemanticFastForward_EPIC@ECCVW.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1- Download our example video and move it to the project folder.

$ wget www.verlab.dcc.ufmg.br/semantic-hyperlapse/data/video-example/example.mp4


% 2- Extract the optical flow information. The output file name must be the same name of the input video using the extesion ".csv".

% Vid2OpticalFlowCSV.exe -v < video_file > -c < config_file > -o < output_file >

$ ./Vid2OpticalFlowCSV.exe -v example.mp4 -c default-config.xml -o example.csv


% 3- Extract semantic information from video with "SemanticScripts/ExtractAndSave.m". Output file will be placed on the input video folder, with video file name, followed by the semantic extractor and the suffix "extracted.mat". Example: "example_face_extracted.mat".

% On MATLAB console, go to the project folder and run the following commands:

% ExtractAndSave(< video_file_path >);

>> ExtractAndSave('../example.mp4');


% Results for steps 2 (example.csv) and 3 (example_face_extracted.mat) for this example video are available for download using the link:

$ wget www.verlab.dcc.ufmg.br/semantic-hyperlapse/data/video-example/example.csv

$ wget www.verlab.dcc.ufmg.br/semantic-hyperlapse/data/video-example/example_face_extracted.mat


% 4- To find the speedups, first use the "SemanticScripts/GetSemanticRanges" function, with the extracted semantic file as argument, to get the number of semantic and non-semantic frames.

% [~, < number_of_non_semantic_frames >, < number_of_semantic_frames >] = GetSemanticRanges(< extracted_semantic_mat_file_path >);

>> [~, Tns, Ts] = GetSemanticRanges('../example_face_extracted.mat');


% 5- Then, use the "SpeedupOptimization" function to find the semantic and non-semantic speedups.

% [<semantic_speedup>, <non_semantic_speedup>] = SpeedupOptimization(< number_of_non_semantic_frames >, < number_of_semantic_frames >, < required_final_speedup >, < max_graph_step >, < first_lambda >, < second_lambda >, < plot >);

>> [SS, SNS] = SpeedupOptimization(641, 246, 10, 100, 15, 20, 0);


% We suggest to use "Util/FindingBestSpeedups.m", which returns a set of possible speedup combinations.

% FindingBestSpeedups(< number_of_non_semantic_frames >, < number_of_semantic_frames >, < required_final_speedup >);

>> [SS, SNS] = FindingBestSpeedups(641, 246, 10);


% 6- To generate the final hyperlapse video, use the "SpeedupVideo" function. The graph weight tuple are composed of [semantic_weight non-semantic_weigth].

% SpeedupVideo(< video_dir >, < experiment_name >, < semantic_extractor >, < semantic_speedup >, < non_semantic_speedup >, < shakiness_weights >, < velocity_weights >, < appearance_weights >, < semantic_weights >);

>> SpeedupVideo('', 'Example', 'face', 6, 14, [10 5], [3 15], [50 30], [20 2]);

% In this script, the example video is inside the project folder, so set the < video_dir > parameter as ''.


% To find good results, we recommend to try different graph weigths and checking the output information in the "out/EXPERIMENT_NAME_GeneralResults.csv" file.
% The user may set the optional argument 'ExportOutputVideo' as false to avoid generate the output video during the search.

>> SpeedupVideo('', 'Example', 'face', 6, 14, [50 50], [50 50], [50 50], [50 50], 'ExportOutputVideo', false);
