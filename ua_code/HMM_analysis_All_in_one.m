%% Dual estimation

clear

data_ses1 = load('input_data/rest_ses1.mat');
data_ses2 = load('input_data/rest_ses2.mat');
data_ses1 = data_ses1.data; % 476 x 33 x 37
data_ses2 = data_ses2.data; % 476x 33 x 37

data_all = cat(3, data_ses1, data_ses2); % 476 x 33 x 74

data_subj = struct();

for i = 1:74
    data_subj(i).X = data_all(:,:,i);
end

% Load our HMM model
best_hmm_result = load('output_HMM/HMM_Model_K10/Hmm');
best_hmm = best_hmm_result.hmm;

% set
options = struct();
options.K = 10;
options.cvverbose = 1; 
options.order = 0; % no autoregressive components
options.zeromean = 0; % do not model the mean
options.covtype = 'full'; % full covariance matrix
options.Fs = 1; % TR = 1s
options.verbose = 1;
options.standardise = 1;
options.inittype = 'HMM-MAR';
options.cyc = 1000;
options.initcyc = 10;
options.initrep = 5;
options.cvverbose = 1;
options.dropstates = 0;
options.cvverbose = 1;

% use hmmdual to get individual HMM model
for i = 1:74
    [hmm_subj, Gamma_subj, vpath_subj] = hmmdual(data_subj(i).X, 476, best_hmm);
    
    dual_hmm(i).hmm_subj = hmm_subj;
    dual_hmm(i).Gamma_subj = Gamma_subj;
    dual_hmm(i).vpath_subj = vpath_subj;
end


%% Figure 1: basic behavioral result - lie
a = load("input_data\Behavioral_data.mat");
data = a.behavioral_data(:, 1:4);
figure;
labels = {'Lie Rate (Total)', 'Lie Rate (Lie Enhanced)', 'Lie Rate (Honesty Enhanced)', 'Lie Rate (Random Enhanced)'};

colors = [0.45, 0.80, 0.69];

daviolinplot(data, 'groups', ones(size(data, 1), 1), ...
                 'colors', colors, 'boxcolors', 'same', ...
                 'violinalpha', 0.8, 'boxalpha', 0.8, ... 
                 'violin', 'half', 'xtlabels', labels, 'outliers',0);

title('Behavioral Summary (Lie Rate)','fontweight','bold');
ylabel('Lie Rate');
grid on;
hold off;

%% Figure 1: basic behavioral result - Entropy
data = a.behavioral_data(:, 5:8);
figure;
labels = {'Entropy (Total)', 'Entropy (Lie Enhanced)', 'Entropy (Honesty Enhanced)', 'Entropy (Random Enhanced)'}; 

colors = [0.98, 0.40, 0.35];

daviolinplot(data, 'groups', ones(size(data, 1), 1), ...
                 'colors', colors, 'boxcolors', 'same', ...
                 'violinalpha', 0.8, 'boxalpha', 0.8, ...
                 'violin', 'half', 'xtlabels', labels,'outliers',0);

title('Behavioral Summary (Entropy)','fontweight','bold');
ylabel('Entropy');
grid on;
hold off;

%% Figure 1: basic behavioral result - Model Parameter
data = a.behavioral_data(:, 9:end);


labels = {'v former diff', 'v ses', 'v former diff ses', 'v diff', 'v diff ses', 'a ses', 'z ses'};

colors =[0.90, 0.70, 0.30]; 

daviolinplot(data, 'groups', ones(size(data, 1), 1), ...
                 'colors', colors, 'violin', 'half', 'xtlabels', labels, 'outliers',0);

title('Model Parameter Summary','fontweight','bold');
ylabel('Fitted Value');
grid on;
hold off;

%% Figure 3 - Brain state visualization (activation + covariance) - To be Continued in Python notebook

Mean = getMean(best_hmm);  % 33 x 10 
z_mean = zscore(Mean)';

save('output_HMM\Brain_state\Mean_states.mat', 'z_mean');

covars = zeros(10,33, 33);

for state = 1:10
    covars(state,:,:) = getFuncConn(best_hmm, state);
end

save('output_HMM\Brain_state\covars.mat', 'covars');

%%
colors = [0 0.4470 0.7410;   % Blue
          0.8500 0.3250 0.0980;  % Red
          0.9290 0.6940 0.1250;  % Yellow
          0.4940 0.1840 0.5560;  % Purple
          0.4660 0.6740 0.1880;  % Green
          0.3010 0.7450 0.9330;  % Cyan
          0.6350 0.0780 0.1840;  % Dark red
          0.7 0.7 0.7;           % Gray
          0.8 0.6 0.6;           % Pink
          0.75 0.75 0];          % Olive

figure;
hold on;

% 用于图例的标签
color_names = {'Blue', 'Red', 'Yellow', 'Purple', 'Green', 'Cyan', 'Dark red', 'Gray', 'Pink', 'Olive'};

% 画出每一个颜色的柱状图
for i = 1:size(colors, 1)
    bar(i, 1, 'FaceColor', colors(i, :), 'DisplayName', color_names{i});
end

% 添加图例
legend('show');

set(gca, 'XTick', 1:10, 'XTickLabel', color_names);
hold off;


%% Figure 4 - Basic connectron analysis

n_states = options.K; 
T_subj = repmat(476, 74, 1); 

FO = zeros(74, n_states);
switching_rate = zeros(74, 1);
mean_life_time = NaN(74, n_states); 

for i = 1:74
    Gamma_subj = dual_hmm(i).Gamma_subj; 
    vpath_subj = dual_hmm(i).vpath_subj; 

    FO(i, :) = getFractionalOccupancy(Gamma_subj, T_subj(i), options, 2);

    switching_rate(i) = getSwitchingRate(vpath_subj, T_subj(i), options);

    lifetimes = getStateLifeTimes(vpath_subj, T_subj(i), options);
    existing_states = unique(vpath_subj); 
    for k = existing_states'
        if ~isempty(lifetimes{k})
            mean_life_time(i, k) = mean(lifetimes{k});
        end
    end

    intervals = getStateIntervalTimes(vpath_subj, T_subj(i), options);
    for k = existing_states'
        if ~isempty(intervals{k})
            mean_interval_time(i, k) = mean(intervals{k});
        end
    end
end

%fdr signfiicant

FO_pre = FO(1:37, :);
FO_post = FO(38:end, :);

p_values = zeros(1, size(FO, 2));

for i = 1:size(FO, 2)
    [p_values(i), ~] = signrank(FO_pre(:, i), FO_post(:, i));
end

adj_p_values = mafdr(p_values, 'BHFDR', true);

disp("FO (no-fdr) Significant:")
disp(p_values);

disp("FO (fdr) Significant:")
disp(adj_p_values);

% switching rate
switching_rate_pre = switching_rate(1:37);
switching_rate_post = switching_rate(38:end);

p_values = signrank(switching_rate_pre, switching_rate_post);

disp("switching rate Significant:")
disp(p_values);


