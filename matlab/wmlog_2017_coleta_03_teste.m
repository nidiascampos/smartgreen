%% PASSO 1c / 4

%% LIMPAR WORKSPACE
clear;
% clf;

%% CARREGAR DADOS
load('logs/coleta03_watermarks_alt');
load('logs/coleta03_watermarks_thingspeak_30may');
load('logs/coleta03_tensiometros');
load('logs/coleta03_estacao_paraipaba');
load('logs/coleta03_estacao_itapipoca');
load('logs/coleta03_estacao_fazgranjeiro_2017');

%% ordenar dados
modulo1 = sortrows(modulo1);
modulo2 = sortrows(modulo2);
modulo3 = sortrows(modulo3);
modulo4 = sortrows(modulo4);
% modulo5 = sortrows(modulo5);
estacao_itapipoca = sortrows(estacao_itapipoca);

%% Removendo dados antes dos sensores estarem conectados
% FIXME: utilizar apenas com o arquivo 'coleta03_watermarks'
% modulo1(1:4,:) = [];
% modulo2(1:9,:) = [];
% modulo3(1:6,:) = [];
% modulo4(1:6,:) = [];

%% Removendo dados de modulos travados
% modulo1(232:end,:) = [];
modulo1_thingspeak(162:end,:) = [];

%% Converter tabelas em timetables
modulo1 = table2timetable(modulo1);
modulo2 = table2timetable(modulo2);
modulo3 = table2timetable(modulo3);
modulo4 = table2timetable(modulo4);
% modulo5 = table2timetable(modulo5);
modulo5_1 = table2timetable(modulo5_1);
modulo5_2 = table2timetable(modulo5_2);
tensiometro1 = table2timetable(tensiometro1);
tensiometro2 = table2timetable(tensiometro2);
tensiometro4 = table2timetable(tensiometro4);
tensiometro5 = table2timetable(tensiometro5);
estacao_itapipoca = table2timetable(estacao_itapipoca);
estacao_paraipaba = table2timetable(estacao_paraipaba);

%% Remover dados redundantes do thingspeak
modulo1_thingspeak(1:23,:) = [];
modulo2_thingspeak(1:24,:) = [];
modulo3_thingspeak(1:19,:) = [];
modulo4_thingspeak(1:13,:) = [];
modulo5_thingspeak(1:12,:) = [];

%% Remover coluna desnecessaria
modulo1.module = [];
modulo2.module = [];
modulo3.module = [];
modulo4.module = [];
% modulo5.module = [];
modulo5_1.module = [];
modulo5_2.module = [];

%% FILTRAGEM: removendo leituras erroneas
% modulo1(233:237,:) = [];
% modulo2(197:200,:) = [];
% modulo3(202:208,:) = [];
% modulo4(87:88,:) = [];

% substituindo valores nulos por NaN
modulo1 = standardizeMissing(modulo1,-1);
modulo2 = standardizeMissing(modulo2,-1);
modulo3 = standardizeMissing(modulo3,-1);
modulo4 = standardizeMissing(modulo4,-1);
% modulo5 = standardizeMissing(modulo5,-1);
modulo5_1 = standardizeMissing(modulo5_1,-1);
modulo5_2 = standardizeMissing(modulo5_2,-1);
modulo5_thingspeak = standardizeMissing(modulo5_thingspeak,-1);

% modulo 5
modulo5_1(1:133,:) = []; % removendo por serem leituras estranhas fora do padrão
modulo5_1(3320:end,:) = []; % removendo por serem leituras estranhas fora do padrão

% FIXME: dados de wetness e rain do modulo5_1 não estão batendo, um dos
% dois está errado
modulo5_1.temperature(modulo5_1.temperature < 22 | modulo5_1.temperature > 32) = NaN;
modulo5_1.rain(modulo5_1.rain ~= 0 & modulo5_1.rain ~= 1) = NaN;
modulo5_1.wetness(modulo5_1.wetness > 1023 | modulo5_1.wetness < 0) = NaN;
modulo5_1.battery(modulo5_1.battery > 6.6 | modulo5_1.battery < 0) = NaN;

modulo5_2.temperature(modulo5_2.temperature < 22 | modulo5_2.temperature > 32) = NaN;
modulo5_2.rain(modulo5_2.rain ~= 0 & modulo5_2.rain ~= 1) = NaN;
modulo5_2.wetness(modulo5_2.wetness > 1023 | modulo5_2.wetness < 0) = NaN;
modulo5_2.battery(modulo5_2.battery > 6.6 | modulo5_2.battery < 0) = NaN;

modulo5_thingspeak.temperature(modulo5_thingspeak.temperature < 22 | modulo5_thingspeak.temperature > 32) = NaN;
modulo5_thingspeak.rain(modulo5_thingspeak.rain ~= 0 & modulo5_thingspeak.rain ~= 1) = NaN;
modulo5_thingspeak.wetness(modulo5_thingspeak.wetness > 1023 | modulo5_thingspeak.wetness < 0) = NaN;
modulo5_thingspeak.battery(modulo5_thingspeak.battery > 6.6 | modulo5_thingspeak.battery < 0) = NaN;

%% resample para horas homegeneas
modulo5_1 = retime(modulo5_1, 'hourly', 'linear');
modulo5_2 = retime(modulo5_2, 'hourly', 'linear');
modulo5 = [modulo5_1; modulo5_2];

