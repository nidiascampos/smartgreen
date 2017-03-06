function [MSE,RATE_rightDec,NoP,x,xest,rho]=MAPF_EX2(N,T,K,TV,SCENARIO)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MODEL AVERANGING PARTICLE FILTER (MAPF)       %%%%%
%%%%% http://vixra.org/abs/1512.0420                %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% EXAMPLE (EX2): parameter selection            %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% N= total number of particles (fixed; shared by the parallel filters)
%%% T= total number of iterations
%%% K= number of models (number of different pamaters to test)
%%% T_V= refreshing parameter  
%%% SCENARIO= different scenarios for testing the algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Examples of use 
%%% [MSE,Ra,NoP]=MAPF_EX2(10000,500,10,100,'S1');
%%% [MSE,Ra,NoP]=MAPF_EX2(10000,500,10,'automatic','S1');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clc



disp('-------------------------------------------------------------------------- ')
disp('               MODEL AVERANGING PARTICLE FILTER (MAPF)')
disp('(cooperative parallel particle filters for tracking and model selection)')
disp('http://vixra.org/abs/1512.0420 ')
disp('-------------------------------------------------------------------------- ')
disp('Example: Parameter selection')
disp('-------------------------------------------------------------------------- ')
disp([' Total number of particles (shared by the filters)= ',num2str(N)])
disp([' Number of models (and parallel filters)= ',num2str(K)])
disp([' Total number of iterations = ',num2str(T)])

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

%%% true parameters of the model %%%
x(1)=0;
s1=1;
s2=1;
a=1;
b=1;
for t=2:T+1         
    x(t)=a*abs(x(t-1))+s1*randn(1,1);  
    y(t)=b*log(x(t).^2)+s2*randn(1,1); 
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controlExpressions=0; %%% 0= no control; 1= controlling weight factorization 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% COOPERATIVE PARALLEL PARTICLE FILTERING          %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% initial parameters of the algorithm

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% THE TRUE MODEL IS CONTAINED IN THE SET OF CONSIDERED MODEL
%%%% THE TRUE MODEL  ALWAYS CORRESPONDS TO THE LAST CONFIGURATION 
%%%% OF THE PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch SCENARIO

    case 'S1'
     %%%%%%%%%%%%%%%%%%%%%%%%%%%    
     %%%% NOTHING COMMON   %%%%% 
     %%%%%%%%%%%%%%%%%%%%%%%%%%% 
     
     disp('------------------------------------------------------------------------------------------------')
     disp('SCENARIO: all the models differ for their parameters in the dynamic and observation equations')
     disp('True model: the last one')
     disp('------------------------------------------------------------------------------------------------')
     
     
       %%%%%
       a_models=[1/K:1/K:1];
       %%%%
       s1_models=[0.1+10*rand(1,K-1) s1];
       %%%%
       par_aux=1/3:10/K:10*(K-1)/K;
       if  length(par_aux)==K-1
           b_models=[par_aux 1];
       else
           b_models=[par_aux 0.1+10*rand(1,K-1-length(par_aux))  1];   
       end
       %%%%%
       s2_models=[0.1+10*rand(1,K-1) s2];
       
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%% 
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%     
  case 'S2'
     %%%%%%%%%%%%%%%%%%%%%%%%%%    
     %%%% COMMON LIKE %%%%%%%%% 
     %%%%%%%%%%%%%%%%%%%%%%%%%%  
     disp('--------------------------------------------------------------------------- ')
     disp('SCENARIO: all the models differ in the dynamic equations')
     disp('COMMON LIKELIHOOD (common observation equation)') 
     disp('True model: the last one')
     disp('--------------------------------------------------------------------------- ')
    
      a_models=[1/K:1/K:1];
      s1_models=[0.1+10*rand(1,K-1) s1];
      b_models=b*ones(1,K);
      s2_models=s2*ones(1,K);
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
 case 'S3'
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
     %%%% COMMON DYNAMIC MODEL %%%%%%%%%% 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     disp('--------------------------------------------------------------------------- ')
     disp('SCENARIO: the models differ in the observation equations')
     disp('COMMON DYNAMIC MODEL (common state equation)') 
     disp('True model: the last one')
     disp('--------------------------------------------------------------------------- ')
     
     
    a_models=a*ones(1,K);
    %%%%
    s1_models=s1*ones(1,K);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par_aux=1/3:10/K:10*(K-1)/K;
       if  length(par_aux)==K-1
           b_models=[par_aux 1];
       else
           b_models=[par_aux 0.1+10*rand(1,K-1-length(par_aux))  1];   
       end
        %%%%
       s2_models=[0.1+10*rand(1,K-1) s2];
       
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'S4'
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
     %%%% COMMON LIKE- and only a_k variable %%%%%%%%% 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
     disp('--------------------------------------------------------------------------- ')
     disp('SCENARIO: only the parameter a_k of the dynamic equation changes')
     disp('COMMON LIKELIHOOD (common observation equation)') 
     disp('True model: the last one')
     disp('--------------------------------------------------------------------------- ')
    
     
     a_models=[1/K:1/K:1];
     s1_models=s1*ones(1,K);   
     b_models=b*ones(1,K);
     s2_models=s2*ones(1,K);
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'S0' 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
     %%%% COMMON BOTH-ONLY 1 MODEL - True model %%%%%%%%% 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
     disp('--------------------------------------------------------------------------- ')
     disp('SCENARIO: all the models are the true model')
     disp('--------------------------------------------------------------------------- ')
     
      a_models=a*ones(1,K);
     s1_models=s1*ones(1,K);
      b_models=b*ones(1,K);
     s2_models=s2*ones(1,K);
       
