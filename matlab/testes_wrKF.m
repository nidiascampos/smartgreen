% load Qoff.data;
% Yn = Qoff(:,4);
%
% utilizando dados gerados por 'mlog_2017_coleta_02_c.mlx'

% gerando transpostas para facilitar o uso do filtro
% sensor1meanT = sensor1meanOrig';
% Yn = [sensor1meanOrig(:,1); sensor1meanOrig(:,2)];
Yn = sensor1meanOrig(:,1);

% 1 sensor
% sensor1fusedKAF1 = kalman([sensor1meanT(1,:)], A, C1, R1, Q);
% 2 sensor
% sensor1fusedKAF2 = kalman([sensor1meanT(1,:); sensor1meanT(2,:)], A, [C1; C2], [R1 0; 0 R2], Q);

x = 1; % initial state value
P = 0.01;
A = 1;
C = 1;
Q = .005;
% R = 1e-4;
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
[zPred, weight, S, P, A, C, Q, R, ss] = wrKF_learn_alt(x, Yn, P, A, C, Q, R, ss_wrKF);
plot(zPred);