function pl1( sd, path)
    [~,block] = min(sd.CDC_Raw_X(end,:));
    plot(sd.CDC_Raw_X(:,block));
    hold on 
    plot(path,sd.CDC_Raw_X(path,block),'bs--')

end

