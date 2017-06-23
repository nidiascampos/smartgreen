%% APP UMIDADE SOLO - PASSOS 2 / 2
% MEDIO NÍVEL

%% TRECHO 1

% Config
% removendo primeiras leituras para não ter mais
% coleta03_parcial([1:39,221:end],:) = [];

coleta03_parcial = coleta03_total(1:39,:);

% periodo
dateRange = coleta03_parcial.when;
dateRangeString = cellstr(dateRange);

% unindo valores em tabelas
sensor15cm = [coleta03_parcial.d15cm_modulo1 coleta03_parcial.d15cm_modulo2 coleta03_parcial.d15cm_modulo3 coleta03_parcial.d15cm_modulo4];
sensor45cm = [coleta03_parcial.d45cm_modulo1 coleta03_parcial.d45cm_modulo2 coleta03_parcial.d45cm_modulo3 coleta03_parcial.d45cm_modulo4];
sensor75cm = [coleta03_parcial.d75cm_modulo1 coleta03_parcial.d75cm_modulo2 coleta03_parcial.d75cm_modulo3 coleta03_parcial.d75cm_modulo4];

%% G-ESD
% bem proximo da media, principalmente o trecho final
[sensor15cm_fused_esd, sensor15cm_fused_esd_outliersIndex, sensor15cm_fused_esd_outliersTotal] = gesdFusion(sensor15cm,dateRangeString,3);
[sensor45cm_fused_esd, sensor45cm_fused_esd_outliersIndex, sensor45cm_fused_esd_outliersTotal] = gesdFusion(sensor45cm,dateRangeString,3);
[sensor75cm_fused_esd, sensor75cm_fused_esd_outliersIndex, sensor75cm_fused_esd_outliersTotal] = gesdFusion(sensor75cm,dateRangeString,3);

%% WRKF
% dados de 15cm ignorados
% dados de 75cm quase completamente ignorados

%% WRKF: 15cm
Yn = sensor15cm_fused_esd;
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

