%% test-retest reliability
load('../data/Figure6/Replication_value.mat');

pic_path = '../data/Figure6/results_fig';
mkdir(pic_path)

color_MEG_Grads = [
    198,233,227
    253,191,184
    253,230,242
]; color_MEG_Grads = color_MEG_Grads./256;

% plot icc
% similarity
icc_val = [Replication_value.Replication_value1, Replication_value.Replication_value2, Replication_value.Replication_value3];

bin_width = 0.01;
for vn = 3:-1:1
    x = icc_val(:, vn);

    pd = fitdist(x, 'Kernel', 'Kernel', 'normal');
    
    x_val = min(x): bin_width: max(x);
    scale_num = bin_width * length(x);
    y_val = scale_num * pdf(pd, x_val);
    
    figure;
    % area(x_val, y_val, FaceColor=color_MEG_Grads(vn, :), EdgeColor=[0, 0, 0], LineWidth=2.5);
    histogram(x, 20, FaceColor=color_MEG_Grads(vn, :), LineWidth=2);

    set(gcf, 'Position', [0, 0, 850, 700]);
    set(gca, 'color', 'none'); set(gcf, 'color', 'none');
    set(gca, 'XLim', [-0.1, 1.1]);
    set(gca, 'xTick', -1:0.25:1);
    set(gca, 'FontSize', 30, 'FontName', 'Aptos');
    set(gca, "Box", "off");
    set(gca, 'LineWidth', 2);

    alpha(0.75);
    
    export_fig(fullfile(pic_path, ['ICC_MEG_Grads', num2str(vn), '.png']), '-m6', '-q100');
    close;

end

%% cross dataset similarity

pic_path = '../data/Figure6/results_fig';
mkdir(pic_path)

load('../data/Figure1/MEG_gradient_group.mat');
load('../data/Figure6/MEG_Gradient_ave_map.mat');

discovery_set = MEG_gradient_group.Functional_Gradient_dynamic_group;
validation_set = MEG_Gradient_ave_map .* 1000; % adjust for better visualization

for i = 1: 3
    for j = 1: 3 
        x = discovery_set(:, i);
        y = validation_set(:, j);
    
        % enigma style
        r_val = roundn(corr(x, y, 'type', 'Pearson'), -2); 
        p_val = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'pearson'), -2);
        
        p = polyfit(x, y, 1);
        f = polyval(p, x);
    
        hold("on");
        plot(x, f, 'Color', [0,0,0], 'LineWidth', 3);
        scatter(x, y, 200, [0.5, 0.5, 0.5], 'fill', 'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0.3);
        annotation('textbox', [0.15, 0.9, 0.1, 0.1], 'FontName', 'Aptos', 'FontSize', 30,...
            'String', ['Spearman''s r = ', num2str(r_val), ', p = ', num2str(p_val)],...
            'BackgroundColor', 'none', 'EdgeColor', 'none');
    
        % better visual effects.
        set(gcf, 'Position', [0, 0, 850, 700]);
        set(gca, 'color', 'none'); set(gcf, 'color', 'none');
        set(gca, 'YLim', [1.05*min(y)-0.05*max(y), 1.05*max(y)-0.05*min(y)]);
        set(gca, 'XLim', [1.05*min(x)-0.05*max(x), 1.05*max(x)-0.05*min(x)]);
        set(gca, 'FontSize', 30, 'FontName', 'Aptos');
        set(gca, 'LineWidth', 2);
    
        out_fig_path = fullfile(pic_path, ['silimarity_discovery_Grad', num2str(i), '_validation_Grad', num2str(j), '.png']);
        export_fig(out_fig_path, '-m2', '-q100');
    
        close;
    end

end
