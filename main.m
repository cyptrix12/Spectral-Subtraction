[clean_signal, Fs_c] = audioread('audio_files\input\clear_voice.wav');
[noisy_signal, Fs_n] = audioread('audio_files\output\noisy_voice.wav');

N_n = Fs_n * 5; % First 5 second of audio file contains only white noise

z = noisy_signal(1:N_n);

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

reconstructed_signal = zeros(N_n, 1);

for i = 1:num_frames
    start_idx = (i - 1) * step_size + 1;
    end_idx = start_idx + window_size - 1;
    
    reconstructed_signal(start_idx:end_idx) = reconstructed_signal(start_idx:end_idx) + frames(:, i);
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

