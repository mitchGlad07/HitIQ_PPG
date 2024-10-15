close all; clear all; clc;

% creates a set of independent components, one of which should be closely
% related to heart rate

% Load data
names = ["12t1c1.csv","12t1c2.csv","12t1c3.csv","12t1c4.csv","12t1c5.csv"];
comToUse = 2;
hr_data = readmatrix("Data\Raw_data\12t1.csv");
fs = 50;
time = length(hr_data) / fs;
t = 0:1/fs:time-1/fs;

band = designfilt('bandpassiir', ...
    'FilterOrder', 6, 'HalfPowerFrequency1', 0.3, ...
    'HalfPowerFrequency2', 10, 'SampleRate', fs);

filt_data = filtfilt(band, hr_data);

%% wavelet and ICA functions
xdft = fft(filt_data);
N = numel(filt_data);
xdft = xdft(1:numel(xdft)/2+1);
freq = 0:fs/N:fs/2;
figure
plot(freq, 20*log10(abs(xdft)))
xlabel('Cycles/second')
ylabel('dB')
grid on

mra = modwtmra(modwt(filt_data, 8));
helperMRAPlot(filt_data, mra, t, 'wavelet', 'Wavelet MRA', [2 3 4 9]);

% Collect D2-D6 and run through ICA
inputWaves = mra(2:6, :);
[components, W, T, mu] = fastICA(inputWaves, 5);

for i = 1:length(components(:, 1))
    figure
    plot(components(i, :))
end

%% saving of components 

%Each output was manually checked, outputs within expected range were put
%through peakDetect to check for accuracy
for i = 1:5
    writematrix(components(i,:), names(i));
end