modulo1_thingspeak = retime(modulo1_thingspeak,'hourly','linear');
modulo2_thingspeak = retime(modulo2_thingspeak,'hourly','linear');
modulo3_thingspeak = retime(modulo3_thingspeak,'hourly','linear');
modulo4_thingspeak = retime(modulo4_thingspeak,'hourly','linear');
modulo5_thingspeak = retime(modulo5_thingspeak,'hourly','linear');

%% Unir tabelas dos watermarks
modulo1 = [modulo1; modulo1_thingspeak];
modulo2 = [modulo2; modulo2_thingspeak];
modulo3 = [modulo3; modulo3_thingspeak];
modulo4 = [modulo4; modulo4_thingspeak];
modulo5 = [modulo5; modulo5_thingspeak];

%% ajuste de rain do modulo 5
modulo5.rain(modulo5.rain > 0.5) = 1;
modulo5.rain(modulo5.rain <= 0.5) = 0;

%% removendo valores do modulo 4 (parou de funcionar varias vezes)
% modulo4.battery(141:333,:) = NaN;
% modulo4.d15cm(141:333,:) = NaN;
% modulo4.d15cm_bias(141:333,:) = NaN;
% modulo4.d45cm(141:333,:) = NaN;
% modulo4.d45cm_bias(141:333,:) = NaN;
% modulo4.d75cm(141:333,:) = NaN;
% modulo4.d75cm_bias(141:333,:) = NaN;

%% Determinar período de tempo a ser utilizado e filtrar tabelas
range = timerange('2017-04-25 16:00', '2017-05-16 23:30');
% periodoComparacao = datetime({'27/04/2017' '09/05/2017'});

modulo1 = modulo1(range,:);
modulo2 = modulo2(range,:);
modulo3 = modulo3(range,:);
modulo4 = modulo4(range,:);
modulo5 = modulo5(range,:);
tensiometro1 = tensiometro1(range,:);
tensiometro2 = tensiometro2(range,:);
tensiometro4 = tensiometro4(range,:);
tensiometro5 = tensiometro5(range,:);
estacao_itapipoca = estacao_itapipoca(range,:);
estacao_paraipaba = estacao_paraipaba(range,:);

%% Converter Ohm para kPa (metodo com temperatura)
% modulo1.d15cm_kPa = (3.213*(modulo1.d15cm./1000)+4.093)./(1-0.009733*(modulo1.d15cm./1000)-0.01205*28);
% modulo2.d15cm_kPa = (3.213*(modulo2.d15cm./1000)+4.093)./(1-0.009733*(modulo2.d15cm./1000)-0.01205*28);
% modulo3.d15cm_kPa = (3.213*(modulo3.d15cm./1000)+4.093)./(1-0.009733*(modulo3.d15cm./1000)-0.01205*28);
% modulo4.d15cm_kPa = (3.213*(modulo4.d15cm./1000)+4.093)./(1-0.009733*(modulo4.d15cm./1000)-0.01205*28);
% 
% modulo1.d45cm_kPa = (3.213*(modulo1.d45cm./1000)+4.093)./(1-0.009733*(modulo1.d45cm./1000)-0.01205*28);
% modulo2.d45cm_kPa = (3.213*(modulo2.d45cm./1000)+4.093)./(1-0.009733*(modulo2.d45cm./1000)-0.01205*28);
% modulo3.d45cm_kPa = (3.213*(modulo3.d45cm./1000)+4.093)./(1-0.009733*(modulo3.d45cm./1000)-0.01205*28);
% modulo4.d45cm_kPa = (3.213*(modulo4.d45cm./1000)+4.093)./(1-0.009733*(modulo4.d45cm./1000)-0.01205*28);
% 
% modulo1.d75cm_kPa = (3.213*(modulo1.d75cm./1000)+4.093)./(1-0.009733*(modulo1.d75cm./1000)-0.01205*28);
% modulo2.d75cm_kPa = (3.213*(modulo2.d75cm./1000)+4.093)./(1-0.009733*(modulo2.d75cm./1000)-0.01205*28);
% modulo3.d75cm_kPa = (3.213*(modulo3.d75cm./1000)+4.093)./(1-0.009733*(modulo3.d75cm./1000)-0.01205*28);
% modulo4.d75cm_kPa = (3.213*(modulo4.d75cm./1000)+4.093)./(1-0.009733*(modulo4.d75cm./1000)-0.01205*28);

%% Converter Ohm para kPa (metodo sem temperatura)
modulo1.d15cm_kPa = (modulo1.d15cm-550)./137.5;
modulo2.d15cm_kPa = (modulo2.d15cm-550)./137.5;
modulo3.d15cm_kPa = (modulo3.d15cm-550)./137.5;
modulo4.d15cm_kPa = (modulo4.d15cm-550)./137.5;

modulo1.d45cm_kPa = (modulo1.d45cm-550)./137.5;
modulo2.d45cm_kPa = (modulo2.d45cm-550)./137.5;
modulo3.d45cm_kPa = (modulo3.d45cm-550)./137.5;
modulo4.d45cm_kPa = (modulo4.d45cm-550)./137.5;

modulo1.d75cm_kPa = (modulo1.d75cm-550)./137.5;
modulo2.d75cm_kPa = (modulo2.d75cm-550)./137.5;
modulo3.d75cm_kPa = (modulo3.d75cm-550)./137.5;
modulo4.d75cm_kPa = (modulo4.d75cm-550)./137.5;