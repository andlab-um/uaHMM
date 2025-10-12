%% -------------- 1. Try some hmm ---------------


TR = 1;  
options = struct();
options.order = 0; % Gaussian
options.zeromean = 0; % model the mean
options.covtype = 'full'; % full covariance matrix
options.Fs = 1/TR; 
options.verbose = 1;
options.dropstates = 1;
options.standardise = 1;
options.detrend = 1;
options.inittype = 'HMM-MAR';
options.cyc = 1000;
options.initcyc = 1000;
options.initrep = 300;
options.pca = 0.8;
load('step1.mat');

Ks = 2:7;

z_fe  = zscore( -fe_Mean(Ks-1) );

z_sim = zscore( run_similarity(Ks-1) );

combined_score = z_fe + z_sim;

% plot
figure;
subplot(2,1,1);
plot(Ks, fe_Mean(Ks-1), '-o','LineWidth',1.5);
xlabel('K');
xticks(2:1:7);
ylabel('averaged free energy');
title('K vs. free energy');

subplot(2,1,2);
plot(Ks, run_similarity(Ks-1), '-o','LineWidth',1);
xlabel('K');
xticks(2:1:7);
ylabel('averaged run similarity');
title('K vs. averaged run similarity');

figure;
plot(Ks, combined_score(Ks-1), '-s', 'LineWidth',1);
xlabel('Number of states K');
xticks(2:1:7);
ylabel('Combined z-score');
title('K vs. Combined Score (z_{sim} + z_{-FE})');
grid on;


clear
clc

%% -------------- 2. Model PCA performance ---------------
load('K_4_HMM_NOpca.mat')
load('data.mat')
maxFO_noPCA = getMaxFractionalOccupancy(Gamma,T,options);

figure;
histogram(maxFO_noPCA, 'BinEdges', 0:0.1:1, 'Normalization', 'probability');
ylabel('Percentage');
xlabel('maxFO');
title('NO PCA Model')
ylim([0 0.3]); 
set(gca, 'FontSize', 14);

n = sum(maxFO_noPCA > 0.6);
percentage_greater = n / 222

load('K_4_HMM_pca90.mat')
maxFO_pca90 = getMaxFractionalOccupancy(Gamma,T,options);

figure;
histogram(maxFO_pca90, 'BinEdges', 0:0.1:1, 'Normalization', 'probability');
ylabel('Percentage');
xlabel('maxFO');
title('PCA 90% Model')
ylim([0 0.3]); 
set(gca, 'FontSize', 14);

n = sum(maxFO_pca90 > 0.6);
percentage_greater = n / 222

load('K_4_HMM_pca80.mat')
maxFO_pca80 = getMaxFractionalOccupancy(Gamma,T,options);

figure;
histogram(maxFO_pca80, 'BinEdges', 0:0.1:1, 'Normalization', 'probability');
ylabel('Percentage');
xlabel('maxFO');
title('PCA 80%  Model')
ylim([0 0.3]); 
set(gca, 'FontSize', 14);

n = sum(maxFO_pca80 > 0.6);
percentage_greater = n / 222
clear
%% -------------- 3. Model stability---------------

load('GammaList.mat')
similarityMatrix = zeros(5, 5);

% Compute similarity for each pair
for i = 1:5
    for j = 1:5
        similarityMatrix(i, j) = getGammaSimilarity(GammaList{i}, GammaList{j});
    end
end

figure
labels = {'Rep1','Rep2','Rep3','Rep4','Rep5'};

h = heatmap(labels, labels, similarityMatrix, ...
    'Colormap',parula, ...              
    'CellLabelFormat','%.2f', ...
    'FontSize',12);

h.Title = 'Model stability';
