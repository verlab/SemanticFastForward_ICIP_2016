function [foe_x, foe_y,est_err, all_scores] = find_foe_from_flow_field(flow_x,flow_y,mag_threshold)

    % Get the size of the flow field, in blocks.
    xblocks = size(flow_x,2);
    yblocks = size(flow_y,1);
    
    % Find the center block. Ideally, the FOE will be here.
    cx = xblocks/2 + 0.5;
    cy = yblocks/2 + 0.5;
    
    

       
    % Threshold vectors with low magnitude. We don't want them affecting
    % the results.
    flow_magnitude = sqrt(flow_x.^2 + flow_y.^2);
    flow_x = flow_x ./ flow_magnitude;
    flow_y = flow_y ./ flow_magnitude;
    
    invalid_mag_mask = flow_magnitude <= mag_threshold;
    % Get number of valid vectors. We normalize the result by this factor.
    num_valid_vectors = sum(~invalid_mag_mask(:));
    
    % This is the search range for the FOE. If the original flow field width is
    % xblock, the we'll look 2 blocks from the 'left' of it, and 2 blocks
    % to the 'right' of it. Same for the Y direction.
    
    %xrange = [-xblocks:3:-4 -2:xblocks+2 xblocks+4:3:2*xblocks];
    %yrange = [-yblocks:3:-4 -2:yblocks+2 yblocks+4:3:2*yblocks];;
    xrange = -4:1:xblocks+4;
    yrange = -4:1:yblocks+4;
        
    % Create a matrix to hold the results (scores).
    res = zeros(numel(yrange),numel(xrange));
    
    global template_arr_x;
    global template_arr_y;
    global template_arr_magnitude;
    global template_arr_init_state;
    global template_arr_dims;
    
    if isempty(template_arr_magnitude) || isempty(template_arr_dims) || ~all(template_arr_dims ==  [xblocks yblocks])
        % Create a mesh create from which we'll create temporary flow
        % templates.
        [meshx, meshy] = meshgrid(1:xblocks,1:yblocks);
        
        template_arr_x = zeros(yblocks,xblocks,numel(xrange)*numel(yrange));
        template_arr_y = zeros(yblocks,xblocks,numel(xrange)*numel(yrange));
        template_arr_magnitude = zeros(yblocks,xblocks,numel(xrange)*numel(yrange));
        template_arr_init_state = zeros(size(template_arr_magnitude,3),1);
        template_arr_dims = [xblocks yblocks];
    end
    
    % Scan the range
    j=1;
    arr_ind = 1;
    for x=xrange
        i=1;
        for y=yrange
           
            if template_arr_init_state(arr_ind)==0
                temp_x = meshx - x;
                temp_y = meshy - y;
                
                template_arr_magnitude(:,:,arr_ind) = sqrt(temp_x.^2 + temp_y.^2);
                
                temp_x = temp_x ./ template_arr_magnitude(:,:,arr_ind);
                temp_y = temp_y ./ template_arr_magnitude(:,:,arr_ind);
                
                temp_x(template_arr_magnitude(:,:,arr_ind)==0) = 0;
                temp_y(template_arr_magnitude(:,:,arr_ind)==0) = 0;
                
                template_arr_x(:,:,arr_ind) = temp_x;
                template_arr_y(:,:,arr_ind) = temp_y;
                
                template_arr_init_state(arr_ind)=1;
                
            end
%             template_x = template_x ./ template_magnitude;
%             template_y = template_y ./ template_magnitude;
%             template_x(template_magnitude==0) = 0;
%             template_y(template_magnitude==0) = 0;
%     
            
            %subsample_inds = 1:2:numel(template_x);
            
            % Estimate the vector-wise deviation angle 
%             ang = atan2((template_x(subsample_inds) .* flow_y(subsample_inds))  -  (template_y(subsample_inds) .* flow_x(subsample_inds)),...
%                         (template_x(subsample_inds)  .* flow_x(subsample_inds)) +  (template_y(subsample_inds) .* flow_y(subsample_inds)));
            
%             ang = atan2((template_x .* flow_y)  -  (template_y .* flow_x),...
%                         (template_x  .* flow_x) +  (template_y .* flow_y));
            
            %cosang = ( 1 - ((template_x .* flow_x) + (template_y .* flow_y))) .* (template_magnitude~=0);
            cosang =  1 - ((template_arr_x(:,:,arr_ind) .* flow_x) + (template_arr_y(:,:,arr_ind) .* flow_y));
            
            % If there are any invalid blocks (low magnitude), ignore them.
             if num_valid_vectors<xblocks*yblocks
                 cosang(invalid_mag_mask) = 0;
             end
            
            % Store the result (the average..)
            res(i,j) = sum(cosang(:));
            %fprintf('%.1f,%.1f == %.3f\n',xrange(j)-cx,yrange(i)-cy,res(i,j) );
            i=i+1;
            arr_ind=arr_ind+1;
        end
        j=j+1;
    end

    
    % Show the result. Comment this if you want to speed things up.
%     figure; imagesc(res);
    
    % Find the global minima. Hopefully, there is only one.
    [min_val, min_ind] = min(res(:));
    
    [i,j] = ind2sub(size(res),min_ind);
    
    % Switch to image coordiantes where (0,0) is in the center of the flow
    % field.
    foe_x=xrange(j)-cx;
    foe_y=yrange(i)-cy;
    
    % Return the avg angle deviation. Low value=better. This can be
    % interpretted as estimation error.
    est_err = min_val ./ num_valid_vectors;
 
    all_scores = res;
end
