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

function [Ranges_and_speedups] = AddNonSemanticRanges(Ranges_and_speedups, Speedup_Rates, startInd, endInd, min_range)

    Ranges_and_speedups = [Ranges_and_speedups; ones(1, size(Ranges_and_speedups, 2))];
    Non_semantic_ranges = [];

    num_frames = endInd - startInd + 1;

    % if empty
    if size(Ranges_and_speedups, 2) == 0
        Ranges_and_speedups = [startInd; endInd; Speedup_Rates(1, 2); 0];
        return;
    end

    % first
    if Ranges_and_speedups(1, 1)-startInd > min_range
        Non_semantic_ranges = [Non_semantic_ranges [startInd; Ranges_and_speedups(1, 1)-1; Speedup_Rates(1, 2); 0]];
    else
        Ranges_and_speedups(1, 1) = startInd;
    end

    % middle
    for i=2:size(Ranges_and_speedups, 2)
        if Ranges_and_speedups(1, i)-Ranges_and_speedups(2, i-1) < min_range
            Ranges_and_speedups(1, i) = Ranges_and_speedups(2, i-1)+1;
        else
            Non_semantic_ranges = [Non_semantic_ranges [Ranges_and_speedups(2, i-1)+1; Ranges_and_speedups(1, i)-1; Speedup_Rates(1, 2); 0]];
        end
    end

    % last
    if endInd-Ranges_and_speedups(2, end) < min_range
        Ranges_and_speedups(2, end) = endInd;
    else
        Non_semantic_ranges = [Non_semantic_ranges [Ranges_and_speedups(2, end)+1; endInd; Speedup_Rates(1, 2); 0]];
    end

    Ranges_and_speedups = [Ranges_and_speedups Non_semantic_ranges];
    [Ranges_and_speedups, ~] = sortrows(Ranges_and_speedups');
    Ranges_and_speedups = Ranges_and_speedups';

end