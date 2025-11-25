%% Figure 3b existing gradient heatmap
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/export_fig');
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));

load('../data/Figure3/Anatomical_modes_modified.mat');
load('../data/Figure3/Functional_gradient.mat');
load('../data/Figure1/MEG_Gradient_ave.mat');
load('../data/Figure3/SC_Gradient_ave1.mat');

MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;
Func_Grad = Functional_Gradient_ave; clear Functional_Gradient_ave;
Geo_Mode = geo_eig; clear geo_eig;
SC_Grad = SC_Gradient_ave1; clear SC_Gradient_ave1;

exist_grad = [Func_Grad(:, 1:3), Geo_Mode(:, 1:3), SC_Grad(:, 1:3)];

exist_grad_name = {'FG1', 'FG2', 'FG3', 'GE1', 'GE2', 'GE3', 'SG1', 'SG2', 'SG3'};
MEG_name = {'MEG Grad1', 'MEG Grad2', 'MEG Grad3'};

% check Spearman's r and its significance
corr_results = zeros(3, length(exist_grad_name));
p_results = zeros(3, length(exist_grad_name));
for i = 1: 3
    for j = 1: length(exist_grad_name)
        x = MEG_Grad(:, i);
        y = exist_grad(:, j);
        corr_results(i, j) = corr(x, y, 'type', 'Spearman');
        p_results(i, j) = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -2);
    end
end

% fdr correction
[~, ~, p_results_adj] = fdr(p_results(:));
p_results_adj = reshape(p_results_adj, 3, length(exist_grad_name));

figure;
heatmap(exist_grad_name, MEG_name, corr_results, CellLabelColor="none", ColorLimits=[-1, 1], FontName='Aptos');
c_map = slanCM(103, 256);
colormap(c_map);

set(gcf, 'Position', [0, 0, 900, 275]);
set(gcf, 'color', 'none');

pic_path = '../data/Figure3/results_fig';
mkdir(pic_path);

export_fig(fullfile(pic_path, 'MEGGrads_Existing_gradients.png'), '-m6', '-q100');
close;

% plotting colorbar
addpath('~/VDisk1/Xinyu/plot_fig_subcortex/dependencies/slanCM');
addpath(genpath('../cortical_mapper'));

pic_path = '../data/Figure3/results_fig';
mkdir(pic_path);

c_map = slanCM(103, 256);

draw_colorbar(c_map);
export_fig(fullfile(pic_path, 'receptor_heatmap_colorbar.png'), '-q100');
close;



%% Figure 3c and its corresponding supplement
% plotting roi-wise data onto cifti-version file.
schaefer200_roi = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');

cifti_template = ft_read_cifti('Schaefer2018_200Parcels_7Networks_order.dlabel.nii');
cifti_template = rmfield(cifti_template, {'parcels', 'parcelslabel', 'parcelsrgba'});

cifti_file_path = '../data/Figure3/results_cifti';
mkdir(cifti_file_path);

load('../data/Figure3/Anatomical_modes_modified.mat');
load('../data/Figure3/Functional_gradient.mat');
load('../data/Figure3/SC_Gradient_ave1.mat');

Func_Grad = Functional_Gradient_ave; clear Functional_Gradient_ave;
Geo_Mode = geo_eig; clear geo_eig;
SC_Grad = SC_Gradient_ave1; clear SC_Gradient_ave1;

max_grad = 3;
max_roi_num = 200;
for modal = {'Func_Grad', 'Geo_Mode', 'SC_Grad'}
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

cifti_file_path = '../data/Figure3/results_cifti';
pic_path = '../data/Figure3/results_fig';
mkdir(pic_path);

max_grad = 3;
for modal = {'Func_Grad', 'Geo_Mode', 'SC_Grad'}
    c_map = slanCM(4, 256);

    % mapping onto surfaces
    for i = 1: max_grad
        cifti_file = fullfile(cifti_file_path, [cell2mat(modal), num2str(i), '.dscalar.nii']);
        create_combined_cortical_image(cifti_file, 'cmap', c_map);
        export_fig(fullfile(pic_path, [cell2mat(modal), num2str(i), '.png']), '-m4', '-q100');
        close;
    end
    
    % colorbars
    draw_colorbar(c_map);
    export_fig(fullfile(pic_path, [cell2mat(modal), '_colorbar.png']), '-q100');
    close;
end

% plotting scatters
addpath(genpath('~/VDisk1/Xinyu/softwares/ENIGMA-master/matlab'));
addpath(genpath('~/VDisk1/Xinyu/softwares/BrainSpace-0.1.2/matlab/'));
addpath('~/VDisk1/Xinyu/softwares/export_fig-3.38');

load('../data/Figure3/Anatomical_modes_modified.mat');
load('../data/Figure3/Functional_gradient.mat');
load('../data/Figure1/MEG_Gradient_ave.mat');
load('../data/Figure3/SC_Gradient_ave1.mat');

MEG_Grad = MEG_Gradient_ave; clear MEG_Gradient_ave;
Func_Grad = Functional_Gradient_ave; clear Functional_Gradient_ave;
Geo_Mode = geo_eig; clear geo_eig;
SC_Grad = SC_Gradient_ave1; clear SC_Gradient_ave1;

% scale Geo mode 1
Geo_Mode(:, 1) = Geo_Mode(:, 1) * 100;

pic_path = '../data/Figure3/results_fig_corr';
mkdir(pic_path)

for modal = {'Func_Grad', 'Geo_Mode', 'SC_Grad'}
    for i = 1: 3
        for j = 1: 3
            x = MEG_Grad(:, i);
            eval(['y = ', cell2mat(modal), '(:, j);']);
    
            % enigma style
            r_val = roundn(corr(x, y, 'type', 'Spearman'), -2); 
            p_val = roundn(spin_test(x, y, 'parcellation_name', 'schaefer_200', 'n_rot', 1000, 'type', 'spearman'), -2);
            
            p = polyfit(x, y, 1);
            f = polyval(p, x);
    
            hold("on");
            plot(x, f, 'Color', [0,0,0], 'LineWidth', 3);
            scatter(x, y, 200, [0.5, 0.5, 0.5], 'fill', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
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
            
            out_fig_path = fullfile(pic_path, ['MEG_Grad', num2str(i), '_', cell2mat(modal), num2str(j), '.png']);
            export_fig(out_fig_path, '-m2', '-q100');
    
            close;
        end
    
    end

end


