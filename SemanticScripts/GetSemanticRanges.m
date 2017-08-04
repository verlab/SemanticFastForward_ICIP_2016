%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   This file is part of ICIP.
%
%    ICIP is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    ICIP is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with ICIP.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Threshold_Ranges, TnsTotal, TsTotal] = GetSemanticRanges(matFileName, varargin)
    close all;
    
    p = inputParser;

    addRequired(p,'matFileName',@ischar);
    parse(p, matFileName);
    
    [Threshold_Ranges, numFrames, frame_rate] = SemanticRange(matFileName, varargin{:});
    
    Ts = 0;
    TsTotal = 0;
    
    fprintf('\n');
    if ~isempty(Threshold_Ranges)
        Range = Threshold_Ranges{1};
        for i = 1 : size(Range,2)
            Ts = Range(2,i) - Range(1,i);
            fprintf('Range Ts %d: %d  -- [%d -> %d]\n', i, Ts, Range(1,i), Range(2,i));
            TsTotal = Ts + TsTotal;
        end
    end
    
    TnsTotal = numFrames-TsTotal;
    
    fprintf('\nTotal Ts: %d\n', TsTotal);
    fprintf('Total Tns: %d\n', TnsTotal);
    fprintf('Real percentage: %f\n', ((TsTotal/numFrames)*100));
    fprintf('Duration: %f minutes @ %.2f FPS\n', numFrames/(frame_rate*60), frame_rate);
    
end
