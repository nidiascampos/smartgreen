% https://www.mathworks.com/matlabcentral/newsreader/view_thread/5706
vn=0.8;%noise amplitude
v=1;%voltage in volts
f=1000;%frequency in Hertz
w=2*pi*f;
t=linspace(0,5,1000)*1e-3;%time = 0 to 5ms
mysignal=v*sin(w*t)+vn*rand(size(t));
% clearsignal=v*sin(w*t)+vn*rand;
clearsignal=smooth(mysignal,0.1,'rlowess');
plot(t,mysignal);
hold on
plot(t,clearsignal,'LineWidth',2);