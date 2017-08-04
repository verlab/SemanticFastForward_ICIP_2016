function str = id2str (cfg,id)

    str = sprintf('%d->%d',ceil((id-1)/cfg.get('maxTemporalDist')),mod((id+1),cfg.get('maxTemporalDist'))+ceil((id-1)/cfg.get('maxTemporalDist'))+1);

end