%% Figure 4 - Graph settings:
% FO
ci_FO_pre_lower = mean(FO_pre) - 1.96 * (std(FO_pre) / sqrt(size(FO_pre, 1)));
ci_FO_pre_upper = mean(FO_pre) + 1.96 * (std(FO_pre) / sqrt(size(FO_pre, 1)));
ci_FO_post_lower = mean(FO_post) - 1.96 * (std(FO_post) / sqrt(size(FO_post, 1)));
ci_FO_post_upper = mean(FO_post) + 1.96 * (std(FO_post) / sqrt(size(FO_post, 1)));

% Switching Rate
ci_switching_pre_lower = mean(switching_rate_pre) - 1.96 * (std(switching_rate_pre) / sqrt(size(switching_rate_pre, 1)));
ci_switching_pre_upper = mean(switching_rate_pre) + 1.96 * (std(switching_rate_pre) / sqrt(size(switching_rate_pre, 1)));
ci_switching_post_lower = mean(switching_rate_post) - 1.96 * (std(switching_rate_post) / sqrt(size(switching_rate_post, 1)));
ci_switching_post_upper = mean(switching_rate_post) + 1.96 * (std(switching_rate_post) / sqrt(size(switching_rate_post, 1)));


colors = [0 0.4470 0.7410;   % Blue
          0.8500 0.3250 0.0980;  % Red
          0.9290 0.6940 0.1250;  % Yellow
          0.4940 0.1840 0.5560;  % Purple
          0.4660 0.6740 0.1880;  % Green
          0.3010 0.7450 0.9330;  % cyan
          0.6350 0.0780 0.1840;  % Dark red
          0.7 0.7 0.7;           % Gray
          0.8 0.6 0.6;           % Pink
          0.75 0.75 0];          % Olive

%%
colors = [0 0.4470 0.7410;   % Blue
          0.8500 0.3250 0.0980;  % Red
          0.9290 0.6940 0.1250;  % Yellow
          0.4940 0.1840 0.5560;  % Purple
          0.4660 0.6740 0.1880;  % Green
          0.3010 0.7450 0.9330;  % Cyan
          0.6350 0.0780 0.1840;  % Dark red
          0.7 0.7 0.7;           % Gray
          0.8 0.6 0.6;           % Pink
          0.75 0.75 0];          % Olive

figure;
hold on;

% 用于图例的标签
color_names = {'State 1', 'State 2', 'State 3', 'State 4', 'State 5', 'State 6', 'State 7', 'State 8', 'State 9', 'State 10'};

% 画出每一个颜色的柱状图
for i = 1:size(colors, 1)
    bar(i, 1, 'FaceColor', colors(i, :), 'DisplayName', color_names{i});
end

% 添加图例
legend('show');

set(gca, 'XTick', 1:10, 'XTickLabel', color_names);
hold off;


%% Figure 4 - graph FO and switching rate with 95% CI

figure;
hold on;

for i = 1:length(ci_FO_pre_lower)
    errorbar(2*i-1, mean(FO_pre(:, i)), mean(FO_pre(:, i)) - ci_FO_pre_lower(i), ci_FO_pre_upper(i) - mean(FO_pre(:, i)), 'o', 'Color', colors(i,:), 'MarkerFaceColor', colors(i,:), 'LineWidth', 1.5);
    errorbar(2*i, mean(FO_post(:, i)), mean(FO_post(:, i)) - ci_FO_post_lower(i), ci_FO_post_upper(i) - mean(FO_post(:, i)), 'o', 'Color', colors(i,:) * 0.5 + 0.5, 'MarkerFaceColor', colors(i,:) * 0.5 + 0.5, 'LineWidth', 1.5);
end

set(gca, 'XTick', 1.5:2:2*length(ci_FO_pre_lower), 'XTickLabel', arrayfun(@(x) ['State ' num2str(x)], 1:length(ci_FO_pre_lower), 'UniformOutput', false));
ylim([0 0.2]);

title('DISTRIBUTION OF THE STATES FRACTIONAL OCCUPANCY');
xlabel('STATE');
ylabel('Fractional Occupancy');
hold off;


figure;
hold on;

errorbar(1, mean(switching_rate_pre), mean(switching_rate_pre) - ci_switching_pre_lower, ci_switching_pre_upper - mean(switching_rate_pre), 'o', 'Color', colors(1,:), 'MarkerFaceColor', colors(1,:), 'LineWidth', 1.5);
errorbar(1.2, mean(switching_rate_post), mean(switching_rate_post) - ci_switching_post_lower, ci_switching_post_upper - mean(switching_rate_post), 'o', 'Color', colors(1,:) * 0.5 + 0.5, 'MarkerFaceColor', colors(1,:) * 0.5 + 0.5, 'LineWidth', 1.5);

set(gca, 'XTick', [1 1.2], 'XTickLabel', {'Pre Task', 'Post Task'});
xlim([0.9 1.3]);
set(gca, 'TickLength', [0 0]);

title('DISTRIBUTION OF THE SWITCHING RATE');
ylabel('Switching Rate');

hold off;

%% Figure 4 -  Basic Transition Matrix analysis
data_all = reshape(permute(data_all, [1 3 2]), [], 33);
Pre_data_all = data_all(1:17612, :);
Post_data_all = data_all(17613:35224, :);

[hmm_Pre,gamma_pre] = hmmdual(Pre_data_all, 17612, best_hmm);
[hmm_Post,gamma_post] = hmmdual(Post_data_all, 17612, best_hmm);

trans_pre = getTransProbs(hmm_Pre);
trans_post = getTransProbs(hmm_Post);

figure;
% Pre Rest HMM
imagesc(trans_pre);
colorbar; 
clim([0 0.25]);
title('Pre Task Transition Probability Matrix');
xlabel('To state');
ylabel('From state');
xticks(1:10); 
yticks(1:10); 
xticklabels({'S1', 'S2', 'S3', 'S4', 'S5', 'S6','S7','S8','S9','S10'});
yticklabels({'S1', 'S2', 'S3', 'S4', 'S5', 'S6','S7','S8','S9','S10'}); 

figure;
% Post Rest HMM
imagesc(trans_post);
colorbar;
clim([0 0.25]);
title('Post Task Transition Probability Matrix');
xlabel('To state');
ylabel('From state');
xticks(1:10);
yticks(1:10);
xticklabels({'S1', 'S2', 'S3', 'S4', 'S5', 'S6','S7','S8','S9','S10'});
yticklabels({'S1', 'S2', 'S3', 'S4', 'S5', 'S6','S7','S8','S9','S10'});

