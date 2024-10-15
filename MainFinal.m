close all; clear all; clc;

% Required libraries:
% Physionet cardiovascular signal toolbox
% wavelet toolbox
% PCA and ICA package

% PPG files are already cut to sections used
% ECG files are the entire test, uses ecg_samples to cut down

% Load data
ppg_data = readmatrix("Data\Raw_data\20240912\lowBPM.csv");
ecg_data = edfread("Data\ECG_data\Sept12.EDF");
ecg_samples = [25000,100000]; %ecg cut for Sep12 test example

% Reconstructed ppg obtained from waveletFinal
reconstruct_ppg = readmatrix("Data\Reconstructed_data\12t1.csv"); % dataform for wavelet reconstruction

fs = 50; % sampling rate
ecg_fs = 1000;

%% Obtaining ECG heart rate
[ecg_array, ecg_imu, ecg_indices] = convertECG(ecg_data,ecg_fs,ecg_samples);

%% ICA method
[reconstruct_bpm, indices] = peakDetect(reconstruct_ppg);

%% FFT method
fft_bpm = freqAnalysis(ppg_data,fs);