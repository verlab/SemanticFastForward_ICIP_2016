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

function Total = FrameSemanticValue(rects, value_type)
    %     Total = FaceSizeBasedValue(rects);
    if nargin < 2
        value_type = 'SizeBased';
    end
    switch value_type
        case 'SizeBased'
            Total = FaceSizeBasedValue(rects);
        case 'ScoreBased'
            Total = FaceScoreBasedValue(rects);
    end
end

function Total = FaceSizeBasedValue(rects)
    Total = 0;
    for j=1:length(rects)
        Total = Total + (rects(j).score * rects(j).gaussianWeight * rects(j).faceSizeValue);
    end
end

function Total = FaceScoreBasedValue(rects)
    Total = 0;
    for j=1:length(rects)
        gaussian_value = floor( ( 2.5 * rects(j).gaussianWeight) );
        
        if rects(j).faceSizeValue < 300
            %size_value = floor( faceSizeValue / 100 );
            size_value = floor( rects(j).faceSizeValue / 100 );
        else
            size_value = 3;
        end
        
        if rects(j).score < 50
            score_value = - ( ( 55 - rects(j).score ) / 50 );
            size_value = 0;
            gaussian_value = 0;
        elseif rects(j).score < 500
            score_value = floor( rects(j).score / 125 );
        else
            score_value = 4;
        end
        
        Total = Total + (1 + score_value + gaussian_value + size_value);
    end
end