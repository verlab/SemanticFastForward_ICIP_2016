function [foe_x, foe_y,est_err, all_scores] = find_foe_from_flow_field_block(flow_x,flow_y,mag_threshold)

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
    

    xrange = -10:1:xblocks+10;
    yrange = -10:1:yblocks+10;
        

    
    global template_arr_x;
    global template_arr_y;
    global template_arr_magnitude;
    global template_arr_init_state;
    global template_arr_non_zeros;
    global template_arr_dims;
    
    
    if isempty(template_arr_magnitude) || isempty(template_arr_dims) || ~all(template_arr_dims ==  [xblocks yblocks])
        % Create a mesh create from which we'll create temporary flow
        % templates.
        [meshx, meshy] = meshgrid(1:xblocks,1:yblocks);
        
        template_arr_x = zeros(yblocks,xblocks,numel(xrange)*numel(yrange));
        template_arr_y = zeros(yblocks,xblocks,numel(xrange)*numel(yrange));
        template_arr_magnitude = zeros(yblocks,xblocks,numel(xrange)*numel(yrange));
        template_arr_init_state = zeros(size(template_arr_magnitude,3),1);
        template_arr_non_zeros = zeros(size(template_arr_magnitude,3),1);
        template_arr_dims = [xblocks yblocks];
        
        % Scan the range
        j=1;
        arr_ind = 1;
        for x=xrange
            i=1;
            for y=yrange

                temp_x = meshx - x;
                temp_y = meshy - y;

                template_arr_magnitude(:,:,arr_ind) = sqrt(temp_x.^2 + temp_y.^2);

                temp_x = temp_x ./ template_arr_magnitude(:,:,arr_ind);
                temp_y = temp_y ./ template_arr_magnitude(:,:,arr_ind);

                temp_x(template_arr_magnitude(:,:,arr_ind)==0) = 0;
                temp_y(template_arr_magnitude(:,:,arr_ind)==0) = 0;

                template_arr_x(:,:,arr_ind) = temp_x;
                template_arr_y(:,:,arr_ind) = temp_y;

                template_arr_non_zeros(arr_ind) = sum(sum(template_arr_magnitude(:,:,arr_ind)~=0));
                
                template_arr_init_state(arr_ind)=1;

                i=i+1;
                arr_ind=arr_ind+1;
            end
            j=j+1;
        end

    end
    
   
    flow_x_3d = repmat(flow_x,[1,1,size(template_arr_x,3)]);
    flow_y_3d = repmat(flow_y,[1,1,size(template_arr_y,3)]);
    invalid_mag_mask_3d = repmat(invalid_mag_mask,[1,1,size(template_arr_y,3)]);
    
    cosang =  ((template_arr_x .* flow_x_3d) + (template_arr_y .* flow_y_3d));

    % If there are any invalid blocks (low magnitude), ignore them.
     if num_valid_vectors<xblocks*yblocks
         cosang(invalid_mag_mask_3d) = 0;
     end

    % Store the result (the average..)
    templates_results = sum(sum(cosang));
    res = template_arr_non_zeros - templates_results(:);
    
    % Show the result. Comment this if you want to speed things up.
%     figure; imagesc(res);
    
    % Find the global minima. Hopefully, there is only one.
    [min_val, min_ind] = min(res(:));
    
    [i,j] = ind2sub([numel(yrange),numel(xrange)],min_ind);
    
    % Switch to image coordiantes where (0,0) is in the center of the flow
    % field.
    foe_x=xrange(j)-cx;
    foe_y=yrange(i)-cy;
    
    % Return the avg angle deviation. Low value=better. This can be
    % interpretted as estimation error.
    est_err = min_val ./ num_valid_vectors;
 
    all_scores = reshape(res,[numel(yrange),numel(xrange)]);
end
