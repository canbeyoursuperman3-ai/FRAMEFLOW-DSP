# FRAMEFLOW project guide

## Project overview

FRAMEFLOW is a MATLAB-based Digital Signal Processing Laboratory project for examining temporal sampling in video, the visual effect of reducing frame rate, and two simple frame reconstruction methods: Zero-Order Hold (ZOH) and linear interpolation.

The project report is the detailed academic narrative. The MATLAB files are the executable artifacts. Generated videos, plots, CSV tables, and MAT files are experiment outputs and should be retained with the submission where required.

## Repository map

- `FRAMEFLOW.m` — main MATLAB workflow currently maintained at the repository root.
- `FRAMEFLOW_Project_Report.tex` — editable LaTeX source for the project report.
- `scripts/FRAMEFLOW_Playback.m` — optional standalone script to play and export the original video.
- `scripts/FRAMEFLOW_Sampling.m` — standalone temporal-sampling demonstration.
- `scripts/FRAMEFLOW_Reconstruction.m` — standalone reconstruction and MSE comparison workflow.
- `docs/IMPLEMENTATION_NOTES.md` — implementation assumptions and validation notes.

## Input and execution

The companion scripts expect a source video named `street.mp4` in the MATLAB Current Folder. If using a different file, change `inputFile` or `videoFile` in the relevant script. Run the scripts in MATLAB Online or a desktop MATLAB installation with support for `VideoReader`, `VideoWriter`, and the image-processing functions used by the selected script.

Suggested order for the standalone workflow:

1. Run `FRAMEFLOW_Playback.m` if you want to preview/export the source video.
2. Run `FRAMEFLOW_Sampling.m` to generate `FRAMEFLOW_Sampled.avi`.
3. Run `FRAMEFLOW_Reconstruction.m` after the sampled video exists.
4. Run the main `FRAMEFLOW.m` workflow for the consolidated analysis it implements.

Run each script from the folder containing the input video. Some scripts use common output filenames, so move or rename outputs between runs if you need to preserve results from different configurations.

## Interpretation

- Temporal sampling retains fewer frames from the original sequence.
- ZOH repeats a retained frame over the interval before the next retained sample.
- Linear interpolation blends adjacent retained frames to estimate intermediate frames.
- Mean squared error (MSE) is a numerical difference measure between aligned original and reconstructed frames; it is not, by itself, a complete measure of perceived video quality.
- Interpolation estimates intermediate pixel values and does not recover scene details that were never sampled.
- Temporal aliasing is a potential consequence of undersampling motion. Describe it only to the extent supported by the actual experimental observations and report.

## Reproducibility and results

The source video is not committed to this repository. Use the same input clip and parameter settings when reproducing results. Keep the generated CSV values and report tables consistent with the actual MATLAB run. Do not substitute example values for measured results.

Generated video and data files are generally kept outside Git to avoid committing large or input-specific outputs. The report source may require its referenced figures and the official institute logo to be uploaded separately when compiling in Overleaf.

## Academic integrity and scope

This repository documents an educational laboratory implementation. Cite any external source material used in the report, use a video you have permission to process, and distinguish measured results from theoretical expectations.
