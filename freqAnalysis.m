function smoothed_bpm = freqAnalysis(hr_data, fs)

% Filters data and estimates heart rate through averaging fft every second

% Initialize variables
f1 = 0.8; % min frequency used
f2 = 5; % max frequency used
window_size = 1 * fs; % window size for 3 seconds
num_windows = floor(length(hr_data) / window_size);

% Filtering step
band = designfilt('bandpassiir', ...
    'FilterOrder', 6, 'HalfPowerFrequency1', f1, ...
    'HalfPowerFrequency2', f2, 'SampleRate', fs);
y = filtfilt(band, hr_data);

peak_frequencies = zeros(num_windows, 1); % Store peak frequencies

for i = 1:num_windows
    % Extract segment
    segment = y((i-1)*window_size + 1:i*window_size);
    
    % FFT
    freq = fft(segment);
    N = length(freq); % number of points in FFT
    f = (0:N-1)*(fs/N); % frequency vector

    % Calculate magnitude
    magnitude = abs(freq)/N; % normalize the magnitude

    % Find the peak frequency
    [peak_mag, peak_idx] = max(magnitude(1:N/2)); % Get peak magnitude and index
    peak_frequencies(i) = f(peak_idx); % Store corresponding frequency
end

% Calculate average peak frequency
avg_peak_freq = mean(peak_frequencies);

% Convert average peak frequency to BPM
smoothed_bpm = avg_peak_freq * 60; % BPM calculation

% Display the average peak frequency and BPM
fprintf('Average Peak Frequency: %.2f Hz\n', avg_peak_freq);
fprintf('Smoothed Estimated BPM: %.2f\n', smoothed_bpm);

end