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

function [sd, cfg] = LoadToMem(video_dir, experiment)
    %% Loads the video into memo, so that we can work on it (use algorithms, etc.)
    close all
    warning ('off', 'images:initSize:adjustingMag');

    cfg = SequenceLibrary.GetFFExperimentDetails(video_dir, experiment, 'Naive', 0,0,0,0,0,0,1);
                                
    % Load the video .mat file
    sd = Util.LoadVidDataFromMat(cfg.get('inputVideoFileName'),'fpstereo','returnonly');
end