[sensor15cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor15cm_fused_esd_WRKF(1) = Yn(1);

%% WRKF: 45cm
Yn = sensor45cm_fused_esd;
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

[sensor45cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor45cm_fused_esd_WRKF(1) = Yn(1);

%% WRKF: 75cm
Yn = sensor75cm_fused_esd;
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

[sensor75cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor75cm_fused_esd_WRKF(1) = Yn(1);

%% criando valor total fusionado que será concatenado
sensor15cm_fused_esd_WRKF_total = sensor15cm_fused_esd_WRKF;
sensor45cm_fused_esd_WRKF_total = sensor45cm_fused_esd_WRKF;
sensor75cm_fused_esd_WRKF_total = sensor75cm_fused_esd_WRKF;

%% TRECHO 2

% Config
% removendo primeiras leituras para não ter mais
% coleta03_parcial([1:39,221:end],:) = [];

coleta03_parcial = coleta03_total(40:220,:);

% periodo
dateRange = coleta03_parcial.when;
dateRangeString = cellstr(dateRange);

% unindo valores em tabelas
sensor15cm = [coleta03_parcial.d15cm_modulo1 coleta03_parcial.d15cm_modulo2 coleta03_parcial.d15cm_modulo3 coleta03_parcial.d15cm_modulo4];
sensor45cm = [coleta03_parcial.d45cm_modulo1 coleta03_parcial.d45cm_modulo2 coleta03_parcial.d45cm_modulo3 coleta03_parcial.d45cm_modulo4];
sensor75cm = [coleta03_parcial.d75cm_modulo1 coleta03_parcial.d75cm_modulo2 coleta03_parcial.d75cm_modulo3 coleta03_parcial.d75cm_modulo4];

%% G-ESD
% bem proximo da media, principalmente o trecho final
[sensor15cm_fused_esd, sensor15cm_fused_esd_outliersIndex, sensor15cm_fused_esd_outliersTotal] = gesdFusion(sensor15cm,dateRangeString,3);
[sensor45cm_fused_esd, sensor45cm_fused_esd_outliersIndex, sensor45cm_fused_esd_outliersTotal] = gesdFusion(sensor45cm,dateRangeString,3);
[sensor75cm_fused_esd, sensor75cm_fused_esd_outliersIndex, sensor75cm_fused_esd_outliersTotal] = gesdFusion(sensor75cm,dateRangeString,3);

%% WRKF
% dados de 15cm ignorados
% dados de 75cm quase completamente ignorados

%% WRKF: 15cm
Yn = sensor15cm_fused_esd;
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

[sensor15cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor15cm_fused_esd_WRKF(1) = Yn(1);

%% WRKF: 45cm
Yn = sensor45cm_fused_esd;
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

[sensor45cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor45cm_fused_esd_WRKF(1) = Yn(1);

%% WRKF: 75cm
Yn = sensor75cm_fused_esd;
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

[sensor75cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor75cm_fused_esd_WRKF(1) = Yn(1);

%% criando valor total fusionado que será concatenado
sensor15cm_fused_esd_WRKF_total = [sensor15cm_fused_esd_WRKF_total; sensor15cm_fused_esd_WRKF];
sensor45cm_fused_esd_WRKF_total = [sensor45cm_fused_esd_WRKF_total; sensor45cm_fused_esd_WRKF];
sensor75cm_fused_esd_WRKF_total = [sensor75cm_fused_esd_WRKF_total; sensor75cm_fused_esd_WRKF];

%% TRECHO 3

% Config
% removendo primeiras leituras para não ter mais
% coleta03_parcial([1:39,221:end],:) = [];

coleta03_parcial = coleta03_total(221:end,:);

% periodo
dateRange = coleta03_parcial.when;
dateRangeString = cellstr(dateRange);

% unindo valores em tabelas
sensor15cm = [coleta03_parcial.d15cm_modulo1 coleta03_parcial.d15cm_modulo2 coleta03_parcial.d15cm_modulo3 coleta03_parcial.d15cm_modulo4];
sensor45cm = [coleta03_parcial.d45cm_modulo1 coleta03_parcial.d45cm_modulo2 coleta03_parcial.d45cm_modulo3 coleta03_parcial.d45cm_modulo4];
sensor75cm = [coleta03_parcial.d75cm_modulo1 coleta03_parcial.d75cm_modulo2 coleta03_parcial.d75cm_modulo3 coleta03_parcial.d75cm_modulo4];

%% G-ESD
% bem proximo da media, principalmente o trecho final
[sensor15cm_fused_esd, sensor15cm_fused_esd_outliersIndex, sensor15cm_fused_esd_outliersTotal] = gesdFusion(sensor15cm,dateRangeString,3);
[sensor45cm_fused_esd, sensor45cm_fused_esd_outliersIndex, sensor45cm_fused_esd_outliersTotal] = gesdFusion(sensor45cm,dateRangeString,3);
[sensor75cm_fused_esd, sensor75cm_fused_esd_outliersIndex, sensor75cm_fused_esd_outliersTotal] = gesdFusion(sensor75cm,dateRangeString,3);

%% WRKF
% dados de 15cm ignorados
% dados de 75cm quase completamente ignorados

%% WRKF: 15cm
Yn = sensor15cm_fused_esd;
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

[sensor15cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor15cm_fused_esd_WRKF(1) = Yn(1);

%% WRKF: 45cm
Yn = sensor45cm_fused_esd;
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

[sensor45cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor45cm_fused_esd_WRKF(1) = Yn(1);

%% WRKF: 75cm
Yn = sensor75cm_fused_esd;
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

[sensor75cm_fused_esd_WRKF, ~, ~, ~, ~, ~, ~, ~, ~] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
sensor75cm_fused_esd_WRKF(1) = Yn(1);

%% criando valor total fusionado que será concatenado
sensor15cm_fused_esd_WRKF_total = [sensor15cm_fused_esd_WRKF_total; sensor15cm_fused_esd_WRKF];
sensor45cm_fused_esd_WRKF_total = [sensor45cm_fused_esd_WRKF_total; sensor45cm_fused_esd_WRKF];
sensor75cm_fused_esd_WRKF_total = [sensor75cm_fused_esd_WRKF_total; sensor75cm_fused_esd_WRKF];

%% JUNÇÃO DOS TRECHOS
% periodo
dateRange = coleta03_total.when;
dateRangeString = cellstr(dateRange);

sensor15cm_timetable = timetable(dateRange,sensor15cm_fused_esd_WRKF_total);
sensor45cm_timetable = timetable(dateRange,sensor45cm_fused_esd_WRKF_total);
sensor75cm_timetable = timetable(dateRange,sensor75cm_fused_esd_WRKF_total);

%% gerar tabela completa dos dados
total_fused_15_45 = outerjoin(sensor15cm_timetable,sensor45cm_timetable);
total_fused = outerjoin(total_fused_15_45,sensor75cm_timetable);
total_fused.Properties.VariableNames{3} = 'd75cm_fused';
total_fused.Properties.VariableNames{2} = 'd45cm_fused';
total_fused.Properties.VariableNames{1} = 'd15cm_fused';

%% FEI-DEO: decisao sobre inicio de irrigacao
limiteUmidade = 10; % valor apenas para teste, o normal seria 60kPa
limiteChuva = 1; % chuva fraca

irrigarUmidade = total_fused.d45cm_fused >= limiteUmidade;
irrigarChuva = coleta03_total.wetness <= 1;
irrigarDecisao = irrigarUmidade .* irrigarChuva;

% grafico
plotUmidade = area(total_fused.dateRange,irrigarUmidade);
hold on
plotChuva = area(total_fused.dateRange,irrigarChuva);
plotDecisao = area(total_fused.dateRange,irrigarDecisao);

% child=get(plotDecisao,'Children');
% set(child,'FaceAlpha',0.2);