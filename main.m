%% Notes

% y - full signal
% x - clear signal
% z - noise signal

% y = x + z


%% Reading audio files

clear all;
close all;
clc;

[clean_signal, Fs_c] = audioread('audio_files\input\clear_voice.wav');
load('audio_files\output\noisy_voice.mat');
Fs_n = Fs;

%% Getting noise signal and noisy signal
N_n = Fs_n * 40; % First 5 second of audio file contains only white noise

% z = noisy_signal(1:N_n);
y = noisy_signal;

z = randn(N_n,1);

%% Setting configuration for hann windows

window_size = 256;
overlap = window_size/2; % 50%
step_size = window_size;  

num_frames = floor((N_n - overlap) / step_size);

hann_window = 0.5 - 0.5 * cos(2 * pi * (0:window_size-1)' / (window_size - 1));
s_win = norm(hann_window,2)^2;

%% Getting z frames via hann windows

z_frames = zeros(window_size, num_frames);

for i = 1:num_frames
    start_idx = (i - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    
    if end_idx > length(z)
        break;
    end
    
    z_frames(:, i) = z(start_idx:end_idx) .* hann_window;
end

periodogram(z_frames);
pwelch(z, hann_window);

%% FFT z - noise signal

Z = fft(z_frames);

% Pz = 1/window_size * abs

% summed_spectrum = sum(abs(Z), 2);
% summed_spectrum = summed_spectrum(1:(window_size/2 + 1));

%% PSD z - noise signal

SZ = 1/s_win * abs(Z).^2;
% SZ = 10*log10(SZ);

figure;
plot(mean(SZ(:,1:6400), 2))
mean(SZ(:,1:10), 2)

summed_SZ = sum(SZ,2);
summed_SZ = summed_SZ(2:(window_size/2));
freq_axis = linspace(0, Fs_n/2, length(summed_SZ));


mean_SZ = mean(summed_SZ);


figure;
plot(freq_axis, summed_SZ);
title('SZ')
xlabel('Freq [Hz]');
ylabel('db/Hz');
grid on;

%% y frames

N_y = length(y);

num_frames = floor((N_y - overlap) / step_size);

hann_window = 0.5 - 0.5 * cos(2 * pi * (0:window_size-1)' / (window_size - 1));

y_frames = zeros(window_size, num_frames);

for i = 1:num_frames
    start_idx = (i - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    
    if end_idx > length(y)
        break;
    end
    
    y_frames(:, i) = y(start_idx:end_idx) .* hann_window;
end

%% FFT y - full signal

Y = fft(y_frames);

%% PSD y - full signal

SY = 1/window_size * abs(Y).^2;



summed_SY = sum(SY,2);
summed_SY = summed_SY(2:(window_size/2));
freq_axis = linspace(0, Fs_n/2, length(summed_SY));

mean_SZ = mean(summed_SY);


figure;
plot(freq_axis, summed_SY);
xlabel('Freq [Hz]');
title('SY');
ylabel('db/Hz');
grid on;

%% Getting SX

summed_SX = summed_SY - summed_SZ;
SX = max(SY - mean_SZ, 0);

freq_axis = linspace(0, Fs_n/2, length(summed_SY));

figure;
hold on;
plot(freq_axis, summed_SY)
plot(freq_axis, summed_SX);
title("SY, SX");
xlabel('Hz');
ylabel('Amp');
grid on;

%% Filter A design

A = sqrt(SX./SY);
A = max(A, 0);

%% Getting X FFT

X = A .* Y;
X_summed = sum(X, 2);
X_summed = X_summed(2:(window_size/2));

%% Getting x(t)

x = ifft(X_summed);
x_frames = ifft(X, [], 1, 'symmetric');
reconstructed_signal = zeros(length(noisy_signal), 1);

num_frames = size(x_frames, 2); 


for i = 1:num_frames
    start_idx = (i - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    if end_idx > length(reconstructed_signal)
        end_idx = length(reconstructed_signal);
        break;
    end

    reconstructed_signal(start_idx:end_idx) = reconstructed_signal(start_idx:end_idx) + x_frames(1:(end_idx-start_idx+1), i);
end

reconstructed_signal = reconstructed_signal / 2; % Works only with 50% overlap


figure;

subplot(2,1,1);
plot(z);
title('Original audio');
xlabel('n');
ylabel('Amp');
grid on;

subplot(2,1,2);
plot(reconstructed_signal, 'b');
title('Reconstructed signal');
xlabel('n');
ylabel('Amp');
grid on;

