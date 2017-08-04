function qu(f_x,f_y)
    f_x = reshape(f_x,10,5)';
    f_y = reshape(f_y,10,5)';
    quiver ((.5:1:size(f_x,2)-.5)-size(f_x,2)/2,(fliplr(.5:1:size(f_x,1)-.5))-size(f_x,1)/2,f_x,-f_y,'r','LineWidth',3);
    
end