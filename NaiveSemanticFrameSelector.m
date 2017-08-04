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

classdef NaiveSemanticFrameSelector < CandidateFrameSelector 
    %NaiveFrameSelector selects output frames based on which frames have
    %more faces
    
    properties
        SemanticData; %Detected semantic data
    end
    
    methods
        function obj = NaiveSemanticFrameSelector (cfg, SemanticData)
            obj = obj@CandidateFrameSelector (cfg);
            obj.SemanticData = SemanticData;
        end
        
        function frame_indices = selectFrames (obj, ~, ~, ~)
            number_of_frames = obj.cfg.get('endInd')-obj.cfg.get('startInd')+1;
            %Sort detected semantics in descend order
            Semantic_Value = cell(obj.cfg.get('endInd')-obj.cfg.get('startInd')+1, 1);
            obj.SemanticData = obj.SemanticData(obj.cfg.get('startInd'):obj.cfg.get('endInd'));
            Semantic_Value(:) = {0};%Initializes the cell
            for i=1:size(obj.SemanticData,1)
                Semantic_Value{i} = FrameSemanticValue(obj.SemanticData{i});
            end
            [dummy, Index] = sort(cellfun(@double, Semantic_Value(:)), 'descend');
            %Select the frames which contain the most faces
            frame_indices = sort(Index(1:round(number_of_frames/obj.cfg.get('FastForwardSkipRatio'))));
        end
        
    end
    
end