load("C:\Users\28694\Documents\GitHub\uaHMM\ua_code\hmm-marout\ua_rep\K27\HMMrun_rep1.mat"); % 加载数据文件


%% part 1
% 你之前提供的时序相似性矩阵绘制代码
dataTransposed = data'; 
similarityMatrix = corr(dataTransposed);
imagesc(similarityMatrix);
colorbar;
title('Time Series Similarity Matrix');
xlabel('Time Series Index');
ylabel('Time Series Index');
hold on;

%% part2
% 绘制状态转换的线
vpath = vpath; % 假设 vpath 包含状态信息
for i = 1:length(vpath)-1
    if vpath(i) ~= vpath(i+1)
        % 在状态改变的地方绘制线
        plot([i i], ylim, 'k--'); % 垂直线
        plot(xlim, [i i], 'k--'); % 水平线
    end
end

hold off;