end



 
 
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
        %%%% Propagation %%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        NumPar=indexAux2-indexAux1+1;
       %%%%% NumPar is equal to NoP(i,k) but can differ just in order to have $N$ total number of particles      
         x_prop(t,indexAux1:indexAux2)=a_models(k)*abs(x_prop(t-1,indexAux1:indexAux2))+s1_models(k)*randn(1,NumPar);     
         sample_per_Filter{k}=x_prop(t,indexAux1:indexAux2);
      %%%% likelihood  
     like(indexAux1:indexAux2)=1/(sqrt(2*pi*s2_models(k)^2))*exp(-(y(t)-b_models(k)*log(x_prop(t,indexAux1:indexAux2).^2)).^2/(2*s2_models(k).^2));
     

     if mod(t,TV-1)==0
         %%%%% IF THERE WAS - REFRESH  %%%%%%
      w(indexAux1:indexAux2)=like(indexAux1:indexAux2)+10^(-323); 
     else      %%%%%% WEIGHT COMPUTATE PROPERLY AFTER RESAMPLING OR NOT  
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
     if mod(t,300)==0 |  mod(t,370)==0 | mod(t,410)==0 | mod(t,480)==0           
        conditionREFRESH=1;
       
    elseif condition1==1     
      %%%% probability of refreshing  
        % pa=sum((NoP(t,:)/N).^2);
        %pa=K*0.01;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Inferring the true model 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  %%%% MAP estimator of the model
  %MAP_model_decision=find(pr_rho==max(pr_rho));
  MAP_model_decision=find(rho(t,:)==max(rho(t,:)));
  
  %%% THE RIGHT MODEL IS THE LAST ONE (always) 
  if  MAP_model_decision(1)==K   %%%% we put 1 only for the case of several maxima  
      Decision_MATCH=Decision_MATCH+1;
  end
%%%% end - inferring model  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
  
end %%%% end filtering - end algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




if SCENARIO=='S4' %%%% all the models coincides with the true model
    Decision_MATCH=T;
  end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% RESULTS %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%

MSE=mean(abs(xest-x).^2);
RATE_rightDec=Decision_MATCH/T;

disp(' ')
disp('----------------------------------------------------------------------------------------------- ')
disp(' ')
disp(['Refreshing Resampling applied ', num2str(countRefresh),' times /',num2str(T)])
disp(['Standard Resampling applied ',num2str(length(positionStandResampling)),' times /',num2str(T),' at the iterations: '])
disp([num2str(positionStandResampling)])
disp(' ')
disp(['Total number of resampling steps: ',num2str(length(positionStandResampling)+countRefresh)])
disp(['MSE in estimation: ',num2str(MSE)])
disp(['(Perfect Match) Rate of right decision about the model: ',num2str(RATE_rightDec)])
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



