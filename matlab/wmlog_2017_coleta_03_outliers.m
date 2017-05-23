%% Config
dateRangeString = cellstr(dateRange);
sensor15cm = [modulo1.d15cm modulo2.d15cm modulo3.d15cm modulo4.d15cm];
sensor45cm = [modulo1.d45cm modulo2.d45cm modulo3.d45cm modulo4.d45cm];
sensor75cm = [modulo1.d75cm modulo2.d75cm modulo3.d75cm modulo4.d75cm];

%% ESD
[sensor1fusedESD, sensor1ESDOutliersIndex, sensor1ESDOutliersTotal] = gesdFusion(sensor15cm,dateRangeString,3);

plotar_metodo_alt(dateRange,sensor15cm,sensor1fusedESD,...
    '15cm_fusao_ESD','Generalized ESD (15cm)',sensor1ESDOutliersTotal,'northwest',sensor1ESDOutliersIndex);

%% WRKF
Yn = sensor1fusedESD;
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

[wrkf, weight, S, P, A, C, Q, R, ss] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
wrkf(1,1) = NaN;

%% plot ESD+WRKF

hold off;
legend('show','Location','northwest');
xlabel('Days');
ylabel('kPa/cbar');

hold on

plot(dateRange,sensor1fusedESD,'DisplayName','ESD','LineStyle','-.','Visible','on');
plot(dateRange,wrkf,'-or','DisplayName','ESD+WRKF','LineWidth',1,'MarkerIndices',1:7:length(wrkf));

%% filtrar por dia
% 25/04 a 09/05

% april25 = table(sensor1fusedESD(1:8)
plotar_scatter_dia('2017-04-25 00:00', '2017-04-25 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-04-26 00:00', '2017-04-26 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-04-27 00:00', '2017-04-27 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-04-28 00:00', '2017-04-28 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-04-29 00:00', '2017-04-29 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-04-30 00:00', '2017-04-30 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');

plotar_scatter_dia('2017-05-01 00:00', '2017-05-01 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-02 00:00', '2017-05-02 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-03 00:00', '2017-05-03 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-04 00:00', '2017-05-04 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-05 00:00', '2017-05-05 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-06 00:00', '2017-05-06 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-07 00:00', '2017-05-07 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-08 00:00', '2017-05-08 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-09 00:00', '2017-05-09 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-10 00:00', '2017-05-10 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-11 00:00', '2017-05-11 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-12 00:00', '2017-05-12 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-13 00:00', '2017-05-13 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-14 00:00', '2017-05-14 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-15 00:00', '2017-05-15 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_dia('2017-05-16 00:00', '2017-05-16 23:59', modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');