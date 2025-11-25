%% Supp Figure 1 visualize kernel loadings
addpath(genpath('~/VDisk1/Xinyu/softwares/BrainSpace-0.1.2/matlab'));

% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');

cifti_template = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
cifti_template = rmfield(cifti_template, {'parcels', 'parcelslabel', 'parcelsrgba'});

cifti_file_path = '../data/SuppFigure1/results_cifti';
mkdir(cifti_file_path);

load('../data/SuppFigure1/MEG_Gradient_source_model.mat');

% gm = GradientMaps();
% resmdl = gm.fit(Source_model_results.Source_shaff_conn);
% kern_load = zeros(200, 4);
% kern_load(:, 1:4) = resmdl.gradients{1}(:, 1:4);

kern_load = zeros(200, 4);
kern_load(:, 1:4) = Source_model_results.Functional_Gradient_sub(:, 1:4);

max_grad = 4;
max_roi_num = 200;
for i = 1: max_grad
    data = zeros(64984, 1);
    for j = 1: max_roi_num
        data(schaefer200_roi.parcels==j) = kern_load(j, i);
    end

    tmp_cifti_template = cifti_template;
    tmp_cifti_template.dscalar = data;
    ft_write_cifti(fullfile(cifti_file_path, ['Kernel_loading_Grad', num2str(i)]), tmp_cifti_template, 'parameter', 'dscalar');

end

% plotting files onto surface.
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

cifti_file_path = '../data/SuppFigure1/results_cifti';
pic_path = '../data/SuppFigure1/results_fig';
mkdir(pic_path);

c_map = flip(slanCM(100, 256));
for i = 1: max_grad
    % c_range = [min(kern_load(:, i)) - 0.2*(max(kern_load(:, i)) - min(kern_load(:, i))), max(kern_load(:, i)) + 0.2*(max(kern_load(:, i)) - min(kern_load(:, i)))]
    cifti_file = fullfile(cifti_file_path, ['Kernel_loading_Grad', num2str(i), '.dscalar.nii']);
    create_combined_cortical_image(cifti_file, 'cmap', c_map);
    export_fig(fullfile(pic_path, ['Kernel_loading_Grad', num2str(i), '.png']), '-m4', '-q100');
    close;

end

% plotting colorbar
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

pic_path = '../data/SuppFigure1/results_fig';
mkdir(pic_path);

c_map = flip(slanCM(100, 256));

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'Kernel_loading_colorbar.png'), '-q100');
close;



%% Supp Figure 1 kernel loadings and gradients scatter plot
% associations with functional hierarchy
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));
addpath(genpath('~/VDisk1/Xinyu/softwares/BrainSpace-0.1.2/matlab/'));
addpath('~/VDisk1/Xinyu/softwares/export_fig-3.38');

pic_path = '../data/SuppFigure1/results_fig';
mkdir(pic_path)

load('../data/SuppFigure1/MEG_Gradient_source_model.mat');
load('../data/Figure1/MEG_Gradient_ave.mat');

MEG_Grad = MEG_Gradient_ave;

% gm = GradientMaps();
% resmdl = gm.fit(Source_model_results.Source_shaff_conn);
% kern_load = zeros(200, 4);
% kern_load(:, 1:4) = resmdl.gradients{1}(:, 1:4);

kern_load = zeros(200, 4);
kern_load(:, 1:4) = Source_model_results.Functional_Gradient_sub(:, 1:4);

for i = 1: 3
    x = MEG_Grad(:, i);
    y = kern_load(:, i);

    % enigma style
    r_val = roundn(corr(x, y, 'type', 'Spearman'), -2); 
    p_val = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -2);

    if p_val < 0.001
        p_annot = '{\it{P}} < 0.001';
    else
        p_annot = ['{\it{P}} = ', num2str(p_val)];
    end
    fprintf(['Spearman''s r = ', num2str(r_val), ', p_val = ', num2str(p_val)]);

    p = polyfit(x, y, 1);
    f = polyval(p, x);
    
    hold("on");
    scatter(x, y, 500, [0.5, 0.5, 0.5], 'fill', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
    plot(x, f, 'Color', [0,0,0], 'LineWidth', 3);

    % better visual effects.
    set(gcf, 'Position', [0, 0, 1100, 800]);
    set(gca, 'color', 'none'); set(gcf, 'color', 'none');
    set(gca, 'YLim', [1.05*min(y)-0.05*max(y), 1.05*max(y)-0.05*min(y)]);
    set(gca, 'XLim', [1.05*min(x)-0.05*max(x), 1.05*max(x)-0.05*min(x)]);
    set(gca, 'FontSize', 35, 'FontName', 'Aptos');
    set(gca, 'LineWidth', 2);
    ax = gca;
    ax.XRuler.TickLabelGapOffset = 25;
    ax.YRuler.TickLabelGapOffset = 40;
    
    % x_axis colorbar
    ax1 = axes('Position', ax.Position, 'Color', 'none', 'Visible', 'off');
    colormap(ax1, slanCM(111, 256));
    cb1 = colorbar(ax1, 'southoutside', 'Ticks', []);
    barwidth = cb1.Position(4)*2;
    cb1.Position = [ax.Position(1), ax.Position(2)-barwidth, ax.Position(3), barwidth]; % position based on main axis
    
    % y_axis colorbar
    ax2 = axes('Position', ax.Position, 'Color', 'none', 'Visible', 'off');
    colormap(ax2, flip(slanCM(100, 256)));
    cb2 = colorbar(ax2, 'westoutside', 'Ticks', []);
    barwidth = cb2.Position(3)*2;
    cb2.Position = [ax.Position(1)-barwidth, ax.Position(2), barwidth, ax.Position(4)]; % position based on main axis

    out_fig_path = fullfile(pic_path, ['MEG_Grad', num2str(i), '_Kernel_loading', num2str(i), '.png']);
    export_fig(out_fig_path, '-m2', '-q100');
    close;

end

