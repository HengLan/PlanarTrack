function draw_plot(trackers, ave_plot_err, pre_threshold, plot_style, pre_rank_idx, idx_seq_set, title_name, x_label_name, y_label_name, save_plot, plot_img_name, save_plot_path)
% draw precision or success plots

% first rank different trackers
perf = zeros(1, numel(trackers));
for k = 1:numel(trackers)
    % get the scores for each tracker
    tmp = ave_plot_err(k, idx_seq_set, :);
    aa  = reshape(tmp, [numel(idx_seq_set), size(ave_plot_err, 3)]);
    bb  = mean(aa);

    perf(k) = bb(pre_rank_idx);
end

[~, index_sort] = sort(perf,'descend');

% draw plots
i = 1;

font_size        = 16; 
font_size_legend = 14;      % for attribute-based plot
axex_font_size   = 14;

tmp_figure = figure;
set(gcf, 'unit', 'normalized', 'position', [0.2,0.2,0.285,0.45]);      % for overall plot

tmp_axes = axes('Parent', tmp_figure, 'FontSize', axex_font_size);

for k = index_sort(1:numel(trackers))

    tmp = ave_plot_err(k, idx_seq_set, :);
    aa  = reshape(tmp, [numel(idx_seq_set), size(ave_plot_err, 3)]);
    bb  = mean(aa);
    
    score = bb(pre_rank_idx);
    tmp   = sprintf('%.3f', score);
 
    
    tmpName{i} = ['[' tmp '] ' trackers{k}];
    plot(pre_threshold, bb, 'color', plot_style{i}.color, 'lineStyle', plot_style{i}.lineStyle,'lineWidth', 4,'Parent', tmp_axes);
    hold on
    grid on;
    if k == index_sort(1)
        set(gca,'GridLineStyle', ':', 'GridColor', 'k', 'GridAlpha', 1, 'LineWidth', 1.2);
    end
    i = i + 1;
end

legend_position = 'Northeast';
lgnd = legend(tmpName, 'Interpreter', 'none', 'fontsize', font_size_legend, 'Location', legend_position);
% set(lgnd,'color', [1, 1, 1]);
title(title_name, 'fontsize', font_size);
xlabel(x_label_name, 'fontsize', font_size);
ylabel(y_label_name, 'fontsize', font_size);
% ylim([0, 1]);

% remove some box edges in plotting
yyaxis right
ax = gca();
ax.YAxis(2).Color = 'none';
% ax.YAxis(1).Color = 'none';
box off
yyaxis left

% save plots
if save_plot
    if ~exist(save_plot_path, 'dir')
        mkdir(save_plot_path);
    end
    
    print('-depsc', fullfile(save_plot_path, plot_img_name));
end

end