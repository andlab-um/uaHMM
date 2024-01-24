dataTransposed = data';

similarityMatrix = corr(dataTransposed);

imagesc(similarityMatrix);
colorbar;
title('Time Series Similarity Matrix');
xlabel('Time Series Index');
ylabel('Time Series Index');
