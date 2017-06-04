%% PASSO 3b / 4
%% Config
% dateRange = modulo1.when;
total_modulos = coleta03_total;
dateRange = total_modulos.when;
dateRangeString = cellstr(dateRange);

% unidando valores em tabelas
sensor15cm = [total_modulos.d15cm_modulo1 total_modulos.d15cm_modulo2 total_modulos.d15cm_modulo3 total_modulos.d15cm_modulo4];
sensor45cm = [total_modulos.d45cm_modulo1 total_modulos.d45cm_modulo2 total_modulos.d45cm_modulo3 total_modulos.d45cm_modulo4];
sensor75cm = [total_modulos.d75cm_modulo1 total_modulos.d75cm_modulo2 total_modulos.d75cm_modulo3 total_modulos.d75cm_modulo4];

% convertendo valores de Ohm para kPa pelo modo basico
% sensor15cm = (sensor15cm-550)./137.5;
% sensor45cm = (sensor45cm-550)./137.5;
% sensor75cm = (sensor75cm-550)./137.5;

% convertendo valores de Ohm para kPa utilizando a temperatura do solo
sensor15cm = (3.213*(sensor15cm./1000)+4.093)./(1-0.009733*(sensor15cm./1000)-0.01205*total_modulos.soil_temperature);
sensor45cm = (3.213*(sensor45cm./1000)+4.093)./(1-0.009733*(sensor45cm./1000)-0.01205*total_modulos.soil_temperature);
sensor75cm = (3.213*(sensor75cm./1000)+4.093)./(1-0.009733*(sensor75cm./1000)-0.01205*total_modulos.soil_temperature);

%% Substituindo NaN pelo ultimo valor valido
sensor15cm = fillmissing(sensor15cm,'previous');
sensor45cm = fillmissing(sensor45cm,'previous');
sensor75cm = fillmissing(sensor75cm,'previous');

%% Media
sensor15cm_fused_mean = basicFusion(sensor15cm,'mean');
sensor45cm_fused_mean = basicFusion(sensor45cm,'mean');
sensor75cm_fused_mean = basicFusion(sensor75cm,'mean');

%% Mediana
sensor15cm_fused_median = basicFusion(sensor15cm,'median');
sensor45cm_fused_median = basicFusion(sensor45cm,'median');
sensor75cm_fused_median = basicFusion(sensor75cm,'median');

%% Peirce
% resultado igual à media
[sensor15cm_fused_peirce, sensor15cm_fused_peirce_outliers, sensor15cm_fused_peirce_outliersTotal] = peirceFusion(sensor15cm);
[sensor45cm_fused_peirce, sensor45cm_fused_peirce_outliers, sensor45cm_fused_peirce_outliersTotal] = peirceFusion(sensor45cm);
[sensor75cm_fused_peirce, sensor75cm_fused_peirce_outliers, sensor75cm_fused_peirce_outliersTotal] = peirceFusion(sensor75cm);

%% Chauvenet
% resultados estranhos
[sensor15cm_fused_chauvenet, sensor15cm_fused_chauvenet_outliers, sensor15cm_fused_chauvenet_outliersTotal] = chauvenetFusion(sensor15cm);
[sensor45cm_fused_chauvenet, sensor45cm_fused_chauvenet_outliers, sensor45cm_fused_chauvenet_outliersTotal] = chauvenetFusion(sensor45cm);
[sensor75cm_fused_chauvenet, sensor75cm_fused_chauvenet_outliers, sensor75cm_fused_chauvenet_outliersTotal] = chauvenetFusion(sensor75cm);

%% ZScore
% resultado igual à media
[sensor15cm_fused_zscore, sensor15cm_fused_zscore_outliersIndex, sensor15cm_fused_zscore_outliersTotal, sensor15cm_zscores] = zScoreFusion(sensor15cm,dateRangeString,6.0);
[sensor45cm_fused_zscore, sensor45cm_fused_zscore_outliersIndex, sensor45cm_fused_zscore_outliersTotal, sensor45cm_zscores] = zScoreFusion(sensor45cm,dateRangeString,6.0);
[sensor75cm_fused_zscore, sensor75cm_fused_zscore_outliersIndex, sensor75cm_fused_zscore_outliersTotal, sensor75cm_zscores] = zScoreFusion(sensor75cm,dateRangeString,6.0);

%% G-ESD
[sensor15cm_fused_esd, sensor15cm_fused_esd_outliersIndex, sensor15cm_fused_esd_outliersTotal] = gesdFusion(sensor15cm,dateRangeString,3);
[sensor45cm_fused_esd, sensor45cm_fused_esd_outliersIndex, sensor45cm_fused_esd_outliersTotal] = gesdFusion(sensor45cm,dateRangeString,3);
[sensor75cm_fused_esd, sensor75cm_fused_esd_outliersIndex, sensor75cm_fused_esd_outliersTotal] = gesdFusion(sensor75cm,dateRangeString,3);

