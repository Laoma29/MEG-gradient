
%% Figure 2: collect model results of E/I ratio, empirical center freq. and simulated center freq.
% not needed any more
base_dir = dir('../data/Figure2/cam_can_para_group/*.mat');

final_computational_model = struct();
final_computational_model.E_I_group = [];
final_computational_model.cen_freq_group = [];
final_computational_model.cen_freq_shaffer_group = [];

for i = 1: length(base_dir)
    [~, filename, ~] = fileparts(base_dir(i).name);
    load(fullfile(base_dir(i).folder, base_dir(i).name));
    eval(['file = ', filename, ';']);

    % non_zero_pos = file.ind_sub;
    non_zero_pos = (mean(file.E_I_group13, 2)~=0) & (std(file.E_I_group13, 0, 2)~=0);
    final_computational_model.E_I_group = [final_computational_model.E_I_group;file.E_I_group13(non_zero_pos, :)];
    final_computational_model.cen_freq_group = [final_computational_model.cen_freq_group; file.cen_fre_group13(non_zero_pos, :)];
    final_computational_model.cen_freq_shaffer_group = [final_computational_model.cen_freq_shaffer_group; file.center_frequency_shaffer_group13(non_zero_pos, :)];
end

save('../data/Figure2/final_computational_model.mat', 'final_computational_model', '-v7.3');

%% Figure 2: surface mapping of E/I ratio, empirical center freq. and simulated center freq.
% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');

cifti_template = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
cifti_template = rmfield(cifti_template, {'parcels', 'parcelslabel', 'parcelsrgba'});

cifti_file_path = '../data/Figure2/results_cifti';
mkdir(cifti_file_path);

load('../data/Figure2/computational_model_Data_structure.mat');
E_I_ratio = mean(Data_structure.E_I_final, 2);
Emp_cen_freq = mean(Data_structure.cen_fre_emperical, 2);
Sim_cen_freq = mean(Data_structure.cen_fre_prediction, 2);

max_roi_num = 200;
for modal = {'E_I_ratio', 'Emp_cen_freq', 'Sim_cen_freq'}
    data = zeros(64984, 1);
    for j = 1: max_roi_num
        eval(['data(schaefer200_roi.parcels==j) = ', cell2mat(modal), '(j);']);
    end

    tmp_cifti_template = cifti_template;
    tmp_cifti_template.dscalar = data;
    ft_write_cifti(fullfile(cifti_file_path, cell2mat(modal)), tmp_cifti_template, 'parameter', 'dscalar');
end

% plotting files onto surface and plotting colorbars.
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

cifti_file_path = '../data/Figure2/results_cifti';
pic_path = '../data/Figure2/results_fig';
mkdir(pic_path);

% E_I_ratio
c_map = slanCM(4, 256);

cifti_file = fullfile(cifti_file_path, 'E_I_ratio.dscalar.nii');
create_combined_cortical_image(cifti_file, 'cmap', c_map, 'color_range', [0.7, 1.4]);
export_fig(fullfile(pic_path, 'E_I_ratio.png'), '-m4', '-q100');
close;

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'E_I_ratio_colorbar.png'), '-q100');
close;

% Emp_cen_freq
c_map = slanCM(4, 256);

cifti_file = fullfile(cifti_file_path, 'Emp_cen_freq.dscalar.nii');
create_combined_cortical_image(cifti_file, 'cmap', c_map, 'color_range', [11, 13]);
export_fig(fullfile(pic_path, 'Emp_cen_freq.png'), '-m4', '-q100');
close;

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'Emp_cen_freq_colorbar.png'), '-q100');
close;

% Sim_cen_freq
c_map = slanCM(4, 256);

cifti_file = fullfile(cifti_file_path, 'Sim_cen_freq.dscalar.nii');
create_combined_cortical_image(cifti_file, 'cmap', c_map, 'color_range', [4, 15]);
export_fig(fullfile(pic_path, 'Sim_cen_freq.png'), '-m4', '-q100');
close;

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'Sim_cen_freq_colorbar.png'), '-q100');
close;

