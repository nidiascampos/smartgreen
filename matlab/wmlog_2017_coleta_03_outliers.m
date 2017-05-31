%% PASSO 3 / 4

%% Config
% dateRange = modulo1.when;
dateRange = total_modulos.when;
dateRangeString = cellstr(dateRange);
% sensor15cm = [modulo1.d15cm modulo2.d15cm modulo3.d15cm modulo4.d15cm];
% sensor45cm = [modulo1.d45cm modulo2.d45cm modulo3.d45cm modulo4.d45cm];
% sensor75cm = [modulo1.d75cm modulo2.d75cm modulo3.d75cm modulo4.d75cm];

sensor15cm = [total_modulos.d15cm_modulo1 total_modulos.d15cm_modulo2 total_modulos.d15cm_modulo3 total_modulos.d15cm_modulo4];
sensor45cm = [total_modulos.d45cm_modulo1 total_modulos.d45cm_modulo2 total_modulos.d45cm_modulo3 total_modulos.d45cm_modulo4];
sensor75cm = [total_modulos.d75cm_modulo1 total_modulos.d75cm_modulo2 total_modulos.d75cm_modulo3 total_modulos.d75cm_modulo4];

%% ESD
[sensor15cmfusedESD, sensor15cmESDOutliersIndex, sensor15cmESDOutliersTotal] = gesdFusion(sensor15cm,dateRangeString,3);
[sensor45cmfusedESD, sensor45cmESDOutliersIndex, sensor45cmESDOutliersTotal] = gesdFusion(sensor45cm,dateRangeString,3);
[sensor75cmfusedESD, sensor75cmESDOutliersIndex, sensor75cmESDOutliersTotal] = gesdFusion(sensor75cm,dateRangeString,3);

% plotar_metodo_alt(dateRange,sensor15cm,sensor15cmfusedESD,...
%     '15cm_fusao_ESD','Generalized ESD (15cm)',sensor15cmESDOutliersTotal,'northwest',sensor15cmESDOutliersIndex);

%% WRKF (15cm)
Yn = sensor15cmfusedESD;
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

[sensor15cmWRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor15cmWRKF(1,1) = NaN;

%% WRKF (45cm)
Yn = sensor45cmfusedESD;
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

[sensor45cmWRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor45cmWRKF(1,1) = NaN;

%% WRKF (75cm)
Yn = sensor75cmfusedESD;
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

[sensor75cmWRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor75cmWRKF(1,1) = NaN;

%% gerar tabela completa dos dados
total_WRKF = table(total_modulos.when,sensor15cmWRKF,sensor45cmWRKF,sensor75cmWRKF,...
    'VariableNames',{'Date' 'd15cm_unified' 'd45cm_unified' 'd75cm_unified'});
% writetable(total_WRKF,'logs/csv/coleta03/filtrados/modulos_unificados.csv');

%% plot ESD+WRKF
% clf;
% figure;
% hold off;
% legend('show','Location','northwest');
% xlabel('Days');
% ylabel('kPa/cbar');
% 
% hold on
% 
% plot(dateRange,sensor75cmfusedESD,'DisplayName','ESD','LineStyle','-.','Visible','on');
% plot(dateRange,sensor75cmWRKF,'-or','DisplayName','ESD+WRKF','LineWidth',1,'MarkerIndices',1:7:length(sensor75cmWRKF));

%% filtrar por dia
% 25/04 a 09/05

% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd45cm', modulo2, 'd45cm', 'Dispersão: Modulo 1 e Modulo 2, 45cm', '45cm_mod1_mod2','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd75cm', modulo2, 'd75cm', 'Dispersão: Modulo 1 e Modulo 2, 75cm', '75cm_mod1_mod2','off');
% 
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd15cm', modulo3, 'd15cm', 'Dispersão: Modulo 1 e Modulo 3, 15cm', '15cm_mod1_mod3','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd45cm', modulo3, 'd45cm', 'Dispersão: Modulo 1 e Modulo 3, 45cm', '45cm_mod1_mod3','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd75cm', modulo3, 'd75cm', 'Dispersão: Modulo 1 e Modulo 3, 75cm', '75cm_mod1_mod3','off');
% 
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd15cm', modulo4, 'd15cm', 'Dispersão: Modulo 1 e Modulo 4, 15cm', '15cm_mod1_mod4','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd45cm', modulo4, 'd45cm', 'Dispersão: Modulo 1 e Modulo 4, 45cm', '45cm_mod1_mod4','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd75cm', modulo4, 'd75cm', 'Dispersão: Modulo 1 e Modulo 4, 75cm', '75cm_mod1_mod4','off');
% 
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd15cm', modulo3, 'd15cm', 'Dispersão: Modulo 2 e Modulo 3, 15cm', '15cm_mod2_mod3','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd45cm', modulo3, 'd45cm', 'Dispersão: Modulo 2 e Modulo 3, 45cm', '45cm_mod2_mod3','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd75cm', modulo3, 'd75cm', 'Dispersão: Modulo 2 e Modulo 3, 75cm', '75cm_mod2_mod3','off');
% 
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd15cm', modulo4, 'd15cm', 'Dispersão: Modulo 2 e Modulo 4, 15cm', '15cm_mod2_mod4','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd45cm', modulo4, 'd45cm', 'Dispersão: Modulo 2 e Modulo 4, 45cm', '45cm_mod2_mod4','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd75cm', modulo4, 'd75cm', 'Dispersão: Modulo 2 e Modulo 4, 75cm', '75cm_mod2_mod4','off');
