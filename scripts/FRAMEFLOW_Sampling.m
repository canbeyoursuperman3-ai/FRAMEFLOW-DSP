clc;
clear;
close all;

%% FRAMEFLOW: TEMPORAL SAMPLING
% Project: Interactive Analysis of Temporal Sampling,
% Aliasing, and Frame Reconstruction in Digital Video

%% STEP 1: Load the Original Video
inputFile = 'street.mp4';
if ~isfile(inputFile)
    error('street.mp4 not found. Check your MATLAB Files panel.');
end

reader = VideoReader(inputFile);
originalFPS = reader.FrameRate;
originalDuration = reader.Duration;
fprintf('Original frame rate: %.2f FPS\n', originalFPS);
fprintf('Video duration: %.2f seconds\n', originalDuration);

%% STEP 2: Read and Store Original Frames
frames = {};
while hasFrame(reader)
    frames{end+1} = readFrame(reader); %#ok<SAGROW>
end
totalFrames = numel(frames);
fprintf('Total original frames: %d\n', totalFrames);

%% STEP 3: Perform Temporal Sampling
samplingFactor = 5;
% Select every fifth frame
sampledFrames = frames(1:samplingFactor:end);
sampledFPS = originalFPS / samplingFactor;

fprintf('Sampling factor: %d\n', samplingFactor);
fprintf('Effective sampled frame rate: %.2f FPS\n', sampledFPS);
fprintf('Number of sampled frames: %d\n', numel(sampledFrames));

%% STEP 4: Save the Sampled Video
outputVideo = 'FRAMEFLOW_Sampled.avi';
writer = VideoWriter(outputVideo, 'Motion JPEG AVI');
writer.FrameRate = sampledFPS;
open(writer);
for k = 1:numel(sampledFrames)
    writeVideo(writer, sampledFrames{k});
end
close(writer);
fprintf('Sampled video saved: %s\n', outputVideo);

%% STEP 5: Display the Sampled Video
figure('Name', 'FRAMEFLOW - Sampled Video');
h = imshow(sampledFrames{1});
title(sprintf('Sampled Video - %.2f FPS', sampledFPS));
for k = 2:numel(sampledFrames)
    h.CData = sampledFrames{k};
    drawnow limitrate;
end

%% STEP 6: Compare Original and Sampled Frame Counts
figure('Name', 'FRAMEFLOW - Frame Count Comparison');
bar([totalFrames, numel(sampledFrames)]);
set(gca, 'XTickLabel', {'Original Video', 'Sampled Video'});
ylabel('Number of Frames');
title('Effect of Temporal Sampling');
grid on;
saveas(gcf, 'FRAMEFLOW_FrameCount_Comparison.png');

%% STEP 7: Compare the First Frames
figure('Name', 'FRAMEFLOW - Original vs Sampled');
subplot(1,2,1);
imshow(frames{1});
title('Original Video');
subplot(1,2,2);
imshow(sampledFrames{1});
title('Sampled Video');
saveas(gcf, 'FRAMEFLOW_Original_vs_Sampled.png');

%% STEP 8: Save Sampling Data
save('FRAMEFLOW_Sampling_Data.mat', ...
    'frames', 'sampledFrames', 'samplingFactor', ...
    'originalFPS', 'sampledFPS', 'originalDuration', 'totalFrames');

%% STEP 9: Save Numerical Results
resultsTable = table(originalFPS, sampledFPS, samplingFactor, ...
    totalFrames, numel(sampledFrames), originalDuration, ...
    'VariableNames', {'OriginalFPS', 'SampledFPS', 'SamplingFactor', ...
    'OriginalFrames', 'SampledFrames', 'DurationSeconds'});
writetable(resultsTable, 'FRAMEFLOW_Sampling_Results.csv');

%% STEP 10: Display Final Results
fprintf('\n====================================\n');
fprintf('FRAMEFLOW SAMPLING COMPLETED!\n');
fprintf('====================================\n');
fprintf('Original FPS: %.2f\n', originalFPS);
fprintf('Sampled FPS: %.2f\n', sampledFPS);
fprintf('Original frames: %d\n', totalFrames);
fprintf('Sampled frames: %d\n', numel(sampledFrames));
fprintf('Saved video: %s\n', outputVideo);
fprintf('Saved data: FRAMEFLOW_Sampling_Data.mat\n');
fprintf('Saved results: FRAMEFLOW_Sampling_Results.csv\n');
fprintf('====================================\n');
