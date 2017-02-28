function xhat = kalman_alt(z, A, C, R, Q)
% Simple Kalman Filter (linear) with optimal gain, no control signal
%
% z Measurement signal              m observations X # of observations
% A State transition model          n X n, n = # of state values
% C Observation model               m X n
% R Covariance of observation noise m X m
% Q Covariance of process noise     n X n
%
% Based on http://en.wikipedia.org/wiki/Kalman_filter, but matrices named
% A, C, G instead of F, H, K.
%
% See http://home.wlu.edu/~levys/kalman_tutorial for background
%
% Copyright (C) 2014 Simon D. Levy
%
% This code is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as
% published by the Free Software Foundation, either version 3 of the
% License, or (at your option) any later version.
%
% This code is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with this code. If not, see <http:#www.gnu.org/licenses/>.

% Initializtion =====================================================

% Number of sensors
m = size(C, 1);

% Number of state values
n = size(C, 2);

% Number of observations
numobs = size(z, 2);

% Use linear least squares to estimate initial state from initial
% observation
xhat = zeros(n, numobs);
xhat(:,1) = C \ z(:,1);

% Initialize P, I
P = ones(size(A));
I = eye(size(A));

% Kalman Filter =====================================================

for k = 2:numobs
    
    % Predict
    xhat(:,k) = A * xhat(:,k-1);
    P         = A * P * A' + Q;
    
    % Update
    S         = (C * P * C' + R)^-1;
    G         = P * C' * S;
    xhat(:,k) = xhat(:,k) + G * (z(:,k) - C * xhat(:,k));
    P         = (I - G * C) * P;
    
end

% Inputs:
%
%  x_prev       : value of the previous state
%  z            : current observed data sample 
%  P            : propagated state covariance 
%  C            : observation matrix (assumed to be constant)
%  R            : observation noise (assumed to be constant)
% 
% Outputs:
%
%  x            : value of the current state
%  S            : posterior covariance of the prediction
%  P            : posterior covariance of the current state
%
%************************************************************
function  [x, S, P] = kf_update(x_prev, z, P, C, R)

dim = size(P,1);

S = C * P * C' + R;
K = P * C * inv(S);
x = x_prev + K * (z - C * x_prev);
P = (eye(dim) - K * C) * P;
