%% use cv fold and C-H value
data_ses1 = load('input_data/rest_ses1.mat');
data_ses2 = load('input_data/rest_ses2.mat');
data_ses1 = data_ses1.data; % 476 x 33 x 37
data_ses2 = data_ses2.data; % 476x 33 x 37

data_all = cat(3, data_ses1, data_ses2); % 476 x 33 x 74

% K range
K_values = 2:10;
num_folds = 74; % equal num of scan, leave one out CV

% HMM parameter 
options = struct();
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

% CV index
indices = crossvalind('Kfold', 74, num_folds);

% loop all Ks, fit HMM and record c-h value
for i = 1:length(K_values)
    K = K_values(i);
    options.K = K;
    
    for fold = 1:num_folds
        disp(['--- Testing K=' num2str(K) ' Fold=' num2str(fold) ' ---']);
        
        % Train and text index
        train_idx = find(indices ~= fold);
        test_idx = find(indices == fold);
        
        % Train data and text data
        train_data = data_all(:,:,train_idx);
        test_data = data_all(:,:,test_idx);
        T_train = repmat(476, length(train_idx), 1);
        T_test = repmat(476, length(test_idx), 1);
        
        % Reshape the data into hmm-mar required
        train_data_reshaped = reshape(permute(train_data, [1 3 2]), [], 33); %  476 x 33
        test_data_reshaped = reshape(permute(test_data, [1 3 2]), [], 33); % 476 x 33
        
        % FIT HMM!
        [hmm] = hmmmar(train_data_reshaped, T_train, options);
        viterbipath = hmmdecode(test_data_reshaped, T_test, hmm, 1);
        
        % Calinski-Harabasz Score
        ch_score = evalclusters(test_data_reshaped, viterbipath, 'CalinskiHarabasz');
        
        % fe
        fe = hmmfe(test_data_reshaped,T_test,hmm);

        % Save directory
        folder_path = sprintf('output_HMM/C-H_scores/K%d', K);
        if ~exist(folder_path, 'dir')
            mkdir(folder_path);
        end
        
        % save
        save(fullfile(folder_path, sprintf('fold%d.mat', fold)), 'ch_score', 'hmm','fe');
    end
end

%% load C-H at each fold and graph 1.CH score 2. Free energy
clear

% Load K and fold settings
K_values = 2:10;
num_folds = 74;

% variable to plot
mean_ch_scores = zeros(length(K_values), 1);
mean_fe_scores = zeros(length(K_values), 1);


for i = 1:length(K_values)
    K = K_values(i);
    ch_scores = zeros(num_folds, 1); 
    fe_scores = zeros(num_folds, 1); 
    for fold = 1:num_folds
        folder_path = sprintf('output_HMM/C-H_scores/K%d', K);
        data = load(fullfile(folder_path, sprintf('fold%d.mat', fold)));
        ch_scores(fold) = data.ch_score.CriterionValues;
        fe_scores = data.fe;
    end

    mean_ch_scores(i) = mean(ch_scores);
    mean_fe_scores(i) = mean(fe_scores);
end

% Let's PLOT!
figure;
plot(K_values, mean_ch_scores, '-o', 'LineWidth', 2);
xlabel('Number of States (K)');
ylabel('Cross-validated Calinski-Harabasz Score');
title('Cross-validated Calinski-Harabasz Score for Different K values');
grid on;

figure;
plot(K_values, mean_fe_scores, '-o', 'LineWidth', 2);
xlabel('Number of States (K)');
ylabel('Free Energy');
title('Mean free energy for Different K values');
grid on;

% Now, we know K = 10, so this is what will be used in later analysis
%
% As if we re-run the HMM, the state will not be the same as our paper, so 
% to replicate the finding, please proceed to HMM_analysis_All_in_one.m 
%
% options = struct();
% options.K = 10;
% options.cvverbose = 1;
% options.order = 0; % no autoregressive components
% options.zeromean = 0; % do not model the mean
% options.covtype = 'full'; % full covariance matrix
% options.Fs = 1; % TR = 1s
% options.verbose = 1;
% options.standardise = 1;
% options.inittype = 'HMM-MAR';
% options.cyc = 1000;
% options.initcyc = 10;
% options.initrep = 5;
% options.cvverbose = 1;
% options.dropstates = 0;
% options.cvverbose = 1;
%
% [hmm, Gamma, Xi, vpath, GammaInit, residuals, fe] = hmmmar(data_all_reshaped, T, options);
% save('output_HMM/HMM_Model_K10/Hmm', 'hmm');

