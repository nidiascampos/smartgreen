%% PASSO 1 / 4

%% LIMPAR WORKSPACE
clear;
% clf;

%% CARREGAR DADOS
load('logs/coleta03_watermarks');
load('logs/coleta03_watermarks_thingspeak_30may');
load('logs/coleta03_tensiometros');
load('logs/coleta03_estacao_paraipaba');
load('logs/coleta03_estacao_itapipoca');
load('logs/coleta03_estacao_fazgranjeiro_2017');

%% Removendo dados antes dos sensores estarem conectados
% FIXME: utilizar apenas com o arquivo 'coleta03_watermarks'
modulo1(1:4,:) = [];
modulo2(1:9,:) = [];
modulo3(1:6,:) = [];
modulo4(1:7,:) = [];

%% Converter tabelas em timetables
modulo1 = table2timetable(modulo1);
modulo2 = table2timetable(modulo2);
modulo3 = table2timetable(modulo3);
modulo4 = table2timetable(modulo4);
modulo5 = table2timetable(modulo5);
tensiometro1 = table2timetable(tensiometro1);
tensiometro2 = table2timetable(tensiometro2);
tensiometro4 = table2timetable(tensiometro4);
tensiometro5 = table2timetable(tensiometro5);
estacao_itapipoca = table2timetable(estacao_itapipoca);
estacao_paraipaba = table2timetable(estacao_paraipaba);

%% ordenar dados
modulo1 = sortrows(modulo1);
modulo2 = sortrows(modulo2);
modulo3 = sortrows(modulo3);
modulo4 = sortrows(modulo4);
modulo5 = sortrows(modulo5);
estacao_itapipoca = sortrows(estacao_itapipoca);

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
modulo5.module = [];

%% Unir tabelas dos watermarks
modulo1 = [modulo1; modulo1_thingspeak];
modulo2 = [modulo2; modulo2_thingspeak];
modulo3 = [modulo3; modulo3_thingspeak];
modulo4 = [modulo4; modulo4_thingspeak];
modulo5 = [modulo5; modulo5_thingspeak];

%% FILTRAGEM: removendo leituras erroneas
modulo1(229:233,:) = [];
modulo2(197:200,:) = [];
modulo3(202:208,:) = [];

modulo5.temperature(modulo5.temperature == -127) = NaN;
modulo5.temperature(modulo5.temperature == 0) = NaN;
modulo5.rain(modulo5.rain < 1 & modulo5.rain > 0) = NaN;

%% Resample dos dados para horas homogeneas (interpolação das medições)
% 'pchip' foi a interpolacao mais interessante, depois do linear
% mas decidi usar o linear para não introduzir nenhuma leitura foda do
% esperado
% teste1 = retime(modulo1,'hourly','linear');
% teste2 = retime(modulo1,'hourly','spline');
% teste3 = retime(modulo1,'hourly','spline');

modulo1 = retime(modulo1,'hourly','linear');
modulo2 = retime(modulo2,'hourly','linear');
modulo3 = retime(modulo3,'hourly','linear');
modulo4 = retime(modulo4,'hourly','linear');
modulo5 = retime(modulo5,'hourly','linear');

%% removendo valores do modulo 4 (parou de funcionar varias vezes)
modulo4.battery(139:end) = NaN;
modulo4.d15cm(139:end) = NaN;
modulo4.d15cm_bias(139:end) = NaN;
modulo4.d45cm(139:end) = NaN;
modulo4.d45cm_bias(139:end) = NaN;
modulo4.d75cm(139:end) = NaN;
modulo4.d75cm_bias(139:end) = NaN;

%% Determinar período de tempo a ser utilizado e filtrar tabelas
range = timerange('2017-04-25 16:00', '2017-05-09 11:00');
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