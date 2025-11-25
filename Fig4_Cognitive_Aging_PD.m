%% Figure 4a Age effect
% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');

cifti_template = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
cifti_template = rmfield(cifti_template, {'parcels', 'parcelslabel', 'parcelsrgba'});

cifti_file_path = '../data/Figure4/results_cifti';
mkdir(cifti_file_path);

load('../data/Figure4/Age_eefect_map.mat');
age_effect = zeros(200, 3);
age_effect(:, 1) = Age_eefect_map.Age_effect_map1;
age_effect(:, 2) = Age_eefect_map.Age_effect_map2;
age_effect(:, 3) = Age_eefect_map.Age_effect_map3;
age_effect(age_effect==0) = NaN;

max_grad = 3;
max_roi_num = 200;
for i = 1: max_grad
    data = zeros(64984, 1);
    for j = 1: max_roi_num
        data(schaefer200_roi.parcels==j) = age_effect(j, i);
    end

    tmp_cifti_template = cifti_template;
    tmp_cifti_template.dscalar = data;
    ft_write_cifti(fullfile(cifti_file_path, ['Age_effect_MEG_Grad', num2str(i)]), tmp_cifti_template, 'parameter', 'dscalar');

end

% plotting files onto surface.
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

cifti_file_path = '../data/Figure4/results_cifti';
pic_path = '../data/Figure4/results_fig';
mkdir(pic_path);

c_map = slanCM(103, 256);
for i = 1: max_grad
    cifti_file = fullfile(cifti_file_path, ['Age_effect_MEG_Grad', num2str(i), '.dscalar.nii']);
    create_combined_cortical_image(cifti_file, 'cmap', c_map, 'color_range', [-0.3, 0.3]);
    export_fig(fullfile(pic_path, ['Age_effect_MEG_Grad', num2str(i), '.png']), '-m4', '-q100');
    close;
end

% plotting colorbar
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

pic_path = '../data/Figure4/results_fig';
mkdir(pic_path);

c_map = slanCM(103, 256);

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'Age_effect_colorbar.png'), '-q100');
close;

%% Figure 4b Age effect correlate with cognition
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/export_fig');
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));
addpath('~/VDisk1/Xinyu/softwares/Ridgeline_plot');

positive_color = [255, 109, 109]; positive_color = positive_color ./ 255;
negative_color = [101, 101, 255]; negative_color = negative_color ./ 255;
word_size = [4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 0];

load('../data/Figure4/cognitive_map200.mat');
cogn_map = cognitive_map200; clear cognitive_map200;
cogn_map([1, 102], :) = [];

cog_term_id = [116 68 41 15 64 87 7 114 91 118 94 67 80 63 100 113 25 28];
cogn_map = cogn_map(:, cog_term_id);

load('../data/Figure4/cognitive_name.mat');
cogn_name = cognitive_name.textdata(1, 2:end);
cogn_name = cogn_name(cog_term_id);

load('../data/Figure4/Age_eefect_map.mat');
age_effect = zeros(200, 3);
age_effect(:, 1) = Age_eefect_map.Age_effect_map1;
age_effect(:, 2) = Age_eefect_map.Age_effect_map2;
age_effect(:, 3) = Age_eefect_map.Age_effect_map3;

max_grad = 3;
age_effect_positive_cogname = cell(max_grad, length(cog_term_id));
age_effect_positive_r_val = zeros(max_grad, length(cog_term_id));
age_effect_negative_cogname = cell(max_grad, length(cog_term_id));
age_effect_negative_r_val = zeros(max_grad, length(cog_term_id));

for grad = 1: max_grad
    % positive
    age_effect_positive = age_effect(:, grad);
    age_effect_positive(age_effect_positive < 0) = 0;
    r_val = zeros(size(cog_term_id));
    for i = 1: length(cog_term_id)
        r_val(i) = corr(age_effect_positive, cogn_map(:, i), 'type', 'Spearman');
    end
    [r_val, ind] = sort(r_val, 'descend');
    age_effect_positive_cogname(grad, :) = cogn_name(ind);
    age_effect_positive_cogname(grad, r_val < 0) = cellstr("");
    age_effect_positive_r_val(grad, :) = r_val;


    % negative
    age_effect_negative = -age_effect(:, grad);
    age_effect_negative(age_effect_negative < 0) = 0;
    r_val = zeros(size(cog_term_id));
    for i = 1: length(cog_term_id)
        r_val(i) = corr(age_effect_negative, cogn_map(:, i), 'type', 'Spearman');
    end
    [r_val, ind] = sort(r_val, 'descend');
    age_effect_negative_cogname(grad, :) = cogn_name(ind);
    age_effect_negative_cogname(grad, r_val < 0) = cellstr("");
    age_effect_negative_r_val(grad, :) = r_val;
end

