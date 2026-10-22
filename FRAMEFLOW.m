%% FRAMEFLOW - Temporal Video Sampling and Reconstruction
% Digital Signal Processing Laboratory project
% Demonstrates temporal downsampling, Zero-Order Hold (ZOH), and
% pixel-wise linear interpolation between retained video frames.
%
% HOW TO RUN
% 1. Upload this script and a video named street.mp4 to the same MATLAB folder.
% 2. Run this script. Change inputFile or samplingFactor below if required.
% 3. Inspect the generated AVI videos, PNG plots, and CSV/MAT data.
%
% NOTE: MSE is measured against corresponding original frames processed in
% each interval. It is a pixel-wise measure, not a complete perceptual score.

clear; clc; close all;

%% User settings
inputFile = 'street.mp4';
samplingFactor = 4;             % Keep every 4th frame (including first)
outputFolder = 'FRAMEFLOW_Output';
writerProfile = 'Motion JPEG AVI';

if samplingFactor < 2 || samplingFactor ~= floor(samplingFactor)
    error('samplingFactor must be an integer greater than or equal to 2.');
end
if ~isfile(inputFile)
    error(['Input video not found: ', inputFile, newline, ...
        'Upload a video to the Current Folder or change inputFile.']);
end
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

%% Open input and create output writers
reader = VideoReader(inputFile);
inputFPS = reader.FrameRate;
if isempty(inputFPS) || ~isfinite(inputFPS) || inputFPS <= 0
    error('Could not determine a valid frame rate from the input video.');
end

sampledPath = fullfile(outputFolder, 'FRAMEFLOW_Sampled.avi');
zohPath = fullfile(outputFolder, 'FRAMEFLOW_ZOH_Reconstructed.avi');
linearPath = fullfile(outputFolder, 'FRAMEFLOW_Linear_Reconstructed.avi');

sampledWriter = VideoWriter(sampledPath, writerProfile);
sampledWriter.FrameRate = max(inputFPS / samplingFactor, 1);
zohWriter = VideoWriter(zohPath, writerProfile);
zohWriter.FrameRate = inputFPS;
linearWriter = VideoWriter(linearPath, writerProfile);
linearWriter.FrameRate = inputFPS;

open(sampledWriter);
open(zohWriter);
open(linearWriter);
writerCleanup = onCleanup(@() closeWriters(sampledWriter, zohWriter, linearWriter)); %#ok<NASGU>

%% Stream through the video using only one sampling interval in memory
frameIndex = 0;
sampledCount = 0;
zohCount = 0;
linearCount = 0;
zohSquaredError = 0;
linearSquaredError = 0;
zohPixelCount = 0;
linearPixelCount = 0;
intervalMSE_ZOH = [];
intervalMSE_Linear = [];
intervalFrameNumbers = [];

previousSample = [];
intervalFrames = {};
intervalStartIndex = 1;

while hasFrame(reader)
    frame = readFrame(reader);
    frameIndex = frameIndex + 1;
    intervalFrames{end + 1} = frame; %#ok<SAGROW>

    isSampleFrame = mod(frameIndex - 1, samplingFactor) == 0;
    if isSampleFrame
        writeVideo(sampledWriter, frame);
        sampledCount = sampledCount + 1;

        if ~isempty(previousSample)
            intervalZOHError = 0;
            intervalLinearError = 0;
            intervalZOHPixels = 0;
            intervalLinearPixels = 0;
            nextSample = intervalFrames{end};

            % Compare each reconstructed frame with its matching source frame.
            for k = 1:numel(intervalFrames)-1
                originalFrame = intervalFrames{k};
                alpha = (k - 1) / samplingFactor;

                zohFrame = previousSample;
                writeVideo(zohWriter, zohFrame);
                zohCount = zohCount + 1;

                blended = (1 - alpha) .* double(previousSample) + ...
                    alpha .* double(nextSample);
                linearFrame = cast(min(max(round(blended), 0), 255), 'uint8');
                writeVideo(linearWriter, linearFrame);
                linearCount = linearCount + 1;

                errZ = double(originalFrame) - double(zohFrame);
                errL = double(originalFrame) - double(linearFrame);
                intervalZOHError = intervalZOHError + sum(errZ(:).^2);
                intervalLinearError = intervalLinearError + sum(errL(:).^2);
                intervalZOHPixels = intervalZOHPixels + numel(errZ);
                intervalLinearPixels = intervalLinearPixels + numel(errL);
            end

            intervalMSE_ZOH(end + 1, 1) = intervalZOHError / max(intervalZOHPixels, 1); %#ok<SAGROW>
            intervalMSE_Linear(end + 1, 1) = intervalLinearError / max(intervalLinearPixels, 1); %#ok<SAGROW>
            intervalFrameNumbers(end + 1, 1) = intervalStartIndex; %#ok<SAGROW>
            zohSquaredError = zohSquaredError + intervalZOHError;
            linearSquaredError = linearSquaredError + intervalLinearError;
            zohPixelCount = zohPixelCount + intervalZOHPixels;
            linearPixelCount = linearPixelCount + intervalLinearPixels;
        end

        previousSample = frame;
        intervalFrames = {frame};
        intervalStartIndex = frameIndex;
    end
