%% ---------------- 1. Load data ----------------
clear
load('data.mat')
load('K_4_HMM_pca80.mat','Gamma','hmm','vpath')

options = struct();
options.order = 0; 
options.zeromean = 0;
options.covtype = 'full'; 
options.Fs = 1; 
options.verbose = 1;
options.dropstates = 1;
options.standardise = 1;
options.detrend = 1;
options.inittype = 'HMM-MAR';
options.cyc = 1000;
options.initcyc = 1000;
options.initrep = 300;
options.pca = 0.8;

%% ----------------  2. Explore HMM metrics (FO) ----------------

FO = getFractionalOccupancy(Gamma,T,options);

session_rest1_FO = FO(1:6:222, :);
task1_FO = FO(2:6:222, :);
task2_FO = FO(3:6:222, :);
task3_FO = FO(4:6:222, :);
task4_FO = FO(5:6:222, :);
session_rest2_FO = FO(6:6:222, :);

% plot pre vs post FO

nSubj = 37;
mean_pre  = mean(session_rest1_FO);
mean_post = mean(session_rest2_FO);
sem_pre   = std(session_rest1_FO) / sqrt(nSubj);
sem_post  = std(session_rest2_FO) / sqrt(nSubj);

x = 1:4;

figure;
hold on;
b1 = bar(x - 0.15, mean_pre, 0.3, 'FaceColor', [0.3 0.6 1], 'EdgeColor', 'none');
b2 = bar(x + 0.15, mean_post, 0.3, 'FaceColor', [1 0.4 0.4], 'EdgeColor', 'none');

errorbar(x - 0.15, mean_pre, sem_pre, 'k.', 'LineWidth', 1);
errorbar(x + 0.15, mean_post, sem_post, 'k.', 'LineWidth', 1);

xlim([0.5 4+0.5]);
xticks(1:4);
xticklabels(arrayfun(@(k) sprintf('State %d', k), 1:4, 'UniformOutput', false));
ylabel('Fractional Occupancy');
title('FO Comparison: Pre vs Post');
box off;

clear b1 b2 mean_post mean_pre nSubj sem_post sem_pre FO x

%% ---------------- 3. Explore HMM metrics (Switch Rate) ----------------


switchRate = getSwitchingRate(Gamma,T,options);
session_rest1 = switchRate(1:6:222, :);
task1         = switchRate(2:6:222, :);
task2         = switchRate(3:6:222, :);
task3         = switchRate(4:6:222, :);
task4         = switchRate(5:6:222, :);
session_rest2 = switchRate(6:6:222, :);
switchRate = [session_rest1,task1,task2,task3,task4,session_rest2];


% plot

pre_vals  = switchRate(:,1);
post_vals = switchRate(:,6);

mean_vals = [mean(pre_vals), mean(post_vals)];
sem_vals  = [std(pre_vals)/sqrt(length(pre_vals)), ...
             std(post_vals)/sqrt(length(post_vals))];

figure;
bar(1:2, mean_vals, 0.5, 'FaceColor', 'flat');
hold on;
set(gca, 'XTickLabel', {'Pre', 'Post'});
b = gca;
b.Children.FaceColor = 'flat';
b.Children.CData = [0.3 0.6 1; 1 0.4 0.4];

errorbar(1:2, mean_vals, sem_vals, 'k.', 'LineWidth', 1.2);
ylabel('Switching Rate');
title('Pre vs Post Switching Rate');
box off;

clear b mean_vals post_vals pre_vals sem_vals task1 task2 task3 task4 session_rest1 session_rest2

%% ---------------- 4. Explore HMM metrics (Dwell time) ----------------


metric = getStateLifeTimes(vpath,T,options,[],[],0);

for i = 1:222
for ii = 1:4
dwell{i,ii} = mean(metric{i,ii});
end
end

session_rest1_dwell = dwell(1:6:222, :);
task1_dwell= dwell(2:6:222, :);
task2_dwell= dwell(3:6:222, :);
task3_dwell= dwell(4:6:222, :);
task4_dwell= dwell(5:6:222, :);
session_rest2_dwell = dwell(6:6:222, :);

% set to zero if a certain state does not exist
session_rest1_dwell = cell2mat(session_rest1_dwell);  
session_rest2_dwell = cell2mat(session_rest2_dwell);
task1_dwell = cell2mat(task1_dwell);  
task2_dwell = cell2mat(task2_dwell);
task3_dwell = cell2mat(task3_dwell); 
task4_dwell = cell2mat(task4_dwell);

session_rest1_dwell(isnan(session_rest1_dwell)) = 0;
session_rest2_dwell(isnan(session_rest2_dwell)) = 0;
task1_dwell(isnan(task1_dwell)) = 0;
task2_dwell(isnan(task2_dwell)) = 0;
task3_dwell(isnan(task3_dwell)) = 0;
task4_dwell(isnan(task4_dwell)) = 0;

clear dwell i ii metric

%% ---------------- 5. Explore HMM metrics (interval time ) ----------------

metric = getStateIntervalTimes(vpath,T,options,1,1,0);

for i = 1:222
for ii = 1:4
interval{i,ii} = mean(metric{i,ii});
end
end

session_rest1_interval = interval(1:6:222, :);
task1_interval= interval(2:6:222, :);
task2_interval= interval(3:6:222, :);
task3_interval= interval(4:6:222, :);
task4_interval= interval(5:6:222, :);
session_rest2_interval = interval(6:6:222, :);

