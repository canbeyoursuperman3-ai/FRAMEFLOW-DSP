# Implementation notes

## Processing approach

The script reads the video sequentially and retains only the frames needed for the current sampling interval. This avoids storing the complete source video in a cell array, which can consume excessive memory in MATLAB Online.

For each pair of retained frames, it writes a sampled frame and generates interval frames using:
- ZOH: the earlier retained frame is repeated.
- Linear interpolation: pixel values are blended using a linearly increasing weight.

The script also handles a final partial interval by holding the last retained frame.

## Assumptions to verify

1. The source video has a stable frame rate and can be read by MATLAB's VideoReader.
2. samplingFactor is an integer of at least 2.
3. The MATLAB environment supports the Motion JPEG AVI writer profile.
4. The reconstruction frame count and playback duration are sensible for the input clip.
5. MSE values are checked against known identical-frame or hand-inspected cases before they are used as academic findings.

## Suggested validation

- Run first on a short clip (a few seconds).
- Confirm that all three AVI files open and play.
- Confirm that the sampled video has fewer frames than the reconstructed videos.
- Inspect the first, middle, and final frames for index alignment and tail handling.
- Compare the CSV frame counts with the video metadata.
- Do not report a result as experimentally verified until the script has run successfully in the target MATLAB environment.
