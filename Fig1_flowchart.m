%% Figure 1a right panel. generate example elements of gradients
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');

pic_path = '../data/Figure1/results_fig';
mkdir(pic_path);

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;

c_map = slanCM(111, 256);

% MEG grad1
figure;
data =  MEG_Grad(1:100, 1);
heatmap(1, linspace(1, 100, 100), data, CellLabelColor="none", ColorLimits=[min(data), max(data)], FontName='Aptos');
colormap(c_map);
set(gcf, 'Position', [0, 0, 200, 1000]);
set(gcf, 'color', 'none');
colorbar("off");
export_fig(fullfile(pic_path, 'MEG_Grad1_bar.png'), '-m4', '-q100');
close;

% MEG grad2
figure;
data =  MEG_Grad(1:100, 2);
heatmap(1, linspace(1, 100, 100), data, CellLabelColor="none", ColorLimits=[min(data), max(data)], FontName='Aptos');
colormap(c_map);
set(gcf, 'Position', [0, 0, 200, 1000]);
set(gcf, 'color', 'none');
colorbar("off");
export_fig(fullfile(pic_path, 'MEG_Grad2_bar.png'), '-m4', '-q100');
close;

% MEG grad3
figure;
data =  MEG_Grad(1:100, 3);
heatmap(1, linspace(1, 100, 100), data, CellLabelColor="none", ColorLimits=[min(data), max(data)], FontName='Aptos');
colormap(c_map);
set(gcf, 'Position', [0, 0, 200, 1000]);
set(gcf, 'color', 'none');
colorbar("off");
export_fig(fullfile(pic_path, 'MEG_Grad3_bar.png'), '-m4', '-q100');
close;

% MEG grad10
figure;
data =  MEG_Grad(1:100, 10);
heatmap(1, linspace(1, 100, 100), data, CellLabelColor="none", ColorLimits=[min(data), max(data)], FontName='Aptos');
colormap(c_map);
set(gcf, 'Position', [0, 0, 200, 1000]);
set(gcf, 'color', 'none');
colorbar("off");
export_fig(fullfile(pic_path, 'MEG_Grad10_bar.png'), '-m4', '-q100');
close;

%% Figure 1b
% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');

cifti_template = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
cifti_template = rmfield(cifti_template, {'parcels', 'parcelslabel', 'parcelsrgba'});

cifti_file_path = '../data/Figure1/results_cifti';
mkdir(cifti_file_path);

load('../data/Figure1/MEG_Gradient_ave.mat');

MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;

max_grad = 3;
max_roi_num = 200;
for modal = {'MEG_Grad'}
    for i = 1: max_grad
        data = zeros(64984, 1);
        for j = 1: max_roi_num
            eval(['data(schaefer200_roi.parcels==j) = ', cell2mat(modal), '(j, i);']);
        end

        tmp_cifti_template = cifti_template;
        tmp_cifti_template.dscalar = data;
        ft_write_cifti(fullfile(cifti_file_path, [cell2mat(modal), num2str(i)]), tmp_cifti_template, 'parameter', 'dscalar');
    end
end

% plotting files onto surface and plotting colorbars.
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

cifti_file_path = '../data/Figure1/results_cifti';
pic_path = '../data/Figure1/results_fig';
mkdir(pic_path);

max_grad = 3;
for modal = {'MEG_Grad'}
    c_map = slanCM(111, 256);

    for i = 1: max_grad
        cifti_file = fullfile(cifti_file_path, [cell2mat(modal), num2str(i), '.dscalar.nii']);
        create_combined_cortical_image(cifti_file, 'cmap', c_map);
        export_fig(fullfile(pic_path, [cell2mat(modal), num2str(i), '.png']), '-m4', '-q100');
        close;
    end

    draw_colorbar(c_map);
    export_fig(fullfile(pic_path, [cell2mat(modal), '_colorbar.png']), '-q100');
    close;
end

%% Figure 1c left panel: basic properties of MEG grads
load('../data/Figure1/MEG_gradient_group.mat');

pic_path = '../data/Figure1/results_fig';
mkdir(pic_path)

color_MEG_Grads = [
    198,233,227
    253,191,184
    253,230,242
]; color_MEG_Grads = color_MEG_Grads./256;

% gradient value
% grad_val = MEG_gradient_group.Functional_Gradient_dynamic_group(:, 1:3, :);
load('../data/Figure1/MEG_gradient_group_aligned.mat');
grad_val = aligned_indiv_grad(:, 1:3, :);

