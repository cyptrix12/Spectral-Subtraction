[clean_signal, Fs] = audioread('audio_files\input\clear_voice.wav');

wn = 0.05 * randn(size(clean_signal));

noisy_signal = clean_signal + wn;

audiowrite('audio_files\output\noisy_voice.wav', noisy_signal, Fs);