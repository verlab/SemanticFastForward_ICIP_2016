function im= im( cfg,num)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    im = imread(sprintf(cfg.get('baseDumpFrameFileName'),num));
    imshow(im)
end