bin_width = 1;
figure; hold;
for vn = 3:-1:1
    x = grad_val(:, vn, :);
    % x = mean(squeeze(x))';
    x = x(:);
    pd = fitdist(x,'Kernel', 'Kernel', 'normal');
    
    x_val = min(x): bin_width: max(x);
    scale_num = bin_width * length(x);
    y_val = scale_num * pdf(pd, x_val);

    area(x_val, y_val, FaceColor=color_MEG_Grads(vn, :), EdgeColor=[0, 0, 0], LineWidth=3);
end

set(gcf, 'Position', [0, 0, 750, 430]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [-70, 70]);
set(gca, 'xTick', -100:50:100);
set(gca, 'FontSize', 30, 'FontName', 'Aptos');
set(gca, 'LineWidth', 2);
alpha(0.75);

out_fig_path = fullfile(pic_path, 'MEG_Grads_value.png');
export_fig(out_fig_path, '-m6', '-q100');
close;

% variance explained
vn_val = zeros(length(MEG_gradient_group.corivace_group1), 3);
vn_val(:, 1) = MEG_gradient_group.corivace_group1;
vn_val(:, 2) = MEG_gradient_group.corivace_group2;
vn_val(:, 3) = MEG_gradient_group.corivace_group3;

bin_width = 0.001;
figure; hold;
for vn = 3:-1:1
    x = vn_val(:, vn);
    pd = fitdist(x,'Kernel', 'Kernel', 'normal');
    
    x_val = min(x): bin_width: max(x);
    scale_num = bin_width * length(x);
    y_val = scale_num * pdf(pd, x_val);

    area(x_val, y_val, FaceColor=color_MEG_Grads(vn, :), EdgeColor=[0, 0, 0], LineWidth=3);
end

set(gcf, 'Position', [0, 0, 750, 430]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [0.1, 0.18]);
set(gca, 'xTick', 0.11:0.02:0.17);
set(gca, 'FontSize', 30, 'FontName', 'Aptos');
set(gca, 'LineWidth', 2);
alpha(0.75);

out_fig_path = fullfile(pic_path, 'MEG_Grads_variance_explained.png');
export_fig(out_fig_path, '-m6', '-q100');
close;

% similarity
grad_val = MEG_gradient_group.Functional_Gradient_dynamic_group(:, 1:3, :);
load('../data/Figure1/MEG_gradient_group_aligned.mat');
grad_val = aligned_indiv_grad(:, 1:3, :);

bin_width = 0.01;
figure; hold;
for vn = 3:-1:1
    grad_val_vn = squeeze(grad_val(:, vn, :));
    x = [];
    for i = 2:size(grad_val, 3)
        for j = i+1: size(grad_val, 3)
            x(end+1) = corr(grad_val_vn(:, i), grad_val_vn(:, j));
        end
    end
    x = x';

    pd = fitdist(x, 'Kernel', 'Kernel', 'normal');
    
    x_val = min(x): bin_width: max(x);
    scale_num = bin_width * length(x);
    y_val = scale_num * pdf(pd, x_val);

    area(x_val, y_val, FaceColor=color_MEG_Grads(vn, :), EdgeColor=[0, 0, 0], LineWidth=3);
end

set(gcf, 'Position', [0, 0, 750, 430]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [-0.35, 1.1]);
set(gca, 'xTick', -0.25:0.5:0.75);
set(gca, 'FontSize', 30, 'FontName', 'Aptos');
set(gca, 'LineWidth', 2);
alpha(0.75);

out_fig_path = fullfile(pic_path, 'MEG_Grads_variability.png');
export_fig(out_fig_path, '-m6', '-q100');
close;

%% Figure 1c right panel: scatter plot for 3 gradient

% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
yeo_7net_color = schaefer200_roi.parcelsrgba(:, 1:3);

pic_path = '../data/Figure1/results_fig';
mkdir(pic_path)

color_MEG_Grads = [
    198,233,227
    253,191,184
    253,230,242
]; color_MEG_Grads = color_MEG_Grads./256;

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;

figure;
scatter(MEG_Grad(:, 1), MEG_Grad(:, 2), 150, yeo_7net_color, 'filled')
set(gcf, 'Position', [0, 0, 700, 700]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [-0.042, 0.022]);
set(gca, 'xTick', -0.1:0.02:0.1);
set(gca, 'YLim', [-0.03, 0.03]);
set(gca, 'yTick', -0.1:0.02:0.1);
set(gca, 'FontSize', 32.5, 'FontName', 'Aptos');
set(gca, 'LineWidth', 2);

