% NAO ESTOU UTILIZANDO ESTE ARQUIVO
% SERVIU APENAS VALIDAR OS DADOS DOS WMLOG_2017_COLETA_03_TESTE
% POIS UTILIZA APENAS DADOS DO MONGODB (NADA DO THINGSPEAK) 

%% LIMPAR WORKSPACE
clear;
% clf;

%% CARREGAR DADOS
load('logs/coleta03_watermarks_mongo_only');
load('logs/coleta03_tensiometros');
load('logs/coleta03_estacao_itapipoca_29may');

%% separando modulos 1 a 4 em tabelas separadas
modulo01 = modulo01a04(1:575,:);
modulo02 = modulo01a04(576:1301,:);
modulo03 = modulo01a04(1302:2054,:);
modulo04 = modulo01a04(2055:end,:);