%% MZscore
[sensor15cm_fused_mzscore, sensor15cm_fused_mzscore_outliersIndex, sensor15cm_fused_mzscore_outliersTotal, sensor15cm_mzscores] = mzScoreFusion(sensor15cm,dateRangeString,3.5);
[sensor45cm_fused_mzscore, sensor45cm_fused_mzscore_outliersIndex, sensor45cm_fused_mzscore_outliersTotal, sensor45cm_mzscores] = mzScoreFusion(sensor45cm,dateRangeString,3.5);
[sensor75cm_fused_mzscore, sensor75cm_fused_mzscore_outliersIndex, sensor75cm_fused_mzscore_outliersTotal, sensor75cm_mzscores] = mzScoreFusion(sensor75cm,dateRangeString,3.5);

%% Adj. Boxplot
% não está funcionando
% [sensor15cm_fused_boxadj, sensor15cm_fused_boxadj_scores, sensor15cm_fused_boxadj_outliers, sensor15cm_fused_boxadj_outliersTotal] = adjboxplotFusion2(sensor15cm,3.5);
% [sensor45cm_fused_boxadj, sensor45cm_fused_boxadj_scores, sensor45cm_fused_boxadj_outliers, sensor45cm_fused_boxadj_outliersTotal] = adjboxplotFusion2(sensor45cm,3.5);
% [sensor75cm_fused_boxadj, sensor75cm_fused_boxadj_scores, sensor75cm_fused_boxadj_outliers, sensor75cm_fused_boxadj_outliersTotal] = adjboxplotFusion2(sensor75cm,3.5);

%% Kalman
% for our single-sensor example, we defined 'r' as the variance of the observation
% noise signal 'vk'; that is, how much it varies around its mean (average) value.
% For a system with more than two sensors, 'R' is a matrix containing the 
% covariance between each pair of sensors

% Let's say that we've observed both our thermometers under climate-controlled
% conditions of steady temperature, and observed that their values fluctuate by
% an average of 0.8 degrees; i.e., the standard deviation of their readings is
% 0.8, making the variance 0.8 * 0.8 = 0.64
R1 = 0.8 * 0.8;
R2 = R1;
R3 = R1;
R4 = R1;
% Covariância do ruído do processo
Q = .005;

% we'll assume we have no knowledge of the state-transition model
% ('A' matrix) and so have to rely only on the sensor values
A = 1;

% We'll assume that both sensors contribute equally to our temperature estimation,
% so our CC matrix is just a pair of 1's
C1 = 1;
C2 = 1;
C3 = 1;
C4 = 1;

% gerando transpostas para facilitar o uso do filtro
sensor15cm_fused_kalman = sensor15cm';
sensor45cm_fused_kalman = sensor45cm';
sensor75cm_fused_kalman = sensor75cm';

% 1 sensor
sensor15cm_fused_KAF1 = kalman([sensor15cm_fused_kalman(1,:)], A, C1, R1, Q);
sensor45cm_fused_KAF1 = kalman([sensor45cm_fused_kalman(1,:)], A, C1, R1, Q);
sensor75cm_fused_KAF1 = kalman([sensor75cm_fused_kalman(1,:)], A, C1, R1, Q);
% sensor2fusedKAF1 = kalman([sensor2kalman(1,:)], A, C1, R1, Q);

% 2 sensores
% sensor1fusedKAF2 = kalman([sensor1kalman(1,:); sensor1kalman(2,:)], A, [C1; C2], [R1 0; 0 R2], Q);
% sensor2fusedKAF2 = kalman([sensor2kalman(1,:); sensor2kalman(2,:)], A, [C1; C2], [R1 0; 0 R2], Q);

% 3 sensores
% sensor1fusedKAF3 = kalman([sensor1kalman(1,:); sensor1kalman(2,:); sensor1kalman(3,:)], A, [C1; C2; C3], [R1 0 0; 0 R2 0; 0 0 R3], Q);
% sensor2fusedKAF3 = kalman([sensor2kalman(1,:); sensor2kalman(2,:); sensor2kalman(3,:)], A, [C1; C2; C3], [R1 0 0; 0 R2 0; 0 0 R3], Q);

% 4 sensores
sensor15cm_fused_KAF4 = kalman([sensor15cm_fused_kalman(1,:); sensor15cm_fused_kalman(2,:); sensor15cm_fused_kalman(3,:); sensor15cm_fused_kalman(4,:)],...
    A, [C1; C2; C3; C4], [R1 0 0 0; 0 R2 0 0; 0 0 R3 0; 0 0 0 R4], Q);
sensor45cm_fused_KAF4 = kalman([sensor45cm_fused_kalman(1,:); sensor45cm_fused_kalman(2,:); sensor45cm_fused_kalman(3,:); sensor45cm_fused_kalman(4,:)],...
    A, [C1; C2; C3; C4], [R1 0 0 0; 0 R2 0 0; 0 0 R3 0; 0 0 0 R4], Q);
sensor75cm_fused_KAF4 = kalman([sensor75cm_fused_kalman(1,:); sensor75cm_fused_kalman(2,:); sensor75cm_fused_kalman(3,:); sensor75cm_fused_kalman(4,:)],...
    A, [C1; C2; C3; C4], [R1 0 0 0; 0 R2 0 0; 0 0 R3 0; 0 0 0 R4], Q);