% set to zero if a certain state does not exist
session_rest1_interval = cell2mat(session_rest1_interval); 
session_rest2_interval = cell2mat(session_rest2_interval);
task1_interval = cell2mat(task1_interval);  
task2_interval = cell2mat(task2_interval);
task3_interval = cell2mat(task3_interval); 
task4_interval = cell2mat(task4_interval);
session_rest1_interval(isnan(session_rest1_interval)) = 0;
session_rest2_interval(isnan(session_rest2_interval)) = 0;
task1_interval(isnan(task1_interval)) = 0;
task2_interval(isnan(task2_interval)) = 0;
task3_interval(isnan(task3_interval)) = 0;
task4_interval(isnan(task4_interval)) = 0;


clear interval i ii metric


%% ---------------- 6. Task > Pre and Post ----------------

nodes = {'1', '2', '3', '4'};
edges = [1 3; 1 2; 2 3;  4 2; 4 3];

nodecolors = [
    [192,   0,   0]/255;   % S1
    [115, 175, 210]/255;   % S2
    [253, 174,  97]/255;   % S3
    [171, 221, 164]/255    % S4
];

G = digraph(edges(:,1), edges(:,2), [], nodes);

figure;
p = plot(G, 'Layout', 'layered', 'ArrowSize', 15, 'NodeLabel', {}, 'MarkerSize', 20);

p.NodeColor = nodecolors;

highlight(p, [1 2 4], 3, 'EdgeColor', 'r', 'LineWidth', 2); 
title('Task > Pre and Post', 'FontSize', 14, 'FontWeight', 'bold');

%% ---------------- 7. Pre and Post > Task ----------------

nodes = {'1', '2', '3', '4'};
edges = [3 1;4 1; 1 4; 2 1; 2 4; 3 4];

G = digraph(edges(:,1), edges(:,2), [], nodes);

figure;
p = plot(G, 'Layout', 'layered', 'ArrowSize', 15, 'NodeLabel', {}, 'MarkerSize', 20);
p.NodeColor = nodecolors;

highlight(p, [2 3 4],1 , 'EdgeColor', 'r', 'LineWidth', 2); 
title('Pre and Post > Task', 'FontSize', 14, 'FontWeight', 'bold');


%% ---------------- 8. HMM dynamic across session (FO)----------------

FO = getFractionalOccupancy(Gamma,T,options);

session_rest1_FO = FO(1:6:222, :);
task1_FO = FO(2:6:222, :);
task2_FO = FO(3:6:222, :);
task3_FO = FO(4:6:222, :);
task4_FO = FO(5:6:222, :);
session_rest2_FO = FO(6:6:222, :);

colors = {
    [192,   0,   0]/255;   % S1
    [115, 175, 210]/255;   % S2
    [253, 174,  97]/255;   % S3
    [171, 221, 164]/255    % S4
};

session_data = {task1_FO, task2_FO, task3_FO, task4_FO};
session_labels = {'Task1', 'Task2', 'Task3', 'Task4'};

for s = 1:4
    data = session_data{s};  % 37×4
    mean_vals = mean(data, 1);
    sem_vals  = std(data, 0, 1) / sqrt(size(data, 1));
    
    figure;
    hold on;
    
    for k = 1:4
        bar(k, mean_vals(k), 0.6, 'FaceColor', colors{k});
    end
    
    errorbar(1:4, mean_vals, sem_vals, 'k.', 'LineWidth', 1.5);
    
    xticks(1:4);
    xticklabels({'S1', 'S2', 'S3', 'S4'});
    ylabel('FO');
    xlabel('State');
    title(sprintf('%s - State-wise FO', session_labels{s}));
    ylim([0, 0.6]);
    grid on;
end

% take a look at S1 and S3

% State 1
s1_task1 = task1_FO(:, 1);
s1_task2 = task2_FO(:, 1);
s1_task3 = task3_FO(:, 1);
s1_task4 = task4_FO(:, 1);

state1_data = [s1_task1, s1_task2, s1_task3, s1_task4];

mean_vals = mean(state1_data);
sem_vals  = std(state1_data, 0, 1) / sqrt(size(state1_data, 1));

figure;
bar(mean_vals, 'FaceColor', [192,   0,   0]/255);   % S1
hold on;
errorbar(1:4, mean_vals, sem_vals, 'k.', 'LineWidth', 1.5);
xticks(1:4);
xticklabels({'Task1', 'Task2', 'Task3', 'Task4'});
ylabel('FO');
xlabel('Session');
title('State 1 FO across Task Sessions');
grid on;


% State 3
s3_task1 = task1_FO(:, 3);
s3_task2 = task2_FO(:, 3);
s3_task3 = task3_FO(:, 3);
s3_task4 = task4_FO(:, 3);

state3_data = [s3_task1, s3_task2, s3_task3, s3_task4];

mean_vals = mean(state3_data);
sem_vals  = std(state3_data, 0, 1) / sqrt(size(state3_data, 1));

figure;
bar(mean_vals, 'FaceColor', [253, 174,  97]/255);   % S3
hold on;
errorbar(1:4, mean_vals, sem_vals, 'k.', 'LineWidth', 1.5);
xticks(1:4);
xticklabels({'Task1', 'Task2', 'Task3', 'Task4'});
ylabel('FO');
xlabel('Session');
title('State 3 FO across Task Sessions');
grid on;

clear
clc