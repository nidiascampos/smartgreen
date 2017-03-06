% main file to create a KF for terpcom application
function  main()
% general commands
close all;
clear all;
clc;

DEBUG =0;

figure(1); hold on;

% Initialization
dt = 0.1; % time
bet = 1/10; % beta
A = [1 0; 0 exp(-bet*dt)]; % State transistion matrix
% state are -> x1=h, x2 = h_err = h_pred - h = h_msl-h_dma - h
% x1dot = w1 ~=N[0, sigma1^2], sigma1 = 20
% x2dot = -beta*x2+w2 sqrt(2sigma2^2*beta) -> sigma2=45

Xhat = [160 2]';
Phat = [10 0; 0 10];
% process noise
sigma1 = 20*dt;
sigma2 = 45*dt;

% measurement model 
H = [1 1; 1 0];

% measurement noise
sigma3 = 10*dt;
sigma4 = 20*dt;

Q = diag([sigma1 sigma2]);
R = diag([sigma3 sigma4]);


% UAV initialization
uvel = 10;
xv = uvel*cos(0);
yv = uvel*sin(0);
zv = 160;

% create terrain
[terrainHeight,terrainTime] = createTerrain; 
plot(terrainHeight,'r');

%CREATE TRUE STUFF
hmslTrue = mslDataTrue(zv,terrainTime);
hdmaTrue = dmaDataTrue(terrainHeight);



% create MSL data
hmsl = mslData(zv,terrainTime,sigma3/dt);
plot(hmsl,'b');
plot(ones(length(hmsl),1)*zv,'k');

% create DMA data
hdma = dmaData(terrainHeight,sigma4/dt);
plot(hdma,'.b');

% particle filter settings
N =100; %number os particles
xp=[];
% make the random particles based on initial gaussian distribution
for ii = 1:N
    xp(ii,1)= 60 + sigma1*randn;
    xp(ii,2)= 2 + sigma2*randn;
end

if(DEBUG)
    figure();
    plot(1,p(:,1),'*r',1,p(:,2),'*b');
    legend('initial distribution');
end