end

% Handle the final partial interval by holding the last retained frame.
if ~isempty(previousSample)
    % Write the final retained frame at its own timestamp.
    writeVideo(zohWriter, previousSample);
    writeVideo(linearWriter, previousSample);
    zohCount = zohCount + 1;
    linearCount = linearCount + 1;

    % Any remaining frames have no later retained sample to blend toward,
    % so both methods hold the final retained frame for this tail.
    if numel(intervalFrames) > 1
        for k = 2:numel(intervalFrames)
            originalFrame = intervalFrames{k};
            writeVideo(zohWriter, previousSample);
            writeVideo(linearWriter, previousSample);
            zohCount = zohCount + 1;
            linearCount = linearCount + 1;

            err = double(originalFrame) - double(previousSample);
            tailError = sum(err(:).^2);
            zohSquaredError = zohSquaredError + tailError;
            linearSquaredError = linearSquaredError + tailError;
            zohPixelCount = zohPixelCount + numel(err);
            linearPixelCount = linearPixelCount + numel(err);
        end
    end
end

closeWriters(sampledWriter, zohWriter, linearWriter);

%% Save run metadata and error summaries
meanMSE_ZOH = zohSquaredError / max(zohPixelCount, 1);
meanMSE_Linear = linearSquaredError / max(linearPixelCount, 1);

summary = table(string(inputFile), inputFPS, samplingFactor, sampledCount, ...
    zohCount, linearCount, meanMSE_ZOH, meanMSE_Linear, ...
    'VariableNames', {'InputVideo','InputFrameRate','SamplingFactor', ...
    'SampledFrameCount','ZOHFrameCount','LinearFrameCount', ...
    'MeanMSE_ZOH','MeanMSE_Linear'});

writetable(summary, fullfile(outputFolder, 'FRAMEFLOW_Sampling_Results.csv'));
save(fullfile(outputFolder, 'FRAMEFLOW_Sampling_Data.mat'), ...
    'inputFile','inputFPS','samplingFactor','sampledCount','zohCount', ...
    'linearCount','meanMSE_ZOH','meanMSE_Linear','intervalMSE_ZOH', ...
    'intervalMSE_Linear','intervalFrameNumbers','summary');

fig1 = figure('Visible','off','Color','w');
bar([sampledCount, zohCount, linearCount]);
set(gca,'XTickLabel',{'Sampled','ZOH reconstructed','Linear reconstructed'});
ylabel('Frames written');
title('FRAMEFLOW: Output Frame Count Comparison');
grid on;
exportgraphics(fig1, fullfile(outputFolder, 'FRAMEFLOW_FrameCount_Comparison.png'));
close(fig1);

if ~isempty(intervalMSE_ZOH)
    fig2 = figure('Visible','off','Color','w');
    plot(intervalFrameNumbers, intervalMSE_ZOH, '-o', 'LineWidth', 1.4);
    hold on;
    plot(intervalFrameNumbers, intervalMSE_Linear, '-s', 'LineWidth', 1.4);
    xlabel('Start frame index of interval');
    ylabel('Mean squared pixel error');
    title('FRAMEFLOW: Reconstruction MSE by Interval');
    legend('ZOH','Linear interpolation','Location','best');
    grid on;
    exportgraphics(fig2, fullfile(outputFolder, 'FRAMEFLOW_Reconstruction_MSE.png'));
    close(fig2);
end

fprintf('\nFRAMEFLOW processing complete.\n');
fprintf('Input: %s | %.3f fps | %d frames read\n', inputFile, inputFPS, frameIndex);
fprintf('Sampled frames: %d\n', sampledCount);
fprintf('ZOH frames: %d | Linear frames: %d\n', zohCount, linearCount);
fprintf('Mean MSE (ZOH): %.6g\n', meanMSE_ZOH);
fprintf('Mean MSE (linear): %.6g\n', meanMSE_Linear);
fprintf('Outputs saved in: %s\n', outputFolder);

function closeWriters(sampledWriter, zohWriter, linearWriter)
try, close(sampledWriter); catch, end
try, close(zohWriter); catch, end
try, close(linearWriter); catch, end
end