%% Figure 4 - dNBS (please type dNBS in command window

for i = 1:74
    TP = getTransProbs(dual_hmm(i).hmm_subj);
    filename = sprintf('subject%02d.txt', i); 
    filepath = fullfile('output_HMM', 'TP', filename);
    writematrix(TP, filepath); 
end

% then could use dNBS, just type dNBS in command window
% Go to NBSDirected1.0.1\Result to see history result
% 
% To replicate, just load \ua_code\output_HMM\dNBS_setting\history-dNBS.mat
% For Pre > Post, set contrast to [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
% For Post > Pre, set contrast to [-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
%

%% Figure 4 - dNBS plot dNBS Pre > Post

connection_matrix = zeros(10, 10);

connections = [
    1 4;  % S1 -> S4
    1 3;  % S1 -> S3
    2 4;  % S2 -> S4
    3 1;  % S3 -> S1
    3 4;  % S3 -> S4
    4 5;  % S4 -> S5
    5 8;  % S5 -> S8
    6 1;  % S6 -> S1
    6 4;  % S6 -> S4
    7 8;  % S7 -> S8
    7 2;  % S7 -> S2
    9 4;  % S9 -> S4
    10 2; % S10 -> S2
    10 7; % S10 -> S7
    10 4  % S10 -> S4
];

for i = 1:size(connections, 1)
    connection_matrix(connections(i, 1), connections(i, 2)) = 1;
end

fractional_occupancy = getFractionalOccupancy(gamma_pre, 17612); 

G = digraph(connection_matrix);

figure;
h = plot(G, 'Layout', 'force', 'ArrowSize', 15);

labelnode(h, 1:10, {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10'});

for i = 1:10
    highlight(h, i, 'NodeColor', colors(i, :), 'MarkerSize', fractional_occupancy(i) * 125);
end

for i = 1:numedges(G)
    start_node = G.Edges.EndNodes(i, 1);
    end_node = G.Edges.EndNodes(i, 2);
    
    edge_weight = trans_pre(start_node, end_node);
    line_width = edge_weight * 10;  

    if start_node == 4 || end_node == 4
        highlight(h, start_node, end_node, 'EdgeColor', 'r', 'LineWidth', line_width);
    else
        highlight(h, start_node, end_node, 'EdgeColor', 'b', 'LineWidth', line_width); 
    end
end

axis off;
title('Pre > Post State Transition Graph');

%% Figure 4 - dNBS plot dNBS Post > Pre

connection_matrix = zeros(10, 10);

connections = [
    1 9;  % S1 -> S9
    1 10; % S1 -> S10
    2 10; % S2 -> S10
    2 6;  % S2 -> S6
    3 8;  % S3 -> S8
    3 7;  % S3 -> S7
    4 1;  % S4 -> S1
    4 6;  % S4 -> S6
    6 7;  % S6 -> S7
    6 9;  % S6 -> S9
    6 10; % S6 -> S10
    7 3;  % S7 -> S3
    7 9;  % S7 -> S9
    9 10; % S9 -> S10
    9 5;  % S9 -> S5
    10 3  % S10 -> S3
];

for i = 1:size(connections, 1)
    connection_matrix(connections(i, 1), connections(i, 2)) = 1;
end

fractional_occupancy = getFractionalOccupancy(gamma_post, 17612);

G = digraph(connection_matrix);

figure;
h = plot(G, 'Layout', 'force', 'ArrowSize', 15);

labelnode(h, 1:10, {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10'});

for i = 1:10
    highlight(h, i, 'NodeColor', colors(i, :), 'MarkerSize', fractional_occupancy(i) * 125);
end

for i = 1:numedges(G)
    start_node = G.Edges.EndNodes(i, 1);
    end_node = G.Edges.EndNodes(i, 2);
    
    edge_weight = trans_pre(start_node, end_node);
    line_width = edge_weight * 10;  

    if start_node == 10 || end_node == 10
        highlight(h, start_node, end_node, 'EdgeColor', 'r', 'LineWidth', line_width);
    else
        highlight(h, start_node, end_node, 'EdgeColor', 'b', 'LineWidth', line_width);
    end
end

h.MarkerSize = fractional_occupancy * 125;  

axis off;
title('Post > Pre State Transition Graph');

%% Figure 5 - HMM and Behavior
clc
% Tranisition Probability and behavior
transition_probs_sum = zeros(74, 10);

for i = 1:74
    TP = getTransProbs(dual_hmm(i).hmm_subj);
    transition_probs_sum(i, :) = sum(TP, 1);
end

transition_probs_pre = transition_probs_sum(1:37, :);
transition_probs_post = transition_probs_sum(38:end, :);
p_values_pre = zeros(1, 10);
p_values_post = zeros(1, 10);

% for behavioral data column 1 to 15
for c = 1:15
    behavior = a.behavioral_data(:,c);
    %for state 1 to 10:
    for i = 1:10
        % Pre
        [rho_pre, p_values_pre(i)] = corr(transition_probs_pre(:, i), behavior, 'Type', 'Spearman');
        
        % Post
        [rho_post, p_values_post(i)] = corr(transition_probs_post(:, i), behavior, 'Type', 'Spearman');
    end

    % FDR correction
    adj_p_values_pre = mafdr(p_values_pre, 'BHFDR', true);
    adj_p_values_post = mafdr(p_values_post, 'BHFDR', true);

    sprintf("---------------For behavioral data Column %d-----------------------", c)
    disp('Pre-scan correlation p value (no correction):');
    disp(p_values_pre);
    disp('Pre-scan correlation p value (FDR correction):');
    disp(adj_p_values_pre);

    disp('Post-scan correlation p value (no correction):');
    disp(p_values_post);
    disp('Post-scan correlation p value (FDR correction):');
    disp(adj_p_values_post);
end

%% Figure 5 - HMM and Behavior
% Visualize TP and Lie rate (All)

transition_probs_post_state10 = transition_probs_post(:, 10);
behavior = a.behavioral_data(:,1); % change this to graph the behavior you want

figure;
scatter(transition_probs_post_state10, behavior, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('Cumulative Transition Probability to State 10)');
ylabel('Lie Rate');
title('Transition to State 10 and Lie Rate (Post-scan)');
box off;
grid on; 

hold on;
p = polyfit(transition_probs_post_state10, behavior, 1);
yfit = polyval(p, transition_probs_post_state10);
plot(transition_probs_post_state10, yfit, '-r', 'LineWidth', 2);

n = length(behavior);
y_resid = behavior - yfit;
SS_resid = sum(y_resid.^2);
SS_total = (n-1) * var(behavior);
r2 = 1 - SS_resid/SS_total;

s_err = sqrt(SS_resid / (n - 2));
x_fit = linspace(min(transition_probs_post_state10), max(transition_probs_post_state10), 100);
y_fit = polyval(p, x_fit);
conf = tinv(0.975, n - 2) * s_err * sqrt(1/n + (x_fit - mean(transition_probs_post_state10)).^2 / ((n - 1) * var(transition_probs_post_state10)));

plot(x_fit, y_fit + conf, '--r', 'LineWidth', 1);
plot(x_fit, y_fit - conf, '--r', 'LineWidth', 1);

%% Figure 5 - HMM and Behavior
% Mean Interval time and behavior
clc
close all
for i = 1:74
    vpath_subj = dual_hmm(i).vpath_subj;
    intervals = getStateIntervalTimes(vpath_subj, T_subj(i), options);
    for k = 1:10
        if ~isempty(intervals{k})
            mean_interval_time(i, k) = mean(intervals{k});
        end
    end
end

mean_interval_time_pre = mean_interval_time(1:37, :);
mean_interval_time_post = mean_interval_time(38:end, :);
p_values_pre = zeros(1, 10);
p_values_post = zeros(1, 10);

% for behavioral data column 1 to 15
for c = 1:4
    behavior = a.behavioral_data(:,c);
    %for state 1 to 10:
    for i = 1:10
        % Pre
        [rho_pre, p_values_pre(i)] = corr(mean_interval_time_pre(:, i), behavior, 'Type', 'Spearman');
        
        % Post
        [rho_post, p_values_post(i)] = corr(mean_interval_time_post(:, i), behavior, 'Type', 'Spearman');
    end

    % FDR correction
    adj_p_values_pre = mafdr(p_values_pre, 'BHFDR', true);
    adj_p_values_post = mafdr(p_values_post, 'BHFDR', true);

    sprintf("---------------For behavioral data Column %d-----------------------", c)
    disp('Pre-scan correlation p value (no correction):');
    disp(p_values_pre);
    disp('Pre-scan correlation p value (FDR correction):');
    disp(adj_p_values_pre);

    disp('Post-scan correlation p value (no correction):');
    disp(p_values_post);
    disp('Post-scan correlation p value (FDR correction):');
    disp(adj_p_values_post);
end

%% Figure 5 - HMM and Behavior
% Visualize Interval time (pre and post) and Lie rate (All)
% Pre:
interval_time_pre_state10 = mean_interval_time(1:37, 10);
behavior = a.behavioral_data(:,1); % change this to graph the behavior you want

figure;
scatter(interval_time_pre_state10, behavior, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('Interval Time of State 10 (Pre-scan)');
ylabel('Lie Rate');
title('Interval Time of State 10 and Lie Rate (Pre-scan)');
box off;
grid on;

hold on;
p_pre = polyfit(interval_time_pre_state10, behavior, 1);
yfit_pre = polyval(p_pre, interval_time_pre_state10);
plot(interval_time_pre_state10, yfit_pre, '-r', 'LineWidth', 2);

n_pre = length(behavior);
y_resid_pre = behavior - yfit_pre;
SS_resid_pre = sum(y_resid_pre.^2);
s_err_pre = sqrt(SS_resid_pre / (n_pre - 2));
x_fit_pre = linspace(min(interval_time_pre_state10), max(interval_time_pre_state10), 100);
y_fit_pre = polyval(p_pre, x_fit_pre);
conf_pre = tinv(0.975, n_pre - 2) * s_err_pre * sqrt(1/n_pre + (x_fit_pre - mean(interval_time_pre_state10)).^2 / ((n_pre - 1) * var(interval_time_pre_state10)));

plot(x_fit_pre, y_fit_pre + conf_pre, '--r', 'LineWidth', 1);
plot(x_fit_pre, y_fit_pre - conf_pre, '--r', 'LineWidth', 1);
hold off;

% Post:
interval_time_post_state10 = mean_interval_time(38:74, 10);

figure;
scatter(interval_time_post_state10, behavior, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('Interval Time of State 10 (Post-scan)');
ylabel('Lie Rate');
title('Interval Time of State 10 and Lie Rate (Post-scan)');
box off;
grid on;

hold on;
p_post = polyfit(interval_time_post_state10, behavior, 1);
yfit_post = polyval(p_post, interval_time_post_state10);
plot(interval_time_post_state10, yfit_post, '-r', 'LineWidth', 2);

n_post = length(behavior);
y_resid_post = behavior - yfit_post;
SS_resid_post = sum(y_resid_post.^2);
s_err_post = sqrt(SS_resid_post / (n_post - 2));
x_fit_post = linspace(min(interval_time_post_state10), max(interval_time_post_state10), 100);
y_fit_post = polyval(p_post, x_fit_post);
conf_post = tinv(0.975, n_post - 2) * s_err_post * sqrt(1/n_post + (x_fit_post - mean(interval_time_post_state10)).^2 / ((n_post - 1) * var(interval_time_post_state10)));

plot(x_fit_post, y_fit_post + conf_post, '--r', 'LineWidth', 1);
plot(x_fit_post, y_fit_post - conf_post, '--r', 'LineWidth', 1);
hold off;

%% Figure 5 - HMM and Behavior
% Entropy and behavior
clc
Ent_rate = zeros(74, 1); 
for i = 1:74
    TP = getTransProbs(dual_hmm(i).hmm_subj);
    FO_data = FO(i, :); 
    Ent_state = zeros(10, 1);
    for s = 1:10
        P = TP(s, :); 
        Ent_state(s) = -sum(P .* log(P + eps));  
    end
    Ent_rate(i) = sum(FO_data .* Ent_state');
end

Ent_rate_pre = Ent_rate(1:37);
Ent_rate_post = Ent_rate(38:end);
p_values_pre = zeros(1, 10);
p_values_post = zeros(1, 10);

% for behavioral data column 5 to 8
for c = 5:8
    behavior = a.behavioral_data(:,c);
% Pre
[rho_pre, p_values_pre] = corr(Ent_rate_pre, behavior, 'Type', 'Spearman');
[rho_post, p_values_post] = corr(Ent_rate_post, behavior, 'Type', 'Spearman');

sprintf("---------------For behavioral data Column %d-----------------------", c)
disp('Pre-scan correlation p value:');
disp(p_values_pre);

disp('Post-scan correlation p value:');
disp(p_values_post);
end

%% Figure 5 - HMM and Behavior
% Visualize Entropy and behavioral entropy (lie enhanced)

behavior = a.behavioral_data(:,6); % change this to graph the behavior you want

figure;
scatter(Ent_rate_pre, behavior, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('HMM Entropy rate (Pre-scan)');
ylabel('Entropy(lie enhanced)');
title('HMM Entropy rate vs Entropy (Pre-scan)');
box off;
grid on;


hold on;
p_pre = polyfit(Ent_rate_pre, behavior, 1);
yfit_pre = polyval(p_pre, Ent_rate_pre);
plot(Ent_rate_pre, yfit_pre, '-r', 'LineWidth', 2);

n_pre = length(behavior);
y_resid_pre = behavior - yfit_pre;
SS_resid_pre = sum(y_resid_pre.^2);
s_err_pre = sqrt(SS_resid_pre / (n_pre - 2));
x_fit_pre = linspace(min(Ent_rate_pre), max(Ent_rate_pre), 100);
y_fit_pre = polyval(p_pre, x_fit_pre);
conf_pre = tinv(0.975, n_pre - 2) * s_err_pre * sqrt(1/n_pre + (x_fit_pre - mean(Ent_rate_pre)).^2 / ((n_pre - 1) * var(Ent_rate_pre)));

plot(x_fit_pre, y_fit_pre + conf_pre, '--r', 'LineWidth', 1);
plot(x_fit_pre, y_fit_pre - conf_pre, '--r', 'LineWidth', 1);
hold off;

%% Figure 5 - HMM and Behavior
% Switching Rate and model parameter

clc

switching_rate_pre = switching_rate(1:37);
switching_rate_post = switching_rate(38:end);
p_values_pre = zeros(1, 10);
p_values_post = zeros(1, 10);

% for behavioral data column 5 to 8
for c = 9:15
    behavior = a.behavioral_data(:,c);
% Pre
[rho_pre, p_values_pre] = corr(switching_rate_pre, behavior, 'Type', 'Spearman');
[rho_post, p_values_post] = corr(switching_rate_post, behavior, 'Type', 'Spearman');

sprintf("---------------For behavioral data Column %d-----------------------", c)
disp('Pre-scan correlation p value:');
disp(p_values_pre);

disp('Post-scan correlation p value:');
disp(p_values_post);
end

%% Figure 5 - HMM and Behavior
% Visualize Switching Rate and model parameter v_former_diff, v_former_diff_ses

for i = [9,11] % v former diff and v former diff ses
    behavior = a.behavioral_data(:,i);
    figure;
    scatter(switching_rate_pre, behavior, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
    xlabel('Switching Rate');
    if i == 9
        ylabel('v former diff');
        title('Switching Rate vs v former diff (Pre-scan)');
    elseif i == 11
        ylabel('v former diff ses');
        title('Switching Rate vs v former diff ses (Pre-scan)');        
    end
    box off;
    grid on;
    
    hold on;
    p_pre = polyfit(switching_rate_pre, behavior, 1);
    yfit_pre = polyval(p_pre, switching_rate_pre);
    plot(switching_rate_pre, yfit_pre, '-r', 'LineWidth', 2);
    
    n_pre = length(behavior);
    y_resid_pre = behavior - yfit_pre;
    SS_resid_pre = sum(y_resid_pre.^2);
    s_err_pre = sqrt(SS_resid_pre / (n_pre - 2));
    x_fit_pre = linspace(min(switching_rate_pre), max(switching_rate_pre), 100);
    y_fit_pre = polyval(p_pre, x_fit_pre);
    conf_pre = tinv(0.975, n_pre - 2) * s_err_pre * sqrt(1/n_pre + (x_fit_pre - mean(switching_rate_pre)).^2 / ((n_pre - 1) * var(switching_rate_pre)));
    
    plot(x_fit_pre, y_fit_pre + conf_pre, '--r', 'LineWidth', 1);
    plot(x_fit_pre, y_fit_pre - conf_pre, '--r', 'LineWidth', 1);
    hold off;
end

%% Figure 6 Task fMRI and Rest HMM

% read Excel 
file_path = 'input_data\Task\activation_data.xlsx'; 

elie_data = readtable(file_path, 'Sheet', 'elie');
ehon_data = readtable(file_path, 'Sheet', 'ehon');
erand_data = readtable(file_path, 'Sheet', 'erand');
eall_data = readtable(file_path, 'Sheet', 'eall');

elie_data = rmmissing(elie_data);
ehon_data = rmmissing(ehon_data);
erand_data = rmmissing(erand_data);
eall_data = rmmissing(eall_data);

% Let's start to compare Task fMRI activation and rest activation
p_values_group = zeros(10, 1);
significant_states = cell(10, 1);
direction = cell(10, 1); 

% Which should we use?
task_fmri = eall_data;

all_hmm_states_data = zeros(37, 33, 10);

for subj_id = 1:37    
    getMean_data = getMean(dual_hmm(subj_id + 37).hmm_subj);
    all_hmm_states_data(subj_id, :, :) = getMean_data;
end

for state = 1:10
    hmm_state_group_data = squeeze(all_hmm_states_data(:, :, state));
    
    task_fmri_data = reshape(task_fmri{:, 2:end}, [], 1);  % 37 x 33 -> 1221 x 1
    hmm_state_group_data_flat = reshape(hmm_state_group_data, [], 1);  % 37 x 33 -> 1221 x 1
    
    [p, h, stats] = signrank(task_fmri_data, hmm_state_group_data_flat);   
    p_values_group(state) = p;
    
    % Direction
    mean_task_fmri = mean(task_fmri_data);
    mean_hmm = mean(hmm_state_group_data_flat);
    
    if mean_hmm > mean_task_fmri
        direction{state} = 'Increase';  % if HMM increase compare to task
    elseif mean_hmm < mean_task_fmri
        direction{state} = 'Decrease';  % if HMM decrease compare to task
    end
    
    % only show significant
    if p < 0.05
        significant_states{state} = sprintf('State %d is significant with p-value: %.4f, Direction: %s', state, p, direction{state});
    end
end

disp('significant:');
for state = 1:10
    if ~isempty(significant_states{state})
        disp(significant_states{state});
    end
end

% fdr correction
p_values_vector = p_values_group(:);

[~, ~, ~, adj_p_values] = fdr_bh(p_values_vector);

disp('FDR corrected significant states:');
for state = 1:10
    if adj_p_values(state) < 0.05
        fprintf('State %d is significant after FDR correction with p-value: %.4f, Direction: %s\n', ...
                state, adj_p_values(state), direction{state});
    end
end

%% Figure 6 Task fMRI and Rest HMM

% Colors
colors = lines(2);

for state = 1:10
    hmm_state_group_data = squeeze(all_hmm_states_data(:, :, state));
    eall_group_data_flat = reshape(task_fmri{:, 2:end}, [], 1);  % 37 x 33 -> 1221 x 1
    hmm_state_group_data_flat = reshape(hmm_state_group_data, [], 1);  % 37 x 33 -> 1221 x 1
    
    [p, h, stats] = signrank(eall_group_data_flat, hmm_state_group_data_flat);
    
    p_values_group(state) = p;
    
    % Graph!
    figure;
    hold on;

    errorbar(1, mean(eall_group_data_flat), std(eall_group_data_flat)/sqrt(length(eall_group_data_flat)), 'o', ...
        'Color', colors(1,:), 'MarkerFaceColor', colors(1,:), 'LineWidth', 1.5);
    
    errorbar(1.2, mean(hmm_state_group_data_flat), std(hmm_state_group_data_flat)/sqrt(length(hmm_state_group_data_flat)), 'o', ...
        'Color', colors(2,:), 'MarkerFaceColor', colors(2,:), 'LineWidth', 1.5);
    set(gca, 'XTick', [1 1.2], 'XTickLabel', {'Task', 'Post'});
    xlim([0.9 1.3]);

    set(gca, 'TickLength', [0 0]);

    ylim([min(mean([eall_group_data_flat; hmm_state_group_data_flat]) - std([eall_group_data_flat; hmm_state_group_data_flat])/sqrt(length([eall_group_data_flat; hmm_state_group_data_flat]))) - 0.1, ...
          max(mean([eall_group_data_flat; hmm_state_group_data_flat]) + std([eall_group_data_flat; hmm_state_group_data_flat])/sqrt(length([eall_group_data_flat; hmm_state_group_data_flat]))) + 0.1]);

    title(sprintf('State %d', state));
    xlabel('Condition');
    ylabel('Activation Level');
    
    hold off;
end


%% Table 1: 33 brain area activation changes in each state (Rest fMRI HMM vs Task fMRI)
close all

brain_area_names  = { ...
    'HIP-rh', 'AMY-rh', 'pTHA-rh', 'aTHA-rh', 'NAc-rh', 'GP-rh', 'PUT-rh', 'CAU-rh', ...
    'HIP-lh', 'AMY-lh', 'pTHA-lh', 'aTHA-lh', 'NAc-lh', 'GP-lh', 'PUT-lh', 'CAU-lh', ...
    'VisCent', 'VisPeri', 'SomMot A', 'SomMot B', 'DorsAttn A', 'DorsAttn B', ...
    'SalVentAttn A', 'SalVentAttn B', 'Limbic A', 'Limbic B', 'Cont A', 'Cont B', ...
    'Cont C', 'Default A', 'Default B', 'Default C', 'TempPar' ...
};

hmm_post_states_data = zeros(37, 33, 10);  


for subj_id = 1:37
    getMean_post = getMean(dual_hmm(subj_id + 37).hmm_subj); 
    hmm_post_states_data(subj_id, :, :) = getMean_post;  
end


mean_task_fmri = task_fmri{:, 2:end}; 


p_values = zeros(33, 10); 

for state = 1:10
    significant_results = cell(33, 5); 
    
    row_index = 1;  
    for brain_area = 1:33
        post_data = hmm_post_states_data(:, brain_area, state); 
        task_data = mean_task_fmri(:, brain_area);
        
        [p_post_task, ~] = signrank(post_data, task_data); 
        

        p_values(brain_area, state) = p_post_task;
    end
    
    p_values_vector = p_values(:, state); 

    [~, ~, ~, adj_p_values_vector] = fdr_bh(p_values_vector);
    
    for brain_area = 1:33
        if adj_p_values_vector(brain_area) < 0.05
            task_mean = mean(mean_task_fmri(:, brain_area));
            post_mean = mean(hmm_post_states_data(:, brain_area, state));
            
            if isempty(task_mean), task_mean = NaN; end
            if isempty(post_mean), post_mean = NaN; end
            
            if post_mean > task_mean
                direction = 'Increase';  
            elseif post_mean < task_mean
                direction = 'Decrease'; 
            else
                direction = 'No Change';  
            end
            
            significant_results{row_index, 1} = brain_area_names{brain_area}; 
            significant_results{row_index, 2} = task_mean;
            significant_results{row_index, 3} = post_mean;  
            significant_results{row_index, 4} = adj_p_values_vector(brain_area); 
            significant_results{row_index, 5} = direction;  
            
            row_index = row_index + 1;
        end
    end
    
    % Convert cell to table and write to CSV
    output_folder = 'output_HMM/Task';
    result_table = cell2table(significant_results(1:row_index-1, :), 'VariableNames', {'Brain_Area', 'Task_Activation', 'Post_Activation', 'FDR_p_value', 'Direction'});
    
    output_filename = sprintf('%s/State_%d_Significant_Brain_Areas.csv', output_folder, state);
    writetable(result_table, output_filename);
    
    fprintf('State %d Significant brain area is saved to "%s"\n', state, output_filename);
end

%% Figure 6 Task fMRI and Rest HMM IS-RSA analysis
clc
HMM_pre_data = zeros(37, 33);
HMM_post_data = zeros(37, 33);

for subj_id = 1:37
    HMM_pre_data(subj_id, :) = mean(getMean(dual_hmm(subj_id).hmm_subj), 2);
    HMM_post_data(subj_id, :) = mean(getMean(dual_hmm(subj_id + 37).hmm_subj), 2);
end

HMM_pre_similarity_matrix = corr(HMM_pre_data');
HMM_post_similarity_matrix = corr(HMM_post_data');
task_activation_data = elie_data{:, 2:end};
task_activation_similarity_matrix = corr(task_activation_data');

lower_triangular_indices = find(tril(ones(37), -1));
HMM_pre_distances = 1 - HMM_pre_similarity_matrix(lower_triangular_indices);
HMM_post_distances = 1 - HMM_post_similarity_matrix(lower_triangular_indices);
task_activation_distances = 1 - task_activation_similarity_matrix(lower_triangular_indices); 

[correlation_pre, p_value_pre] = corr(HMM_pre_distances, task_activation_distances, 'Type', 'Pearson');
[correlation_post, p_value_post] = corr(HMM_post_distances, task_activation_distances, 'Type', 'Pearson');

num_permutations = 5000;
permuted_correlations_pre = zeros(num_permutations, 1);
permuted_correlations_post = zeros(num_permutations, 1);

for perm = 1:num_permutations
    permuted_task_activation_distances = task_activation_distances(randperm(length(task_activation_distances)));
    
    permuted_correlations_pre(perm) = corr(HMM_pre_distances, permuted_task_activation_distances, 'Type', 'Pearson');
    
    permuted_correlations_post(perm) = corr(HMM_post_distances, permuted_task_activation_distances, 'Type', 'Pearson');
end

mean_permuted_corr_pre = mean(permuted_correlations_pre);
std_permuted_corr_pre = std(permuted_correlations_pre);
p_value_permutation_pre = mean(permuted_correlations_pre >= correlation_pre);

mean_permuted_corr_post = mean(permuted_correlations_post);
std_permuted_corr_post = std(permuted_correlations_post);
p_value_permutation_post = mean(permuted_correlations_post >= correlation_post);

fprintf('HMM_pre and Task correlation: %.4f, Permutation p value: %.4f\n', correlation_pre, p_value_permutation_pre);
fprintf('HMM_post and Task correlation: %.4f, Permutation p value: %.4f\n', correlation_post, p_value_permutation_post);

%% Figure 6 Task fMRI and Rest HMM IS-RSA analysis

% HMM Pre RSA matrix
figure;
imagesc(HMM_pre_similarity_matrix);
colorbar;
title('HMM Pre Similarity Matrix');
xlabel('Subjects');
ylabel('Subjects');
axis square;

% HMM post RSA matrix
figure;
imagesc(HMM_post_similarity_matrix); 
colorbar;
title('HMM Post Similarity Matrix');
xlabel('Subjects');
ylabel('Subjects');
axis square;

% Task RSA matrix
figure;
imagesc(task_activation_similarity_matrix); 
colorbar;
title('Task Activation Similarity Matrix');
xlabel('Subjects');
ylabel('Subjects');
axis square;

% Correlation graph Pre and Task
figure;
scatter(HMM_pre_distances, task_activation_distances, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('HMM Pre Distances');
ylabel('Task Activation Distances');
title(sprintf('r = %.3f, PVAL = %.3f', correlation_pre, p_value_pre));
box off;
grid on;

hold on;
p_pre = polyfit(HMM_pre_distances, task_activation_distances, 1);
yfit_pre = polyval(p_pre, HMM_pre_distances);
plot(HMM_pre_distances, yfit_pre, '-r', 'LineWidth', 2);

n_pre = length(task_activation_distances);
y_resid_pre = task_activation_distances - yfit_pre;
SS_resid_pre = sum(y_resid_pre.^2);
s_err_pre = sqrt(SS_resid_pre / (n_pre - 2));
x_fit_pre = linspace(min(HMM_pre_distances), max(HMM_pre_distances), 100);
y_fit_pre = polyval(p_pre, x_fit_pre);
conf_pre = tinv(0.975, n_pre - 2) * s_err_pre * sqrt(1/n_pre + (x_fit_pre - mean(HMM_pre_distances)).^2 / ((n_pre - 1) * var(HMM_pre_distances)));

plot(x_fit_pre, y_fit_pre + conf_pre, '--r', 'LineWidth', 1);
plot(x_fit_pre, y_fit_pre - conf_pre, '--r', 'LineWidth', 1);
hold off;

% Correlation graph Post and Task

figure;
scatter(HMM_post_distances, task_activation_distances, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g');
xlabel('HMM Post Distances');
ylabel('Task Activation Distances');
title(sprintf('r = %.3f, PVAL = %.3f', correlation_post, p_value_post));
box off;
grid on;

hold on;
p_post = polyfit(HMM_post_distances, task_activation_distances, 1);
yfit_post = polyval(p_post, HMM_post_distances);
plot(HMM_post_distances, yfit_post, '-r', 'LineWidth', 2);

n_post = length(task_activation_distances);
y_resid_post = task_activation_distances - yfit_post;
SS_resid_post = sum(y_resid_post.^2);
s_err_post = sqrt(SS_resid_post / (n_post - 2));
x_fit_post = linspace(min(HMM_post_distances), max(HMM_post_distances), 100);
y_fit_post = polyval(p_post, x_fit_post);
conf_post = tinv(0.975, n_post - 2) * s_err_post * sqrt(1/n_post + (x_fit_post - mean(HMM_post_distances)).^2 / ((n_post - 1) * var(HMM_post_distances)));

plot(x_fit_post, y_fit_post + conf_post, '--r', 'LineWidth', 1);
plot(x_fit_post, y_fit_post - conf_post, '--r', 'LineWidth', 1);
hold off;

%% Figure 7 Rest HMM and Behavior IS-RSA
%FO and behavior
for c = 1:15
    behavior = a.behavioral_data(1:37,c); % change this to select which behaivor measure
    
    % FO_pre and FO_post RSA
    FO_pre_similarity_matrix = corr(FO_pre'); 
    FO_post_similarity_matrix = corr(FO_post');
    
    % distance matrix (1-correlation)
    FO_pre_distance_matrix = 1 - FO_pre_similarity_matrix;
    FO_post_distance_matrix = 1 - FO_post_similarity_matrix;
    
    % behavioral data 
    behavior_distance_matrix = squareform(pdist(behavior, 'euclidean'));  
    
    % Peason correlation
    lower_triangular_indices = find(tril(ones(37), -1));  
    FO_pre_distances = FO_pre_distance_matrix(lower_triangular_indices);
    FO_post_distances = FO_post_distance_matrix(lower_triangular_indices); 
    behavior_distances = behavior_distance_matrix(lower_triangular_indices); 
    
    [correlation_pre, p_value_pre] = corr(FO_pre_distances, behavior_distances, 'Type', 'Pearson');
    [correlation_post, p_value_post] = corr(FO_post_distances, behavior_distances, 'Type', 'Pearson');
    
    % 5. Permutation 
    num_permutations = 5000; %5000 permutation test
    permuted_correlations_pre = zeros(num_permutations, 1);
    permuted_correlations_post = zeros(num_permutations, 1);
    
    for perm = 1:num_permutations
        permuted_behavior_distances = behavior_distances(randperm(length(behavior_distances)));
        permuted_correlations_pre(perm) = corr(FO_pre_distances, permuted_behavior_distances, 'Type', 'Pearson');
        permuted_correlations_post(perm) = corr(FO_post_distances, permuted_behavior_distances, 'Type', 'Pearson');
    end
    
    % FO pre p value 
    mean_permuted_corr_pre = mean(permuted_correlations_pre);
    std_permuted_corr_pre = std(permuted_correlations_pre);
    p_value_permutation_pre = mean(permuted_correlations_pre >= correlation_pre);
    
    % FO post p value 
    mean_permuted_corr_post = mean(permuted_correlations_post);
    std_permuted_corr_post = std(permuted_correlations_post);
    p_value_permutation_post = mean(permuted_correlations_post >= correlation_post);
    
    sprintf("---------------For behavioral data Column %d-----------------------", c)
    fprintf('FO_pre correlation: %.4f, Permutation p value: %.4f\n', correlation_pre, p_value_permutation_pre);
    fprintf('FO_Post correlation: %.4f, Permutation p value: %.4f\n', correlation_post, p_value_permutation_post);

end

%% Figure 7 Rest HMM and Behavior IS-RSA

% Get TP for every participant
n_subjects = 74;
n_states = 10;
trans_pre = zeros(37, n_states, n_states);
trans_post = zeros(37, n_states, n_states);

for i = 1:n_subjects
    TP = getTransProbs(dual_hmm(i).hmm_subj);
    if i <= 37
        trans_pre(i, :, :) = TP;
    else
        trans_post(i-37, :, :) = TP;
    end
end

for c = 1:15
    behavior = a.behavioral_data(1:37,c);
    
    distance_matrix_pre = zeros(74, 74);
    distance_matrix_post = zeros(74, 74);
    
    for i = 1:37
        for j = i+1:37
            matrix_i_pre = squeeze(trans_pre(i, :, :));  % participant i Pre TP
            matrix_j_pre = squeeze(trans_pre(j, :, :));  % participant j Pre TP
            
            matrix_i_post = squeeze(trans_post(i, :, :));  % i's Post TP
            matrix_j_post = squeeze(trans_post(j, :, :));  % j's Post TP
            
            matrix_i_pre(logical(eye(10))) = NaN;
            matrix_j_pre(logical(eye(10))) = NaN;
            matrix_i_post(logical(eye(10))) = NaN;
            matrix_j_post(logical(eye(10))) = NaN;
            vector_i_pre = matrix_i_pre(~isnan(matrix_i_pre));
            vector_j_pre = matrix_j_pre(~isnan(matrix_j_pre));
            vector_i_post = matrix_i_post(~isnan(matrix_i_post));
            vector_j_post = matrix_j_post(~isnan(matrix_j_post));
            
            distance_matrix_pre(i, j) = 1 - corr(vector_i_pre, vector_j_pre, 'Type', 'Pearson');
            distance_matrix_post(i, j) = 1 - corr(vector_i_post, vector_j_post, 'Type', 'Pearson');
            
            distance_matrix_pre(j, i) = distance_matrix_pre(i, j);
            distance_matrix_post(j, i) = distance_matrix_post(i, j);
        end
    end
    
    behavior_distance_matrix = squareform(pdist(behavior, 'euclidean'));
    
    lower_triangular_indices = find(tril(ones(37), -1));  % 下三角索引
    
    distances_pre = distance_matrix_pre(lower_triangular_indices);
    distances_post = distance_matrix_post(lower_triangular_indices);
    behavior_distances = behavior_distance_matrix(lower_triangular_indices);
    
    [correlation_pre, p_value_pre] = corr(distances_pre, behavior_distances, 'Type', 'Pearson');
    [correlation_post, p_value_post] = corr(distances_post, behavior_distances, 'Type', 'Pearson');
    
    % Permutaiton test
    num_permutations = 5000;
    
    perm_rho_pre = zeros(1, num_permutations);
    perm_rho_post = zeros(1, num_permutations);
    
    for perm = 1:num_permutations
        permuted_behavior = behavior(randperm(37));
        
        permuted_behavior_distance_matrix = squareform(pdist(permuted_behavior, 'euclidean'));
        permuted_behavior_distances = permuted_behavior_distance_matrix(lower_triangular_indices);
        
        perm_rho_pre(perm) = corr(distances_pre, permuted_behavior_distances, 'Type', 'Pearson');
        perm_rho_post(perm) = corr(distances_post, permuted_behavior_distances, 'Type', 'Pearson');
    end
    
    p_value_permutation_pre = mean(abs(perm_rho_pre) >= abs(correlation_pre));
    p_value_permutation_post = mean(abs(perm_rho_post) >= abs(correlation_post));

    sprintf("---------------For behavioral data Column %d-----------------------", c)
    fprintf('FO_pre correlation: %.4f, Permutation p value: %.4f\n', correlation_pre, p_value_permutation_pre);
    fprintf('FO_Post correlation: %.4f, Permutation p value: %.4f\n', correlation_post, p_value_permutation_post);
end

%% Figure 7 Rest HMM and Behavior IS-RSA

% Graph:
% 1. FO pre, State TP Pre, Entropy and Lie rate (Random) RSA Matrix
% 2. FO Pre and Lie (random)
% 3. FO Pre and Entropy (random)
% 4. State Transition Pre and Lie (random)

% Graph 1
% FO Pre RSA matrix 
figure;
FO_pre_similarity_matrix_upper = triu(FO_pre_similarity_matrix, 1);
FO_pre_similarity_matrix_upper(FO_pre_similarity_matrix_upper == 0) = NaN;
imagesc(FO_pre_similarity_matrix_upper);
colorbar;
title('FO Matrix (Pre-scan)');
xlabel('Subjects');
ylabel('Subjects');
axis square;

% State Transition Pre RSA matrix
figure;
trans_pre_similarity_matrix = corr(trans_pre(:,:)'); 
trans_pre_similarity_matrix_upper = triu(trans_pre_similarity_matrix, 1); 
trans_pre_similarity_matrix_upper(trans_pre_similarity_matrix_upper == 0) = NaN; 
imagesc(trans_pre_similarity_matrix_upper);
colorbar;
title('State Transition Matrix (Pre-scan)');
xlabel('Subjects');
ylabel('Subjects');
axis square;

% Lie Rate Random
figure;
behavior_distance_matrix = squareform(pdist(a.behavioral_data(1:37,4), 'euclidean'));
lie_rate_distance_matrix_tril = tril(behavior_distance_matrix, -1); 
lie_rate_distance_matrix_tril(lie_rate_distance_matrix_tril == 0) = NaN; 
imagesc(lie_rate_distance_matrix_tril); 
colorbar;
title('Lie Rate Matrix (Random Enhanced)');
xlabel('Subjects');
ylabel('Subjects');
axis square;

% Entropy Random
figure;
behavior_distance_matrix = squareform(pdist(a.behavioral_data(1:37,8), 'euclidean'));
Entropy_distance_matrix_tril = tril(behavior_distance_matrix, -1);  
Entropy_distance_matrix_tril(Entropy_distance_matrix_tril == 0) = NaN; 
imagesc(Entropy_distance_matrix_tril);
colorbar;
title('Entropy Matrix (Random Enhanced)');
xlabel('Subjects');
ylabel('Subjects');
axis square;

% Graph 2 FO and Lie rate

FO_pre_similarity_matrix = corr(FO_pre'); 

FO_pre_distance_matrix = 1 - FO_pre_similarity_matrix;
lower_triangular_indices = find(tril(ones(size(FO_pre_distance_matrix)), -1)); 
distances_FO_pre = FO_pre_distance_matrix(lower_triangular_indices);

behavior_distance_matrix = squareform(pdist(a.behavioral_data(1:37,4), 'euclidean'));  
distances_behavior = behavior_distance_matrix(lower_triangular_indices);

figure;
scatter(distances_FO_pre, distances_behavior, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('FO Pre Distances');
ylabel('Lie Rate Distances');
title('r = 0.1099, Perm PVAL = 0.0028');
box off;
grid on;

hold on;
p = polyfit(distances_FO_pre, distances_behavior, 1);
yfit_pre = polyval(p, distances_FO_pre);
plot(distances_FO_pre, yfit_pre, '-r', 'LineWidth', 2);

n = length(distances_behavior);
y_resid = distances_behavior - yfit_pre;
SS_resid = sum(y_resid.^2);
s_err = sqrt(SS_resid / (n - 2));
x_fit = linspace(min(distances_FO_pre), max(distances_FO_pre), 100);
y_fit = polyval(p, x_fit);
conf_pre = tinv(0.975, n - 2) * s_err * sqrt(1/n + (x_fit - mean(distances_FO_pre)).^2 / ((n - 1) * var(distances_FO_pre)));

plot(x_fit, y_fit + conf_pre, '--r', 'LineWidth', 1);
plot(x_fit, y_fit - conf_pre, '--r', 'LineWidth', 1);
hold off;

% Graph 3 FO and Entropy
FO_pre_similarity_matrix = corr(FO_pre'); 

FO_pre_distance_matrix = 1 - FO_pre_similarity_matrix;
lower_triangular_indices = find(tril(ones(size(FO_pre_distance_matrix)), -1)); 
distances_FO_pre = FO_pre_distance_matrix(lower_triangular_indices);  

behavior_distance_matrix = squareform(pdist(a.behavioral_data(1:37,8), 'euclidean'));  
distances_behavior = behavior_distance_matrix(lower_triangular_indices);

figure;
scatter(distances_FO_pre, distances_behavior, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('FO Pre Distances');
ylabel('Entropy Distances');
title('r = 0.1146, Perm PVAL = 0.0012');
box off;
grid on;

hold on;
p = polyfit(distances_FO_pre, distances_behavior, 1);
yfit_pre = polyval(p, distances_FO_pre);
plot(distances_FO_pre, yfit_pre, '-r', 'LineWidth', 2);

n = length(distances_behavior);
y_resid = distances_behavior - yfit_pre;
SS_resid = sum(y_resid.^2);
s_err = sqrt(SS_resid / (n - 2));
x_fit = linspace(min(distances_FO_pre), max(distances_FO_pre), 100);
y_fit = polyval(p, x_fit);
conf_pre = tinv(0.975, n - 2) * s_err * sqrt(1/n + (x_fit - mean(distances_FO_pre)).^2 / ((n - 1) * var(distances_FO_pre)));

plot(x_fit, y_fit + conf_pre, '--r', 'LineWidth', 1);
plot(x_fit, y_fit - conf_pre, '--r', 'LineWidth', 1);
hold off;

% Graph 4 Trans and Lie rate
trans_pre_similarity_matrix = corr(trans_pre(:,:)');

distance_matrix_pre = 1 - trans_pre_similarity_matrix;  
lower_triangular_indices = find(tril(ones(size(distance_matrix_pre)), -1)); 
distances_HMM = distance_matrix_pre(lower_triangular_indices);  

behavior_distance_matrix = squareform(pdist(a.behavioral_data(1:37,4), 'euclidean'));
distances_behavior = behavior_distance_matrix(lower_triangular_indices); 

figure;
scatter(distances_HMM, distances_behavior, 'filled', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('State Transition Distances');
ylabel('Lie Rate Distances');
title('r = 0.120, Perm PVAL = 0.038');
box off;
grid on;

hold on;
p = polyfit(distances_HMM, distances_behavior, 1);
yfit_pre = polyval(p, distances_HMM);
plot(distances_HMM, yfit_pre, '-r', 'LineWidth', 2);

n = length(distances_behavior);
y_resid = distances_behavior - yfit_pre;
SS_resid = sum(y_resid.^2);
s_err = sqrt(SS_resid / (n - 2));
x_fit = linspace(min(distances_HMM), max(distances_HMM), 100);
y_fit = polyval(p, x_fit);
conf_pre = tinv(0.975, n - 2) * s_err * sqrt(1/n + (x_fit - mean(distances_HMM)).^2 / ((n - 1) * var(distances_HMM)));

plot(x_fit, y_fit + conf_pre, '--r', 'LineWidth', 1);
plot(x_fit, y_fit - conf_pre, '--r', 'LineWidth', 1);
hold off;

