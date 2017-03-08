%% SETTINGS

% date range
periodoComparacao = datetime({'31/01/2017' '07/02/2017'});

% wrkf
Yn = sensor2fusedESD;
x = 1; % initial state value
P = 0.01;
A = 1;
C = 1;
Q = .005;
R = 0.64;
ss_wrKF.sum_wzxT = 0;                
ss_wrKF.sum_wxxT = 0;
ss_wrKF.sum_xxold = 0;
ss_wrKF.sum_xxoldT = 0;
ss_wrKF.sum_N = 0;
ss_wrKF.sum_wzz = 0;
ss_wrKF.sum_wzx = 0;
ss_wrKF.sum_ExTx = 0;
ss_wrKF.sum_Exxold = 0;

%% FILTERING
% WRKF
[wrkf, weight, S, P, A, C, Q, R, ss] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);

% LOESS
loess01 = smooth(sensor2fusedESD,0.1,'loess');
loess02 = smooth(sensor2fusedESD,0.2,'loess');
loess03 = smooth(sensor2fusedESD,0.3,'loess');
loess04 = smooth(sensor2fusedESD,0.4,'loess');

% RLOESS
rloess01 = smooth(sensor2fusedESD,0.1,'rloess');
rloess02 = smooth(sensor2fusedESD,0.2,'rloess');
rloess03 = smooth(sensor2fusedESD,0.3,'rloess');
rloess04 = smooth(sensor2fusedESD,0.4,'rloess');

% RLWOESS
rlowess01 = smooth(sensor2fusedESD,0.1,'rlowess');
rlowess02 = smooth(sensor2fusedESD,0.2,'rlowess');
rlowess03 = smooth(sensor2fusedESD,0.3,'rlowess');
rlowess04 = smooth(sensor2fusedESD,0.4,'rlowess');

% SAVITZKY-GOLAY
sgolay1 = smooth(sensor2fusedESD,'sgolay',1);
sgolay2 = smooth(sensor2fusedESD,'sgolay',2); % valor default
sgolay3 = smooth(sensor2fusedESD,'sgolay',3);
sgolay4 = smooth(sensor2fusedESD,'sgolay',4);

%% PLOTTING
filtering = figure;
plot(baterias_Mean.Date,baterias_Mean.baterias_p45cmMean*0.3,'--d','DisplayName','tensiometros');
hold on;
plot(dateRange,sensor2fusedESD,'DisplayName','ESD','LineStyle','-.','Visible','on');
plot(dateRange,sensor2fusedKAFalt,'DisplayName','ESD+Kalman','LineStyle','--','Visible','on');

% LOESS
% plot(dateRange,loess01,'DisplayName','ESD+loess 0.1');
plot(dateRange,loess02,'DisplayName','ESD+loess 0.2','Marker','+','Visible','on');
% plot(dateRange,loess03,'DisplayName','ESD+loess 0.3');
% plot(dateRange,loess04,'DisplayName','ESD+loess 0.4');

% RLOESS
plot(dateRange,rloess01,'DisplayName','ESD+rloess 0.1','Marker','*','Visible','on');
% plot(dateRange,rloess02,'DisplayName','ESD+rloess 0.2');
% plot(dateRange,rloess03,'DisplayName','ESD+rloess 0.3');
% plot(dateRange,rloess04,'DisplayName','ESD+rloess 0.4');

% RLOWESS
plot(dateRange,rlowess01,'DisplayName','ESD+rlowess 0.1','Marker','x','Visible','on');
% plot(dateRange,rlowess02,'DisplayName','ESD+rlowess 0.2');
% plot(dateRange,rlowess03,'DisplayName','ESD+rlowess 0.3');
% plot(dateRange,rlowess04,'DisplayName','ESD+rlowess 0.4');

% SAVITZKY-GOLAY
plot(dateRange,sgolay1,'DisplayName','ESD+sgolay 1','Marker','o','Visible','on');
% plot(dateRange,sgolay2,'DisplayName','ESD+sgolay 2');
% plot(dateRange,sgolay3,'DisplayName','ESD+sgolay 3');
% plot(dateRange,sgolay4,'DisplayName','ESD+sgolay 4');

% WRKF
plot(dateRange,wrkf,'DisplayName','ESD+WRKF','Marker','square','Visible','on');

% LEGEND
hold off;
legend('show','Location','best');

% SET LIMIT
xlim(periodoComparacao);
ylim([10 25]);

% SAVE
saveas(filtering,'graphs/manuais/ESD_kalman_loess_sgolay_45cm','png');