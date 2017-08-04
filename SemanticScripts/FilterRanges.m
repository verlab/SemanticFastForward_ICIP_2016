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

function [ranges_and_speedups] = FilterRanges(ranges_and_speedups)
% Filter ranges_and_speedups to remove redundant segments.

	index = 1;
	while index < size(ranges_and_speedups,2) - 1
		if ( ranges_and_speedups(3,index) == ranges_and_speedups(3,index+1) )
			ranges_and_speedups(2,index) = ranges_and_speedups(2,index+1);
			ranges_and_speedups(:,index+1) = []; 
		else 
			index = index + 1;
		end
	end

end
