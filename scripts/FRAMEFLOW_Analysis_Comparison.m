clc;
clear;
close all;

%% FRAMEFLOW: VIDEO SAMPLING AND RECONSTRUCTION
% Interactive analysis of temporal sampling, aliasing,
% and frame reconstruction in digital video.

fprintf('\n========================================\n');
fprintf('       FRAMEFLOW VIDEO ANALYSIS\n');
fprintf('========================================\n');

%% 1. LOAD THE VIDEO
videoFile = 'street.mp4';
if ~isfile(videoFile)
    [fileName, filePath] = uigetfile( ...
        { '*.mp4;*.avi;*.mov', 'Video Files (*.mp4, *.avi, *.mov)' }, ...
        'Select your street video');
    if isequal(fileName, 0)
        error(['Video selection cancelled. ', ...
            'Place street.mp4 in the current folder and run again.']);
    end
    videoFile = fullfile(filePath, fileName);
end

videoReader = VideoReader(videoFile);
originalFPS = videoReader.FrameRate;
videoDuration = videoReader.Duration;
fprintf('\nVideo loaded successfully!\n');
fprintf('Video file: %s\n', videoFile);
fprintf('Original frame rate: %.2f FPS\n', originalFPS);
fprintf('Video duration: %.2f seconds\n', videoDuration);

%% 2. READ VIDEO FRAMES
% Resize frames to reduce processing time in MATLAB Online.
maxFrames = 45;
frames = {};
frameCount = 0;
while hasFrame(videoReader) && frameCount < maxFrames
    frame = readFrame(videoReader);
    frame = imresize(frame, [240 426]);
    frameCount = frameCount + 1;
    frames{frameCount} = frame; %#ok<SAGROW>
end

if frameCount < 3
    error('The video must contain at least three readable frames.');
end
fprintf('Frames processed: %d\n', frameCount);

% Convert frames to grayscale for numerical analysis.
grayFrames = zeros(240, 426, frameCount);
for k = 1:frameCount
    grayFrames(:,:,k) = im2double(rgb2gray(frames{k}));
end

%% 3. DISPLAY ORIGINAL VIDEO FRAME
figure('Name', 'FRAMEFLOW - Original Video');
imshow(frames{1});
title('Original Video - First Frame');

%% 4. TEMPORAL SAMPLING
% Keep every 2nd, 5th, and 10th frame.
decimationFactors = [2 5 10];
sampledFrames = cell(length(decimationFactors), 1);
reconstructedHold = cell(length(decimationFactors), 1);
reconstructedLinear = cell(length(decimationFactors), 1);
averageMSE = zeros(length(decimationFactors), 1);
effectiveFPS = zeros(length(decimationFactors), 1);
originalVideo = grayFrames;

for d = 1:length(decimationFactors)
    factor = decimationFactors(d);
    sampleIndices = 1:factor:frameCount;
    sampledFrames{d} = frames(sampleIndices);
    effectiveFPS(d) = originalFPS / factor;

    %% 5. ZERO-ORDER HOLD RECONSTRUCTION
    holdVideo = zeros(size(originalVideo));
    for k = 1:frameCount
        sampleIndex = floor((k - 1) / factor) + 1;
        sampleIndex = min(sampleIndex, length(sampleIndices));
        holdVideo(:,:,k) = grayFrames(:,:,sampleIndices(sampleIndex));
    end
    reconstructedHold{d} = holdVideo;

    %% 6. LINEAR INTERPOLATION RECONSTRUCTION
    linearVideo = zeros(size(originalVideo));
    for k = 1:frameCount
        position = (k - 1) / factor;
        leftSample = floor(position) + 1;
        leftSample = min(leftSample, length(sampleIndices));
        rightSample = min(leftSample + 1, length(sampleIndices));
        fraction = position - floor(position);
        if leftSample == rightSample
            fraction = 0;
        end
        leftFrame = grayFrames(:,:,sampleIndices(leftSample));
        rightFrame = grayFrames(:,:,sampleIndices(rightSample));
        linearVideo(:,:,k) = (1 - fraction) .* leftFrame + fraction .* rightFrame;
    end
    reconstructedLinear{d} = linearVideo;

    %% 7. MEAN SQUARED ERROR
    difference = originalVideo - linearVideo;
    averageMSE(d) = mean(difference(:).^2);
end

