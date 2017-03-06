
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% MODEL AVERANGING PARTICLE FILTER (MAPF)       %%%%%
%%%%% http://vixra.org/abs/1512.0420                %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all
clc

 EXAMPLE=2; %%% 1 or 2 
 
 
 
 
switch EXAMPLE
    
    
    
    case 1    
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
%%% [MSE,NoP,x,xest,rho]=MAPF_EX1(10000,500,100,250);
%%% [MSE,NoP,x,xest,rho]=MAPF_EX1(10000,500,'automatic',250);
%%% [MSE,NoP,x,xest,rho]=MAPF_EX1(10000,500,'automatic',100);
%%% [MSE,NoP,x,xest,rho]=MAPF_EX1(10000,500,'automatic',50);
%%% [MSE,NoP,x,xest,rho]=MAPF_EX1(10000,500,50,300);
%%% [MSE,NoP,x,xest,rho]=MAPF_EX1(10000,500,10,300);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        N=10000;
        T=500;
        TV=100;
        %TV='automatic';
        TimeChangeModel=250;
        
     [MSE,NoP,x,xest,rho]=MAPF_EX1(N,T,TV,TimeChangeModel);
     
     
    case 2
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
N=10000;
T=500;
K=10;
TV=100;
SCENARIO='S0'; %%% alternatives: S2 S3 S4 and S0 (S0: all models are the true model 

[MSE,RATE_rightDec,NoP,x,xest,rho]=MAPF_EX2(N,T,K,TV,SCENARIO);
end