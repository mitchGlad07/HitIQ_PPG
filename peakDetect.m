function [bpm, peak_indices] = peakDetect(hr_data)



%% analysis

% Peak detection algorithm
w1 = 7; % min width of a peak in samples
w2 = 30; % size of component to check at a time
fs = 50;

time = length(hr_data) / fs;
t = 0:1/fs:time-1/fs;

y_enhance = hr_data;

% Generating blocks of interest
MA_event = movmean(y_enhance, w1);
MA_cycle = movmean(y_enhance, w2);

% Ensure lengths match by padding NaNs
if length(MA_event) < length(y_enhance)
    MA_event = [nan(w1-1, 1); MA_event];  % Pad with NaNs at the beginning
end

if length(MA_cycle) < length(y_enhance)
    MA_cycle = [nan(w2-1, 1); MA_cycle];  % Pad with NaNs at the beginning
end

% Calculate threshold
thresh1 = MA_cycle + 0.11;

% Ensure thresh1 matches the length of y_enhance
if length(thresh1) < length(y_enhance)
    thresh1 = [nan(length(y_enhance) - length(thresh1), 1); thresh1];
end

% Plotting
figure
plot(t(1:length(MA_event)), MA_event, t(1:length(thresh1)), thresh1, 'r--')
title("Thresholding of Events")
legend("Moving Event Average", "Threshold")

blocks = MA_event > thresh1;

% Find connected components of 1's
cc = bwconncomp(blocks);

% Initialize arrays to store peaks and their indices
peaks = [];
peak_indices = [];

% Loop through each connected component
for i = 1:cc.NumObjects
    componentIndices = cc.PixelIdxList{i};

    % Ensure the current component has valid indices
    if ~isempty(componentIndices) && all(componentIndices <= length(y_enhance))
        if length(componentIndices) >= w1
            blockData = y_enhance(componentIndices);
            [~, maxIdx] = max(blockData);
            peakIdx = componentIndices(maxIdx);
            peaks = [peaks; y_enhance(peakIdx)];
            peak_indices = [peak_indices; peakIdx];
        end
    else
        disp(['Component ', num2str(i), ' has invalid indices.']);
    end
end

% plot detected peaks for clarification
figure
plot(t,y_enhance)
hold on
plot(peak_indices/50, peaks, 'ro') % 'ro' for red circles
title("Detected Peaks in the Signal")
xlabel("time")
ylabel("Enhanced Signal Value")
legend("Enhanced PPG Signal", "Detected Peaks")

% Calculate time intervals between successive peaks
if length(peak_indices) > 1
    peak_intervals = diff(peak_indices) / fs; % Convert sample intervals to seconds
    avg_interval = mean(peak_intervals); % Average interval in seconds
    bpm = 60 / avg_interval; % Convert interval to BPM
    disp(['Estimated Beats Per Minute (BPM): ', num2str(bpm)]);
else
    disp('Not enough peaks to estimate BPM.');
end
