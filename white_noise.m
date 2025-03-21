[clean_signal, Fs] = audioread('audio_files\input\clear_voice.wav');

wn = 1 * randn(size(clean_signal));

noisy_signal = clean_signal + wn;

save('audio_files\output\noisy_voice.mat', 'noisy_signal', 'Fs');