
%% Figure 3a: receptor heatmap
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/export_fig');
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;
load('../data/Figure5/Receptor_map.mat');
receptor_map = Receptor_map.receptor_map200;

receptor_name = Receptor_map.receptor_name;
MEG_name = {'MEG Grad1', 'MEG Grad2', 'MEG Grad3'};

% check Spearman's r and its significance
corr_results = zeros(3, length(receptor_name));
p_results = zeros(3, length(receptor_name));
for i = 1: 3
    for j = 1: length(receptor_name)
        x = MEG_Grad(:, i);
        y = receptor_map(:, j);
        corr_results(i, j) = corr(x, y, 'type', 'Spearman');
        p_results(i, j) = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -2);
    end
end

% fdr correction
[~, ~, p_results_adj] = fdr(p_results(:));
p_results_adj = reshape(p_results_adj, 3, length(receptor_name));

figure;
heatmap(receptor_name, MEG_name, corr_results, CellLabelColor="none", ColorLimits=[-1, 1], FontName='Aptos');
c_map = slanCM(103, 256);
colormap(c_map);

set(gcf, 'Position', [0, 0, 1800, 275]);
set(gcf, 'color', 'none');

pic_path = '../data/Figure5/results_fig';
mkdir(pic_path);

export_fig(fullfile(pic_path, 'MEGGrads_Receptor_Heatmap.png'), '-m6', '-q100');
close;

% plotting colorbar
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

pic_path = '../data/Figure5/results_fig';
mkdir(pic_path);

c_map = slanCM(103, 256);

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'receptor_heatmap_colorbar.png'), '-q100');
close;

%% Fig 3b.1 BigBrain histG1 and microG1
addpath('~/VDisk1/Xinyu/softwares/npy-matlab-master/npy-matlab');

hist_G1 = readNPY('../data/Figure5/bbw-zqliu-202210/parc-200Parcels7Networks_desc-Hist_G1.npy');
micro_G1 = readNPY('../data/Figure5/bbw-zqliu-202210/parc-200Parcels7Networks_desc-Micro_G1.npy');

% create cifti file
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');

cifti_template = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
cifti_template = rmfield(cifti_template, {'parcels', 'parcelslabel', 'parcelsrgba'});

cifti_file_path = '../data/Figure5/results_cifti';
mkdir(cifti_file_path);

max_roi_num = 200;
for modal = {'hist_G1', 'micro_G1'}
    data = zeros(64984, 1);
    for j = 1: max_roi_num
        eval(['data(schaefer200_roi.parcels==j) = ', cell2mat(modal), '(j);']);
    end

    tmp_cifti_template = cifti_template;
    tmp_cifti_template.dscalar = data;
    ft_write_cifti(fullfile(cifti_file_path, cell2mat(modal)), tmp_cifti_template, 'parameter', 'dscalar');
end

% cortical map
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

pic_path = '../data/Figure5/results_fig';
mkdir(pic_path);

for modal = {'hist_G1', 'micro_G1'}
    c_map = slanCM(4, 256);

    cifti_file = fullfile(cifti_file_path, [cell2mat(modal), '.dscalar.nii']);
    create_combined_cortical_image(cifti_file, 'cmap', c_map);
    export_fig(fullfile(pic_path, [cell2mat(modal), '.png']), '-m4', '-q100');
    close;
end

% associations with MEG grads
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));
addpath(genpath('~/VDisk1/Xinyu/softwares/BrainSpace-0.1.2/matlab/'));
addpath('~/VDisk1/Xinyu/softwares/export_fig-3.38');

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;

pic_path = '../data/Figure5/results_fig';
mkdir(pic_path)

for modal = {'hist_G1', 'micro_G1'}
    for i = 1: 3
        x = MEG_Grad(:, i);
        eval(['y = ', cell2mat(modal), '(:);']);

        % enigma style
        r_val = roundn(corr(x, y, 'type', 'Spearman'), -2); 
        p_val = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -2);
        
        p = polyfit(x, y, 1);
        f = polyval(p, x);

        hold("on");
        plot(x, f, 'Color', [0,0,0], 'LineWidth', 3);
        scatter(x, y, 200, [0.5, 0.5, 0.5], 'fill', 'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0.3);
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

        out_fig_path = fullfile(pic_path, [cell2mat(modal), '_MEG_Grad', num2str(i), '.png']);
        export_fig(out_fig_path, '-m2', '-q100');

        close;
    
    end

end

%% Fig. 3b.2 Layer thickness heatmap plot
addpath('~/VDisk1/Xinyu/softwares/npy-matlab-master/npy-matlab');
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/export_fig');
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;

layer_thickness = readNPY('../data/Figure5/bbw-zqliu-202210/parc-200Parcels7Networks_desc-layer_thickness.npy');
layer_thickness = layer_thickness';

MEG_name = {'MEG Grad1', 'MEG Grad2', 'MEG Grad3'};
layer_name = {'Layer 1', 'Layer 2', 'Layer 3', 'Layer 4', 'Layer 5', 'Layer 6'};

% check Spearman's r and its significance
corr_results = zeros(3, 6);
p_results = zeros(3, 6);
for i = 1: 3
    for j = 1: 6
        x = MEG_Grad(:, i);
        y = layer_thickness(:, j);
        corr_results(i, j) = corr(x, y, 'type', 'Spearman');
        p_results(i, j) = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -3);
    end
end

% fdr correction
[~, ~, p_results_adj] = fdr(p_results(:));
p_results_adj = reshape(p_results_adj, 3, 6);

