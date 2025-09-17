%% ---------------- 1. Lie Rate (condition) ----------------


T = readtable('behavior_data_summary.xlsx', 'Sheet', 'Condition');

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
% clear

%% ---------------- 2. Lie Rate (Session) ----------------

T = readtable('behavior_data_summary.xlsx', 'Sheet', 'Session');

T.condition = categorical(T.condition, ...
    {'enhance_lie', 'enhance_honesty', 'enhance_random'}, ...
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

%% ---------------- 3. state 1, 3 and lie rate ----------------
clear

T = readtable('Behavior-HMM.xlsx');

% Graph All lie & Rest 2 State 3 FO
x = T.Rest2_State3_FO;
y = T.Lie_total_elie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [166,206,227]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [166,206,227]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 FO','FontSize',20);
ylabel('All Task Lie','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;


% Graph All lie & Rest 2 State 3 interval
x = T.Rest2_State3_interval;
y = T.Lie_total_elie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [166,206,227]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [166,206,227]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 Interval','FontSize',20);
ylabel('All Task Lie','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% Graph All lie & Rest 2 state 1 Dwell
x = T.Task1_State1_Dwell;
y = T.Lie_total_elie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [251,154,153]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [251,154,153]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Task1 State1 Dwell','FontSize',20);
ylabel('All Task Lie','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;


%% ---------------- 4. Session Lie Rate and HMM ----------------

% Graph FO & Task1
x = T.Rest2_State3_FO;
y = T.Task1_Lie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [178,223,138]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [178,223,138]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 FO','FontSize',20);
ylabel('Task1 Lie Rate','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% Graph FO & Task4
x = T.Rest2_State3_FO;
y = T.Task4_Lie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [51,160,44]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [51,160,44]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 FO','FontSize',20);
ylabel('Task4 Lie Rate','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;


% Graph Dwell & Task1
x = T.Rest2_State3_Dwell;
y = T.Task1_Lie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [251,154,153]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [251,154,153]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 Dwell Time','FontSize',20);
ylabel('Task1 Lie Rate','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;


% Graph Dwell & Task4
x = T.Rest2_State3_Dwell;
y = T.Task4_Lie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [227,26,28]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [227,26,28]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 Dwell','FontSize',20);
ylabel('Task4 Lie Rate','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% TP & Task 1
x = T.Rest2_Trans_to_State3;
y = T.Task1_Lie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [253,191,111]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [253,191,111]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 Cumulative Transitions to State3','FontSize',20);
ylabel('Task1 Lie Rate','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;


% TP & Task 4
x = T.Rest2_Trans_to_State3;
y = T.Task4_Lie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [255,127,0]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [255,127,0]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 Cumulative Transitions to State3','FontSize',20);
ylabel('Task4 Lie Rate','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% Interval & Task 1
x = T.Rest2_State3_interval;
y = T.Task1_Lie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [202,178,214]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [202,178,214]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 Interval','FontSize',20);
ylabel('Task1 Lie Rate','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% Interval & Task 2
x = T.Rest2_State3_interval;
y = T.Task2_Lie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [106,61,154]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [106,61,154]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 Interval','FontSize',20);
ylabel('Task4 Lie Rate','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% ---------------- Task 1 State 1 Dwell & Lie Ses 2,3,4 ----------------

x = T.Task1_State1_Dwell;
y = T.Lie_ses2_elie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [228,26,28]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [228,26,28]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Task1 State1 Dwell','FontSize',20);
ylabel('Task2 Lie Rate','FontSize',20);

hold off;


% ses3
x = T.Task1_State1_Dwell;
y = T.Lie_ses3_elie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [55,126,184]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [55,126,184]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Task1 State1 Dwell','FontSize',20);
ylabel('Task3 Lie Rate','FontSize',20);
hold off;

% ses4
x = T.Task1_State1_Dwell;
y = T.Lie_ses4_elie;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [77,175,74]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [77,175,74]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Task1 State1 Dwell','FontSize',20);
ylabel('Task4 Lie Rate','FontSize',20);
hold off;


%% ---------------- 5. DDM parameter and HMM ----------------

% FO & v_diff
x = T.Task1_State1_FO;
y = T.v_diff;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [31,120,180]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [31,120,180]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Task1 State1 FO','FontSize',20);
ylabel('V Diff','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% Dwell & v_diff
x = T.Task1_State1_Dwell;
y = T.v_diff;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [51,160,44]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [51,160,44]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Task1 State1 Dwell Time','FontSize',20);
ylabel('V Diff','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;


% TP & v_diff
x = T.Task1_Trans_to_State1;
y = T.v_diff;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [227,26,28]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [227,26,28]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Task1 Cumulative Transitions to State1 ','FontSize',20);
ylabel('V Diff','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% interval & v_diff
x = T.Rest2_State3_interval_1;
y = T.v_diff;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [124,152,149]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [124,152,149]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest2 State3 Interval','FontSize',20);
ylabel('V Diff','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;

% interval & z_ses
x = T.Rest1_Trans_to_State1;
y = T.z_ses;
mdl = fitlm(x, y);

x_pred = linspace(min(x), max(x), 100)';
[y_pred, y_ci] = predict(mdl, x_pred);
figure('Position',[100 100 800 600]);
scatter(x, y, 50, [177,89,40]/255, 'filled'); 
hold on;

plot(x_pred, y_pred, 'Color', 'k', 'LineWidth', 2,'LineStyle','--');
fill([x_pred; flipud(x_pred)], [y_ci(:,1); flipud(y_ci(:,2))], ...
     [177,89,40]/255, 'FaceAlpha', 0.3, 'EdgeColor','none');


ax = gca;
ax.Box = 'off';
ax.LineWidth = 1.5;
ax.FontSize = 16;
xlabel('Rest1 Cumulative Transitions to State1','FontSize',20);
ylabel('Z Ses','FontSize',20);

[R, P] = corr(x, y, 'type', 'Spearman');
title(sprintf('Spearman rho = %.2f, p = %.3f', R, P), 'FontSize', 20);
hold off;