%% Figure 2a. associating empirical and simulated center freqency.
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));
addpath(genpath('~/VDisk1/Xinyu/softwares/BrainSpace-0.1.2/matlab/'));
addpath('~/VDisk1/Xinyu/softwares/export_fig-3.38');

pic_path = '../data/Figure2/results_fig';
mkdir(pic_path)

load('../data/Figure2/computational_model_Data_structure.mat');
Emp_cen_freq = Data_structure.cen_fre_emperical;
Sim_cen_freq = Data_structure.cen_fre_prediction;
Emp_cen_freq_group = mean(Data_structure.cen_fre_emperical, 2);
Sim_cen_freq_group = mean(Data_structure.cen_fre_prediction, 2);

% group-level similarty
x = Emp_cen_freq_group;
y = Sim_cen_freq_group;

r_val = roundn(corr(x, y, 'type', 'Spearman'), -2); 
p_val = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -2);

p = polyfit(x, y, 1);
f = polyval(p, x);

hold("on");
plot(x, f, 'Color', [0,0,0], 'LineWidth', 3);
scatter(x, y, 300, [0.5, 0.5, 0.5], 'fill', 'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0.3);
annotation('textbox', [0.15, 0.9, 0.1, 0.1], 'FontName', 'Aptos', 'FontSize', 30,...
    'String', ['Spearman''s r = ', num2str(r_val), ', p = ', num2str(p_val)],...
    'BackgroundColor', 'none', 'EdgeColor', 'none');

% better visual effects.
set(gcf, 'Position', [0, 0, 900, 750]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'YLim', [1.05*min(y)-0.05*max(y), 1.05*max(y)-0.05*min(y)]);
set(gca, 'XLim', [1.05*min(x)-0.05*max(x), 1.05*max(x)-0.05*min(x)]);
set(gca, 'FontSize', 30, 'FontName', 'Aptos');
set(gca, 'LineWidth', 2);

out_fig_path = fullfile(pic_path, 'Emp_cenfreq_Sim_cenfreq.png');
export_fig(out_fig_path, '-m2', '-q100');

close;


% individual-level similarty
bin_width = 0.01;

x = roundn(corr(Emp_cen_freq, Sim_cen_freq, 'type', 'Spearman'), -2); 
x = diag(x);

pd = fitdist(x, 'Kernel', 'Kernel', 'normal');

x_val = min(x): bin_width: max(x);
scale_num = bin_width * length(x);
y_val = scale_num * pdf(pd, x_val);

area(x_val, y_val, FaceColor=[0.5 0.5 0.5], EdgeColor=[0, 0, 0], LineWidth=3);

set(gcf, 'Position', [0, 0, 900, 350]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'XLim', [-0.35, 0.6]);
set(gca, 'Box', 'off');
set(gca, 'xTick', -0.25:0.25:0.75);
set(gca, 'FontSize', 30, 'FontName', 'Aptos');
set(gca, 'LineWidth', 2);
alpha(0.75);

out_fig_path = fullfile(pic_path, 'Emp_cenfreq_Sim_cenfreq_indiv_similarity.png');
export_fig(out_fig_path, '-m6', '-q100');
close;

%% Figure 2b. plotting scatters associate E_I_ratio with MEG grads
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));
addpath(genpath('~/VDisk1/Xinyu/softwares/BrainSpace-0.1.2/matlab/'));
addpath('~/VDisk1/Xinyu/softwares/export_fig-3.38');

load('../data/Figure1/MEG_Gradient_ave.mat');
MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;

load('../data/Figure2/computational_model_Data_structure.mat');
E_I_ratio = mean(Data_structure.E_I_final, 2);

pic_path = '../data/Figure2/results_fig';
mkdir(pic_path)

for modal = {'E_I_ratio'}
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
