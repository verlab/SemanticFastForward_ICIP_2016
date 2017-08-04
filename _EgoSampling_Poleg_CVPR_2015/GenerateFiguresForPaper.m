function GenerateFiguresForPaper(varargin)

        global GEN_FIG_FONTSIZE;
        GEN_FIG_FONTSIZE = 32;
        avail_figs = containers.Map();

        data_sources = containers.Map();


        
        avail_figs('overview_figs') = @gen_overview_figs;
        data_sources('overview_figs') = struct('observer_dir','D:\samples\huji\egocorrM2M\Exp-12\Yair-Test-1',...
                                               'observer_data_file', 'traj.csv',...
                                               'observer_lk_file','D:\samples\huji\egocorrM2M\Exp-12\FPV-Yair.csv',...
                                               'head_traj',1,...
                                               'torso_trajs',9:34,...
                                               'observer_first_frame_face_rect',[10 10 200 200],....
                                               'subject_offset',5,...
                                               'subject_frames_dir','D:\samples\huji\egocorrM2M\Exp-12\FPV-Chetan-Frames',...
                                               'subject_example_frame',257,...
                                               'subject_example_frame_face_rect',[10 10 200 200],....
                                               'subject_lk_csv','D:\samples\huji\egocorrM2M\Exp-12\FPV-Chetan.csv',...
                                               'subject_single_lk_traj',28,...
                                               'match_range',-100:1:100,...
                                               'skipstart',1,...
                                               'skipend',1,...
                                               'special_config',{{'SUBJECT_FLIP_Y_SIGN',0}});                                            

        

                                           
        avail_figs('Exp-Standing1') = @gen_exp_result;
        data_sources('Exp-Standing1') = struct('exp_name','standing1',...
                                               'observer_dir','D:\samples\huji\egocorrM2M\Exp-12\Yair-Test-1',...
                                               'observer_data_file', 'traj.csv',...
                                               'observer_lk_file','D:\samples\huji\egocorrM2M\Exp-12\FPV-Yair.csv',...
                                               'head_traj',1,...
                                               'torso_trajs',9:34,...
                                               'subject_offset',5,...
                                               'subject_lk_csv','D:\samples\huji\egocorrM2M\Exp-12\FPV-Chetan.csv',...
                                               'subject_frames_dir','D:\samples\huji\egocorrM2M\Exp-12\FPV-Chetan-Frames',...
                                               'match_range',-100:1:100,...
                                               'skipstart',1,...
                                               'skipend',1,...
                                               'total_score_only',0,...
                                               'output_signal',0,...
                                               'output_visualization_video',1,...
                                               'visualization_video_title','''Standing'' Sequence',...
                                               'visualization_video_blurface',1,...
                                               'visualization_video_fps',60,...
                                               'special_config',{{'SUBJECT_FLIP_Y_SIGN',0}});                                           
        
        avail_figs('Exp-Workstation1') = @gen_exp_result;
        data_sources('Exp-Workstation1') = struct('exp_name','workstation1',...
                                               'observer_dir','D:\samples\huji\egocorrM2M\Exp-14\Yair-Test-1',...
                                               'observer_data_file', 'traj.csv',...
                                               'observer_lk_file','D:\samples\huji\egocorrM2M\Exp-14\FPV-Yair.csv',...
                                               'head_traj',1,...
                                               'torso_trajs',13:38,...
                                               'subject_offset',-45,...
                                               'subject_lk_csv','D:\samples\huji\egocorrM2M\Exp-14\FPV-Chetan.csv',...
                                               'subject_frames_dir','D:\samples\huji\egocorrM2M\Exp-14\FPV-Chetan-Frames',...
                                               'match_range',-100:1:100,...
                                               'skipstart',100,...
                                               'skipend',150,...
                                               'total_score_only',0,...
                                               'output_signal',0,...
                                               'output_visualization_video',1,...
                                               'visualization_video_title','''Workstation'' Sequence',...
                                               'visualization_video_blurface',0,...
                                               'visualization_video_fps',60,...
                                               'special_config',{{'SUBJECT_FLIP_Y_SIGN',1}});                                             

        avail_figs('Exp-Whiteboard1') = @gen_exp_result;
        data_sources('Exp-Whiteboard1') = struct('exp_name','whiteboard1',...
                                               'observer_dir','D:\samples\huji\egocorrM2M\Exp-15\Yair-Test-1',...
                                               'observer_data_file', 'traj.csv',...
                                               'observer_lk_file','D:\samples\huji\egocorrM2M\Exp-15\FPV-Yair.csv',...
                                               'head_traj',8,...
                                               'torso_trajs',11:72,...
                                               'subject_offset',344,...
                                               'subject_lk_csv','D:\samples\huji\egocorrM2M\Exp-15\FPV-Chetan.csv',...
                                               'subject_frames_dir','D:\samples\huji\egocorrM2M\Exp-15\FPV-Chetan-Frames',...
                                               'match_range',-100:1:100,...
                                               'skipstart',500,...
                                               'skipend',500,...
                                               'total_score_only',0,...
                                               'output_signal',0,...
                                               'output_visualization_video',1,...
                                               'visualization_video_title','''Whiteboard'' Sequence',...
                                               'visualization_video_blurface',1,...
                                               'visualization_video_fps',60,...                                               
                                               'special_config',{{'SUBJECT_FLIP_Y_SIGN',0}});    
                                           
        avail_figs('Exp-WalkingWithBack1') = @gen_exp_result;
        data_sources('Exp-WalkingWithBack1') = struct('exp_name','walkwithback1',...
                                               'observer_dir','D:\samples\huji\egocorrM2M\Exp-16\Yair-Test-1',...
                                               'observer_data_file', 'traj.csv',...
                                               'observer_lk_file','D:\samples\huji\egocorrM2M\Exp-16\FPV-Yair.csv',...
                                               'head_traj',1,...
                                               'torso_trajs',13:77,...
                                               'subject_offset',0,...
                                               'subject_lk_csv','D:\samples\huji\egocorrM2M\Exp-16\FPV-Chetan.csv',...
                                               'subject_frames_dir','D:\samples\huji\egocorrM2M\Exp-16\FPV-Chetan-Frames',...
                                               'match_range',-300:1:300,...
                                               'skipstart',1200,...
                                               'skipend',1200,...
                                               'total_score_only',0,...
                                               'output_signal',0,...
                                               'output_visualization_video',1,...
                                               'visualization_video_title','''WalkingWithBack'' Sequence',...
                                               'visualization_video_blurface',0,...
                                               'visualization_video_fps',60,...                                               
                                               'special_config',{{'SUBJECT_FLIP_Y_SIGN',1}}); 

        avail_figs('Exp-Crossover1') = @gen_exp_result;
        data_sources('Exp-Crossover1') = struct('exp_name','crossover1',...
                                               'observer_dir','D:\samples\huji\egocorrM2M\Exp-17\Yair-Test-1',...
                                               'observer_data_file', 'traj.csv',...
                                               'observer_lk_file','D:\samples\huji\egocorrM2M\Exp-17\FPV-Yair.csv',...
                                               'head_traj',3,...
                                               'torso_trajs',8:23,...
                                               'subject_offset',-4,...
                                               'subject_lk_csv','D:\samples\huji\egocorrM2M\Exp-17\FPV-Chetan.csv',...
                                               'subject_frames_dir','D:\samples\huji\egocorrM2M\Exp-17\FPV-Chetan-Frames',...
                                               'match_range',-100:1:100,...
                                               'skipstart',500,...
                                               'skipend',100,...
                                               'total_score_only',0,...
                                               'output_signal',0,...
                                               'output_visualization_video',1,...
                                               'visualization_video_title','''Crossover'' Sequence',...
                                               'visualization_video_blurface',1,...
                                               'visualization_video_fps',60,...                                               
                                               'special_config',{{'SUBJECT_FLIP_Y_SIGN',0}});
                                           
                                           
        avail_figs('Exp-Missmatch1') = @gen_exp_result;
        data_sources('Exp-Missmatch1') = struct('exp_name','missmatch1',...
                                               'observer_dir','D:\samples\huji\egocorrM2M\Exp-15\Yair-Test-1',...
                                               'observer_data_file', 'traj.csv',...
                                               'observer_lk_file','D:\samples\huji\egocorrM2M\Exp-15\FPV-Yair.csv',...
                                               'head_traj',8,...
                                               'torso_trajs',11:72,...
                                               'subject_offset',344,...
                                               'subject_lk_csv','D:\samples\huji\egocorrM2M\Exp-12\FPV-Chetan.csv',...
                                               'match_range',-200:1:200,...
                                               'skipstart',300,...
                                               'skipend',1000,...
                                               'total_score_only',0,...
                                               'output_signal',0,...
                                               'special_config',{{'SUBJECT_FLIP_Y_SIGN',0}});   
                                           
        avail_figs('FPProbability-Whiteboard') = @gen_exp_fp_probability;
        data_sources('FPProbability-Whiteboard') = struct('exp_name','whiteboard1',...,
                                                         'experiment_data_file','ObserverUniquenessTest_Whiteboard.mat',...
                                                         'special_config',{{}});
                    
                                                     
        avail_figs('FPProbability-Workstation') = @gen_exp_fp_probability;
        data_sources('FPProbability-Workstation') = struct('exp_name','workstation1',...,
                                                         'experiment_data_file','ObserverUniquenessTest_Workstation.mat',...
                                                         'special_config',{{}});
                                                     
                                                     
        avail_figs('FPProbability-Standing') = @gen_exp_fp_probability;
        data_sources('FPProbability-Standing') = struct('exp_name','standing1',...,
                                                         'experiment_data_file','ObserverUniquenessTest_Standing.mat',...
                                                         'special_config',{{}}); 
                                                     
        
        avail_figs('FPProbability-Combined') = @gen_exp_fp_probability_combined;
        data_sources('FPProbability-Combined') = struct('exp_name','combined',...,
                                                         'experiment_data_files',{{'ObserverUniquenessTest_Standing.mat'...
                                                                                  'ObserverUniquenessTest_Workstation.mat',...
                                                                                  'ObserverUniquenessTest_Whiteboard.mat'}},...
                                                         'names',{{'Standing','Workstation','Whiteboard'}},...
                                                         'special_config',{{}}); 
                          
        avail_figs('FPS-Invariancy') = @gen_fps_invariancy;
        data_sources('FPS-Invariancy') = struct([]);
        
        
        avail_figs('Signature-Variance-FPCount') = @gen_sigvariance_fpcount;
        data_sources('Signature-Variance-FPCount') = struct( 'experiment_data_file','SubjectIntrinsicUniquenessTest_signature_len_100.mat'); 
                                                     
        % Which figures to produce?
        if numel(varargin)==0
            figs = avail_figs.keys;
        else
            figs = varargin;
        end
        
        for i=1:numel(figs)
            figname=figs{i};
            func = avail_figs(figname);
            func(data_sources(figname) );
            close all;
        end
        
        clear GEN_FIG_FONTSIZE;

end

function save_fig(h,fname)
    output_dir='figures/';
    print(h,[output_dir 'fig_' fname '.png'],'-dpng');
    %print(h,[output_dir 'fig_' fname '.emf'],'-dmeta');
    %print(h,[output_dir 'fig_' fname '.eps'],'-depsc');
    print(h,[output_dir 'fig_' fname '.pdf'],'-dpdf');
end

function gen_exp_result(ds)
    % Create a config file
    ExpCfg = {};
                    
    cfg = Config(ExpCfg);
    
    for i=1:2:numel(ds.special_config)
        cfg.argsmap(ds.special_config{i}) = ds.special_config{i+1};
    end

    observer = ObserverData(ds.observer_dir,...
                            ds.observer_data_file,[ds.head_traj ds.torso_trajs],...
                            ds.observer_lk_file,...
                            ds.skipstart,ds.skipend,cfg);                        

    subject = SubjectData([],ds.subject_lk_csv,cfg);    

    frame_range = observer.mStartFrameNum:(observer.mStartFrameNum+observer.mNumFrames-1);
%     w=800;
%     h=w/(1920/1080);
%     matcher = MatchSignals(subject, observer, ds.subject_offset, cfg);
%  
%     [all_score_x,all_score_y,normalized_total_score,search_range] = matcher.Match(ds.match_range,0,0);
%     close;
%     
%     % Plot Total score
%     hx=figure(); 
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperUnits', 'points ');
%     set(gcf, 'PaperSize', [w,h]);
%     set(gcf, 'PaperPosition', [0,0,w,h]);
%     set(gcf,'Units','points');
%     set(gcf,'Position',[100,100,w,h]);
%     plot(ds.match_range,normalized_total_score,'LineWidth',2);
%     hold on;    
%     ylim([-2.2 2.2]);
%     %set(gca,'Position',[0.08 0.1 0.89 0.8]);
%     grid on;  set(gca,'LineWidth',2);
%     
%     % Fix font sizes.
%     global GEN_FIG_FONTSIZE; set(gca,'FontSize',GEN_FIG_FONTSIZE);
%     set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
% 
%     
%     title('');
%     xlim([search_range(1),search_range(end)]);
%     xlabel('Offset From Ground Truth (Frames)');
%     ylabel('Score');
%     save_fig(hx,['exp_' ds.exp_name '_score_total']);    
%     
%     % Total score wide version 
%     set(gcf, 'PaperSize', [2*w,h]);
%     set(gcf, 'PaperPosition', [0,0,2*w,h]);
%     save_fig(hx,['exp_' ds.exp_name '_score_total_wide']);  
%     
%     
%     if ds.total_score_only ~= 1
%         % Plot X and Y scores as well..
%         
%         % Plot X score
%         hx=figure(); 
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperUnits', 'points ');
%         set(gcf, 'PaperSize', [w,h]);
%         set(gcf, 'PaperPosition', [0,0,w,h]);
%         set(gcf,'Units','points');
%         set(gcf,'Position',[100,100,w,h]);
%         plot(ds.match_range,all_score_x,'LineWidth',2);
%         hold on;    
%         ylim([-1.1 1.1]);
%         %set(gca,'Position',[0.08 0.1 0.89 0.8]);
%         grid on;  set(gca,'LineWidth',2);
% 
%         % Fix font sizes.
%         set(gca,'FontSize',GEN_FIG_FONTSIZE);
% 
%         title('');
%         xlim([ds.match_range(1),ds.match_range(end)]);
%         xlabel('Offset From Ground Truth (Frames)');
%         ylabel('X Score');
%         save_fig(hx,['exp_' ds.exp_name '_score_x']);
%         
%         % Plot Y score
%         hx=figure(); 
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperUnits', 'points ');
%         set(gcf, 'PaperSize', [w,h]);
%         set(gcf, 'PaperPosition', [0,0,w,h]);
%         set(gcf,'Units','points');
%         set(gcf,'Position',[100,100,w,h]);
%         plot(ds.match_range,all_score_y,'LineWidth',2);
%         hold on;    
%         ylim([-1.1 1.1]);
%         %set(gca,'Position',[0.18 0.18 0.80 0.75]);
%         grid on;  set(gca,'LineWidth',2);
% 
%         % Fix font sizes.
%         set(gca,'FontSize',GEN_FIG_FONTSIZE);
% 
%         title('');
%         xlim([ds.match_range(1),ds.match_range(end)]);
%         xlabel('Offset From Ground Truth (Frames)');
%         ylabel('Y Score');
%         save_fig(hx,['exp_' ds.exp_name '_score_y']);
%         
%     end
%     
%     if ds.output_signal==1
%         [subject_data_x, subject_data_y] = subject.GetDataForMatching();
%         [observer_data_x, observer_data_y] = observer.GetDataForMatching();
% 
%         % Plot X head motion signals
%         hx=figure(); 
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperUnits', 'points ');
%         set(gcf, 'PaperSize', [w,h]);
%         set(gcf, 'PaperPosition', [0,0,w,h]);
%         set(gcf,'Units','points');
%         set(gcf,'Position',[100,100,w,h]);
%         plot(frame_range,[matnormalize(observer_data_x);matnormalize(subject_data_x(:,frame_range))]','LineWidth',2);
%         legend('Observer''s Signature','Subject''s Signature','Location','SouthWest');
%         hold on;    
%         %set(gca,'Position',[0.18 0.18 0.80 0.75]);
%         grid on;  set(gca,'LineWidth',2);
% 
%         % Fix font sizes.
%         set(gca,'FontSize',GEN_FIG_FONTSIZE);
% 
%         title('');
%         xlim([frame_range(1),frame_range(end)]);
%         xlabel('Frame #');
%         ylabel('Signature Value (X)');
%         save_fig(hx,['exp_' ds.exp_name '_signatures_x']);
%         
%         
%         % Plot Y head motion signals
%         hx=figure(); 
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperUnits', 'points ');
%         set(gcf, 'PaperSize', [w,h]);
%         set(gcf, 'PaperPosition', [0,0,w,h]);
%         set(gcf,'Units','points');
%         set(gcf,'Position',[100,100,w,h]);
%         plot(frame_range,[matnormalize(observer_data_y);matnormalize(subject_data_y(:,frame_range))]','LineWidth',2);
%         legend('Observer''s Signature','Subject''s Signature','Location','SouthWest');
%         hold on;    
%         %set(gca,'Position',[0.18 0.18 0.80 0.75]);
%         grid on;  set(gca,'LineWidth',2);
% 
%         % Fix font sizes.
%         set(gca,'FontSize',GEN_FIG_FONTSIZE);
% 
%         title('');
%         xlim([frame_range(1),frame_range(end)]);
%         xlabel('Frame #');
%         ylabel('Signature Value (Y)');
%         save_fig(hx,['exp_' ds.exp_name '_signatures_y']);
%         
%         
%     end
%     
    
    if isfield(ds,'output_visualization_video') && ds.output_visualization_video==1
        
        h = VidSequenceDisplay;
        
        handles = guidata(h);
        
        set(handles.txtTitle,'String',ds.visualization_video_title);
        
        [subject_data_x, subject_data_y] = subject.GetDataForMatching();
        [observer_data_x, observer_data_y] = observer.GetDataForMatching();

        % Plot X head motion signals
        plot(handles.axXSig,frame_range,[matnormalize(observer_data_x);matnormalize(subject_data_x(:,frame_range))]','LineWidth',2);
        cur_x_ylim = ylim(handles.axXSig);
        ylim(handles.axXSig,'manual');
        ylim(handles.axXSig,cur_x_ylim);
        set(handles.axXSig, 'XTickLabel', [], 'YTickLabel', []);
        %legend(handles.axXSig,'Observer','Subject','Location','SouthWest');
        % Fix font sizes.
        set(handles.axXSig,'FontSize',12);
        
        % Plot X head motion signals
        plot(handles.axYSig,frame_range,[matnormalize(observer_data_y);matnormalize(subject_data_y(:,frame_range))]','LineWidth',2);
        cur_y_ylim = ylim(handles.axYSig);
        ylim(handles.axYSig,'manual');
        ylim(handles.axYSig,cur_y_ylim);
        set(handles.axYSig, 'XTickLabel', [],'YTickLabel', []);
        set(handles.axYSig,'FontSize',12);
        %legend('Observer','Subject');
        
        WSIZE = 100;
    
        faceDetector = vision.CascadeObjectDetector('FrontalFaceLBP');
        
        writerObj = VideoWriter(['figures/exp_' ds.exp_name '.avi']); % Name it.
        writerObj.FrameRate = ds.visualization_video_fps; % How many frames per second.
        open(writerObj); 

        
        
%         if (ds.visualization_video_blurface==1)
%             Iobs = imread(fullfile(ds.observer_dir,sprintf('frame_%05d.png',frame_range(1))));
%             [obs_pointTracker, obs_face_points,obs_orig_bbox] = init_tracker(Iobs);
%             
%             
%             Isub = imread(fullfile(ds.subject_frames_dir,sprintf('frame_%05d.png',frame_range(1))));
%             [sub_pointTracker, sub_face_points,sub_orig_bbox] = init_tracker(Isub);
%         end
        
        obs_orig_bbox=[];
        sub_orig_bbox=[];
        obs_bbox=[];
        sub_bbox=[];
        obs_tracker_init_frames_ago = inf;
        sub_tracker_init_frames_ago = inf;
        for i=1:numel(frame_range)
            display(sprintf('%sDumping frame %d/%d..',log_line_prefix,i,numel(frame_range)));
            
            
            cur_observer_frame = frame_range(i);
            cur_subject_frame = cur_observer_frame + ds.subject_offset;
            
            xlim(handles.axXSig,'manual');
            xlim(handles.axXSig,[cur_observer_frame-WSIZE cur_observer_frame]);
            
            xlim(handles.axYSig,'manual');
            xlim(handles.axYSig,[cur_observer_frame-WSIZE cur_observer_frame]);
            legend(handles.axYSig,'Observer''s Signature','Subject''s Signature','Location','SouthWest');
            Iobs = imread(fullfile(ds.observer_dir,sprintf('frame_%05d.png',cur_observer_frame)));
            Iobs = imresize(Iobs,0.5);
            Isub = imread(fullfile(ds.subject_frames_dir,sprintf('frame_%05d.png',cur_subject_frame)));
            Isub = imresize(Isub,0.5);
            if (ds.visualization_video_blurface==1)
                
                if (numel(obs_bbox)==0 || ( (obs_bbox(3)*obs_bbox(4))<0.5*(obs_orig_bbox(3)*obs_orig_bbox(4))))
                    display(sprintf('%sLost track on observer in frame %d, re-initializing..',log_line_prefix,i));
                    if (obs_tracker_init_frames_ago > 5)
                        [obs_pointTracker, obs_face_points,obs_orig_bbox] = init_tracker(Iobs);
                        obs_tracker_init_frames_ago = 0;
                    else
                        obs_tracker_init_frames_ago = obs_tracker_init_frames_ago+1;
                    end
                end
                
                if (numel(sub_bbox)==0 || ( (sub_bbox(3)*sub_bbox(4))<0.5*(sub_orig_bbox(3)*sub_orig_bbox(4))))
                    display(sprintf('%sLost track on subject in frame %d, re-initializing..',log_line_prefix,i));                    
                    if (sub_tracker_init_frames_ago > 5)
                        [sub_pointTracker, sub_face_points,sub_orig_bbox] = init_tracker(Isub);
                        sub_tracker_init_frames_ago = 0;
                    else
                        sub_tracker_init_frames_ago = sub_tracker_init_frames_ago+1;
                    end
                end
                
                [Iobs_smeared, obs_bbox, obs_face_points, obs_pointTracker] = smear_faces(obs_pointTracker, Iobs, obs_face_points,0.95);
                [Isub_smeared, sub_bbox, sub_face_points, sub_pointTracker] = smear_faces(sub_pointTracker, Isub, sub_face_points,0.95);
                
                Isub = Isub_smeared;
                Iobs = Iobs_smeared;
            end
       
            imshow(imresize(Iobs,0.5),'Parent',handles.axObserverImg);
            imshow(imresize(Isub,0.5),'Parent',handles.axSubjectImg); 

            frame = getframe(h); % 'gcf' can handle if you zoom in to take a movie.
            writeVideo(writerObj, frame);
            
            drawnow;
            
            
        end

        close(writerObj);
        
        
    end
end

function [Iout, face_bbox, foundPts, tracker] = smear_faces(tracker, I, pts,opacity)

    if size(pts,1)<2
        foundPts=[];
        face_bbox=[];
        Iout = I;
        return;
    end


    [pts, isFound] = step(tracker, I);
    foundPts = pts(isFound, :);
    
    if sum(isFound)<2
        face_bbox=[];
        Iout = I;
        return;
    end
    
    % Insert a bounding box around the object being tracked
    margin=uint32(15);
    top = min(foundPts(:,2));
    left = min(foundPts(:,1));
    bot = max(foundPts(:,2));
    right = max(foundPts(:,1));
    face_bbox = uint32([left top (right-left) (bot-top)]);
    Iout = insertShape(I, 'FilledRectangle', face_bbox + [-margin -margin margin margin],'Opacity',opacity);
            
end

function [tracker pts bbox] = init_tracker(I)
    tracker = vision.PointTracker('MaxBidirectionalError', 2);    
    f=figure;
    [~, bbox] = imcrop(I);
    if ~ishandle(f)
        pts = [];
        bbox = [];
        return;
    end
    close(f);
    
    pts = detectMinEigenFeatures(rgb2gray(I), 'ROI', uint32(bbox));
    
    pts = pts.Location;
    initialize(tracker, pts, I);

    top = min(pts(:,2));
    left = min(pts(:,1));
    bot = max(pts(:,2));
    right = max(pts(:,1));
    bbox = uint32([left top (right-left) (bot-top)]);
end

function gen_overview_figs(ds)
    % Create a config file
    ExpCfg = {};
                    
    cfg = Config(ExpCfg);
    
    for i=1:2:numel(ds.special_config)
        cfg.argsmap(ds.special_config{i}) = ds.special_config{i+1};
    end

    observer = ObserverData(ds.observer_dir,...
                            ds.observer_data_file,[ds.head_traj ds.torso_trajs],...
                            ds.observer_lk_file,...
                            ds.skipstart,ds.skipend,cfg);                        

    subject = SubjectData(ds.subject_lk_csv,ds.subject_lk_csv,cfg);    

    
    frame_range = observer.mStartFrameNum:(observer.mStartFrameNum+observer.mNumFrames-1);
    w=800;
    h=w/(1920/1080);
    
    
    
    % Extract frame from subject's point of view
    Is = imread(fullfile(ds.subject_frames_dir,sprintf('frame_%05d.png',ds.subject_example_frame)));
    hgamma = vision.GammaCorrector(1.7,'Correction','Gamma'); 
    Is = step(hgamma, Is);
    % Create a cascade detector object.
    faceDetector = vision.CascadeObjectDetector('EyePairSmall');
    % Read a video frame and run the detector.
    face_bbox = step(faceDetector, Is);
    face_bbox(1:2) = face_bbox(1:2)-15;
    face_bbox(3:4) = face_bbox(3:4) + 30;

    % Draw the returned bounding box around the detected face.
    Is = insertShape(Is,'FilledRectangle',face_bbox,'Opacity',1);
    
    hs=figure; 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);   
    
    imshow(Is); hold on
    %set(gca,'Position',[0 0 1 1]);
    save_fig(hs,['overview_subject_frame']);
      
    
    
    % Plot Raw LK X - single traj
    hx=figure(); 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);
    
    plot(frame_range,subject.mTrajRaw.LK_X(ds.subject_single_lk_traj,frame_range)','LineWidth',2);
    lk_ylim=ylim;
    hold on;    
    xlim([frame_range(1),frame_range(end)]);
    %set(gca,'Position',[0.18 0.18 0.80 0.75]);
    grid on;  set(gca,'LineWidth',2);
    
    % Fix font sizes.
    global GEN_FIG_FONTSIZE; 
    set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    set(0, 'defaulttextfontsize', GEN_FIG_FONTSIZE);
    
    title('');
    xlabel('Frame #');
    ylabel('X Displacement');
    save_fig(hx,'overview_lk_raw_single');
    
    
    % Plot Raw LK X 
    hx=figure(); 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);

    plot(frame_range,subject.mTrajRaw.LK_X(:,frame_range)');
    ylim(lk_ylim);
    xlim([frame_range(1),frame_range(end)]);
    hold on;    
    %set(gca,'Position',[0.18 0.18 0.80 0.75]);
    grid on;  set(gca,'LineWidth',2);
    
    % Fix font sizes.
    set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    set(0, 'defaulttextfontsize', GEN_FIG_FONTSIZE);
    
    title('');
    xlabel('Frame #');
    ylabel('X Displacement');
    save_fig(hx,'overview_lk_raw');

    
    
    % Plot Avg LK X 
    hax=figure(); 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);

    [subject_data_x, ~] = subject.GetDataForMatching();
    
    plot(frame_range,subject_data_x(:,frame_range)','b','LineWidth',2);
    xlim([frame_range(1),frame_range(end)]);
    hold on;    
    %set(gca,'Position',[0.18 0.18 0.80 0.75]);
    ylim(lk_ylim);
    grid on;  set(gca,'LineWidth',2);
    title('');
    xlabel('Frame #');
    ylabel('Avg Displacement');
    save_fig(hax,'overview_lk_avg');
    
    
    
    
    % Feature vector for X head pose
    
    hf = figure;
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);    
    %set(gca,'Position',[0.18 0.18 0.80 0.75]);
    plot(frame_range,observer.mFeatTrajX(1,:),'LineWidth',2);
    grid on;  set(gca,'LineWidth',2);
    title('');
    xlim([frame_range(1),frame_range(end)]);
    xlabel('Frame #');
    ylabel('Feature Position (X)');

    % Fix font sizes.
    set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    set(0, 'defaulttextfontsize', GEN_FIG_FONTSIZE);
    
    
    save_fig(hf,['overview_head_abs_x_position']);    
    
    % Derivative of abs. position
    hd = figure;
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);   
    %set(gca,'Position',[0.18 0.18 0.80 0.75]);
    plot(frame_range,imfilter(observer.mFeatTrajX(1,:),[-1 1],'same','replicate'),'LineWidth',2);
    grid on;  set(gca,'LineWidth',2);
    % Fix font sizes.
    set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    set(0, 'defaulttextfontsize', GEN_FIG_FONTSIZE);
    
    title('');
    xlim([frame_range(1),frame_range(end)]);
    xlabel('Frame #');
    ylabel('Feature Displacement (X)');
    save_fig(hd,['overview_head_displacement_x']);
    


    % Paint source frame, head and torso.
    I1 = imread(observer.mInputFrameFiles{1});
    hgamma = vision.GammaCorrector(2,'Correction','Gamma'); 
    I1=step(hgamma,I1);
    
    % Create a cascade detector object.
    faceDetector = vision.CascadeObjectDetector('EyePairSmall');
    % Read a video frame and run the detector.
    face_bbox = step(faceDetector, I1);
    face_bbox(1:2) = face_bbox(1:2)-15;
    face_bbox(3:4) = face_bbox(3:4) + 30;

    % Draw the returned bounding box around the detected face.
    I1 = insertShape(I1,'FilledRectangle',face_bbox,'Opacity',1);
    
    P1_head = [observer.mFeatTrajX(1,1),observer.mFeatTrajY(1,1)];
    P1_torso = [observer.mFeatTrajX(2:end,1),observer.mFeatTrajY(2:end,1)];
        
    hx=figure; 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);   
    
    imshow(I1); hold on;
    
    scatter(observer.mFeatTrajX(1,2:end),observer.mFeatTrajY(1,2:end),'o','r');
    scatter(P1_head(1),P1_head(2),30,'o','b','Linewidth',2);
    %scatter(P1_torso(:,1),P1_torso(:,2),'+','b','LineWidth',1);
    %set(gca,'Position',[0 0 1 1]);
    
    save_fig(hx,['overview_ref_frame']);

    
    
    hw=figure; 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);   
    
    % Showing the ref frame
    imshow(I1); hold on
    
    scatter(P1_head(1),P1_head(2),30,'o','b','Linewidth',2);
    scatter(P1_torso(:,1),P1_torso(:,2),'+','b','LineWidth',1);
   
    pts_head = zeros(2:numel(frame_range),2);
    pts_torso = zeros(0,2);
    for i=2:numel(frame_range)
        P2_head = [observer.mFeatTrajX(1,i),observer.mFeatTrajY(1,i)];
        P2_torso = [observer.mFeatTrajX(2:end,i),observer.mFeatTrajY(2:end,i)];

        tform = inv(reshape(observer.mTforms(:,i),3,3));
        %P1_head_w = tform*[P1_head 1]'; P1_head_w = [P1_head_w(1)/P1_head_w(3) P1_head_w(2)/P1_head_w(3)];
        %P1_torso_w = tform*[P1_torso ones(size(P1_torso,1),1)]'; P1_torso_w = [P1_torso_w(1,:)./P1_torso_w(3,:); P1_torso_w(2,:)./P1_torso_w(3,:)]';

        P2_head_w = tform*[P2_head 1]'; P2_head_w = [P2_head_w(1)/P2_head_w(3) P2_head_w(2)/P2_head_w(3)];
        P2_torso_w = tform*[P2_torso ones(size(P2_torso,1),1)]'; P2_torso_w = [P2_torso_w(1,:)./P2_torso_w(3,:); P2_torso_w(2,:)./P2_torso_w(3,:)]';

        pts_head(i,:) = P2_head_w;
        pts_torso = [pts_torso ; P2_torso_w];
        
    end
    
    %set(gca,'Position',[0 0 1 1]);

    scatter(pts_head(:,1),pts_head(:,2),30,'*','r','Linewidth',2);
    scatter(pts_torso(:,1),pts_torso(:,2),'s','r','LineWidth',1);

    scatter(P1_head(1),P1_head(2),30,'o','b','Linewidth',2);
    scatter(P1_torso(:,1),P1_torso(:,2),'+','b','LineWidth',1);
   
    save_fig(hw,['overview_warped_frame']);
    

    hs = figure;
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);   
    [data_x data_y] = observer.GetDataForMatching();
    plot(frame_range,data_x,'LineWidth',2);
    grid on;  set(gca,'LineWidth',2);
    % Fix font sizes.
    set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    set(0, 'defaulttextfontsize', GEN_FIG_FONTSIZE);
    
    title('');
    xlim([frame_range(1),frame_range(end)]);
    xlabel('Frame #');
    ylabel('Head Activity (X)');
    
    %set(gca,'Position',[0.18 0.18 0.80 0.75]);
    
    save_fig(hs,['overview_head_activity_x']);
    
    
    
    [subject_data_x, subject_data_y] = subject.GetDataForMatching();
    [observer_data_x, observer_data_y] = observer.GetDataForMatching();

    % Plot X head motion signals
    hx=figure(); 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);
    plot(frame_range,[matnormalize(observer_data_x);matnormalize(subject_data_x(:,frame_range))]','LineWidth',2);
    grid on;  set(gca,'LineWidth',2);
    % Fix font sizes.
    set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    set(0, 'defaulttextfontsize', GEN_FIG_FONTSIZE);
    hold on;    
    
    xlim([frame_range(1),frame_range(end)]);
    xlabel('Frame #');
    ylabel('Head Activity (X)');    
    legend('Observer''s Signature','Subject''s Signature','Location','SouthWest');
    %set(gca,'Position',[0.18 0.18 0.80 0.75]);
    
    
    save_fig(hx,['overview_head_activity_correlation_x']);
end


function gen_fps_invariancy(ds)

    w=800;
    h=w/(1920/1080);
    
    trajs = [8 11:72];
    match_range = -200:1:200;

    %% 60 FPS Data
    ratio = 1;
    ExpCfg = {'OBSERVER_DOWNSAMPLING_FACTOR',ratio; 'SUBJECT_DATA_RESAMPLE_FACTOR_PQ',[1 ratio]};
    cfg = Config(ExpCfg);
    subject_offset = 344; %floor(344/4);
    skip_start=floor(500/ratio);
    skip_end=floor(500/ratio);
    observer = ObserverData('D:\samples\huji\egocorrM2M\Exp-15\Yair-Test-1','traj.csv',trajs,[],skip_start,skip_end,cfg);                        
    subject = SubjectData([],'D:\samples\huji\egocorrM2M\Exp-15\FPV-Chetan.csv',cfg);   
    matcher = MatchSignals(subject, observer, subject_offset, cfg);
    [all_score_x,all_score_y,normalized_total_score_60fps,search_range] = matcher.Match(match_range,0,0);
    close;

    %% 30 FPS Data
    ratio = 2;
    ExpCfg = {'OBSERVER_DOWNSAMPLING_FACTOR',ratio; 'SUBJECT_DATA_RESAMPLE_FACTOR_PQ',[1 ratio]};
    cfg = Config(ExpCfg);
    subject_offset = 344/2+126;
    skip_start=floor(500/ratio);
    skip_end=floor(500/ratio);
    observer = ObserverData('D:\samples\huji\egocorrM2M\Exp-15\Yair-Test-1','traj.csv',trajs,[],skip_start,skip_end,cfg);                        
    subject = SubjectData([],'D:\samples\huji\egocorrM2M\Exp-15\FPV-Chetan.csv',cfg);   
    matcher = MatchSignals(subject, observer, subject_offset, cfg);
    [all_score_x,all_score_y,normalized_total_score_30fps,search_range] = matcher.Match(match_range,0,0);
    close;
    
    %% 15 FPS Data
    ratio = 4;
    ExpCfg = {'OBSERVER_DOWNSAMPLING_FACTOR',ratio; 'SUBJECT_DATA_RESAMPLE_FACTOR_PQ',[1 ratio]};    
    cfg = Config(ExpCfg);
    subject_offset = 344/2+9; 
    skip_start=floor(500/ratio);
    skip_end=floor(500/ratio);
    observer = ObserverData('D:\samples\huji\egocorrM2M\Exp-15\Yair-Test-1','traj.csv',trajs,[],skip_start,skip_end,cfg);                        
    subject = SubjectData([],'D:\samples\huji\egocorrM2M\Exp-15\FPV-Chetan.csv',cfg);   
    matcher = MatchSignals(subject, observer, subject_offset, cfg);
    [all_score_x,all_score_y,normalized_total_score_15fps,search_range] = matcher.Match(match_range,0,0);
    close;
    
    %% 5 FPS Data
    ratio = 12;
    ExpCfg = {'OBSERVER_DOWNSAMPLING_FACTOR',ratio; 'SUBJECT_DATA_RESAMPLE_FACTOR_PQ',[1 ratio]};    
    cfg = Config(ExpCfg);
    subject_offset = 344/2-142+38;
    skip_start=floor(500/ratio);
    skip_end=floor(500/ratio);
    observer = ObserverData('D:\samples\huji\egocorrM2M\Exp-15\Yair-Test-1','traj.csv',trajs,[],skip_start,skip_end,cfg);                        
    subject = SubjectData([],'D:\samples\huji\egocorrM2M\Exp-15\FPV-Chetan.csv',cfg);   
    matcher = MatchSignals(subject, observer, subject_offset, cfg);
    [all_score_x,all_score_y,normalized_total_score_5fps,search_range] = matcher.Match(match_range,0,0);
    %close;
    
    %%
    % Remove 0 vals
    normalized_total_score_60fps(normalized_total_score_60fps==0) = nan;
    normalized_total_score_30fps(normalized_total_score_30fps==0) = nan;
    normalized_total_score_15fps(normalized_total_score_15fps==0) = nan;
    normalized_total_score_5fps(normalized_total_score_5fps==0) = nan;
    
    % Plot Total score
    hx=figure(); 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);
    plot(match_range,normalized_total_score_60fps,...
         match_range,normalized_total_score_30fps,...
         match_range,normalized_total_score_15fps,...
         match_range,normalized_total_score_5fps,'LineWidth',2);
     
    legend('60 FPS','30 FPS','15 FPS','5 FPS');
    hold on;    
    ylim([-2.2 2.2]);
    %set(gca,'Position',[0.08 0.1 0.89 0.8]);
    grid on;  set(gca,'LineWidth',2);
    
    % Fix font sizes.
    global GEN_FIG_FONTSIZE; set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);

    
    title('');
    xlim([search_range(1),search_range(end)]);
    xlabel('Offset From Ground Truth (Frames)');
    ylabel('Score');
    save_fig(hx,['fps_invariancy']);              

    
    % Total score wide version 
    set(gcf, 'PaperSize', [2*w,h]);
    set(gcf, 'PaperPosition', [0,0,2*w,h]);
    save_fig(hx,['fps_invariancy_wide']);  
end


function gen_exp_fp_probability(ds)
    load(ds.experiment_data_file);
    hx=figure; 
    w=800;
    h=w/(1920/1080);
    
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);
    
    plot(sig_lengths,cat(1,exp_results(:).TotalFP) ./ cat(1,exp_results(:).TotalComparisons),'LineWidth',2);
    ylim([-0.01 0.1]); 
    grid on;  set(gca,'LineWidth',2);
    % Fix font sizes.
    global GEN_FIG_FONTSIZE; set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    
    ylabel('Probability of False Positive'); 
    xlabel('Signature Length (Frames)');
    
    save_fig(hx,['fp_probability_' ds.exp_name]);
end


function gen_exp_fp_probability_combined(ds)
    
    hx=figure; 
    w=800;
    h=w/(1920/1080);
    
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);
    
    load(ds.experiment_data_files{1});
    plot(sig_lengths,cat(1,exp_results(:).TotalFP) ./ cat(1,exp_results(:).TotalComparisons),'--r','LineWidth',2);
    hold on;
    
%     load(ds.experiment_data_files{2});
%     plot(sig_lengths,cat(1,exp_results(:).TotalFP) ./ cat(1,exp_results(:).TotalComparisons),'--g','LineWidth',2);
%     
%     load(ds.experiment_data_files{3});
%     plot(sig_lengths,cat(1,exp_results(:).TotalFP) ./ cat(1,exp_results(:).TotalComparisons),'--b','LineWidth',2);
%     legend(ds.names{1},ds.names{2},ds.names{3});

    
    
    ylim([-0.01 0.1]); 
    grid on;  set(gca,'LineWidth',2);
    % Fix font sizes.
    global GEN_FIG_FONTSIZE; set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    
    ylabel('Probability of False Positive'); 
    xlabel('Signature Length (Frames)');
    
    save_fig(hx,['fp_probability_' ds.exp_name]);
end



function gen_sigvariance_fpcount(ds);

    load(ds.experiment_data_file);

    hx=figure; 
    w=800;
    h=w/(1920/1080);

    data = zeros(0,3);

    for i=1:2
        sigx = normr(cat(1,exp_results(i).signatures(:).DataX));
        sigx = sigx - repmat(mean(sigx,2),1,size(sigx,2));

        sigy = normr(cat(1,exp_results(i).signatures(:).DataX));
        sigy = sigy - repmat(mean(sigy,2),1,size(sigy,2));

        datax = var(sigx,[],2);
        datay = var(sigy,[],2);

        fpcount = cat(1,exp_results(i).sig_result(:).TotalFPCount);

        data = [data ; datax, datay,fpcount];
    end



    close all;
    figure;
    % We are ploting var(sigx)+var(sigy) together
    v=data(:,1) + data(:,2);
    fp=data(:,3);

    %Remove outliers
    sel = v<0.2;
    v = v(sel);
    fp = fp(sel);
    
    % Switch to probability
    fp = fp ./ sum(fp);

%     scatter(v,fp);
%     xlabel('Signature Total (X+Y) Variance');
%     ylabel('# FP');

    numbins=10;

    binrange = linspace(min(v),max(v),numbins);
    [n,bins] = histc(v,binrange);

    % Get the median per bin
    medperbin = zeros(numbins,1);
    for i=1:numbins
        if n(i)>10
            medperbin(i) = median(fp(bins == i));
        else
            medperbin(i) = nan;
        end
    end
    
    
    hx=figure; 
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'points ');
    set(gcf, 'PaperSize', [w,h]);
    set(gcf, 'PaperPosition', [0,0,w,h]);
    set(gcf,'Units','points');
    set(gcf,'Position',[100,100,w,h]);
    
    plot(binrange,medperbin,'LineWidth',2); 
    xlim([binrange(1) binrange(end)]);
    cur_ylim = ylim; ylim([cur_ylim(1) max(medperbin)]);
    grid on;  set(gca,'LineWidth',2);
    
    global GEN_FIG_FONTSIZE; set(gca,'FontSize',GEN_FIG_FONTSIZE);
    set(0, 'defaultaxesfontsize', GEN_FIG_FONTSIZE);
    
    ylabel('Probability of False Positive'); 
    xlabel('Signature Variance');
    
    save_fig(hx,'fp_vs_variance');

end