figure;
heatmap(layer_name, MEG_name, corr_results, CellLabelColor="none", ColorLimits=[-1, 1], FontName='Aptos');
c_map = slanCM(103, 256);
colormap(c_map);

set(gcf, 'Position', [0, 0, 625, 275]);
set(gcf, 'color', 'none');

pic_path = '../data/Figure5/results_fig';
mkdir(pic_path);

export_fig(fullfile(pic_path, 'MEGGrads_layerthickness_Heatmap.png'), '-m6', '-q100');
close;

% plotting colorbar
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

pic_path = '../data/Figure5/results_fig';
mkdir(pic_path);

c_map = slanCM(103, 256);

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'layerthickness_heatmap_colorbar.png'), '-q100');
close;

%% Figure 3b.3 intensity profile
addpath('~/VDisk1/Xinyu/softwares/npy-matlab-master/npy-matlab');

color_MEG_Grads = [
    198,233,227
    253,191,184
    253,230,242
]; color_MEG_Grads = color_MEG_Grads./256;

pic_path = '../data/Figure5/results_fig';

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;

intensity_profile = readNPY('../data/Figure5/bbw-zqliu-202210/parc-200Parcels7Networks_desc-intensity_profiles.npy');
intensity_profile = intensity_profile';

% check Spearman's r and its significance
corr_results = zeros(3, size(intensity_profile, 2));
for i = 1: 3
    for j = 1: size(intensity_profile, 2)
        x = MEG_Grad(:, i);
        y = intensity_profile(:, j);
        corr_results(i, j) = corr(x, y, 'type', 'Spearman');
    end
end

% seperate plot for better visualization
% MEG grad 1
figure;
% plot(corr_results(1, :), linspace(1, size(intensity_profile, 2), size(intensity_profile, 2)), Color=[0,0,0], LineWidth=2);
barh(corr_results(1, :), 1, FaceColor=color_MEG_Grads(1, :))

set(gcf, 'Position', [0, 0, 500, 625]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [0.35, 0.75]);
set(gca, 'xTick', -1:0.1:1);
set(gca, 'YTick', [1, 10, 20, 30, 40, 50]);
set(gca, 'FontSize', 30, 'FontName', 'Aptos');
set(gca, 'Box', 'off');
set(gca, 'LineWidth', 2);

export_fig(fullfile(pic_path, 'intensity_profile_MEG_Grad1.png'), '-m4', '-q100');
close;

% MEG grad 2
figure;
% plot(corr_results(2, :), linspace(1, size(intensity_profile, 2), size(intensity_profile, 2)), Color=[0,0,0], LineWidth=2);
barh(corr_results(2, :), 1, FaceColor=color_MEG_Grads(2, :))

set(gcf, 'Position', [0, 0, 500, 625]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [-0.35, -0.05]);
set(gca, 'xTick', -1:0.1:1);
set(gca, 'YTick', [1, 10, 20, 30, 40, 50]);
set(gca, 'FontSize', 30, 'FontName', 'Aptos');
set(gca, 'Box', 'off');    
set(gca, 'LineWidth', 2);

export_fig(fullfile(pic_path, 'intensity_profile_MEG_Grad2.png'), '-m4', '-q100');
close;

% MEG grad 3
figure;
% plot(corr_results(3, :), linspace(1, size(intensity_profile, 2), size(intensity_profile, 2)), Color=[0,0,0], LineWidth=2);
barh(corr_results(3, :), 1, FaceColor=color_MEG_Grads(3, :))

set(gcf, 'Position', [0, 0, 500, 625]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [-0.35, 0.5]);
set(gca, 'xTick', -1:0.2:1);
set(gca, 'YTick', [1, 10, 20, 30, 40, 50]);
set(gca, 'FontSize', 30, 'FontName', 'Aptos');
set(gca, 'Box', 'off');    
set(gca, 'LineWidth', 2);

export_fig(fullfile(pic_path, 'intensity_profile_MEG_Grad3.png'), '-m4', '-q100');
close;

%% Figure 3c: cell type heatmap
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/export_fig');
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;
load('../data/Figure5/cell_map_final.mat');
cell_map = cell_map_final.cell_map';

cell_name = cell_map_final.cell_name;
MEG_name = {'MEG Grad1', 'MEG Grad2', 'MEG Grad3'};

% check Spearman's r and its significance
corr_results = zeros(3, length(cell_name));
p_results = zeros(3, length(cell_name));
for i = 1: 3
    for j = 1: length(cell_name)
        x = MEG_Grad(:, i);
        y = cell_map(:, j);
        corr_results(i, j) = corr(x, y, 'type', 'Spearman');
        p_results(i, j) = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -2);
    end
end

% fdr correction
[~, ~, p_results_adj] = fdr(p_results(:));
p_results_adj = reshape(p_results_adj, 3, length(cell_name));

figure;
heatmap(cell_name, MEG_name, corr_results, CellLabelColor="none", ColorLimits=[-1, 1], FontName='Aptos');
c_map = slanCM(103, 256);
colormap(c_map);

set(gcf, 'Position', [0, 0, 1800, 250]);
set(gcf, 'color', 'none');

pic_path = '../data/Figure5/results_fig';
mkdir(pic_path);

export_fig(fullfile(pic_path, 'MEGGrads_Celltype_Heatmap.png'), '-m6', '-q100');
close;

% plotting colorbar
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

pic_path = '../data/Figure5/results_fig';
mkdir(pic_path);

c_map = slanCM(103, 256);

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'celltype_heatmap_colorbar.png'), '-q100');
close;



