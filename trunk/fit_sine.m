function [tfit yfit]=fit_sine(y)
%sine fit
x=(1:size(y,1))';
[M loc] = max(y);

NFFT = 2^nextpow2(length(y));
Yfft = fft(y-mean(y),NFFT);
f = 1/2*linspace(0,1,NFFT/2+1);
% figure; plot(f,abs(Yfft(1:NFFT/2+1)))
[m mindx]=max(abs(Yfft(1:NFFT/2+1)));
period=1/f(mindx);

X = [ones(size(x)) cos((2*pi/period)*(x-loc))];
s_coeffs = X\y;
tfit = (1:0.01:length(x))';
yfit = [ones(size(tfit)) cos((2*pi/period)*(tfit-loc))]*s_coeffs; 