%% KALMAN: utilizando modified z-score como base
sensor15cm_fused_esd_KAF = sensor15cm_fused_esd';
sensor45cm_fused_esd_KAF = sensor45cm_fused_esd';
sensor75cm_fused_esd_KAF = sensor75cm_fused_esd';

sensor15cm_fused_esd_KAF = kalman([sensor15cm_fused_esd_KAF(1,:)], A, C1, R1, Q);
sensor45cm_fused_esd_KAF = kalman([sensor45cm_fused_esd_KAF(1,:)], A, C1, R1, Q);
sensor75cm_fused_esd_KAF = kalman([sensor75cm_fused_esd_KAF(1,:)], A, C1, R1, Q);

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

%% Plotar: 15cm
figure;
plot(dateRange,sensor15cm_fused_mean,'DisplayName','media'); hold on
plot(dateRange,sensor15cm_fused_median,'DisplayName','mediana');
plot(dateRange,sensor15cm_fused_peirce,'DisplayName','peirce');
plot(dateRange,sensor15cm_fused_chauvenet,'DisplayName','chauvenet');
plot(dateRange,sensor15cm_fused_zscore,'DisplayName','zscore');
plot(dateRange,sensor15cm_fused_esd,'DisplayName','esd');
plot(dateRange,sensor15cm_fused_mzscore,'DisplayName','mzscore');
plot(dateRange,sensor15cm_fused_KAF1,'DisplayName','kalman (1)');
plot(dateRange,sensor15cm_fused_KAF4,'DisplayName','kalman (4)');
plot(dateRange,sensor15cm_fused_esd_KAF,'DisplayName','esd + kalman');
plot(dateRange,sensor15cm_fused_esd_WRKF,'DisplayName','esd + wrkf');

%% Plotar: 45cm
figure;
plot(dateRange,sensor45cm_fused_mean,'DisplayName','media'); hold on
plot(dateRange,sensor45cm_fused_median,'DisplayName','mediana');
plot(dateRange,sensor45cm_fused_peirce,'DisplayName','peirce');
plot(dateRange,sensor45cm_fused_chauvenet,'DisplayName','chauvenet');
plot(dateRange,sensor45cm_fused_zscore,'DisplayName','zscore');
plot(dateRange,sensor45cm_fused_esd,'DisplayName','esd');
plot(dateRange,sensor45cm_fused_mzscore,'DisplayName','mzscore');
plot(dateRange,sensor45cm_fused_KAF1,'DisplayName','kalman (1)');
plot(dateRange,sensor45cm_fused_KAF4,'DisplayName','kalman (4)');
plot(dateRange,sensor45cm_fused_esd_KAF,'DisplayName','esd + kalman');
plot(dateRange,sensor45cm_fused_esd_WRKF,'DisplayName','esd + wrkf');

%% Plotar: 75cm
figure;
plot(dateRange,sensor75cm_fused_mean,'DisplayName','media'); hold on
plot(dateRange,sensor75cm_fused_median,'DisplayName','mediana');
plot(dateRange,sensor75cm_fused_peirce,'DisplayName','peirce');
plot(dateRange,sensor75cm_fused_chauvenet,'DisplayName','chauvenet');
plot(dateRange,sensor75cm_fused_zscore,'DisplayName','zscore');
plot(dateRange,sensor75cm_fused_esd,'DisplayName','esd');
plot(dateRange,sensor75cm_fused_mzscore,'DisplayName','mzscore');
plot(dateRange,sensor75cm_fused_KAF1,'DisplayName','kalman (1)');
plot(dateRange,sensor75cm_fused_KAF4,'DisplayName','kalman (4)');
plot(dateRange,sensor75cm_fused_esd_KAF,'DisplayName','esd + kalman');
plot(dateRange,sensor75cm_fused_esd_WRKF,'DisplayName','esd + wrkf');

%% reinserindo tempo nas tabelas dos dados
% sensor15cm_timetable = timetable(dateRange,sensor15cm_fused_esd_KAF');
% sensor45cm_timetable = timetable(dateRange,sensor45cm_fused_esd_KAF');
% sensor75cm_timetable = timetable(dateRange,sensor75cm_fused_esd_KAF');

%% reinserindo tempo nas tabelas dos dados
sensor15cm_timetable = timetable(dateRange,sensor15cm_fused_esd_WRKF);
sensor45cm_timetable = timetable(dateRange,sensor45cm_fused_esd_WRKF);
sensor75cm_timetable = timetable(dateRange,sensor75cm_fused_esd_WRKF);

%% gerar tabela completa dos dados
total_fused_15_45 = outerjoin(sensor15cm_timetable,sensor45cm_timetable);
total_fused = outerjoin(total_fused_15_45,sensor75cm_timetable);
total_fused.Properties.VariableNames{3} = 'd75cm_fused';
total_fused.Properties.VariableNames{2} = 'd45cm_fused';
total_fused.Properties.VariableNames{1} = 'd15cm_fused';