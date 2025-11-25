%% procrustes alignment on MEG grads.
addpath(genpath('~/VDisk1/Xinyu/softwares/BrainSpace-0.1.2/matlab'));

% group grad val
load('../data/Figure1/MEG_Gradient_ave.mat');
group_grad = MEG_Gradient_ave; clear MEG_Gradient_ave;


% indiv grad val
load('../data/Figure1/MEG_gradient_group.mat');
indiv_grad = MEG_gradient_group.Functional_Gradient_dynamic_group;
aligned_indiv_grad = zeros(size(indiv_grad));

indiv_grad = squeeze(num2cell(indiv_grad, [1, 2]));
aligned = procrustes_alignment(indiv_grad, 'reference', group_grad);

for i = 1: length(aligned)
    aligned_indiv_grad(:, :, i) = aligned{i};
end


%% Figure 4c PD alignment and 2 sample t-test
addpath(genpath('~/VDisk1/Xinyu/softwares/BrainSpace-0.1.2/matlab'));

% group grad val
load('../data/Figure1/MEG_Gradient_ave.mat');
original_group_grad = MEG_Gradient_ave; 
clear MEG_Gradient_ave;

load('../data/SuppFigure4/PD_MEG_Gradient_group_final13.mat');
HC_grad = MEG_Gradient_group.MEG_Gradient_HC;
PD_grad = MEG_Gradient_group.MEG_Gradient_PD;

MEG_Gradient_HC_aligned = zeros(size(HC_grad));
MEG_Gradient_PD_aligned = zeros(size(PD_grad));

HC_grad = squeeze(num2cell(HC_grad, [1, 2]));
aligned = procrustes_alignment(HC_grad);
for i = 1: length(aligned)
    MEG_Gradient_HC_aligned(:, :, i) = aligned{i};
end

PD_grad = squeeze(num2cell(PD_grad, [1, 2]));
aligned = procrustes_alignment(PD_grad);
for i = 1: length(aligned)
    MEG_Gradient_PD_aligned(:, :, i) = aligned{i};
end

% after visulaize checking PD grad2 aligns with HC grad3, PD grad3 aligns
% with HC grad2, therefore switch PD grad2 and grad 3
val = MEG_Gradient_PD_aligned(:, 2, :);
MEG_Gradient_PD_aligned(:, 2, :) = MEG_Gradient_PD_aligned(:, 3, :);
MEG_Gradient_PD_aligned(:, 3, :) = val;

% val = MEG_Gradient_HC_aligned(:, 2, :);
% MEG_Gradient_HC_aligned(:, 2, :) = MEG_Gradient_HC_aligned(:, 4, :);
% MEG_Gradient_HC_aligned(:, 4, :) = val;
% val = MEG_Gradient_PD_aligned(:, 2, :);
% MEG_Gradient_PD_aligned(:, 2, :) = MEG_Gradient_PD_aligned(:, 4, :);
% MEG_Gradient_PD_aligned(:, 4, :) = val;

MEG_Gradient_HC_aligned_avg = struct;
MEG_Gradient_HC_aligned_avg.grad1 = mean(squeeze(MEG_Gradient_HC_aligned(:, 1, :)), 2);
MEG_Gradient_HC_aligned_avg.grad2 = mean(squeeze(MEG_Gradient_HC_aligned(:, 2, :)), 2);
MEG_Gradient_HC_aligned_avg.grad3 = mean(squeeze(MEG_Gradient_HC_aligned(:, 3, :)), 2);
MEG_Gradient_PD_aligned_avg = struct;
MEG_Gradient_PD_aligned_avg.grad1 = mean(squeeze(MEG_Gradient_PD_aligned(:, 1, :)), 2);
MEG_Gradient_PD_aligned_avg.grad2 = mean(squeeze(MEG_Gradient_PD_aligned(:, 2, :)), 2);
MEG_Gradient_PD_aligned_avg.grad3 = mean(squeeze(MEG_Gradient_PD_aligned(:, 3, :)), 2);
save('../data/SuppFigure4/PD_HC_average.mat', "MEG_Gradient_HC_aligned_avg", "MEG_Gradient_PD_aligned_avg", '-v7.3');

for grad = 1: 3
    t_val = zeros(200, 1);
    p_val = zeros(200, 1);
    for i = 1: 200
        [~, p, ~, stat] = ttest2( MEG_Gradient_PD_aligned(i, grad, :), MEG_Gradient_HC_aligned(i, grad, :));
        p_val(i) = p;
        t_val(i) = stat.tstat;
    end
    [~, ~, p_val_adj] = fdr(p_val);

    t_val(p_val_adj > 0.05) = NaN;

    res = struct;
    res.t_val = t_val;
    res.p_val = p_val;
    res.p_val_adj = p_val_adj;
    
    eval(['MEG_grad', num2str(grad), '_pd_effect = res;']);

end

save('../data/SuppFigure4/PD_effect.mat', "MEG_grad1_pd_effect", "MEG_grad2_pd_effect", "MEG_grad3_pd_effect", '-v7.3');

