%% ---------------- 1. Lie Rate (condition) ----------------


T = readtable('behavior_data_summary.xlsx', 'Sheet', 'agg_entropy');

T.condition = categorical(T.condition, ...
    {'enhance_lie', 'enhance_honesty', 'enhance_random'}, ...
    'Ordinal', true);

conds = categories(T.condition);
data_cell = cell(1, numel(conds));

for i = 1:numel(conds)
    data_cell{i} = T.lierate(T.condition == conds{i});
end

colors = [
    228, 26, 28;    % enhance_lie
    77, 175, 74;   % enhance_honesty
    55, 126, 184    % enhance_random
] / 255;

figure;
daviolinplot(data_cell, ...
    'colors', colors, ...
    'xtlabels', {'elie','ehon','random'});  
ylim([0,1]);
ylabel('Lie Rate');
clear

%% ---------------- 1. Lie Rate (Session) ----------------

T = readtable('behavior_data_summary.xlsx', 'Sheet', 'agg');

T.condition = categorical(T.condition, ...
    {'enhance_lie', 'enhance_random', 'enhance_honesty'}, ...
    'Ordinal', true);
T.session = double(T.session); 

conds = categories(T.condition);
sessions = unique(T.session);

mean_mat = zeros(length(conds), length(sessions));
se_mat = zeros(length(conds), length(sessions));

colors = [
    228, 26, 28;    % enhance_lie
    77, 175, 74;   % enhance_honesty
    55, 126, 184    % enhance_random
] / 255;


for i = 1:length(conds)
    for j = 1:length(sessions)
        idx = T.condition == conds{i} & T.session == sessions(j);
        data = T.acc(idx);
        mean_mat(i,j) = mean(data);
        se_mat(i,j) = std(data) / sqrt(length(data));
    end
end

figure; hold on;

for i = 1:length(conds)
    x = sessions;
    y = mean_mat(i,:);
    se = se_mat(i,:);

    errorbar(x, y, se, 'Color', colors(i,:), ...
        'LineWidth', 1.5, 'CapSize', 10);

    scatter(x, y, 70, ...
        'MarkerFaceColor', colors(i,:), ...
        'MarkerEdgeColor', colors(i,:), ...
        'LineWidth', 1.5);
end

xlim([0.8, 4.2]);
ylim([0, 1]);
xticks(1:4);
xlabel('Session');
ylabel('Lie Rate');
set(gca, 'FontSize', 14);
box off;

