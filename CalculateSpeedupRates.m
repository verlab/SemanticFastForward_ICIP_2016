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

function [Speedup_Rates, Semantic_Ranges, Ranges_and_speedups, err, Ts, Tns] = CalculateSpeedupRates(semantic_filename, Sb, SS, SNS, varargin)
    [Semantic_Ranges, num_frames, ~] = SemanticRange(semantic_filename, varargin{:});

    num_ranges = length(Semantic_Ranges);

    if(num_ranges == 0)
        Speedup_Rates = [Sb, Sb];
    else
        Speedup_Rates = zeros(num_ranges, 2);
    end

    err = 0;
    num_frames_aux = num_frames;

    ranges_concat = horzcat(Semantic_Ranges{:});
    Ranges_and_speedups = zeros(3, size(ranges_concat,2));
    Ranges_and_speedups(1:2,:) = ranges_concat;

    k = 1;
    Ts = 0;
    Tns = num_frames;
    for i=1:length(Semantic_Ranges)
        Ts = sum(Semantic_Ranges{i}(2,:) - Semantic_Ranges{i}(1,:));
        Tns = num_frames_aux - Ts;
        Speedup_Rates(i,:) = [SS; SNS];
        
        for j=1:size(Semantic_Ranges{i},2)
            Ranges_and_speedups(3, k) = SS;
            k = k+1;
        end
        
        %% Calculating error
        err = err + abs((Ts+Tns)/Sb - (Ts/SS + Tns/SNS));
        
        %% Updates to iterate
        Sb = SS;
        num_frames_aux = Tns;
    end

    [Ranges_and_speedups, ~] = sortrows(Ranges_and_speedups');
    Ranges_and_speedups = Ranges_and_speedups';

    err = err/num_frames;% Percentage error
end
