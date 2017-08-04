function argsmap = whatsin(fname)
    
    datafile = load(fname,'cfg');
    argsmap = datafile.cfg.ToKeyValCellArray();

end