out_fig_path = fullfile(pic_path, 'MEG_Grad1_MEG_Grad2_scatter.png');
export_fig(out_fig_path, '-m6', '-q100');
close;

figure;
scatter(MEG_Grad(:, 1), MEG_Grad(:, 3), 150, yeo_7net_color, 'filled')
set(gcf, 'Position', [0, 0, 700, 700]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [-0.042, 0.022]);
set(gca, 'xTick', -0.1:0.02:0.1);
set(gca, 'YLim', [-0.042, 0.022]);
set(gca, 'yTick', -0.1:0.02:0.1);
set(gca, 'FontSize', 32.5, 'FontName', 'Aptos');
set(gca, 'LineWidth', 2);

out_fig_path = fullfile(pic_path, 'MEG_Grad1_MEG_Grad3_scatter.png');
export_fig(out_fig_path, '-m6', '-q100');
close;

figure;
scatter(MEG_Grad(:, 2), MEG_Grad(:, 3), 150, yeo_7net_color, 'filled')
set(gcf, 'Position', [0, 0, 700, 700]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [-0.03, 0.03]);
set(gca, 'xTick', -0.1:0.02:0.1);
set(gca, 'YLim', [-0.042, 0.022]);
set(gca, 'yTick', -0.1:0.02:0.1);
set(gca, 'FontSize', 32.5, 'FontName', 'Aptos');
set(gca, 'LineWidth', 2);

out_fig_path = fullfile(pic_path, 'MEG_Grad2_MEG_Grad3_scatter.png');
export_fig(out_fig_path, '-m6', '-q100');
close;



%% Figure 1c visualize 7 network distribution
addpath('~/VDisk1/Xinyu/softwares/Violinplot-Matlab-master');

pic_path = '../data/Figure1/results_fig';
mkdir(pic_path)

% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
yeo_7net_color = [
    0.470588235294118	0.0705882352941177	0.525490196078431
    0.274509803921569	0.509803921568627	0.705882352941177
    0	0.462745098039216	0.0549019607843137
    0.768627450980392	0.227450980392157	0.980392156862745
    0.862745098039216	0.972549019607843	0.643137254901961
    0.901960784313726	0.580392156862745	0.133333333333333
    0.803921568627451	0.243137254901961	0.305882352941177    
];

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;

network_name = {'Vis', 'Mot', 'dATN', 'Sal', 'LMB', 'FPN', 'DMN'};

for grad = 1:3
    network_parcellation = struct();
    network_parcellation.Vis = MEG_Grad(contains(schaefer200_roi.parcelslabel, 'Vis'), grad);
    network_parcellation.Mot = MEG_Grad(contains(schaefer200_roi.parcelslabel, 'SomMot'), grad);
    network_parcellation.dATN = MEG_Grad(contains(schaefer200_roi.parcelslabel, 'DorsAttn'), grad);
    network_parcellation.Sal = MEG_Grad(contains(schaefer200_roi.parcelslabel, 'SalVentAttn'), grad);
    network_parcellation.LMB = MEG_Grad(contains(schaefer200_roi.parcelslabel, 'Limbic'), grad);
    network_parcellation.FPN = MEG_Grad(contains(schaefer200_roi.parcelslabel, 'Cont'), grad);
    network_parcellation.DMN = MEG_Grad(contains(schaefer200_roi.parcelslabel, 'Default'), grad);
    
    figure; hold;
%     violinplot(network_parcellation, {'Vis', 'Mot', 'dATN', 'Sal', 'LMB', 'FPN', 'DMN'},...
%         'GroupOrder',  {'Vis', 'Mot', 'dATN', 'Sal', 'LMB', 'FPN', 'DMN'},...
%         'Orientation', 'horizontal',...
%         'ViolinColor', yeo_7net_color);

    draw_box_plot_seperate(network_parcellation, {'Vis', 'Mot', 'dATN', 'Sal', 'LMB', 'FPN', 'DMN'},...
        'horizontal', yeo_7net_color);
    set(gcf, 'Position', [0, 0, 500, 700]);
    set(gca, 'Box', 'off');
    % set(gca, 'XLim', [-0.045, 0.025])
    set(gca, 'color', 'none'); set(gcf, 'color', 'none');
    set(gca, 'FontSize', 30, 'FontName', 'Aptos');

    out_fig_path = fullfile(pic_path, ['MEG_Grad', num2str(grad), '_distribution.png']);
    export_fig(out_fig_path, '-m6', '-q100');
    close;

end

