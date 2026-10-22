# FRAMEFLOW — Temporal Sampling and Video Reconstruction

**Digital Signal Processing Laboratory | MATLAB**

FRAMEFLOW is an educational MATLAB project that makes temporal sampling visible by reducing the number of frames in a video and comparing two simple reconstruction methods:

- **Temporal sampling:** retains one frame every M frames.
- **Zero-Order Hold (ZOH):** repeats the most recently retained frame.
- **Linear interpolation:** blends adjacent retained frames to estimate intermediate frames.
- **Evaluation:** records output frame counts and computes pixel-wise mean squared error (MSE) against corresponding source frames processed by the script.

The purpose is to illustrate how fewer temporal samples affect motion continuity and how simple reconstruction methods differ. Interpolation estimates missing frames; it does not recover scene information that was never observed.

## Repository contents

- FRAMEFLOW.m — main MATLAB script.
- FRAMEFLOW_Project_Report.tex — editable LaTeX report draft.
- docs/IMPLEMENTATION_NOTES.md — workflow, assumptions, and verification notes.
- Generated outputs are written to FRAMEFLOW_Output/ when the script is run. Large videos and generated results are intentionally not committed to this repository.

## Run in MATLAB Online

1. Download FRAMEFLOW.m from this repository.
2. Upload the script and a video file to MATLAB Online. The default input name is street.mp4; edit inputFile near the top of the script if your video has a different name.
3. Run FRAMEFLOW.m.
4. Open the FRAMEFLOW_Output folder and inspect the AVI files, PNG plots, CSV summary, and MAT data.

The script uses the **Motion JPEG AVI** writer profile. Codec availability can vary by MATLAB environment.

## Main output files

- FRAMEFLOW_Sampled.avi
- FRAMEFLOW_ZOH_Reconstructed.avi
- FRAMEFLOW_Linear_Reconstructed.avi
- FRAMEFLOW_FrameCount_Comparison.png
- FRAMEFLOW_Reconstruction_MSE.png (when interval data is available)
- FRAMEFLOW_Sampling_Results.csv
- FRAMEFLOW_Sampling_Data.mat

## Parameters

At the beginning of FRAMEFLOW.m:

- inputFile: path/name of the input video.
- samplingFactor: integer of 2 or greater; larger values retain fewer frames.

## Important interpretation notes

- The input video is not included. Use a video file that you have permission to process.
- MSE is meaningful only for correctly aligned frames of the same dimensions and pixel representation. Here, the script calculates it interval by interval against source frames held in the current interval buffer. Review indexing and output durations for your chosen video before quoting numerical conclusions.
- ZOH intentionally produces repeated frames. Linear interpolation can create blur or ghosting because it blends pixels without modelling object motion.
- Generated plots and numerical values should be produced by running the script; this repository does not claim that any specific numerical result has already been experimentally verified.

## Project report

The LaTeX file is an editable report draft. Before academic submission, review it against the final code and actual generated outputs, replace any figure placeholders, and verify every result and claim.

## Reproducibility

This repository is intended for educational demonstration. Keep the input video and generated outputs separate from the source code so the experiment can be rerun with a different clip.
