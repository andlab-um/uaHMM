% Code used in Vidaurre et al. (2017) PNAS
%
% Detailed documentation and further examples can be found in:
% https://github.com/OHBA-analysis/HMM-MAR
% Adapted by Eric WANG
%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP THE MATLAB PATHS AND FILE NAMES

K_values = 23:30; % K value range
repetitions = 1; % number of repeat
DirOutBase = 'C:\Users\28694\Documents\GitHub\uaHMM\ua_code\hmm-marout\ua\'; 

TR = 0.72;  
use_stochastic = 0; % disabled - error if enable

N = 25; % Participants number, 25 if ua, 37 if ua-rep
T = repmat(240, N*2, 1); % 240 if ua, 480 if ua-rep


for K = K_values

    DirOut = [DirOutBase 'K' num2str(K) '\'];
    if ~exist(DirOut, 'dir')
        mkdir(DirOut);
    end


    options = struct();
    options.K = K;
    options.order = 0; 
    options.zeromean = 0; 
    options.covtype = 'full'; 
    options.Fs = 1 / TR;
    options.verbose = 1;
    options.standardise = 1;
    options.inittype = 'HMM-MAR';
    options.cyc = 500;
    options.initcyc = 10;
    options.initrep = 3;

    if use_stochastic
        options.BIGNbatch = round(N/30);
        options.BIGtol = 1e-7;
        options.BIGcyc = 500;
        options.BIGundertol_tostop = 5;
        options.BIGforgetrate = 0.7;
        options.BIGbase_weights = 0.9;
    end

    for r = 1:repetitions
        [hmm, Gamma, ~, vpath] = hmmmar(data, T, options);
        
        save([DirOut 'HMMrun_rep' num2str(r) '.mat'], 'Gamma', 'vpath', 'hmm');
        disp(['RUN ' num2str(r) ' for K=' num2str(K) 'finished']);
    end
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
    filename = fullfile(DirOutBase, sprintf('K%d/HMM_SimilarityResults_K%d.mat', K, K));
    similarity_struct = load(filename);
    similarity_values = struct2array(similarity_struct);
    average_similarities(i) = mean(similarity_values);
end

% graph K against simliarities
plot(K_ranges, average_similarities, '-o');
xlabel('K value');
ylabel('Average Similarity');
title('Average Similarity for Different K values Using UA-rep Data');

%% using t distance
K_range = 2:22;
t_distances = zeros(length(K_range), 1);


for K = K_range
    % HMM output dir
    filePath = fullfile(DirOutBase, ['K' num2str(K)], 'HMMrun_rep1.mat');
    
    % Load gamma
    load(filePath, 'Gamma');
    
    % get most likely state at each timepoint
    [~, most_likely_states] = max(Gamma, [], 2);


    within_state_corrs = [];
    between_state_corrs = [];

    % for all timepoint
    for t = 1:(size(Gamma, 1) - 1)
        % within
        if most_likely_states(t) == most_likely_states(t+1)
            within_state_corrs(end+1) = corr(data(t, :)', data(t+1, :)');
        else
            % between
            between_state_corrs(end+1) = corr(data(t, :)', data(t+1, :)');
        end
    end

    % ttest
    [~, ~, ~, stats] = ttest2(within_state_corrs, between_state_corrs);
    t_distances(K-1) = stats.tstat;

    disp(['The t-distance for K=' num2str(K) ' is: ', num2str(stats.tstat)]);
end

% graph
figure;
plot(K_range, t_distances, 'o-');
xlabel('Number of states (K)');
ylabel('t-distance');
title('t-distance for different K values');
