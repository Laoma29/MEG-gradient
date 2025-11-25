%% Supp Figure 4 visualize PD and HC
% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');

cifti_template = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
cifti_template = rmfield(cifti_template, {'parcels', 'parcelslabel', 'parcelsrgba'});

cifti_file_path = '../data/SuppFigure4/results_cifti';
mkdir(cifti_file_path);

load('../data/SuppFigure4/PD_HC_average.mat')
HC_avg = zeros(200, 3);
HC_avg(:, 1) = MEG_Gradient_HC_aligned_avg.grad1;
HC_avg(:, 2) = MEG_Gradient_HC_aligned_avg.grad2;
HC_avg(:, 3) = MEG_Gradient_HC_aligned_avg.grad3;

PD_avg = zeros(200, 3);
PD_avg(:, 1) = MEG_Gradient_PD_aligned_avg.grad1;
PD_avg(:, 2) = MEG_Gradient_PD_aligned_avg.grad2;
PD_avg(:, 3) = MEG_Gradient_PD_aligned_avg.grad3;

max_grad = 3;
max_roi_num = 200;
for i = 1: max_grad
    data = zeros(64984, 1);
    for j = 1: max_roi_num
        data(schaefer200_roi.parcels==j) = PD_avg(j, i);
    end

    tmp_cifti_template = cifti_template;
    tmp_cifti_template.dscalar = data;
    ft_write_cifti(fullfile(cifti_file_path, ['PD_avg_MEG_Grad', num2str(i)]), tmp_cifti_template, 'parameter', 'dscalar');

    data = zeros(64984, 1);
    for j = 1: max_roi_num
        data(schaefer200_roi.parcels==j) = HC_avg(j, i);
    end

    tmp_cifti_template = cifti_template;
    tmp_cifti_template.dscalar = data;
    ft_write_cifti(fullfile(cifti_file_path, ['HC_avg_MEG_Grad', num2str(i)]), tmp_cifti_template, 'parameter', 'dscalar');

end

% plotting files onto surface.
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

cifti_file_path = '../data/SuppFigure4/results_cifti';
pic_path = '../data/SuppFigure4/results_fig';
mkdir(pic_path);

c_map = slanCM(111, 256);
for i = 1: max_grad
    c_range = [min(HC_avg(:, i)) - 0.2*(max(HC_avg(:, i)) - min(HC_avg(:, i))), max(HC_avg(:, i)) + 0.2*(max(HC_avg(:, i)) - min(HC_avg(:, i)))]
    cifti_file = fullfile(cifti_file_path, ['HC_avg_MEG_Grad', num2str(i), '.dscalar.nii']);
    create_combined_cortical_image(cifti_file, 'cmap', c_map, 'color_range', c_range);
    export_fig(fullfile(pic_path, ['HC_avg_MEG_Grad', num2str(i), '.png']), '-m4', '-q100');
    close;

    c_range = [min(PD_avg(:, i)) - 0.2*(max(PD_avg(:, i)) - min(PD_avg(:, i))), max(PD_avg(:, i)) + 0.2*(max(PD_avg(:, i)) - min(PD_avg(:, i)))]
    cifti_file = fullfile(cifti_file_path, ['PD_avg_MEG_Grad', num2str(i), '.dscalar.nii']);
    create_combined_cortical_image(cifti_file, 'cmap', c_map, 'color_range', c_range);
    export_fig(fullfile(pic_path, ['PD_avg_MEG_Grad', num2str(i), '.png']), '-m4', '-q100');
    close;
end

% plotting colorbar
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

pic_path = '../data/SuppFigure4/results_fig';
mkdir(pic_path);

c_map = slanCM(111, 256);

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'PD_avg_colorbar.png'), '-q100');
close;
draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'HC_avg_colorbar.png'), '-q100');
close;
