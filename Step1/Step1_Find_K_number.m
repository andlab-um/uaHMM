%% ---------------- 1. Load data ----------------
parpool(24); % start parallel processing
load('data.mat')

%% -------------- 2. Try some hmm ---------------


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

Nrep = 5;
Kmin = 2;
Kmax = 7;

fe_Mean        = nan(1, Kmax);
run_similarity = nan(1, Kmax);

for K = Kmin:Kmax
    fprintf('@@@@@@@@@@@ testing K = %d @@@@@@@@@\n', K)
    options.K = K;
    
    fe_all    = zeros(1, Nrep);
    Gamma_all = cell(1,  Nrep);
    tmp       = zeros(Nrep);
    
    % run 5 times
    for rep = 1:Nrep
        fprintf('@@@@@@@@@@@ Run %d @@@@@@@@@@\n', rep)
        [~, Gamma, ~, ~, ~, ~, fehist] = hmmmar(allData, T, options);
        fe_all(rep)      = fehist(end);
        Gamma_all{rep}   = Gamma;
    end
    
    % free energy
    fe_Mean(K-1) = mean(fe_all);

    % pairwise similarity
    idx = 0;
    for i = 1:Nrep
        for j = i+1:Nrep
            idx = idx + 1;
            sims(idx) = getGammaSimilarity(Gamma_all{i}, Gamma_all{j});
        end
    end
    run_similarity(K-1) = mean(sims);
end

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

save('step1.mat','fe_Mean','run_similarity')
clear
clc

%% -------------- 3. Model PCA performance ---------------
load('K_4_HMM_NOpca.mat')
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

%% -------------- 4. Run Best hmm---------------
options.K=4;
options.pca = 0.8;
[hmm, Gamma, Xi, vpath, GammaInit, residuals, fehist] = hmmmar(allData, T, options);
save('K_4_HMM_pca80.mat','hmm','Gamma','Xi','vpath','GammaInit','residuals','fehist')

%% -------------- 5. Model stability---------------

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
