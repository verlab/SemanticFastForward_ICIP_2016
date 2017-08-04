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

function ShowSemanticPercentages(matFileName, varargin)

    close all;
    
    p = inputParser;

    addRequired(p,'matFileName',@ischar);
    parse(p, matFileName);
        
    [Threshold_Ranges, numFrames, ~, Semantic_frames_indexes] = SemanticRange(matFileName, varargin{:});
        
    fprintf('\n');
    fprintf('Semantic Percentage for: %s', matFileName);
    Ts = 0;
    if(~isempty(Threshold_Ranges))
        Range = Threshold_Ranges{1};
        Ts = sum(Range(2,:) - Range(1,:));
    end
    fprintf('\nTs: %d\n', Ts);
    fprintf('Tns: %d\n', numFrames-Ts);
    fprintf('ps = Ts/(Ts+Tns)*100%%: %f%%\n', ((Ts/numFrames)*100));
    fprintf('Semantic Percentage: %f%% \n', length(Semantic_frames_indexes)/numFrames*100);
    fprintf('\n');

end
