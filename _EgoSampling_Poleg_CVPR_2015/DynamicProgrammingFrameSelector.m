classdef DynamicProgrammingFrameSelector < CandidateFrameSelector
    %DynamicProgrammingFrameSelector finds path with minimum energy,
    %uses terms to third degree
    
properties
end

methods

function obj = DynamicProgrammingFrameSelector (cfg)
    obj = obj@CandidateFrameSelector (cfg);
end

function frame_indices = selectFrames (obj, interFrameCost, thirdDegreeCost)
    terminal_level = obj.cfg.get('terminalConnectionDegree') ;
    tempDist = obj.cfg.get('maxTemporalDist');
    num_input_frames = size(interFrameCost,1);
    num_output_frames = floor(num_input_frames/obj.cfg.get('FastForwardSkipRatio'));

     s_cost = cellfun(@zeros,repmat({num_input_frames},[ 1 num_output_frames]),...
        repmat({tempDist},[ 1 num_output_frames]),...
         repmat({'single'},[ 1 num_output_frames]),'UniformOutput', false);

    %     s_cost = cellfun(@sparse,repmat({num_input_frames},[ 1 num_output_frames]),...
%         repmat({tempDist},[ 1 num_output_frames]),'UniformOutput', false);
    
%     ndSparse.build([],[],[num_output_frames, num_input_frames,tempDist],...
%         numel(thirdDegreeCost)+num_input_frames*2 );
    %s_cost(i,j,k) = cost of having input frame j as output frame i, when
    %last frame was j-k
    
    D = zeros(num_input_frames, 1);
    V = interFrameCost;    
    H = thirdDegreeCost;
    
    back_traking =cellfun(@zeros,repmat({num_input_frames},[ 1 num_output_frames]),...
        repmat({tempDist},[ 1 num_output_frames]),...
         repmat({'uint16'},[ 1 num_output_frames]),'UniformOutput', false);
%     ndSparse.build([],[],...
%         [num_output_frames, num_input_frames,tempDist],...
%         (numel(thirdDegreeCost)+num_input_frames*2) );
        
%first output frame can be only one of those
    s_cost{1}( 1:terminal_level ,:) = 1;

%second output frame does not have H (second neighbour) element

    fprintf('%sBuilding dynamic programing matrix, output frame 2\n',log_line_prefix);

    for j = 2:min(num_input_frames, terminal_level  +tempDist)
            for k =1:tempDist
                if j > terminal_level + k
                    s_cost{2}(j,k) = inf;
                    continue
                end
                if k > j-1
                    s_cost{2}(j,k) = inf;
                else
                    s_cost{2}(j,k) = D(j) + V(j-k,k) + s_cost{1}(j-k,1);
                    back_traking{2}(j,k) = -1; %should not be used
                end
            end
    end
    profile off
    profile on
    for i = 3:num_output_frames
        if i == 20
            profile viewer
        end
        if mod(i,10) == 3
            fprintf('%sBuilding dynamic programing matrix, output frames %d-%d\n',log_line_prefix,i,i+9);
        end
        for j = i:min(num_input_frames,(i-1)*tempDist+terminal_level)
            for k =1:tempDist
                if j > terminal_level + k +(i-2)*tempDist
                    s_cost{i}(j,k) = inf;
                    continue
                end
                if k > j-i+1
                    s_cost{i}(j,k) = inf;
                else
                    H_in_borders = min(tempDist, j-k-1);
                    ind_H = sub2ind(size(H), j-k-1 : -1 : j-k-H_in_borders , 1:H_in_borders, ones(1,H_in_borders)*k);
                    %s_cost (i,j,k) holds the cumulative cost for output i ,
                    %input j, and previous input j-k (1<=k<=maxtempDist)
                    [~,l] = min(full(s_cost{i-1}(j-k,1:H_in_borders))+H(ind_H));
                    s_cost{i}(j,k) = D(j) + V(j-k,k) + H(j-k-l, l, k) + s_cost{i-1}(j-k,l);
                    %(j-k-l,j-k) are the indexes of the previous input frames 
                    %in the shortest path to j
                    back_traking{i}(j,k) = j-k-l;    
                end
            end
        end
    end
    
    s_cost {end}( 1:end-terminal_level ,:) = inf;
    [min_energy, curr] = min(full(s_cost{end}));
    [~, dist_to_prev] = min(min_energy);
    curr = curr(dist_to_prev);
    
    frame_indices = zeros(num_output_frames,1);
    frame_indices(end) = curr;
    frame_indices(end-1) = curr(1)-dist_to_prev;
    
    prev_prev = back_traking{end}(curr,dist_to_prev);
    for i = num_output_frames-1:-1:2
        frame_indices(i-1) = prev_prev;
        curr = curr-dist_to_prev;
        dist_to_prev = curr-prev_prev;
        prev_prev = back_traking{i}(curr,dist_to_prev);
        
    end
end
end
end

