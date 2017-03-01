%************************************************************
% File:         wrKF_learn.m
% Date:         January 8, 2008
% Author:       Jo-Anne Ting
% Description:
%  Implements the weighted outlier-robust Kalman filter (as
%  described in Ting et al., 2007) where the system
%  dynamics (A, C, Q, R) are learnt as well
%
% Inputs:
%
%  x_prev       : value of the previous state
%  z            : current observed data sample
%  P            : propagated state covariance
%  A            : state transition matrix
%  C            : observation matrix
%  Q            : state noise variance
%  R            : observation noise variance
%  ss           : sufficient statistics
%
% Outputs:
%
%  x            : value of the current state
%  weight       : posterior weight of the data sample
%  S            : posterior covariance of the prediction
%  P            : posterior covariance of the current state
%  A            : updated state transition matrix
%  C            : updated observation matrix
%  Q            : updated state noise variance
%  R            : updated observation noise variance
%  ss           : updated sufficient statistics
%
%************************************************************
function [z_predicted_wrKF, x, weight, S, P, A, C, Q, R, ss] = ...
         wrKF_learn_alt(x_pred, z, P, A, C, Q, R, ss) 

% Initializtion =====================================================

% Number of sensors
m = size(C, 1);

% Number of state values
n = size(C, 2);

% Number of observations (data samples)
% numobs = size(z, 2);
% N      = size(Qoff,1);    % number of data samples (original)
numobs = size(z, 1);

% Use linear least squares to estimate initial state from initial
% observation
% x_hat = zeros(n, numobs);
% x_hat(:,1) = C \ z(:,1);
% z = zeros(numobs, 1);
% x_hat(1,:) = rand;
% x_hat_wrKF(1,:)  = x_hat(1,1);
x(1,:) = x_pred;

% Initialize P, I
% P = ones(size(A));
% I = eye(size(A));

% Initialize sufficient statistics to be collected 
% ss.sum_wzxT = 0;                
% ss.sum_wxxT = 0;
% ss.sum_xxold = 0;
% ss.sum_xxoldT = 0;
% ss.sum_N = 0;
% ss.sum_wzz = 0;
% ss.sum_wzx = 0;
% ss.sum_ExTx = 0;
% ss.sum_Exxold = 0;

% Kalman Filter =====================================================

for i = 2:numobs % come?a em 2 pq 1 ? o valor inicial (k-1)
   % A small constant to avoid computationally problems
    SMALL = 1e-6;

    % Initial priors for weight of the observed data sample
    %-------------------------------------------------------
    alpha = 1e-6;  
    beta  = 1e-6; 

    % Calculate posterior mean and covariance of state
    %---------------------------------------------------
    oldP = P;
    r = z(i,:) - C*x(i-1,:);
    omega = r'*r + trace(C'*C*oldP); 
    weight = (alpha + 0.5)/(beta + (0.5/(R+SMALL))*omega); 

    S = C*Q*C' + R/(weight+SMALL);
    P = inv(weight*(C'/(R+SMALL))*C + 1/Q + SMALL);
    x(i,:) = P/Q*A*x(i-1,:)  + weight*P*C'/(R+SMALL)*z(i,:);

    % Update sufficient statistics for A, C, Q and R
    %--------------------------------------------------
    ss.sum_wzxT = ss.sum_wzxT + weight*z(i,:)*x(i,:)';
    ss.sum_wxxT = ss.sum_wxxT + weight*(x(i,:)*x(i,:)' + P);
    ss.sum_xxold = ss.sum_xxold + x(i,:)*x(i-1,:);
    ss.sum_xxoldT = ss.sum_xxoldT + (x(i-1,:)*x(i-1,:)' + oldP);

    ss.sum_N = ss.sum_N + 1;
    ss.sum_wzz = ss.sum_wzz + weight*z(i,:)'*z(i,:);
    ss.sum_wzx = ss.sum_wzx + weight*(z(i,:).*x(i,:));
    ss.sum_ExTx = ss.sum_ExTx + (x(i,:)'*x(i,:) + P);
    ss.sum_Exxold = ss.sum_Exxold + x(i,:).*x(i-1,:);

    % Calculate new system dynamics
    %--------------------------------
    A = ss.sum_xxold / ss.sum_xxoldT;
    C = ss.sum_wzxT / ss.sum_wxxT;
    R = ss.sum_wzz - 2*sum(ss.sum_wzx'*C) + diag(C*ss.sum_wxxT*C);
    R = R / ss.sum_N;
    Q = ss.sum_ExTx - 2*sum(ss.sum_Exxold'*A) + diag(A*ss.sum_xxoldT*A);
    Q = Q / ss.sum_N; 
    
    % Calculate predicted output
   %---------------------------------------------------------
    z_predicted_wrKF(i,:) = C * x(i,:);
end
