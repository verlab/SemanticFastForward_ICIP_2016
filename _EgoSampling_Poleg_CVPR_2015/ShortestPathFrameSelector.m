classdef ShortestPathFrameSelector < CandidateFrameSelector
    %ShortestPathFrameSelector selects frames based on shortest path in
    %graph
    
    properties
    end
    
    methods
        function obj = ShortestPathFrameSelector (cfg)
            obj = obj@CandidateFrameSelector (cfg);
        end
   
function frame_indices = selectFramesThirdDegree (obj, interFrameCost, thirdDegreeCost)
    temporalDist = obj.cfg.get('maxTemporalDist');
    terminalConnectionDegree = obj.cfg.get('terminalConnectionDegree');
    num_frames = size(interFrameCost,1);            

    interFrame_first_ind = repmat(meshgrid(1:temporalDist,1:temporalDist),[1 num_frames-1]) +...
        reshape(meshgrid(1:num_frames-1,1:temporalDist^2),[temporalDist temporalDist*(num_frames-1)]);

    [mesh1,mesh2] = meshgrid(2:1+temporalDist, 1:temporalDist);
    interFrame_second_ind = repmat(mesh1 + mesh2, [1 num_frames-1]) +...
            reshape(meshgrid(0:num_frames-2,1:temporalDist^2),[temporalDist temporalDist*(num_frames-1)]);
    
    thirdDegree_first_ind = ...
        reshape(meshgrid(1:num_frames-1,1:temporalDist^2),[1 temporalDist* temporalDist*(num_frames-1)]);

    thirdDegree_second_ind = ...
        repmat(meshgrid(1:temporalDist,1:temporalDist)+1,[1 num_frames-1]) + ...            
        reshape(meshgrid(0:num_frames-2,1:temporalDist^2),[temporalDist temporalDist*(num_frames-1)]);

    thirdDegree_third_ind = ...
        interFrame_second_ind;

    source_indices = meshgrid(1:temporalDist*(num_frames-1), 1:temporalDist);

    dest_indices = (meshgrid(1:temporalDist^2,1:num_frames-1) +...
        meshgrid(1:num_frames-1,1:temporalDist^2)' * temporalDist)' ;

    interFrame_first_ind  = interFrame_first_ind (:);
    interFrame_second_ind = interFrame_second_ind (:);

    indices_out_of_bounds = interFrame_second_ind > num_frames;
    
    dummy_start_node_i = ones(1,terminalConnectionDegree*temporalDist);
    dummy_start_node_j = (1:terminalConnectionDegree*temporalDist) +1;
%     dummy_end_node_i   = find(...
%                thirdDegree_third_ind(~indices_out_of_bounds) > num_frames- terminalConnectionDegree);
    dummy_end_node_i = thirdDegree_third_ind (:) > num_frames-terminalConnectionDegree ...
                            & ~indices_out_of_bounds;
    dummy_end_node_i = unique(sort(dest_indices(dummy_end_node_i )))+1;
    
%     dummy_end_node_i(dummy_end_node_i<=num_frames * temporalDist);
%         ((num_frames- terminalConnectionDegree)*temporalDist+1 ...
%                                    : num_frames*temporalDist  )+1;
    dummy_end_node_j   = ones(size(dummy_end_node_i )) * (num_frames*temporalDist+2); %index of end dummy is num_frames*temporalDist+2
    
    source_indices = source_indices (:);
    dest_indices   = dest_indices(:);
    
    source_indices = source_indices (~indices_out_of_bounds);
    dest_indices   = dest_indices   (~indices_out_of_bounds);
    
    interFrame_first_ind  = interFrame_first_ind  (~indices_out_of_bounds);
    interFrame_second_ind = interFrame_second_ind (~indices_out_of_bounds);
    
    interFrame_second_ind = interFrame_second_ind - interFrame_first_ind ;
        
    
    thirdDegree_first_ind  = thirdDegree_first_ind (:);            
    thirdDegree_second_ind = thirdDegree_second_ind (:);             
    thirdDegree_third_ind  = thirdDegree_third_ind (:);
    
    thirdDegree_third_ind  = thirdDegree_third_ind - thirdDegree_second_ind ;
    thirdDegree_second_ind = thirdDegree_second_ind - thirdDegree_first_ind ;

    thirdDegree_first_ind  = thirdDegree_first_ind (~indices_out_of_bounds); 
    thirdDegree_second_ind = thirdDegree_second_ind (~indices_out_of_bounds); 
    thirdDegree_third_ind  = thirdDegree_third_ind (~indices_out_of_bounds); 

    
    ind_to_interFrame = sub2ind(size(interFrameCost),...
        interFrame_first_ind , interFrame_second_ind);
    
    ind_to_thirdDegree = sub2ind(size(thirdDegreeCost),...
        thirdDegree_first_ind , thirdDegree_second_ind, thirdDegree_third_ind);
    
    interFrame_first_ind = [];
    interFrame_second_ind = [];
    thirdDegree_first_ind  =[];
    thirdDegree_second_ind =[];
    thirdDegree_third_ind =[];
    
    sparse_ind_i = [dummy_start_node_i source_indices'+1 dummy_end_node_i'];
    sparse_ind_j = [dummy_start_node_j dest_indices'+1   dummy_end_node_j'];
           
    sparse_entry = [ones(1, terminalConnectionDegree*temporalDist) ...
        interFrameCost(ind_to_interFrame)'+...
        thirdDegreeCost(ind_to_thirdDegree)' ...
        ones(size(dummy_end_node_i))']; %uniform cost from and to dummy nodes
    
    ind_to_interFrame =[];
    ind_to_thirdDegree =[];
    
    cost_matrix = sparse(sparse_ind_i, sparse_ind_j, sparse_entry, num_frames*temporalDist+2, num_frames*temporalDist+2); 

    %uncomment next line to view the graph (ONLY for small graphs)
%     view(biograph(cost_matrix,cellfun(@id2str,repmat({obj.cfg},[num_frames*temporalDist+2,1]) ,mat2cell((1:num_frames*temporalDist+2)',ones(1,num_frames*temporalDist+2)),'UniformOutput',false),'ShowWeights','on'))
    fprintf('%sStart shortest path in graph algorithm..\n', log_line_prefix);
    [~, frame_indices, ~] = graphshortestpath (cost_matrix, 1, num_frames*temporalDist+2,'Method','Acyclic');%Bellman-Ford');
    fprintf('%Done shortest path in graph algorithm..\n', log_line_prefix);
    frame_indices = frame_indices(2:end-1)-1;
%     last_frame = mod(frame_indices(end),temporalDist)+ceil(frame_indices(end)/temporalDist);
    frame_indices = ceil(frame_indices/temporalDist);
end

        function frame_indices = selectFrames (obj, interFrameCost)
            
            temporalDist = obj.cfg.get('maxTemporalDist');
                        
            num_frames = size(interFrameCost,1);
            [frame_index,temporal_dist_index] = ...
                    meshgrid(1 : num_frames, 1 : temporalDist);
            
            index = frame_index + temporal_dist_index;

            source_frame_indices = repmat( 1:num_frames, [1 temporalDist]);
            dest_frame_indices = index';
            dest_frame_indices = dest_frame_indices(:)';
            
            interFrameCost(interFrameCost==0) = 0.000000000001;
            
            interFrameCost(isnan(interFrameCost)) = 0;
            interFrameCost(interFrameCost==inf) = 0;
            
            interFrameCost = interFrameCost(:)';
            source_frame_indices = source_frame_indices(:)'; 
            
            nan_indices = dest_frame_indices  > num_frames;
            interFrameCost = interFrameCost(~nan_indices );
            source_frame_indices = source_frame_indices(~nan_indices );
            dest_frame_indices = dest_frame_indices(~nan_indices );
               
            terminalConnectionDegree = obj.cfg.get('terminalConnectionDegree') ;
            dummy_start_node_i = ones(1,terminalConnectionDegree);
            dummy_start_node_j = (1:terminalConnectionDegree) +1;
            dummy_end_node_i   = (num_frames - terminalConnectionDegree+1:num_frames)+1;
            dummy_end_node_j   = ones(1,terminalConnectionDegree) * (num_frames+2); %index of end dummy is num_frames+2

            sparse_ind_i = [dummy_start_node_i source_frame_indices+1 dummy_end_node_i];
            sparse_ind_j = [dummy_start_node_j dest_frame_indices+1   dummy_end_node_j];
            
            sparse_entry = [ones(1, terminalConnectionDegree) interFrameCost ones(1, terminalConnectionDegree)]; %uniform cost from and to dummy nodes
    
            cost_matrix = sparse(sparse_ind_i, sparse_ind_j, sparse_entry, num_frames+2, num_frames+2); 

            [~, frame_indices, ~] = graphshortestpath (cost_matrix, 1, num_frames+2,'Method','Bellman-Ford');
            frame_indices = frame_indices(2:end-1)-1; %because of the dummy indices
        end
        
        
    end
    
end

