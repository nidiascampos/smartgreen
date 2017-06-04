%% PASSO 3 / 4

%% Config
% dateRange = modulo1.when;
total_modulos = coleta03_total;
dateRange = total_modulos.when;
dateRangeString = cellstr(dateRange);
% sensor15cm = [modulo1.d15cm modulo2.d15cm modulo3.d15cm modulo4.d15cm];
% sensor45cm = [modulo1.d45cm modulo2.d45cm modulo3.d45cm modulo4.d45cm];
% sensor75cm = [modulo1.d75cm modulo2.d75cm modulo3.d75cm modulo4.d75cm];

sensor15cm = [total_modulos.d15cm_modulo1 total_modulos.d15cm_modulo2 total_modulos.d15cm_modulo3 total_modulos.d15cm_modulo4];
sensor45cm = [total_modulos.d45cm_modulo1 total_modulos.d45cm_modulo2 total_modulos.d45cm_modulo3 total_modulos.d45cm_modulo4];
sensor75cm = [total_modulos.d75cm_modulo1 total_modulos.d75cm_modulo2 total_modulos.d75cm_modulo3 total_modulos.d75cm_modulo4];

% sensor15cm(isnan(sensor15cm)) = -100000;
% sensor45cm(isnan(sensor45cm)) = -100000;
% sensor75cm(isnan(sensor75cm)) = -100000;

%% ESD
[sensor15cmfusedESD, sensor15cmESDOutliersIndex, sensor15cmESDOutliersTotal] = gesdFusion(sensor15cm,dateRangeString,3);
[sensor45cmfusedESD, sensor45cmESDOutliersIndex, sensor45cmESDOutliersTotal] = gesdFusion(sensor45cm,dateRangeString,3);
[sensor75cmfusedESD, sensor75cmESDOutliersIndex, sensor75cmESDOutliersTotal] = gesdFusion(sensor75cm,dateRangeString,3);

% plotar_metodo_alt(dateRange,sensor15cm,sensor15cmfusedESD,...
%     '15cm_fusao_ESD_bla','Generalized ESD (15cm)',sensor15cmESDOutliersTotal,'northwest',sensor15cmESDOutliersIndex);
% 
% plotar_metodo_alt(dateRange,sensor45cm,sensor45cmfusedESD,...
%     '45cm_fusao_ESD_bla','Generalized ESD (45cm)',sensor45cmESDOutliersTotal,'northwest',sensor45cmESDOutliersIndex);
% 
% plotar_metodo_alt(dateRange,sensor75cm,sensor75cmfusedESD,...
%     '75cm_fusao_ESD_bla','Generalized ESD (75cm)',sensor75cmESDOutliersTotal,'northwest',sensor75cmESDOutliersIndex);

%% aplicando interpolação linear nos dados dos sensores de 75cm
temp = timetable(dateRange,sensor75cmfusedESD);
temp = retime(temp,'hourly','linear');
sensor75cmfusedESD = temp.sensor75cmfusedESD;

% sensor75cmfusedESD(isnan(sensor75cmfusedESD)) = 0;

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

%% reinserindo tempo nas tabelas dos dados
sensor15cm_timetable = timetable(dateRange,sensor15cmWRKF);
sensor45cm_timetable = timetable(dateRange,sensor45cmWRKF);
% sensor75cm_timetable = timetable(dateRange,sensor75cmWRKF);
% 75cm tem um tempo diferente pois foi utilizada interpolação para dar
% continuidade nos dados
sensor75cm_timetable = timetable(temp.dateRange,sensor75cmWRKF);

%% gerar tabela completa dos dados
total_WRKF_15_45 = outerjoin(sensor15cm_timetable,sensor45cm_timetable);
total_WRKF = outerjoin(total_WRKF_15_45,sensor75cm_timetable);
total_WRKF.Properties.VariableNames{3} = 'sensor75cmWRKF';
% total_WRKF = table(total_modulos.when,sensor15cmWRKF,sensor45cmWRKF,sensor75cmWRKF,...
%     'VariableNames',{'Date' 'd15cm_unified' 'd45cm_unified' 'd75cm_unified'});
% writetable(total_WRKF,'logs/csv/coleta03/filtrados/modulos_unificados.csv');