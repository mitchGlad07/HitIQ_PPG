function [ecg_array, imu_mag, qrs_indices] = convertECG(ecg_data,fs,samples)

%Converts the ecg signal into arrays and runs pan thomkins method

%convert from timetable to one array
ecg_workable = timetable2table(ecg_data);
ecg_array = ecg_workable.ECG{1,1};
for i = (1:(height(ecg_workable) - 1))
    ecg_array = cat(1,ecg_array,ecg_workable.ECG{i+1,1});
end
ecg_array = ecg_array(samples(1):samples(2));

%% running of pan tompkins on ecg data

[qrs_amp,qrs_indices,delay] = pan_tompkin(ecg_array,fs,1);
fprintf("ecg detected %f beats in %f seconds\n",[length(qrs_indices),length(ecg_array)/1000])
fprintf("ecg bpm reads at: %f\n",(length(qrs_indices)/(length(ecg_array)/1000)) * 60)