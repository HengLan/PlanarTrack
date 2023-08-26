% evaluation toolkit for PlanarTrack
% 2023 Feb

clc; clear; close all;

%% add additional path
addpath('./utils/');

%% setting
anno_path = 'annotation';                    % path to the annotation files (point, homography, and flag)
res_path  = 'tracking_result';
test_seq_path = 'test_split/test_seq.txt';   % path to the file storing test sequences

% trackers to be evaluated
trackers = {'GIFT', 'Gracker', 'HDN', 'IC', 'SOL', 'LISRD', ...
            'SCV', 'SIFT', 'ESM', 'WOFT'};

% sequences used for evaluation
seqs = read_seq(test_seq_path);
% settings for precision (based on alignment error) and success (based on homography discrepancy)
pre_threshold = 0:1:20;
pre_rank_idx = 6;
suc_threshold = 0:10:200;
suc_rank_idx = 4;
corners = [-1 -1 1; 1 -1 1; -1 1 1; 1 1 1];

% setting of plot style
plot_style = config_plot_style();

% perform challenging factor-based (or attribute-based) evaluation or not
att_eval = true;
att_name = {'Occlusion', 'Motion Blur', 'Rotation', 'Scale Variation', ...
            'Perspective Distortion', 'Out-of-View', 'Low Resolution', ...
            'Background Clutter'};
att_fig_name = {'OCC', 'MB', 'ROT', 'SV', 'PD', 'OV', 'LR', 'BC'};


% save plots
save_plot = true;
save_plot_path = 'plots';

%% evaluation on each sequence for each tracker
for i = 1:numel(seqs)   % on each sequence

    seq_name = seqs{i};

    % load GT and flags;
    anno_point = dlmread(fullfile(anno_path, [seq_name '.txt']));
    anno_homo  = dlmread(fullfile(anno_path, [seq_name '_homography.txt']));
    anno_flag  = dlmread(fullfile(anno_path, [seq_name '_flag.txt']));
    
    % only frames labeled are used for evaluation
    anno_point_sum    = sum(anno_point, 2);   % 0, not labeled
    labeled_index_1   = anno_point_sum ~= 0;  % frames labeled
    labeled_index_2   = anno_flag == 0;       % frames that can be used for evaluation
    labeled_index     = labeled_index_1 & labeled_index_2;

    anno_point = anno_point(labeled_index, :);   % only consider the labeled frames
    anno_homo  = anno_homo(labeled_index, :);
    anno_point = anno_point(2:end, :);  % drop the initial frame
    anno_homo  = anno_homo(2:end, :);

    for k = 1:numel(trackers) % for each tracker
        tracker_name = trackers{k};

        % load tracking results
        res_point = dlmread(fullfile(res_path, tracker_name, [seq_name '_' tracker_name '.txt']));
        res_homo  = dlmread(fullfile(res_path, tracker_name, [seq_name '_' tracker_name '_homography.txt']));
        
        % only consider the labeled frames and drop the initial frame
        res_point  = res_point(labeled_index, :);
        res_homo   = res_homo(labeled_index, :);
        res_point  = res_point(2:end, :);
        res_homo   = res_homo(2:end, :);

        fprintf(['evaluating ' tracker_name ' on ' seq_name ' ...\n']);

        succ_pre_num     = zeros(1, numel(pre_threshold));  % we need to compute score for precision and success at each threshold
        succ_hde_num     = zeros(1, numel(suc_threshold));

        % calculate the alignment error 
        aerr = sqrt(sum((anno_point - res_point).^2, 2)/4);

        % calculate the homograph discrepency
        tmp_N = size(anno_homo, 1);
        heer = zeros(tmp_N, 1);
        for t = 1:tmp_N
            T_gt = reshape(anno_homo(t, :), [3, 3])';
            T_rt = reshape(res_homo(t, :), [3, 3])';

            distance = 0;
            for m = 1:4
                H = T_gt * pinv(T_rt);
                pt = corners(m,:)';
                ptProj = H * pt;
                ptProj(1) = ptProj(1)/ptProj(3); 
                ptProj(2) = ptProj(2)/ptProj(3);
                dx = pt(1) - ptProj(1); 
                dy = pt(2) - ptProj(2);
                distance = distance+sqrt(dx*dx + dy*dy)/4;
            end
            heer(t) = distance;
        end

        % success score at each threshold
        for t_idx = 1:numel(pre_threshold)
            succ_pre_num(1, t_idx) = sum(aerr <= pre_threshold(t_idx));
        end
        for t_idx = 1:numel(suc_threshold)
            succ_hde_num(1, t_idx) = sum(heer <= suc_threshold(t_idx));
        end

        len_all = size(anno_point, 1);  % number of frames used for evaluation
        ave_pre_plot_aerr(k, i, :) = succ_pre_num/(len_all + eps);
        avg_hde_plot_heer(k, i, :) = succ_hde_num/(len_all + eps);
    end
