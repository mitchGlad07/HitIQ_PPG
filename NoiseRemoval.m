function [ppg_data, ecg_data] = NoiseRemoval(hr_data, ecg)

% Removes sections of data above the desired variance to eliminate
% excessive noise, cutoff variance on line 26

% Parameters
fs_ppg = 50;    % Sample rate for PPG
fs_ecg = 1000;  % Sample rate for ECG
window_size = 0.5 * fs_ppg; % window size for 0.5 seconds

% Filtering step
f1 = 0.8; % min frequency used
f2 = 5;   % max frequency used
band = designfilt('bandpassiir', ...
    'FilterOrder', 6, 'HalfPowerFrequency1', f1, ...
    'HalfPowerFrequency2', f2, 'SampleRate', fs_ppg);
filt_data = filtfilt(band, hr_data);

% Split data into 0.5 sec periods
y_blocks = reshape(filt_data(1:floor(length(filt_data) / window_size) * window_size), window_size, []);
% Find variance of 0.5 sec periods
variances = var(y_blocks, 0, 1); % Compute variance along columns

% Determine cutoff variance
%sorted_vari = sort(variances);
cutoff_vari = 4*10^4; %sorted_vari(floor(length(sorted_vari) * 0.9));

% Identify blocks with high variance
to_remove_blocks = find(variances > cutoff_vari);

% Initialize indices to remove
ppg_to_remove_indices = [];
ecg_to_remove_indices = [];

% Calculate indices to remove for PPG and ECG
for i = 1:length(to_remove_blocks)
    block_start = (to_remove_blocks(i) - 1) * window_size + 1; % Start index in PPG
    block_end = to_remove_blocks(i) * window_size;             % End index in PPG
    
    % Append the indices to remove for PPG
    ppg_to_remove_indices = [ppg_to_remove_indices, block_start:block_end];
    
    % Calculate corresponding indices for ECG and append
    ecg_block_start = (block_start - 1) * (fs_ecg / fs_ppg) + 1;
    ecg_block_end = block_end * (fs_ecg / fs_ppg);
    ecg_to_remove_indices = [ecg_to_remove_indices, ecg_block_start:ecg_block_end];
end

% Remove indices from PPG and ECG data
new_ppg = filt_data;
new_ppg(ppg_to_remove_indices) = [];

new_ecg = ecg;
new_ecg(ecg_to_remove_indices) = [];

% Plot original PPG data with deleted segments
figure;
plot(filt_data);
hold on;
plot(ppg_to_remove_indices, filt_data(ppg_to_remove_indices), 'ro'); % 'ro' for red circles
title("Deleted Segments in the PPG Signal");
xlabel("Sample Index");
ylabel("Signal Value");
legend("Filtered Signal", "Segments of too high variance", 'Location', 'south');

% Plot the cleaned PPG data
figure;
plot(new_ppg);
title("High Variance Segments Removed from PPG");
xlabel("Sample Index");
ylabel("Signal Value");

% Optionally, plot the cleaned ECG data
figure;
plot(new_ecg);
title("Corresponding ECG Data after Noise Removal");
xlabel("Sample Index");
ylabel("ECG Signal Value");

% Return the cleaned data
ppg_data = new_ppg;
ecg_data = new_ecg;

end
