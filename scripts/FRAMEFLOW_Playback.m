clc;
clear;
close all;

%% FRAMEFLOW: ORIGINAL VIDEO PLAYBACK AND EXPORT
inputFile = 'street.mp4';
outputFile = 'FRAMEFLOW_Original.avi';

if ~isfile(inputFile)
    error('street.mp4 not found. Check your MATLAB Current Folder.');
end

reader = VideoReader(inputFile);
writer = VideoWriter(outputFile, 'Motion JPEG AVI');
writer.FrameRate = reader.FrameRate;
open(writer);

figure('Name', 'FRAMEFLOW - Original Video');
firstFrame = readFrame(reader);
h = imshow(firstFrame);
title('FRAMEFLOW - Original Video');
writeVideo(writer, firstFrame);

while hasFrame(reader)
    frame = readFrame(reader);
    h.CData = frame;
    drawnow limitrate;
    writeVideo(writer, frame);
end

close(writer);
disp('Original video displayed and saved successfully!');
disp(outputFile);