end


%% draw overall precision and success plots

% use all test sequences for evaluation (overall performance)
idx_seq_set = 1:numel(seqs);

% precision plot
pre_title_name    = 'Precisoin plots on PlanarTrack';
pre_x_label_name  = 'Alignment error threshold';
pre_y_label_name  = 'Precision';
pre_plot_img_name = 'overall_precision_plot';
draw_plot(trackers, ave_pre_plot_aerr, pre_threshold, plot_style, pre_rank_idx, idx_seq_set, ...
          pre_title_name, pre_x_label_name, pre_y_label_name, save_plot, pre_plot_img_name, save_plot_path);

% success plot
suc_title_name = 'Success plots on PlanarTrack';
suc_x_label_name = 'Homography discrepancy threshold';
suc_y_label_name = 'Success rate';
pre_plot_img_name = 'overall_success_plot';
draw_plot(trackers, avg_hde_plot_heer, suc_threshold, plot_style, suc_rank_idx, idx_seq_set, ...
          suc_title_name, suc_x_label_name, suc_y_label_name, save_plot, pre_plot_img_name, save_plot_path);

%% draw precision and success plots on each challenging factor (or attribute)
if att_eval
    % load challenging factor information
    for i = 1:numel(seqs)
        seq_name = seqs{i};
        seq_att = dlmread(fullfile(anno_path, 'challenging_factor', [seq_name '_challenging_factor.txt']));
        if i == 1
            att_all = zeros(numel(seqs), numel(seq_att));
        end
        att_all(i, :) = seq_att;
    end

    att_num = size(att_all, 2);  % number of challenging factors
    for att_idx = 1:att_num            % for each attribute
        idx_seq_set = find(att_all(:, att_idx) > 0);
        disp([att_name{att_idx} ' ' num2str(length(idx_seq_set))]);

        % precision plot for this attribute
        pre_title_name = ['Precisoin plots - ' att_name{att_idx} ' (' num2str(length(idx_seq_set)) ')'];
        pre_x_label_name = 'Alignment error threshold';
        pre_y_label_name = 'Precision';
        pre_plot_att_img_name = [att_fig_name{att_idx} '_precision_plot'];
        draw_plot(trackers, ave_pre_plot_aerr, pre_threshold, plot_style, pre_rank_idx, idx_seq_set, ...
                  pre_title_name, pre_x_label_name, pre_y_label_name, save_plot, pre_plot_att_img_name, save_plot_path);

        % success plot for this attribute
        suc_title_name = ['Success plots - ' att_name{att_idx} ' (' num2str(length(idx_seq_set)) ')'];
        suc_x_label_name = 'Homography discrepancy threshold';
        suc_y_label_name = 'Success rate';
        suc_plot_att_img_name = [att_fig_name{att_idx} '_success_plot'];
        draw_plot(trackers, avg_hde_plot_heer, suc_threshold, plot_style, suc_rank_idx, idx_seq_set, ...
                  suc_title_name, suc_x_label_name, suc_y_label_name, save_plot, suc_plot_att_img_name, save_plot_path);
    end
end