% Main loop
t = 0;
simTime = 299;
ind = 1;
while t < simTime
   
    
   
    
    
    % for all particles
    
    % using the state transittion update new position on all the
    % particles + noise
    xp(:,1) = 1*xp(:,1) + randn([N,1])*sigma1/2;
    xp(:,2) = exp(-bet*dt)*xp(:,2) + randn([N,1])*(sigma2/2);
    
    % predited measurement for the particles
    yp(:,1)= xp(:,1) + xp(:,2) + sigma3*randn([N,1]);
    yp(:,2)= xp(:,1) + sigma4*randn([N,1]); % H=[ 1 1; 1 0]*[x1,X2]'
    
    
    %get observations
    z1 = interp1(terrainTime,hmsl,t) - interp1(terrainTime,hdma,t); % measurement z1 = hmsl - hdma
    z2 = interp1(terrainTime,zv-terrainHeight,t);
    % add some noise and form state obeservation
    z = [z1 z2]'+ R *[prand(sigma3/2) prand(sigma4/2)]';
    
    % compute the weights based on gaussian centered value
    %predicted measurements that are close to the observation have more weight
    % combine a 2d gaussian distribution for x1,x2
    w(:,1) =(1/sqrt(2*pi*R(1,1)*R(2,2)))*exp(-( ( z(1) - yp(:,1)).^2/(2*R(1,1) ) + ( z(2) - yp(:,2)).^2/(2*R(2,2)) ));
    
    
    
    
    
    % normalize thr likelihood for particles
    w = w./sum(w);
    
    % get the state
    x_est =[sum(xp(:,1).*w) sum(xp(:,2).*w)];
    
    
    
    
    % resample
    Neff =1./sum(w.*w); % calculates the number efective of particles that are representing the state
    rho=Neff/N; 
    
    % if the valu is lower than the threshold, resample (this avoids always
    % resampling at each iteraction
    if rho <0.7
        [xp(:,:), w(:,:)] = navresample(xp(:,:),w(:));
    end
    
    
    
    % Linear kalman
    
    % prediction
    Xhat = A*Xhat+[prand(sigma1/2) prand(sigma2/2)]';
    Phat = A*Phat*A'+ Q;
    
    % update variables
    z1 = interp1(terrainTime,hmsl,t) - interp1(terrainTime,hdma,t); % measurement z1 = hmsl - hdma
    z2 = interp1(terrainTime,zv-terrainHeight,t)  ;
    z = [z1 z2]'+ R *[prand(sigma3/2) prand(sigma4/2)]';
    Innovation = z-H*Xhat;
    S = H*Phat*H'+R;
    W = Phat*H'*inv(S);
    
    %update
    Xhat = Xhat+W*Innovation;
    Phat = Phat-W*S*W';
    ind = ind + 1;
    t = t + dt;
    
    
    % get the Sd
    st=std(xp(:,:));
    u(ind,1)=mean(st);
    st(ind,:)= st;
    
    % ploting the eros
    XdataP(ind,:) = x_est';%plot(t,zv-x_est(1),'*r','LineWidth',4);
    Xdata(ind,:) = Xhat';  %plot(t,zv-Xhat(1),'.b','LineWidth',4);
    %     figure(2);hold on;
    %     PlotEllipse(Xhat,Phat,0.5);
    
    % savind data for post analisys
    Xtrue(ind,1) = interp1(terrainTime,hmslTrue,t) - interp1(terrainTime,hdmaTrue,t);
    Xtrue(ind,2) = interp1(terrainTime,zv-terrainHeight,t);
    Xest(ind,:) = Xhat';
    Pest(ind,:,:) =Phat;
    
    
    
    
end

plot(0:.1:(simTime+0.1),zv-Xdata(:,1),'k')
plot(0:.1:(simTime+0.1),zv-XdataP(:,1),'g')
plot(terrainHeight,'r','LineWidth',2);

figure(2);
hold on
plot(0:.1:(simTime+0.1), Xest(:,1),'r',0:.1:(simTime+0.1),Xtrue(:,1)+3*sqrt(squeeze(Pest(:,1,1))),'b',0:.1:(simTime+0.1),Xtrue(:,1)-3*sqrt(squeeze(Pest(:,2,2))),'b');
legend('Estimated h', 'Estimated h Error');
xlabel('Time');
ylabel('Value');
title('Error Analysis');

figure(3);
hold on
plot(0:.1:(simTime+0.1), Xest(:,2),'r',0:.1:(simTime+0.1),3*sqrt(squeeze(Pest(:,2,2))),'b',0:.1:(simTime+0.1),-3*sqrt(squeeze(Pest(:,2,2))),'b');
legend('Estimated h', 'Estimated h Error');
xlabel('Time');
ylabel('Value');
title('Error Analysis');

figure(4)
hold on
plot(0:.1:(simTime+0.1), u(:,1),'r');

end



function val = prand(sigma)

randVal = rand;
if rand >= 0.5
    val = sigma*randVal;
else
    val = -sigma*randVal;
end

end

function hmsl = mslData(xv,terrainTime,hmslError)

hmsl = zeros(length(terrainTime),1);
for i = 1:length(terrainTime)
    hrand = rand;
    if (rand-0.5) > 0
        hmsl(i) = xv+hrand*hmslError;
    else
        hmsl(i) = xv-hrand*hmslError;
    end
end
end

function hdma = dmaData(terrainHeight, dmaError)

for i = 1:length(terrainHeight)
    hrand = rand;
    if rand > 0.5
        hdma(i) = terrainHeight(i) + hrand*dmaError;
    else
        hdma(i) = terrainHeight(i) - hrand*dmaError;
    end
end
end

% CREATE TRUE STUFF
function hmsl = mslDataTrue(xv,terrainTime)

hmsl = zeros(length(terrainTime),1);
for i = 1:length(terrainTime)
        hmsl(i) = xv;   
end
end

function hdma = dmaDataTrue(terrainHeight)

hdma = zeros(length(terrainHeight),1);
for i = 1:length(terrainHeight)
        hdma(i) = terrainHeight(i);
    
end
end


