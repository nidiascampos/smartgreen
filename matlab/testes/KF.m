% Nonlinear Discrete-Time Kalman filter

%% USER INPUT
h = 0.1; 		% sampling time (s)
N = 1000;		% no. of iterations

% model parameters
a  = -1;              
b  = 1;
e  = 1;

% initial values for x and u
x = [0 0]';	        
u = 0;

% initialization of Kalman filter
x_bar = [0 0]';        
X_bar = diag([1 1]);
Q = 1;
R = 10;

%% MAIN LOOP

simdata = zeros(N+1,9);                  % memory allocation

for i=1:N+1,
   t = (i-1)*h;                          % time (s)             
   
   % measurement   
   z = x(1)+0.1*randn(1);                % position + white noise

   % estimation error
   z_bar = x_bar(1);
   eps   = z-z_bar;   

   % Plant
   u = 0.1*sin(0.1*t);                   % input
   w = 0.1*randn(1);                     % process noise
   f = [ x(2)
         a*x(2)*abs(x(2))+b*u];
   E = [0 e]';
   x_dot = f + E*w;                      % dx/dt = f + Ew
   
   % Discrete-time matrices: PHI, GAMMA, H 
   PHI   = [1   h
            0  1+h*2*a*abs(x_bar(2))];   
   GAMMA = h*E;    
   H     = [1 0]; 

   % KF gain      
   K = X_bar*H'*inv(H*X_bar*H'+R);

   % corrector   
   IKH = eye(2)-K*H;
   X_hat = IKH*X_bar*IKH' + K*R*K';
   x_hat = x_bar + K*eps;   
   
   % store simulation data in a table   
   simdata(i,:) = [t x' x_hat' X_hat(1,1) X_hat(2,2) eps z];    

   % discrete-time extended KF-model
   f_hat = [x_hat(2)
            a*x_hat(2)*abs(x_hat(2))+b*u];
   f_k   = x_hat + h*f_hat;
      
   % predictor (k+1)  
   x_bar = f_k;
   X_bar = PHI*X_hat*PHI' + GAMMA*Q*GAMMA';
   
   % Euler integration (k+1)
   x = x + h*x_dot;
end

%% PLOTS

t     = simdata(:,1); 
x     = simdata(:,2:3); 
x_hat = simdata(:,4:5); 
X_hat = simdata(:,6:7);
eps   = simdata(:,8);
z     = simdata(:,9);

clf
figure(gcf)

subplot(221),plot(t,z,'g',t,x_hat(:,1),'r')
xlabel('time (s)'),title('Position x_1'),grid
legend('z=x_1','x_1hat')

subplot(222),plot(t,x(:,2),'g',t,x_hat(:,2),'r')
xlabel('time (s)'),title('Velocity x_2'),grid
legend('x_2','x_2hat')

subplot(223),plot(t,eps),xlabel('time (s)'),title('Estimation error: z - zhat'),grid
subplot(224),plot(t,X_hat),xlabel('time (s)'),title('Diagonal of covariance matrix X'),grid




