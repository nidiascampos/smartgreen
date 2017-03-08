%% SETTINGS
periodoComparacao = datetime({'30/01/2017' '10/02/2017'});

%% FILTERING
% LOESS
loess01 = smooth(sensor1fusedESD,0.1,'loess');
loess02 = smooth(sensor1fusedESD,0.2,'loess');
loess03 = smooth(sensor1fusedESD,0.3,'loess');
loess04 = smooth(sensor1fusedESD,0.4,'loess');
% RLOESS
rloess01 = smooth(sensor1fusedESD,0.1,'rloess');
rloess02 = smooth(sensor1fusedESD,0.2,'rloess');
rloess03 = smooth(sensor1fusedESD,0.3,'rloess');
rloess04 = smooth(sensor1fusedESD,0.4,'rloess');
% SAVITZKY-GOLAY
sgolay1 = smooth(sensor1fusedESD,'sgolay',1);
sgolay2 = smooth(sensor1fusedESD,'sgolay',2); % valor default
sgolay3 = smooth(sensor1fusedESD,'sgolay',3);
sgolay4 = smooth(sensor1fusedESD,'sgolay',4);

%% PLOTTING
filtering = figure;
plot(baterias_Mean.Date,baterias_Mean.baterias_p15cmMean,'--d','DisplayName','tensi?metros');
hold on;
plot(dateRange,sensor1fusedESD,'DisplayName','ESD');
plot(dateRange,sensor1fusedKAFalt,'DisplayName','ESD+Kalman','LineStyle','--','Visible','on');
% LOESS
% plot(dateRange,loess01,'DisplayName','ESD+loess 0.1');
plot(dateRange,loess02,'DisplayName','ESD+loess 0.2','Marker','+','Visible','on');
% plot(dateRange,loess03,'DisplayName','ESD+loess 0.3');
% plot(dateRange,loess04,'DisplayName','ESD+loess 0.4');
% RLOESS (suavizou muito)
plot(dateRange,rloess01,'DisplayName','ESD+rloess 0.1');
plot(dateRange,rloess02,'DisplayName','ESD+rloess 0.2');
plot(dateRange,rloess03,'DisplayName','ESD+rloess 0.3');
plot(dateRange,rloess04,'DisplayName','ESD+rloess 0.4');
% SAVITZKY-GOLAY
plot(dateRange,sgolay1,'DisplayName','ESD+sgolay 1','Marker','o','Visible','on');
% plot(dateRange,sgolay2,'DisplayName','ESD+sgolay 2');
% plot(dateRange,sgolay3,'DisplayName','ESD+sgolay 3');
% plot(dateRange,sgolay4,'DisplayName','ESD+sgolay 4');
% LEGEND
hold off;
legend('show','Location','best');
% SET LIMIT
xlim(periodoComparacao);
% SAVE
saveas(filtering,'graphs/manuais/ESD_kalman_loess_sgolay','png');