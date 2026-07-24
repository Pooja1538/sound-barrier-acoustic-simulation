# sound-barrier-acoustic-simulation
MATLAB simulation of acoustic attenuation by different sound barrier materials (Concrete, Wood, Glass, Vegetation) on real audio, with automatic barrier-size optimization against the WHO 55 dB safe limit.

# Sound Barrier Acoustic Simulation

Digital Signal Processing project simulating the noise-attenuation effect of different
sound barrier materials on real-world audio recordings, and checking whether each
barrier brings noise down to the World Health Organization (WHO) safe sound level
limit of **55 dB**.

## Aim
Urban and residential areas are frequently exposed to noise pollution from traffic,
construction, and industrial activity. Sound barriers are a common mitigation measure,
but different materials attenuate sound differently depending on frequency. This project
models and compares four barrier types — Concrete, Wood, Glass, and Vegetation — using
digital filters, and evaluates their real-world effectiveness against WHO guidelines.

## Objectives
- Simulate noise attenuation characteristics of different barrier materials
- Analyze how barrier dimension affects Sound Pressure Level (SPL)
- Visualize frequency-domain (FFT) and time-frequency-domain (spectrogram) changes
- Suggest a minimum barrier dimension if the selected size is insufficient

## Methodology

### 1. Barrier Selection
User selects one of four barrier types, each modeled with a different filter behavior:

| Barrier    | Filter Type                  | Acoustic Behavior                          |
|------------|-------------------------------|---------------------------------------------|
| Concrete   | 4th-order low-pass Butterworth | Blocks high-frequency noise                |
| Wood       | 4th-order band-pass Butterworth| Reduces mid-frequency components           |
| Glass      | 4th-order high-pass Butterworth| Reflects low, passes high frequencies      |
| Vegetation | Notch (band-stop) IIR filter   | Absorbs specific frequency bands           |

### 2. Dimension Input
- Concrete & Vegetation → height (m)
- Wood & Glass → thickness (m)

Dimension dynamically sets the filter's cutoff frequency / quality factor.

### 3. Audio Input
User selects a `.wav`, `.mp3`, or `.flac` file. Audio is loaded, converted to mono if
needed, and normalized.

### 4. Filtering
The selected barrier's filter (Butterworth or notch) is applied to the audio signal.

### 5. SPL Analysis
Sound Pressure Level is computed (via RMS) before and after filtering, and compared
against the WHO 55 dB safe limit.

### 6. Automatic Barrier Optimization
If SPL after filtering still exceeds 55 dB, the script incrementally increases the
barrier dimension (up to a 10 m max) and re-filters until the limit is met or the max
size is reached.

### 7. Visualization
- FFT (frequency domain) before/after filtering
- Spectrograms (time-frequency domain) before/after filtering
- Bar chart comparing SPL before vs. after

## Files
- `sound_barrier_simulation.m` — main MATLAB script (barrier selection, filtering, SPL
  analysis, optimization loop, and all visualizations)

## Requirements
- MATLAB with the **Signal Processing Toolbox** (for `butter`, `iirnotch`, `filter`,
  `spectrogram`)

## Usage
```matlab
sound_barrier_simulation
```
Run in MATLAB — the script will prompt for barrier type, dimension, and an audio file
via a file-selection dialog.

## Results Interpretation
- **FFT & Spectrograms** — show how each barrier reshapes the frequency content
- **SPL bar chart** — shows whether the barrier brings noise to a safe level
- **Dimension suggestion** — minimum size needed if the original choice falls short

## Conclusion
Demonstrates how different barrier materials attenuate sound across frequencies,
provides SPL evaluation against WHO health guidelines, and gives automated sizing
recommendations for real-world barrier design.

## Future Work
- GUI for improved user experience
- Real-time audio playback before/after filtering
- Exportable reports with plots and data summaries
- More advanced acoustic modeling (reflections, absorption coefficients)


