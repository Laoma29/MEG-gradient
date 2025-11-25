%% 1. genetic mechanism p value barplot
addpath('~/VDisk1/Xinyu/softwares/export_fig-3.38');

pic_path = '../data/SuppFigure3/results_fig';
mkdir(pic_path)

c_map = [
    228, 26, 28
    55, 126, 184
    77, 175, 74
    152, 78, 163
    255, 127, 0
    255, 255, 51
    166, 86, 40
    247, 129, 191
    153, 153, 153
    141, 211, 199
    255, 255, 179
    190, 186, 218
    251, 128, 114
    128, 177, 211
    253, 180, 98
    179, 222, 105
    252, 205, 229
    217, 217, 217
    188, 128, 189
    204, 235, 197
];
c_map = flip(c_map ./ 255);


% gradient 1
data = flip(readtable('../data/SuppFigure3/MEG_Grad1_GO_pval.xlsx'));

figure; hold on;
for i = 1: 20
    barh(i, flip(-data.log_p(i)), 'FaceColor', c_map(i, :));
end

set(gca, 'YTick', linspace(1, 20, 20));
set(gca, 'YTickLabel', data.name);

set(gcf, 'Position', [0, 0, 700, 700]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'Box', 'off');
set(gca, 'FontSize', 15, 'FontName', 'Aptos');

export_fig(fullfile(pic_path, 'MEG_Grad1_GO_pval.png'), '-m4', '-q100');
close;

% gradient 2
data = flip(readtable('../data/SuppFigure3/MEG_Grad2_GO_pval.xlsx'));

figure; hold on;
for i = 1: 20
    barh(i, flip(-data.log_p(i)), 'FaceColor', c_map(i, :));
end

set(gca, 'YTick', linspace(1, 20, 20));
set(gca, 'YTickLabel', data.name);

set(gcf, 'Position', [0, 0, 700, 700]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'Box', 'off');
set(gca, 'FontSize', 15, 'FontName', 'Aptos');

export_fig(fullfile(pic_path, 'MEG_Grad2_GO_pval.png'), '-m4', '-q100');
close;

% gradient 3
data = flip(readtable('../data/SuppFigure3/MEG_Grad3_GO_pval.xlsx'));

figure; hold on;
for i = 1: 20
    barh(i, flip(-data.log_p(i)), 'FaceColor', c_map(i, :));
end

set(gca, 'YTick', linspace(1, 20, 20));
set(gca, 'YTickLabel', data.name);

set(gcf, 'Position', [0, 0, 700, 700]);
set(gca, 'color', 'none'); set(gcf, 'color', 'none');
set(gca, 'Box', 'off');
set(gca, 'FontSize', 15, 'FontName', 'Aptos');

export_fig(fullfile(pic_path, 'MEG_Grad3_GO_pval.png'), '-m4', '-q100');
close;