%% 8. DISPLAY SAMPLING AND RECONSTRUCTION COMPARISON
comparisonIndex = find(decimationFactors == 5, 1);
figure('Name', 'FRAMEFLOW - Sampling Comparison');
subplot(2,2,1);
imshow(frames{1});
title('Original Video Frame');
subplot(2,2,2);
sampleIndex = min(2, length(sampledFrames{comparisonIndex}));
imshow(sampledFrames{comparisonIndex}{sampleIndex});
title('Temporally Sampled Frame');
subplot(2,2,3);
imshow(reconstructedHold{comparisonIndex}(:,:,min(6,frameCount)), []);
title('Zero-Order Hold Reconstruction');
subplot(2,2,4);
imshow(reconstructedLinear{comparisonIndex}(:,:,min(6,frameCount)), []);
title('Linear Interpolation Reconstruction');

%% 9. DISPLAY RECONSTRUCTED FRAME COMPARISON
frameToCompare = min(10, frameCount);
figure('Name', 'FRAMEFLOW - Reconstruction Methods');
subplot(1,3,1);
imshow(originalVideo(:,:,frameToCompare), []);
title('Original Frame');
subplot(1,3,2);
imshow(reconstructedHold{comparisonIndex}(:,:,frameToCompare), []);
title('Frame Repetition');
subplot(1,3,3);
imshow(reconstructedLinear{comparisonIndex}(:,:,frameToCompare), []);
title('Linear Interpolation');

%% 10. PLOT EFFECTIVE FRAME RATE
figure('Name', 'FRAMEFLOW - Effective Frame Rate');
bar(decimationFactors, effectiveFPS);
xlabel('Decimation Factor');
ylabel('Effective Frame Rate (FPS)');
title('Temporal Sampling and Effective Frame Rate');
grid on;

%% 11. PLOT RECONSTRUCTION ERROR
figure('Name', 'FRAMEFLOW - Reconstruction Error');
plot(effectiveFPS, averageMSE, '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Effective Frame Rate (FPS)');
ylabel('Mean Squared Error (MSE)');
title('Reconstruction Error vs Effective Frame Rate');
grid on;

%% 12. DISPLAY PIXEL INTENSITY COMPARISON
figure('Name', 'FRAMEFLOW - Pixel Intensity Comparison');
pixelRow = 120;
pixelColumn = 213;
originalValues = squeeze(originalVideo(pixelRow, pixelColumn, :));
holdValues = squeeze(reconstructedHold{comparisonIndex}(pixelRow, pixelColumn, :));
linearValues = squeeze(reconstructedLinear{comparisonIndex}(pixelRow, pixelColumn, :));
plot(1:frameCount, originalValues, 'LineWidth', 1.5);
hold on;
plot(1:frameCount, holdValues, '--', 'LineWidth', 1.5);
plot(1:frameCount, linearValues, ':', 'LineWidth', 2);
xlabel('Frame Number');
ylabel('Normalized Pixel Intensity');
title('Original vs Reconstructed Pixel Intensity');
legend('Original', 'Frame Repetition', 'Linear Interpolation');
grid on;
hold off;

%% 13. DISPLAY RESULTS TABLE
resultsTable = table(decimationFactors(:), effectiveFPS(:), averageMSE(:), ...
    'VariableNames', {'DecimationFactor', 'EffectiveFPS', 'AverageMSE'});
fprintf('\n========================================\n');
fprintf('         ANALYSIS RESULTS\n');
fprintf('========================================\n');
disp(resultsTable);
fprintf('\nProject execution completed successfully!\n');
fprintf('Compare the graphs to study temporal sampling\n');
fprintf('and reconstruction quality.\n');
fprintf('========================================\n');

%% 14. SAVE PROJECT RESULTS
writetable(resultsTable, 'FRAMEFLOW_Results.csv');
save('FRAMEFLOW_Data.mat', 'resultsTable', 'decimationFactors', ...
    'effectiveFPS', 'averageMSE', 'originalFPS', 'frameCount');

figures = findall(groot, 'Type', 'figure');
for k = 1:length(figures)
    filename = sprintf('FRAMEFLOW_Figure_%02d.png', k);
    exportgraphics(figures(k), filename);
end

fprintf('\nAll project results have been saved!\n');
fprintf('Check your MATLAB Current Folder for the files.\n');
