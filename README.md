# FRAMEFLOW — Temporal Sampling, Aliasing, and Video Reconstruction

**Digital Signal Processing Laboratory | MATLAB | CBIT (A), ECE**

FRAMEFLOW is an educational MATLAB project for studying temporal sampling in digital video and comparing two reconstruction methods: Zero-Order Hold (ZOH) and linear interpolation.

## Project overview

- **Temporal sampling:** retains selected frames from the original sequence.
- **Zero-Order Hold (ZOH):** repeats a retained frame until the next sample.
- **Linear interpolation:** blends adjacent retained frames to estimate intermediate frames.
- **Evaluation:** compares original and reconstructed frames using pixel-wise mean squared error (MSE), alongside visual and frame-rate comparisons.
- **Aliasing context:** demonstrates the consequences of reducing temporal samples; conclusions about aliasing should be tied to the observations and results recorded in the project report.

Interpolation estimates intermediate pixel values; it does not recover scene information that was never sampled.

## Repository contents

- `FRAMEFLOW.m` — main MATLAB analysis script.
- `FRAMEFLOW_Project_Report.tex` — editable LaTeX source for the academic report.
- `scripts/FRAMEFLOW_Playback.m` — standalone original-video preview and export.
- `scripts/FRAMEFLOW_Sampling.m` — standalone temporal-sampling workflow.
- `scripts/FRAMEFLOW_Reconstruction.m` — standalone ZOH/linear reconstruction and MSE comparison.
- `docs/PROJECT_GUIDE.md` — project workflow, inputs, outputs, and interpretation.
- `docs/IMPLEMENTATION_NOTES.md` — implementation assumptions and validation notes.

Generated videos and experiment-specific output files are not committed by default, keeping the repository lightweight. Keep your verified result files alongside your final report or submission package when required.

## Run in MATLAB Online

The scripts expect a source video named `street.mp4` in the MATLAB Current Folder unless the input filename is changed in the relevant script.

For the standalone workflow:

1. Upload `street.mp4` and the scripts to MATLAB Online.
2. Run `scripts/FRAMEFLOW_Playback.m` if you want to preview and export the source video.
3. Run `scripts/FRAMEFLOW_Sampling.m` to create `FRAMEFLOW_Sampled.avi` and sampling results.
4. Run `scripts/FRAMEFLOW_Reconstruction.m` after the sampled video has been created.
5. Run `FRAMEFLOW.m` for the main consolidated analysis.

The scripts use MATLAB video-reading/writing functions and the Motion JPEG AVI profile. Available codecs and performance can vary by MATLAB environment. Run scripts from the folder containing the input video and keep outputs from different runs separate if you need to preserve them.

## Typical generated outputs

Depending on which script you run, outputs include:

- `FRAMEFLOW_Original.avi`
- `FRAMEFLOW_Sampled.avi`
- `FRAMEFLOW_ZOH_Reconstructed.avi`
- `FRAMEFLOW_Linear_Reconstructed.avi`
- `FRAMEFLOW_FrameCount_Comparison.png`
- `FRAMEFLOW_Original_vs_Sampled.png`
- `FRAMEFLOW_Reconstruction_MSE.png`
- `FRAMEFLOW_Sampling_Results.csv`
- `FRAMEFLOW_Reconstruction_Results.csv`
- MAT files containing numerical data and processing variables.

## Interpretation notes

- Larger sampling factors retain fewer frames and reduce the effective frame rate.
- ZOH produces repeated frames and may appear jerky during motion.
- Linear interpolation blends pixels between adjacent samples and may introduce blur or ghosting because it does not model object motion.
- MSE is meaningful only when the original and reconstructed frames are aligned and have matching dimensions and pixel representation. It is a numerical error measure, not a complete measure of perceived video quality.
- Use the numerical values from your actual MATLAB run in the final report; do not replace measured results with example values.

## Report and reproducibility

The report source is editable LaTeX. Review it together with the actual generated figures, CSV tables, and video outputs before submission. If compiling the report in Overleaf, upload any referenced figures and the official institute logo that you intend to display.

For a fuller workflow and file guide, see [docs/PROJECT_GUIDE.md](docs/PROJECT_GUIDE.md).