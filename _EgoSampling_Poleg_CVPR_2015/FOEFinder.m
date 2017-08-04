classdef FOEFinder < handle
    %FOEFinder finds foe of optical flow 
    
    properties
        sd;
        cfg;
        num_blocks;
        mag_thresh ;
    end
    
    methods
        function obj = FOEFinder (sd, cfg)       
            obj.sd = sd;
            obj.cfg = cfg;
            
            obj.num_blocks = [obj.sd.num_x_cells, obj.sd.num_y_cells];
            obj.mag_thresh = obj.cfg.get('findFOEMagThresh');
        end
        
        % foe of smoothed optical flow to succesive frame 
        function [foe_x, foe_y] = FOE(obj,ind,smoothed)
            if smoothed     
                [foe_x, foe_y, ~,~] = find_foe_from_flow_field_block(...
                    reshape(obj.sd.CDC_Smoothed_X(ind,:),obj.num_blocks(1),obj.num_blocks(2))' ,...
                    reshape(obj.sd.CDC_Smoothed_Y(ind,:),obj.num_blocks(1),obj.num_blocks(2))' ,...
                    obj.mag_thresh );
            else
                [foe_x, foe_y, ~,~] = find_foe_from_flow_field_block(...
                    reshape(obj.sd.CDC_Smoothed_X(ind,:),obj.num_blocks(1),obj.num_blocks(2))' ,...
                    reshape(obj.sd.CDC_Smoothed_Y(ind,:),obj.num_blocks(1),obj.num_blocks(2))' ,...
                    obj.mag_thresh );

            end
        end
        
        function [foe_x, foe_y] = FOEfromOF(obj,OF_x, OF_y)
                [foe_x, foe_y, ~,~] = find_foe_from_flow_field_block(...
                    reshape(OF_x,obj.num_blocks(1),obj.num_blocks(2))' ,...
                    reshape(OF_y,obj.num_blocks(1),obj.num_blocks(2))' ,...
                    obj.mag_thresh);
        end
    end
    
end

