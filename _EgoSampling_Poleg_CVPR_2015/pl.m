function pl( sd, path)
    plot(sd.CDC_Raw_X);
    hold on 
    plot(path,sd.CDC_Raw_X(path,1),'bs--')

end

