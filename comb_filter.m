
close all;
clear all;
clc;
[x,Fs] =  audioread('mbt_70_experimental_us_army_1970_360p.mp4');
Nx = length(x)

df = Fs / Nx % frequency resolution of the FFT

% calculate the FFT of the signal
X = fft(x(:,1))/Nx;

%% take a look at the signal in the frequency domain in dB

dw = 2*pi/Nx;

XdB = mag2db(abs(X)); % convert to dB
XdB = XdB - max(XdB); % scale to 0dB

w = (1:(Nx/2)+1)*dw;

figure(1)
plot(f,XdB(1:Nx/2+1));
xlabel('f');
ylabel('|X(f)|(dB)');

fig1name = sprintf('|X(f)|(dB).jpg');

fullFileName1 = fullfile(fig1name);
saveas(figure(1),fullFileName1)
%% plot one sided FFT

figure(2);
f = (1:(Nx/2)+1)*df;
stem(f,abs(X(1:(Nx/2)+1)));
ylabel('|X(f)|');
xlabel('f');

fig2name = sprintf('|X(f)|.jpg');

fullFileName2 = fullfile(fig2name);
saveas(figure(2),fullFileName2)



%% look at INPUT between 130-140Hz
figure(3);

stem(f(floor(130/df):floor(140/df)),abs(X(floor(130/df):floor(140/df))));
ylabel('|X(f)|');
xlabel('f');

fig3name = sprintf('130-140_|X(f)|.jpg');

fullFileName3 = fullfile(fig3name);
saveas(figure(3),fullFileName3)

%% setup comb filter
fo = 134.8;
bw = .97; 
[b,a] = iircomb(floor(Fs/fo),bw,'notch'); % notch type comb
fvtool(b,a);

y=filter(b,a,x(:,1));

N = size(y,1);
%%
df = Fs / N;
f = (1:(Nx/2)+1)*df;
Y = fft(y(:,1))/Nx;
%% 
figure(4);
stem(f,abs(Y(1:(Nx/2)+1)));
ylabel('|Y(f)|');
xlabel("f");

%% look at the output between
figure(5);
stem(f(floor(130/df):floor(140/df)),abs(Y(floor(130/df):floor(140/df))));
xlabel("f");
ylabel("|G(f)|")

fig5name = sprintf('130-140_|G(f)|.jpg');

fullFileName5 = fullfile(fig5name);
saveas(figure(5),fullFileName5)


%% plot |Y(w)| from 100Hz to 1000Hz to see if there are any other harmonic peaks

figure(6);
stem(f,abs(Y(1:(Nx/2+1))));
xlabel("f");
ylabel("|G(f)|")


fig6name = sprintf('final_|G(f)|.jpg');

fullFileName6 = fullfile(fig6name);
saveas(figure(6),fullFileName6)

%%
dw = 2*pi/Nx;

YdB = mag2db(abs(Y)); % convert to dB
YdB = YdB - max(YdB); % scale to 0dB

w = (1:(Nx/2)+1)*dw;
figure(7)
plot(f,YdB(1:Nx/2+1));
xlabel('f');
ylabel('|G(f)|(dB)');



fig7name = sprintf('final_|G(f)|(dB).jpg');

fullFileName7 = fullfile(fig7name);
saveas(figure(7),fullFileName7)


%%
%audiowrite('COMB_output_fo=134.8_bw =.97_best.m4a',y,Fs)
