close all

% se.Frame_selector = NaiveFrameSelector(se.cfg);
% se.Frame_selector = ShortestPathFrameSelector(se.cfg);

a=3; %shakeness
b=10; %velocity
c=3; %histogram
d=5; %forwardness
e = 500; % heigher order term
mergeFOEcoeff =4;

%cfg.set('UseHigherOrder',true);

% Ta=6; 
% Tb=1; 
% Tc=2; 
% Ca=1000;
% Cb=1000;
% Cc=1000;


ShaknessTermInvalidValue=1000000;

% Tv = 4;
Tv_mean_cumulative =10; 
recalc_velocity_term=true;
%those two lines make the targer velocity become the mean of the cumulative
%OF over 'Tv_mean_cumulative' frames
 cfg.set('VelocityTarget','CumulativeMean');
 cfg.set('FastForwardSkipRatio',Tv_mean_cumulative );
            
cfg.set('ForwardnessMergeWithShaknessCoef',mergeFOEcoeff);
cfg.set('CostWeightMethod','Sum'); 
% cfg.set('VelocityManualTargetValue', Tv);
cfg.set('ShaknessTermWeight',a);
cfg.set('VelocityTermWeight',b);
cfg.set('AppearanceTermWeight',c); 
cfg.set('ForwardnessTermWeight', d);
cfg.set('HighOrderTermWeight',e);

% cfg.set('ShaknessTermBinaryThreshold',Ta);
% cfg.set('VelocityTermBinaryThreshold',Tb);
% cfg.set('AppearanceTermBinaryThreshold',Tc); 

% cfg.set('ShakenessTermClampedValue',Ca);
% cfg.set('VelocityTermClampedValue',Cb);
% cfg.set('AppearanceTermClampedValue',Cc); 

cfg.set('terminalConnectionDegree',120); 
cfg.set('ShaknessTermInvalidValue',ShaknessTermInvalidValue);

 
 
 %% adjust velocity cost (in batches)
 
startInd = cfg.get('startInd');
endInd = cfg.get('endInd');

lastSparseInd =1;
batchSize = min(cfg.get('maxBatchMemory')/cfg.get('maxTemporalDist'), endInd-startInd);
numberOfBatches = ceil((endInd-startInd)/batchSize);

OFEstimator = CumulativeLKEstimator(se.sd,se.cfg);
velocityCostEstimator = OFMagnitudeCost(se.sd,se.cfg);

if recalc_velocity_term
     fprintf('%sCalculating velocity cost...\n',log_line_prefix);

    for batch = 1:numberOfBatches

        startBatch = startInd + batchSize*(batch-1);
        endBatch = min(startBatch + batchSize-1, endInd);
        fprintf('\n\n%sStarting batch No. %d from frame %d to frame %d\n\n',log_line_prefix, batch, startBatch, endBatch);

        fprintf('%sReEstimating optical flow between pairs of frames...\n',log_line_prefix);
        [OF_X,OF_Y,~,~] = OFEstimator.estimateBatch(startBatch, endBatch);

        fprintf('%sCalculating velocity cost...\n',log_line_prefix);
        [Velocity_cost_batch] = velocityCostEstimator.calculateCostBatch(OF_X, OF_Y,startBatch, endBatch);

        se.Velocity_cost       (startBatch-startInd+1 : endBatch-startInd+1, :) = Velocity_cost_batch;

    end
end

%  shakenessCostEstimator = FOEDistanceCost(sd,cfg);
%  fprintf('%sCalculating shakness cost...\n',log_line_prefix);
%  [se.Shakeness_cost] = shakenessCostEstimator.calculateCostBatch (se.OF_X, se.OF_Y);

se.Solve();