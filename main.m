[clean_signal, Fs_c] = audioread('audio_files\input\clear_voice.wav');
[noisy_signal, Fs_n] = audioread('audio_files\output\noisy_voice.wav');

N_n = Fs_n * 5; % First 5 second of audio file contains only white noise

z = noisy_signal(1:N_n);
y = noisy_signal;

window_size = 1024;
overlap = window_size/2; % 50%
step_size = window_size - overlap;  

num_frames = floor((N_n - overlap) / step_size);

hann_window = 0.5 - 0.5 * cos(2 * pi * (0:window_size-1)' / (window_size - 1));

frames = zeros(window_size, num_frames);

for i = 1:num_frames
    start_idx = (i - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    
    if end_idx > length(z)
        break;
    end
    
    frames(:, i) = z(start_idx:end_idx) .* hann_window;
end

Z = fft(frames);


% summed_spectrum = sum(abs(Z), 2);
% summed_spectrum = summed_spectrum(1:(window_size/2 + 1));



SZ = 1/window_size * abs(Z).^2;
% SZ = 10*log10(SZ);
summed_SZ = sum(SZ,2);
summed_SZ = summed_SZ(2:(window_size/2));
freq_axis = linspace(0, Fs/2, length(summed_SZ));

mean_SZ = mean(summed_SZ);


figure;
plot(freq_axis, summed_SZ);
xlabel('Freq [Hz]');
ylabel('db/Hz');
grid on;

%% Y

N_y = length(y);

num_frames = floor((N_y - overlap) / step_size);

hann_window = 0.5 - 0.5 * cos(2 * pi * (0:window_size-1)' / (window_size - 1));

frames = zeros(window_size, num_frames);

for i = 1:num_frames
    start_idx = (i - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    
    if end_idx > length(y)
        break;
    end
    
    frames(:, i) = y(start_idx:end_idx) .* hann_window;
end

Y = fft(frames);



SY = 1/window_size * abs(Y).^2;
summed_SY = sum(SY,2);
summed_SY = summed_SY(2:(window_size/2));
freq_axis = linspace(0, Fs/2, length(summed_SY));

mean_SZ = mean(summed_SY);


figure;
plot(freq_axis, summed_SY);
xlabel('Freq [Hz]');
ylabel('db/Hz');
grid on;

summed_SX = summed_SY - summed_SZ;
SX = max(SY - mean_SZ, 0);

A = sqrt(SX./SY);
A = max(A, 0);

X = A .* Y;

x_frames = ifft(X, 'symmetric');

reconstructed_signal = zeros(N_n, 1);

for i = 1:num_frames
    start_idx = (i - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    if end_idx > length(reconstructed_signal)
    end_idx = length(reconstructed_signal);
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

