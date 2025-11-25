
%% SuppFigure 2 archicortex and paleocortex 
% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');

cifti_template = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
cifti_template = rmfield(cifti_template, {'parcels', 'parcelslabel', 'parcelsrgba'});

cifti_file_path = '../data/SuppFigure2/results_cifti';
mkdir(cifti_file_path);

load('../data/SuppFigure2/archicortex_paleocortex_geo_dist.Schaefer2018_200Parcels_7Networks_order.mat');

Archi = archicortex_geo_dist_ROI;
Paleo = -paleocortex_geo_dist_ROI;

max_roi_num = 200;
for modal = {'Archi', 'Paleo'}
    data = zeros(64984, 1);
    for i = 1: max_roi_num
        eval(['data(schaefer200_roi.parcels==i) = ', cell2mat(modal), '(i);']);
    end

    tmp_cifti_template = cifti_template;
    tmp_cifti_template.dscalar = data;
    ft_write_cifti(fullfile(cifti_file_path, cell2mat(modal)), tmp_cifti_template, 'parameter', 'dscalar');
end

% plotting files onto surface and plotting colorbars.
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

cifti_file_path = '../data/SuppFigure2/results_cifti';
pic_path = '../data/SuppFigure2/results_fig';
mkdir(pic_path);

c_map = slanCM(103, 256);

% colorbars
draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'Archi_Paleo_colorbar.png'), '-q100');
close;

%% Supp Fig 2 plotting scatters
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));
addpath('~/VDisk1/Xinyu/softwares/export_fig-3.38');

load('../data/Figure1/MEG_Gradient_ave.mat');
load('../data/SuppFigure2/archicortex_paleocortex_geo_dist.Schaefer2018_200Parcels_7Networks_order.mat');

MEG_Grad = MEG_Gradient_ave;
Archi = archicortex_geo_dist_ROI;
Paleo = paleocortex_geo_dist_ROI;

pic_path = '../data/SuppFigure2/results_fig_corr';
mkdir(pic_path)

for modal = {'Archi', 'Paleo'}
    for i = 1: 3
        x = MEG_Grad(:, i);
        eval(['y = ', cell2mat(modal), '(:);']);

        % enigma style
        r_val = roundn(corr(x, y, 'type', 'Spearman'), -2); 
        p_val = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -2);
        
        p = polyfit(x, y, 1);
        f = polyval(p, x);

        hold("on");
        plot(x, f, 'Color', [0,0,0], 'LineWidth', 4);
        scatter(x, y, 100, [0.5, 0.5, 0.5], 'fill', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
        annotation('textbox', [0.15, 0.9, 0.1, 0.1], 'FontName', 'Aptos', 'FontSize', 30,...
            'String', ['Spearman''s r = ', num2str(r_val), ', p = ', num2str(p_val)],...
            'BackgroundColor', 'none', 'EdgeColor', 'none');

        % better visual effects.
        set(gcf, 'Position', [0, 0, 700, 700]);
        set(gca, 'color', 'none'); set(gcf, 'color', 'none');
        set(gca, 'YLim', [1.05*min(y)-0.05*max(y), 1.05*max(y)-0.05*min(y)]);
        set(gca, 'XLim', [1.05*min(x)-0.05*max(x), 1.05*max(x)-0.05*min(x)]);
        set(gca, 'FontSize', 30, 'FontName', 'Aptos');
        set(gca, 'LineWidth', 2);
        
        out_fig_path = fullfile(pic_path, ['MEG_Grad', num2str(i), '_', cell2mat(modal), '.png']);
        export_fig(out_fig_path, '-m2', '-q100');
        close;

    end

end

%% Supp Fig 2 check distribution
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));
addpath('~/VDisk1/Xinyu/softwares/export_fig-3.38');
addpath('~/VDisk1/Xinyu/softwares/multdist-master');

load('../data/Figure1/MEG_Gradient_ave.mat');
load('../data/SuppFigure2/archicortex_paleocortex_geo_dist.Schaefer2018_200Parcels_7Networks_order.mat');

MEG_Grad = MEG_Gradient_ave;
Archi = archicortex_geo_dist_ROI;
Paleo = paleocortex_geo_dist_ROI;

color_list = [
    0.350423000000000	6.10000000000000e-05	0.0304990000000000
    0.00132800000000000	0.0698360000000000	0.379529000000000
    ];

pic_path = '../data/SuppFigure2/results_fig';
mkdir(pic_path)

for modal = {'Archi', 'Paleo'}
    for i = 1: 3
        x = MEG_Grad(:, i);
        eval(['y = ', cell2mat(modal), '(:);']);

        modal_val = struct;
        modal_val.positive = y(x > 0);
        modal_val.negative = y(x < 0);

        [p, e_n] = minentest(modal_val.positive, modal_val.negative);
        p = roundn(p, -2);
        e_n = roundn(e_n, -2);
        fprintf(['Energy test for MEG grad ', num2str(i), ' on ', modal{1}, '...\n']);
        fprintf(['p value = ', num2str(p), ', energy statistics = ', num2str(e_n), '\n\n']);

        figure; hold;
        draw_violin_scatter_box_plot(modal_val, {'positive', 'negative'}, 'vertical', color_list, 50);
        annotation('textbox', [0.15, 0.9, 0.1, 0.1], 'FontName', 'Aptos', 'FontSize', 30,...
            'String', ['Energy statistics = ', num2str(e_n), ', p = ', num2str(p)],...
            'BackgroundColor', 'none', 'EdgeColor', 'none');

        set(gcf, 'Position', [0, 0, 700, 500]);
        set(gca, 'XTickLabel', {'Positive', 'Negative'});
        set(gca, 'FontSize', 30);
        set(gca, 'LineWidth', 2);
        
        out_fig_path = fullfile(pic_path, ['Energy_test_MEG_Grad', num2str(i), '_', cell2mat(modal), '.png']);
        export_fig(out_fig_path, '-m2', '-q100');
        close;

    end
end
