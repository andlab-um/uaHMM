% Code used in Vidaurre et al. (2017) PNAS
%
% Detailed documentation and further examples can be found in:
% https://github.com/OHBA-analysis/HMM-MAR
% Adapted by Eric WANG
%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP THE MATLAB PATHS AND FILE NAMES
K = 3; % no. states
repetitions = 5; % to run it multiple times (keeping all the results)
DirOut = 'C:/Users/28694/Desktop/ua_code/hmm-marout/ua/';

TR = 0.72;  
use_stochastic = 0 % set to 1 if you have loads of data

N = 25; % no. subjects
T = repmat(240, N*2, 1);  % Create a 1 x 2N vector with all elements 480
disp(T);

options = struct();
options.K = K; % number of states
options.order = 0; % no autoregressive components
options.zeromean = 0; % model the mean
options.covtype = 'full'; % full covariance matrix
options.Fs = 1/TR;
options.verbose = 1;
options.standardise = 1;
options.inittype = 'HMM-MAR';
options.cyc = 500;
options.initcyc = 10;
options.initrep = 3;

% stochastic options
if use_stochastic
    options.BIGNbatch = round(N/30);
    options.BIGtol = 1e-7;
    options.BIGcyc = 500;
    options.BIGundertol_tostop = 5;
    options.BIGforgetrate = 0.7;
    options.BIGbase_weights = 0.9;
end

% We run the HMM multiple times
for r = 1:repetitions
    [hmm, Gamma, ~, vpath] = hmmmar(data,T,options);
    save([DirOut 'HMMrun_rep' num2str(r) '.mat'],'Gamma','vpath','hmm')
    disp(['RUN ' num2str(r)])
end
%% Calculate similarity

for i = 1:repetitions-1
    for j = i+1:repetitions
        % load 2 gamma
        data_i = load([DirOut 'HMMrun_rep' num2str(i) '.mat'], 'Gamma');
        gamma_i = data_i.Gamma;
        data_j = load([DirOut 'HMMrun_rep' num2str(j) '.mat'], 'Gamma');
        gamma_j = data_j.Gamma;
        
        % calculate similarity
        [similarity, ~, ~] = getGammaSimilarity(gamma_i, gamma_j);
        

        similarity_name = ['similarity_' num2str(i) '_' num2str(j)];
        similarity_results.(similarity_name) = similarity;
        
        fprintf('Similarity between run %d and run %d: %.4f\n', i, j, similarity);
    end
end
save([DirOut 'HMM_SimilarityResults_K' num2str(K) '.mat'], '-struct', 'similarity_results');

%% Graph and determine no. K states
 
K_ranges = 2:8; 
average_similarities = zeros(size(K_ranges)); 


for i = 1:length(K_ranges)
    K = K_ranges(i);
    filename = fullfile(DirOut, sprintf('K%d/hmm-maroutHMM_SimilarityResults_K%d.mat', K, K));
    similarity_struct = load(filename);
    similarity_values = struct2array(similarity_struct);
    average_similarities(i) = mean(similarity_values);
end

% graph K against simliarities
plot(K_ranges, average_similarities, '-o');
xlabel('K value');
ylabel('Average Similarity');
title('Average Similarity for Different K values');


%% Pull out metastates

for r = 1:repetitions
    figure(r)
    load([DirOut 'HMMrun_rep' num2str(r) '.mat'],'Gamma','hmm')
    subplot(1,2,1) % Figure 2B
    GammaSessMean = squeeze(mean(reshape(Gamma,[480 2 N K]),1));    
    GammaSubMean = squeeze(mean(GammaSessMean,1));
    [~,pca1] = pca(GammaSubMean','NumComponents',1);
    [~,ord] = sort(pca1); 
    imagesc(corr(GammaSubMean(:,ord))); colorbar
    subplot(1,2,2) % Figure 2A
    P = hmm.P;
    for j=1:K, P(j,j) = 0; P(j,:) = P(j,:) / sum(P(j,:));  end
    imagesc(P(ord,ord),[0 0.25]); colorbar
    axis square
    hold on
    for j=0:13
        plot([0 13] - 0.5,[j j] + 0.5,'k','LineWidth',2)
        plot([j j] + 0.5,[0 13] - 0.5,'k','LineWidth',2)
    end
    hold off
end


