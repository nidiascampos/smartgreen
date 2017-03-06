function [MSE,NoP,x,xest,rho]=MAPF_EX1(N,T,TV,TimeChangeModel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MODEL AVERANGING PARTICLE FILTER (MAPF)       %%%%%
%%%%% http://vixra.org/abs/1512.0420                %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% EXAMPLE (EX1): online model selection (with time-varying model)%%%%%
%%%%  TWO MODELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% N= total number of particles (fixed; shared by the parallel filters)
%%% T= total number of iterations
%%% T_V= refreshing parameter  
%%% TimeChangeModel= iteration when the model changes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Examples of use 
%%% [MSE,Ra,NoP]=MAPF_EX1(10000,500,100,250);
%%% [MSE,Ra,NoP]=MAPF_EX1(10000,500,'automatic',250);
%%% [MSE,Ra,NoP]=MAPF_EX1(10000,500,'automatic',100);
%%% [MSE,Ra,NoP]=MAPF_EX1(10000,500,'automatic',50);
%%% [MSE,Ra,NoP]=MAPF_EX1(10000,500,50,300);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clc

if  TimeChangeModel>T | TimeChangeModel<10
    TimeChangeModel=fix(T/2);
end
    


disp('-------------------------------------------------------------------------- ')
disp('               MODEL AVERANGING PARTICLE FILTER (MAPF)')
disp('(cooperative parallel particle filters for tracking and model selection)')
disp('http://vixra.org/abs/1512.0420  ')
disp('-------------------------------------------------------------------------- ')
disp('Example: online model selection (with time-varying model)')
disp('-------------------------------------------------------------------------- ')
disp([' Total number of particles (shared by the filters)= ',num2str(N)])
disp([' Number of models (and parallel filters)= 2'])
disp([' Total number of iterations = ',num2str(T)])
disp([' Change of the model (1==>2) at the iteration= ',num2str(TimeChangeModel)])
if TV=='automatic'
   disp([' Refreshing parameter = Automatic and Adaptive'])
else
    disp([' Refreshing parameter = ',num2str(TV)])
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% GENERATION of the true states and measurements %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% parameters of the models %%%
x(1)=0;
s1=1;
s2=0.5;
a=1;
b=1;

for t=2:T+1
   
    if t<TimeChangeModel %%%% FIRST MODEL             
      x(t)=-10*x(t-1)./(1+3*x(t-1).^2)+s1*randn(1,1);  
      y(t)=b*x(t)+s2*randn(1,1); 
    else  %%%% START THE SECOND MODEL     
      x(t)=x(t-1)+1*randn(1,1);  
       y(t)=b*exp(-0.2*x(t))+s2*randn(1,1); 
    end
           
end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controlExpressions=0; %%% 0= no control; 1= controlling weight factorization 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% COOPERATIVE PARALLEL PARTICLE FILTERING          %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% initial parameters of the algorithm


K=2; %%% number of models (and filters) %%% EXAMPLE 1
w(1,:)=ones(1,N); %%%  starting unnormalized weights
x_prop(1,:)=zeros(1,N); %%% initial proposed particles


rho=1/K*ones(1,K);%%% initializing of the POST PROBABILITY OF THE MODELS (AUX VARIABLE FOR CODING - USED JOINTLY WITH pr_rho) 
pr_rho=1/K*ones(1,K); %%% POST PROBABILITY OF THE MODELS (AUX VARIABLE FOR CODING - USED JOINTLY WITH rho)
NoP=pr_rho*N; %%% (initial) number of particles for each filter
Z=ones(1,K); %%% initializing marginal likelihood estimators
xest=zeros(1,T); %%% initializing global estimation

MINIMUM_PARTICLES_PER_FILTER=N*0.1/100; %%% it should be >= 2 

W_before=ones(1,N); %%% aux parameter
Decision_MATCH=0; %%% aux parameter
positionStandResampling=[];  %%% aux parameter
 countRefresh=0; %%% aux parameter -only for displying stat of the algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([' Minimum number of particles per filter = ',num2str(MINIMUM_PARTICLES_PER_FILTER)])
disp('-------------------------------------------------------------------------- ')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% THE TRUE MODEL IS CONTAINED IN THE SET OF CONSIDERED MODEL
%%%% THE TRUE MODEL  ALWAYS CORRESPONDS TO THE LAST CONFIGURATION 
%%%% OF THE PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%%%%%%% STARTING FILTERING %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for t=2:T+1
    
    %%%% for displaying 
    if mod(t,100)==0
      disp([num2str(min([fix(t*100/T) 100])) '%']) 
      disp(['Particles in each filter (at least):'])
      disp([num2str(fix(pr_rho.*N))])
    end
    
 
    NoP(t,:)=fix(pr_rho.*N);
    
    
   COUNTAUX=0;
    for k=1:K %%%% for each filter/model
        
       %%%%%%%%%%%%%%%%%%%%%%%%
       %%%%% PROPAGATION  %%%%% 
       %%%%%%%%%%%%%%%%%%%%%%%%
      indexAux1=COUNTAUX+1; 
      
      if k==K
       indexAux2=N;
      else 
       indexAux2=COUNTAUX+NoP(t,k);    
      end 
      COUNTAUX=COUNTAUX+NoP(t,k);
        %%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        NumPar=indexAux2-indexAux1+1;
       %%%%% NumPar is equal to NoP(i,k) but can differ just in order to have $N$ total number of particles      
      
         switch k
         case 1
                %%%% Propagation %%%%%%%%%%%
                F_X=-10*x_prop(t-1,indexAux1:indexAux2)./(1+3*x_prop(t-1,indexAux1:indexAux2).^2);
                x_prop(t,indexAux1:indexAux2)=F_X+s1*randn(1,NumPar);
                %%%% likelihood 
                like(indexAux1:indexAux2)=1/(sqrt(2*pi*s2^2))*exp(-(y(t)-b*x_prop(t,indexAux1:indexAux2)).^2/(2*s2.^2));
             case 2
                 %%%% Propagation %%%%%%%%%%%
                x_prop(t,indexAux1:indexAux2)=x_prop(t-1,indexAux1:indexAux2)+1*randn(1,NumPar); 
                %%%% likelihood 
                like(indexAux1:indexAux2)=1/(sqrt(2*pi*s2^2))*exp(-(y(t)-b*exp(-0.2*x_prop(t,indexAux1:indexAux2))).^2/(2*s2.^2));

         end 

          sample_per_Filter{k}=x_prop(t,indexAux1:indexAux2);
          
          
     if mod(t,TV-1)==0
         %%%%% IF THERE WAS - REFRESH  %%%%%%
      w(indexAux1:indexAux2)=like(indexAux1:indexAux2)+10^(-323); 
     else      %%%%%% WEIGHT COMPUTATE PROPERLY AFTER RESAMPLING oR NOT  
       w(indexAux1:indexAux2)=W_before(indexAux1:indexAux2).*like(indexAux1:indexAux2)+10^(-323); %%%  10^(-323) for avoiding numerical problems
     end
      
      Z(t,k)=mean(w(indexAux1:indexAux2));
      W_before(indexAux1:indexAux2)=Z(t,k); %%%%% if there is RESAMPLING, it remains invariant  
      
     
      wn{k}=w(indexAux1:indexAux2)/sum(w(indexAux1:indexAux2));
      
     %%% Partial estimation of each filter at each iteration
     %%% xestpar(t,k)=sum(wn{k}.*x_prop(t,indexAux1:indexAux2));
     
      
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
     %%%% in order to control formulas of the paper %%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     if controlExpressions==1
      waux{k}=w(indexAux1:indexAux2);
      SUMaux(k)=sum(w(indexAux1:indexAux2));
      NoPaux(k)=length(wn{k});
     end
      
      
     
    end
    
   

  

  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    rho(t,:)=Z(t,:)./sum(Z(t,:)); %%%% ESTIMATION POSTERIOR PROB OF THE MODELS 
    GammaGlobalWeights=w./sum(w); %%%% GLOBAL WEIGHTS
    xest(t)=sum(GammaGlobalWeights.*x_prop(t,:)); %%%% GLOBAL MMSE ESTIMATOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
  %%%%% CODE below only for checking some expression in the paper 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   %%%%%%%% control factorization and other formulas %%%% 
  if controlExpressions==1 
     disp('**********************')
      disp('**   Control Mode   **')
      disp('**********************')
      disp('Controlling weight factorization')
      
      
     error=SUMaux-NoPaux.*Z(t,:);
     mean(error)
    disp('it is possible to have small numerical error- ok')
    error=sum(SUMaux)- sum(w);
    mean(error)
    disp('it is possible to have small numerical error- ok')
    DenControl=sum(NoPaux.*Z(t,:)); 
 
    countContr=0;
    for k=1:K
    GammaControl(countContr+1:countContr+length(wn{k}))=(NoPaux(k).*Z(t,k).*wn{k})/DenControl;
    countContr=countContr+length(wn{k});
    end
   errorNum=GammaGlobalWeights-GammaControl; %%% virtually zero; order 10^(-17)- numerical error
   disp('Weight Factorization control; mean error')
   mean(errorNum)
   disp('it is possible to have small numerical error- ok')
   disp('Press a key')
   disp(' ')
    pause   
  end %%% control- if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
 
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% choosing an ESS approximation %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TypeESS='Standard';
switch  TypeESS
    case'Standard'    
     ESS=1/sum(GammaGlobalWeights.^2);
     epsilon=max([1/N+0.1,0.1]);
    case 'Alternative'  
       ESS=1/max(GammaGlobalWeights); %%% alternative and more robust option
       epsilon=max([1/N+0.1,0.1]);
    otherwise
      ESS=1/sum(GammaGlobalWeights.^2);
      epsilon=max([1/N+0.1,0.5]); 
  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% condition for refreshing  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if TV=='automatic'
    condition1=(ESS<=epsilon*N);
 %   if mod(t,370)==0 | mod(t,410)==0 | mod(t,450)==0
    if mod(t,300)==0 |  mod(t,370)==0 | mod(t,410)==0 | mod(t,450)==0      
        conditionREFRESH=1;
       
    elseif condition1==1     
      %%%% probability of refreshing %%%%
       pa=0.1;
       conditionREFRESH=randsrc(1,1,[0 1;1-pa pa]);
            
    else
        conditionREFRESH=0;   
    end
   
else %%% no automatic/adaptive refreshing %%%  
    conditionREFRESH=(mod(t,TV)==0);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% RESAMPLINGS: DIFFERENT TYPES    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if conditionREFRESH %%% REFRESH
    
     disp(['REFRESH Global Resampling at the iteration: ',num2str(t), ' /',num2str(T+1)])
    
     countRefresh=countRefresh+1;
     pr_rho=1/K*ones(1,K); 
    NoP(t,:)=fix(pr_rho*N); %%% update number of particles
     NUM_of_particles_still_needed=sum(NoP(t,:))-N;
    auxfind2=find(NoP(t,:)==max(NoP(t,:)));
      NoP(t,auxfind2(1))=NoP(t,auxfind2(1))-NUM_of_particles_still_needed;
      pr_rho=NoP(t,:)./sum(NoP(t,:));
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%% resampling of the REFRESH step %%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       x_prop(t,:)=randsrc(1,N,[x_prop(t,:);GammaGlobalWeights]);
   %%%% end resampling of the REFRESH step

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%% STANDARD RESAMPLING %%%%%%%    
elseif ESS<=epsilon*N %%% STANDARD RESAMPLING WITHIN EACH FILTER
%%%%%%%% IF WE HAVE ALREADY REFRESHED WE DO NOT DO STANDARD RESAMPLING, clearly 


        
  
      pr_rho=rho(t,:); %%%% UPDATING post-prob of the models
      
      NoP(t,:)=fix(pr_rho*N);
      auxfind=find(NoP(t,:)<=MINIMUM_PARTICLES_PER_FILTER);
      auxfind2=find(NoP(t,:)==max(NoP(t,:)));
      NoP(t,auxfind)=MINIMUM_PARTICLES_PER_FILTER;
      NUM_of_particles_still_needed=sum(NoP(t,:))-N;
      NoP(t,auxfind2(1))=NoP(t,auxfind2(1))-NUM_of_particles_still_needed;
  
      
    pr_rho=NoP(t,:)./sum(NoP(t,:));
      
 %%%% resampling
    COUNTAUX=0;
    for k=1:K
       indexAux1=COUNTAUX+1; 
      if k==K
       indexAux2=N;
      else 
       indexAux2=COUNTAUX+NoP(t,k);    
      end 
      COUNTAUX=COUNTAUX+NoP(t,k);
       NumPar=indexAux2-indexAux1+1;%%%%% NumPar is equal to NoP(i,k) but can differ just in order to have $N$ total number of particles 
      x_prop(t,indexAux1:indexAux2)=randsrc(1,NumPar,[sample_per_Filter{k};wn{k}]);
    end 
   %%%% end resampling
   %%%% aux var= iteration when the standard resampling is applied   
   positionStandResampling(end+1)=t-1;
   
   
  else %%%% NO-RESAMPLING (any kind)
      W_before=w; %%% restore the correct weights   
end
%%%% end resampling and adaptation     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  
  
  
end %%%% end filtering - end algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% RESULTS %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

MSE=mean(abs(xest-x).^2);


disp(' ')
disp('----------------------------------------------------------------------------------------------- ')
disp(' ')
disp(['Refreshing Resampling applied ', num2str(countRefresh),' times /',num2str(T)])
disp(['Standard Resampling applied ',num2str(length(positionStandResampling)),' times /',num2str(T),' at the iterations: '])
disp([num2str(positionStandResampling)])
disp(' ')
disp(['Total number of resampling steps: ',num2str(length(positionStandResampling)+countRefresh)])
disp(['MSE in estimation: ',num2str(MSE)])
disp(' ')
disp('----------------------------------------------------------------------------------------------- ')


figure
plot(x,'b--')
hold on
plot(xest,'r')
legend('True','Estimated')
set(gca,'FontSize',20)
 set(gca,'FontWeight','Bold')
 xlabel('t')
 axis([0 T+20 min([x xest])-5 max([x xest])+5])
 
 

figure
plot(NoP)
set(gca,'FontSize',20)
 set(gca,'FontWeight','Bold')
 xlabel('t')
 title('Number of particles per filter')
  axis([0 T+20 0 N])



