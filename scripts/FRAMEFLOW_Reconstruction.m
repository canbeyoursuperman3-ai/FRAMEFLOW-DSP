clc;
clear;
close all;

%% FRAMEFLOW: VIDEO RECONSTRUCTION
inputFile = 'street.mp4';
sampledFile = 'FRAMEFLOW_Sampled.avi';
samplingFactor = 5;

if ~isfile(inputFile) || ~isfile(sampledFile)
    error('Required video files are missing. Check the Files panel.');
end

original = VideoReader(inputFile);
originalFPS = original.FrameRate;
outputFPS = originalFPS;

%% CREATE OUTPUT VIDEO WRITERS
zohWriter = VideoWriter('FRAMEFLOW_ZOH_Reconstructed.avi', 'Motion JPEG AVI');
linearWriter = VideoWriter('FRAMEFLOW_Linear_Reconstructed.avi', 'Motion JPEG AVI');
zohWriter.FrameRate = outputFPS;
linearWriter.FrameRate = outputFPS;
open(zohWriter);
open(linearWriter);

%% READ SAMPLED FRAMES AND RECONSTRUCT
sampledReader = VideoReader(sampledFile);
if ~hasFrame(sampledReader)
    close(zohWriter);
    close(linearWriter);
    error('The sampled video contains no readable frames.');
end

previousFrame = readFrame(sampledReader);
frameCount = 0;
squaredErrorZOH = 0;
squaredErrorLinear = 0;
pixelCount = 0;
original = VideoReader(inputFile);

while hasFrame(original)
    originalFrame = readFrame(original);
    frameCount = frameCount + 1;

    % Advance to the next sampled frame at each sampling boundary.
    if mod(frameCount - 1, samplingFactor) == 0
        currentSampledFrame = previousFrame;
        if hasFrame(sampledReader)
            nextSampledFrame = readFrame(sampledReader);
        else
            nextSampledFrame = currentSampledFrame;
        end
        previousFrame = currentSampledFrame;
    end

    % Zero-order hold: repeat the current sampled frame.
    zohFrame = currentSampledFrame;

    % Linear interpolation between adjacent sampled frames.
    alpha = mod(frameCount - 1, samplingFactor) / samplingFactor;
    linearFrame = uint8((1 - alpha) .* double(currentSampledFrame) + ...
        alpha .* double(nextSampledFrame));

    writeVideo(zohWriter, zohFrame);
    writeVideo(linearWriter, linearFrame);

    differenceZOH = double(originalFrame) - double(zohFrame);
    differenceLinear = double(originalFrame) - double(linearFrame);
    squaredErrorZOH = squaredErrorZOH + sum(differenceZOH(:).^2);
    squaredErrorLinear = squaredErrorLinear + sum(differenceLinear(:).^2);
    pixelCount = pixelCount + numel(originalFrame);
end

%% CLOSE OUTPUT FILES
close(zohWriter);
close(linearWriter);

%% CALCULATE MEAN SQUARED ERRORS
MSE_ZOH = squaredErrorZOH / pixelCount;
MSE_Linear = squaredErrorLinear / pixelCount;
fprintf('\nFRAMEFLOW Reconstruction Results\n');
fprintf('Original frames processed: %d\n', frameCount);
fprintf('ZOH reconstruction MSE: %.4f\n', MSE_ZOH);
fprintf('Linear interpolation MSE: %.4f\n', MSE_Linear);

%% SAVE NUMERICAL RESULTS
Method = {'Zero-Order Hold'; 'Linear Interpolation'};
MSE = [MSE_ZOH; MSE_Linear];
resultsTable = table(Method, MSE);
writetable(resultsTable, 'FRAMEFLOW_Reconstruction_Results.csv');
save('FRAMEFLOW_Reconstruction_Data.mat', ...
    'MSE_ZOH', 'MSE_Linear', 'samplingFactor', 'originalFPS', 'frameCount');

%% PLOT AND SAVE MSE COMPARISON
figure('Name', 'FRAMEFLOW Reconstruction Error');
bar([MSE_ZOH, MSE_Linear]);
set(gca, 'XTick', [1 2]);
set(gca, 'XTickLabel', {'Zero-Order Hold', 'Linear Interpolation'});
ylabel('Mean Squared Error');
title('Reconstruction Quality Comparison');
grid on;
saveas(gcf, 'FRAMEFLOW_Reconstruction_MSE.png');

fprintf('\nReconstruction complete!\n');
fprintf('Saved: FRAMEFLOW_ZOH_Reconstructed.avi\n');
fprintf('Saved: FRAMEFLOW_Linear_Reconstructed.avi\n');
fprintf('Saved: FRAMEFLOW_Reconstruction_Results.csv\n');
fprintf('Saved: FRAMEFLOW_Reconstruction_Data.mat\n');
fprintf('Saved: FRAMEFLOW_Reconstruction_MSE.png\n');
