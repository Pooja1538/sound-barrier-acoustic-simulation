clc; clear; close all;
%% Step 1: User Input - Barrier Selection
barrierTypes = {'Concrete', 'Wood', 'Glass', 'Vegetation'};
barrierProperties = {
    'Concrete: Blocks high frequencies, effective against traffic noise', 
    'Wood: Reduces mid frequencies, commonly used in residential areas', 
    'Glass: Reflects low frequencies but lets high frequencies pass', 
    'Vegetation: Absorbs specific frequencies, eco-friendly option'};
fprintf('\n==============================\n');
disp('AVAILABLE SOUND BARRIERS');
fprintf('==============================\n\n');
for i = 1:length(barrierTypes)
    fprintf('%d. %s → %s\n', i, barrierTypes{i}, barrierProperties{i});
end
fprintf('\n==============================\n');
barrierChoice = input('Enter the number of your chosen barrier: ');
if barrierChoice < 1 || barrierChoice > length(barrierTypes)
    error('Invalid selection! Please restart and choose a valid option.');
end
selectedBarrier = barrierTypes{barrierChoice};
fprintf('\nYOU SELECTED: %s\n', upper(selectedBarrier));
fprintf('%s\n', barrierProperties{barrierChoice});
fprintf('==============================\n');
%% Step 2: Get Barrier Dimension Input
switch selectedBarrier
    case 'Concrete'
        dimension = input('Enter height of the concrete wall (in meters): ');
    case 'Wood'
        dimension = input('Enter thickness of the wooden barrier (in meters): ');
    case 'Glass'
        dimension = input('Enter thickness of the glass barrier (in meters): ');
    case 'Vegetation'
        dimension = input('Enter height of the vegetation (in meters): ');
end
%% Step 3: Select Audio File
[filename, filepath] = uigetfile({'.wav;.mp3;.flac', 'Audio Files (.wav, *.mp3, *.flac)'}, 'Select an Audio File');
if isequal(filename, 0)
    error('No file selected. Please restart and select a valid audio file.');
end
audioFile = fullfile(filepath, filename);
fprintf('\nSelected Audio File: %s\n', audioFile);
%% Step 4: Load and Normalize Audio
[noiseSignal, fs] = audioread(audioFile);
if size(noiseSignal, 2) > 1
    noiseSignal = mean(noiseSignal, 2);
end
noiseSignal = noiseSignal / max(abs(noiseSignal));
%% Step 5: Apply Filter Based on Barrier and Dimension
switch selectedBarrier
    case 'Concrete'
        base_fc_low = 500;
        fc = base_fc_low / dimension;
        [b, a] = butter(4, fc/(fs/2), 'low');
    case 'Wood'
        base_band = [300 3000];
        widthFactor = max(0.1, 1 / dimension);
        fc = base_band .* widthFactor;
        [b, a] = butter(4, fc/(fs/2), 'bandpass');
    case 'Glass'
        base_fc_high = 1000;
        fc = base_fc_high * dimension;
        [b, a] = butter(4, fc/(fs/2), 'high');
    case 'Vegetation'
        base_notch = 800;
        notch_freq = base_notch;
        Q = min(50, 5 * dimension);
        [b, a] = iirnotch(notch_freq/(fs/2), notch_freq/(fs/2)/Q);
end
filteredNoise = filter(b, a, noiseSignal);
%% Step 6: SPL Analysis
SPL_before = 20 * log10(rms(noiseSignal) / 20e-6);
SPL_after = 20 * log10(rms(filteredNoise) / 20e-6);
WHO_SAFE_LIMIT = 55;
%% Step 7: Suggest Dimension Adjustment if Needed
if SPL_after < WHO_SAFE_LIMIT
    fprintf('\nCurrent barrier is sufficient. SPL after: %.2f dB\n', SPL_after);
else
    fprintf('\nSPL after filtering is %.2f dB which is above the safe limit of %.2f dB.\n', SPL_after, WHO_SAFE_LIMIT);
    fprintf('Finding minimum required %s size...\n', lower(selectedBarrier));
    new_dim = dimension;
    max_dim = 10;
    while SPL_after > WHO_SAFE_LIMIT && new_dim < max_dim
        new_dim = new_dim + 0.1;
        switch selectedBarrier
            case 'Concrete'
                fc = base_fc_low / new_dim;
                [b, a] = butter(4, fc/(fs/2), 'low');
            case 'Wood'
                widthFactor = max(0.1, 1 / new_dim);
                fc = base_band .* widthFactor;
                [b, a] = butter(4, fc/(fs/2), 'bandpass');
            case 'Glass'
                fc = base_fc_high * new_dim;
                [b, a] = butter(4, fc/(fs/2), 'high');
            case 'Vegetation'
                Q = min(50, 5 * new_dim);
                [b, a] = iirnotch(notch_freq/(fs/2), notch_freq/(fs/2)/Q);
        end
        filteredNoise = filter(b, a, noiseSignal);
        SPL_after = 20 * log10(rms(filteredNoise) / 20e-6);
    end
    if new_dim >= max_dim
        fprintf('Even max size (%.1f m) of %s barrier cannot reduce SPL below safe limit.\n', max_dim, selectedBarrier);
    else
        fprintf('Increase %s to at least %.2f meters to meet WHO safe limit.\n', lower(selectedBarrier), new_dim);
    end
end
%% Step 8: Display FFT and Spectrogram
n = length(noiseSignal);
n_half = floor(n / 2);
f = (0:n_half-1) * (fs / n);
fft_noise = abs(fft(noiseSignal));
fft_filtered = abs(fft(filteredNoise));
fft_noise = fft_noise(1:n_half);
fft_filtered = fft_filtered(1:n_half);
figure;
subplot(2,1,1); plot(f, fft_noise); title('FFT Before Barrier'); xlabel('Frequency (Hz)'); ylabel('Amplitude');
subplot(2,1,2); plot(f, fft_filtered); title(['FFT After ', selectedBarrier, ' Barrier']); xlabel('Frequency (Hz)'); ylabel('Amplitude');
figure;
subplot(2,1,1); spectrogram(noiseSignal, 256, 200, 256, fs, 'yaxis'); title('Spectrogram Before');
subplot(2,1,2); spectrogram(filteredNoise, 256, 200, 256, fs, 'yaxis'); title(['Spectrogram After ', selectedBarrier]);
figure;
bar([SPL_before, SPL_after]);
set(gca, 'xticklabels', {'Before', 'After'});
ylabel('SPL (dB)');
title(sprintf('SPL Reduction Using %s Barrier', selectedBarrier));
grid on;
