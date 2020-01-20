close all;
clear all; 
clc;

 
[x,Fs] = audioread('COMB_output_fo=134.8_bw =.97_best.mp4'); 


Nx = length(x)

%%
    x = x(:,1);
%% create the data matrix
M = 256;
X = corrmtx(x,M);



%% plot the Rxx matrix

R = X'*X;

dim = size(R);
[axis1,axis2] = ndgrid(1:dim(1),1:dim(2));


%%
figure(1)
params = sprintf('Rxx,M=%d',M);

plot3(axis1,axis2,abs(R));
zlabel('R')
xlabel('n');
ylabel('n');
legend(params);


fig1name = sprintf('Rgg_M=%d.jpg',M);

fullFileName1 = fullfile(fig1name);
%saveas(figure(1),fullFileName1)


%% plot the first column of Rxx

figure(2)

params = sprintf('Rgg(1,:),M=%d',M);
stem(R(1,:))
ylabel('Rgg(1,:)');
xlabel('n');
legend(params);

fig2name = sprintf('Rgg(1,:)_M=%d.jpg',M);

fullFileName2 = fullfile(fig2name);
%saveas(figure(2),fullFileName2)

%% abs

figure(3)
params = sprintf('abs(Rx(1,:)),M=%d',M);
stem(abs(R(1,:)))
ylabel('|Rgg(1,:)|');
xlabel('n');
legend(params);

fig3name = sprintf('abs(Rgg(1,:))_M=%d.jpg',M);

fullFileName3 = fullfile(fig3name);
%saveas(figure(3),fullFileName3)

%% plot the last few seconds of the signal

Ng = floor(Nx/81);  
g = x(Nx-Ng:Nx);
G = fft(g)/Ng;

df = Fs / Ng;

line = .0006*ones(1,2500);

plot(line, 'r')

figure(4);
f = (1:(Ng/2)+1)*df;
stem(f(floor(2/df):floor(2500/df)),abs(G(floor(2/df):floor(2500/df)))); %stem(f,abs(G(1:(Ng/2)+1)));
hold on
plot(line, 'r')
hold off
ylabel('|G(f)|');
xlabel('f');



fig4name = sprintf('|G(f)|_snippet.jpg');

fullFileName4 = fullfile(fig4name);
%saveas(figure(4),fullFileName4)

%% now do eigven value decomposition to determine the optimal learning rate mu

[V,D] = eig(R);
lambda_max = max(max(D));

 mu = .00001 % mu = .0001 -- very good, mu = .00001 -- even better. 

%% calculate the delay 

r = abs(R(:,1));


L = 3;%2;
%% delay the signal               

delay = dsp.Delay(L);

xL = delay(x); % delayed version of the signal, ie the reference.

%% Using an Adaptive Line Enhancer to remove humming tone from Audio Signal. To implement the filter, I use the builtin LMSFilter, which has good performance. 

M = 32 %48 ; 64 good, 48 btter. 32 is also a best value. 
lms = dsp.LMSFilter(M,'Method','Normalized LMS','StepSize',mu);

% matlab notes: [y,err,wts] = lms(input_x,desired) 
[y,e,wts] = lms(xL,x);


release(lms)

%% plot learing curve
parameters = sprintf('M=%d, mu=%.6f, L=%d.jpg',M,mu, L);

J=e.^2;

figure(5)
plot(J)
ylabel("J(n)");
xlabel("n")
legend(parameters)

fig1name = sprintf('J(n)_M=%d,mu=%.6f,L=%d.jpg',M,mu, L);

fullFileName1 = fullfile(fig1name);
saveas(figure(5),fullFileName1)

%% FFT plots 

Y = fft(y);

dw = 2*pi/Nx;

df = Fs / Nx;
f = (1:(Nx/2)+1)*df;

YdB = mag2db(abs(Y)); % convert to dB
YdB = YdB - max(YdB); % scale to 0dB

w = (1:(Nx/2)+1)*dw;

parameters = sprintf('M=%d, mu=%.6f, L=%d.jpg',M,mu, L);


figure(7)
plot(f,YdB(1:Nx/2+1));
xlabel('f');
ylabel('|G(f)|(dB)');
legend(parameters)

fig7name = sprintf('final_|G()|(dB)_L=%d,M=%d.jpg', L, M);

fullFileName7 = fullfile(fig7name);
saveas(figure(7),fullFileName7)

 %% I probably should plot the learning curve and see if this thing is converging. I ight have to do a damn grid search again. 
Ng = floor(Nx/81); 
%sound(y(1:13*Ng),Fs)

%%
Ng = floor(Nx/81);  
yg = y(Nx-Ng:Nx);
YG = fft(yg)/Ng;

df = Fs / Ng;

figure(8);
f = (1:(Ng/2)+1)*df;
stem(f(floor(2/df):floor(2500/df)),abs(YG(floor(2/df):floor(2500/df))));  %stem(f,abs(YG(1:(Ng/2)+1)));
hold on
plot(line, 'r')
hold off
ylabel('|Y(f)|');
xlabel('f');

fig8name = sprintf('|Y(f)|_snippet.jpg');

fullFileName8 = fullfile(fig8name);

%saveas(figure(8),fullFileName8)


%% %% save the audio file
%file output name


filename = sprintf('y(n)_ALE_output_M=%d_mu=%.6f_L=%d.m4a',M,mu, L);

audiowrite(filename,y,Fs);


%% Ng = floor(Nx/81);  
yg2 = y(Nx-Ng:Nx);
YG2 = fft(yg2,Nx)/Ng;

%%
df = Fs / Nx;

figure(18);
f = (1:(Nx/2)+1)*df;
stem(f(floor(2/df):floor(2500/df)),abs(YG2(floor(2/df):floor(2500/df))));  %stem(f,abs(YG(1:(Ng/2)+1)));
hold on
plot(line, 'r')
hold off
ylabel('|Y(f)|');
xlabel('f');

fig18name = sprintf('|Y(f)|_snippet.jpg');

fullFileName18 = fullfile(fig18name);

%saveas(figure(18),fullFileName18)

 