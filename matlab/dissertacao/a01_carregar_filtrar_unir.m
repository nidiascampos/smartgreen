%% APP UMIDADE SOLO - PASSOS 1 / 2
% BAIXO NÍVEL

%% LIMPAR WORKSPACE
clear;
% clf;

%% CARREGAR DADOS
load('logs/coleta03_watermarks_alt');
load('logs/coleta03_watermarks_thingspeak_30may');
load('logs/coleta03_tensiometros');

%% ajustando manualmente dados do modulo 5
modulo5_1(1:15,:) = [];
modulo5_1(2:72,:) = [];
modulo5_1(3:53,:) = [];
modulo5_1(4:8,:) = [];
modulo5_1(5:23,:) = [];
modulo5_1(6:68,:) = [];
modulo5_1(7:76,:) = [];
modulo5_1(8:73,:) = [];
modulo5_1(9:82,:) = [];
modulo5_1(10:89,:) = [];
modulo5_1(11:90,:) = [];
modulo5_1(12:89,:) = [];
modulo5_1(13:89,:) = [];
modulo5_1(14:93,:) = [];
modulo5_1(15:94,:) = [];
modulo5_1(16:96,:) = [];
modulo5_1(17:97,:) = [];
modulo5_1(18:97,:) = [];
modulo5_1(19:98,:) = [];
modulo5_1(20:101,:) = [];
modulo5_1(21:107,:) = [];
modulo5_1(22:102,:) = [];
modulo5_1(23:102,:) = [];
modulo5_1(24:83,:) = [];
modulo5_1(25:102,:) = [];
modulo5_1(26:58,:) = [];
modulo5_1(27:49,:) = [];
modulo5_1(28:101,:) = [];
modulo5_1(29:105,:) = [];
modulo5_1(30:103,:) = [];
modulo5_1(31:107,:) = [];
modulo5_1(32:108,:) = [];
modulo5_1(33:113,:) = [];
modulo5_1(34:111,:) = [];
modulo5_1(35:116,:) = [];
modulo5_1(36:114,:) = [];
modulo5_1(37:113,:) = [];
modulo5_1(38:117,:) = [];
modulo5_1(39:122,:) = [];
modulo5_1(40:127,:) = [];
modulo5_1(41:142,:) = [];
modulo5_1(42:129,:) = [];
modulo5_1(43:132,:) = [];
modulo5_1(44:132,:) = [];
modulo5_1(45:127,:) = [];
modulo5_1(46:122,:) = [];
modulo5_1(47:117,:) = [];
modulo5_1(48:86,:) = [];
modulo5_1(49:64,:) = [];

% converter em timetable
modulo5_1 = table2timetable(modulo5_1);
modulo5_2 = table2timetable(modulo5_2);

% ajustando horarios
modulo5_1.when(1:end,:).Second = 0;
modulo5_1.when(1:end,:).Minute = 0;
modulo5_1.when(49,:).Hour = 14;
modulo5_1.module(50) = 5;
modulo5_1.battery(50) = NaN;
modulo5_1.wetness(50) = NaN;
% modulo5_1.rain(50) = NaN;
modulo5_1.temperature(50) = NaN;
modulo5_1.when(50).Hour = 14;
modulo5_1.when(50) = '2017-04-26 14:00:00.000';

modulo5_2 = retime(modulo5_2, 'hourly', 'linear');
modulo5_2(1,:) = [];

% reordenando a timetable
modulo5_1 = sortrows(modulo5_1);

% retornando ao formato tabela
modulo5_1 = timetable2table(modulo5_1);
modulo5_2 = timetable2table(modulo5_2);

modulo5 = [modulo5_1; modulo5_2];

%% ordenar dados
modulo1 = sortrows(modulo1);
modulo2 = sortrows(modulo2);
modulo3 = sortrows(modulo3);
modulo4 = sortrows(modulo4);
modulo5 = sortrows(modulo5);

%% Removendo dados de modulos travados
% modulo1(232:end,:) = [];
modulo1_thingspeak(162:end,:) = [];

%% Removendo linha repetida
modulo2(106,:) = [];

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

%% Remover dados redundantes do thingspeak
modulo1_thingspeak(1:25,:) = [];
modulo2_thingspeak(1:26,:) = [];
modulo3_thingspeak(1:19,:) = [];
modulo4_thingspeak(1:14,:) = [];
modulo5_thingspeak(1:12,:) = [];

%% Remover coluna desnecessaria
modulo1.module = [];
modulo1.d15cm_bias = [];
modulo1.d45cm_bias = [];
modulo1.d75cm_bias = [];
modulo2.module = [];
modulo2.d15cm_bias = [];
modulo2.d45cm_bias = [];
modulo2.d75cm_bias = [];
modulo3.module = [];
modulo3.d15cm_bias = [];
modulo3.d45cm_bias = [];
modulo3.d75cm_bias = [];
modulo4.module = [];
modulo4.d15cm_bias = [];
modulo4.d45cm_bias = [];
modulo4.d75cm_bias = [];
modulo5.module = [];

modulo1_thingspeak.d15cm_bias = [];
modulo1_thingspeak.d45cm_bias = [];
modulo1_thingspeak.d75cm_bias = [];
modulo2_thingspeak.d15cm_bias = [];
modulo2_thingspeak.d45cm_bias = [];
modulo2_thingspeak.d75cm_bias = [];
modulo3_thingspeak.d15cm_bias = [];
modulo3_thingspeak.d45cm_bias = [];
modulo3_thingspeak.d75cm_bias = [];
modulo4_thingspeak.d15cm_bias = [];
modulo4_thingspeak.d45cm_bias = [];
modulo4_thingspeak.d75cm_bias = [];

modulo1.battery = [];
modulo2.battery = [];
modulo3.battery = [];
modulo4.battery = [];
modulo5.battery = [];

modulo1_thingspeak.battery = [];
modulo2_thingspeak.battery = [];
modulo3_thingspeak.battery = [];
modulo4_thingspeak.battery = [];
modulo5_thingspeak.battery = [];

modulo5.rain = [];
modulo5_thingspeak.rain = [];

%% dividindo thingspeak
% modulo1_thingspeak não precisa ser dividido, os dados estão continuos

modulo2_thingspeak_1 = modulo2_thingspeak(1:256,:);
modulo2_thingspeak_2 = modulo2_thingspeak(257:end,:);

modulo3_thingspeak_1 = modulo3_thingspeak(1:73,:);
modulo3_thingspeak_2 = modulo3_thingspeak(74:end,:);

% modulo_thingspeak não precisa ser dividido, os dados estão continuos

modulo5_thingspeak_1 = modulo5_thingspeak(4:149,:);
modulo5_thingspeak_2 = modulo5_thingspeak(152:end,:);

%% resample para horas homegeneas
modulo1_thingspeak = retime(modulo1_thingspeak,'hourly','linear');

% modulo2_thingspeak = retime(modulo2_thingspeak,'hourly','linear');
modulo2_thingspeak_1 = retime(modulo2_thingspeak_1,'hourly','linear');
modulo2_thingspeak_2 = retime(modulo2_thingspeak_2,'hourly','linear');

% modulo3_thingspeak = retime(modulo3_thingspeak,'hourly','linear');
modulo3_thingspeak_1 = retime(modulo3_thingspeak_1,'hourly','linear');
modulo3_thingspeak_2 = retime(modulo3_thingspeak_2,'hourly','linear');

modulo4_thingspeak = retime(modulo4_thingspeak,'hourly','linear');

% modulo5_thingspeak = retime(modulo5_thingspeak,'hourly','linear');
modulo5_thingspeak_1 = retime(modulo5_thingspeak_1,'hourly','linear');
modulo5_thingspeak_1.temperature(63:end,:) = NaN;
modulo5_thingspeak_2 = retime(modulo5_thingspeak_2,'hourly','linear');

%% reunificando thingspeak do modulo 5
modulo2_thingspeak = [modulo2_thingspeak_1; modulo2_thingspeak_2];
modulo3_thingspeak = [modulo3_thingspeak_1; modulo3_thingspeak_2];
modulo5_thingspeak = [modulo5_thingspeak_1; modulo5_thingspeak_2];

%% Unir tabelas dos watermarks
modulo1 = [modulo1; modulo1_thingspeak];
modulo2 = [modulo2; modulo2_thingspeak];
modulo3 = [modulo3; modulo3_thingspeak];
modulo4 = [modulo4; modulo4_thingspeak];
modulo5 = [modulo5; modulo5_thingspeak];

%% renomeando variavel de temperatura do modulo5
modulo5.Properties.VariableNames{2} = 'soil_temperature';

%% unificando dados
coleta03_total_12 = outerjoin(modulo1,modulo2);
coleta03_total_34 = outerjoin(modulo3,modulo4);
coleta03_total_1234 = outerjoin(coleta03_total_12,coleta03_total_34);
coleta03_total = outerjoin(coleta03_total_1234,modulo5);

%% DAI-FEO - conversão dados de chuva (modulo5)
% sem chuva
coleta03_total.wetness(coleta03_total.wetness > 900 & coleta03_total.wetness <= 1023) = 0;
% chuva fraca
coleta03_total.wetness(coleta03_total.wetness > 600 & coleta03_total.wetness <= 900 & coleta03_total.wetness ~= 0) = 1;
% chuva moderada
coleta03_total.wetness(coleta03_total.wetness > 400 & coleta03_total.wetness <= 600 & coleta03_total.wetness ~= 0  & coleta03_total.wetness ~= 1) = 2;
% chuva intensa
coleta03_total.wetness(coleta03_total.wetness <= 400 & coleta03_total.wetness ~= 0 & coleta03_total.wetness ~= 1 & coleta03_total.wetness ~= 2) = 3;

% filtragem de valores fora do escopo do sensor
coleta03_total.wetness(coleta03_total.wetness ~= 0 & coleta03_total.wetness ~= 1 & coleta03_total.wetness ~= 2 & coleta03_total.wetness ~= 3) = NaN;

%% DAI-DAO - conversão dados de temperatura do solo
% conversão feita no arduino

% filtragem de valores fora do escopo do sensor
coleta03_total.soil_temperature(coleta03_total.soil_temperature < 20 | coleta03_total.soil_temperature > 32) = NaN;

%% DAI-FEO - conversão dados de umidade do solo
coleta03_total.d15cm_modulo1 = (3.213*(coleta03_total.d15cm_modulo1./1000)+4.093)./(1-0.009733*(coleta03_total.d15cm_modulo1./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d15cm_modulo2 = (3.213*(coleta03_total.d15cm_modulo2./1000)+4.093)./(1-0.009733*(coleta03_total.d15cm_modulo2./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d15cm_modulo3 = (3.213*(coleta03_total.d15cm_modulo3./1000)+4.093)./(1-0.009733*(coleta03_total.d15cm_modulo3./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d15cm_modulo4 = (3.213*(coleta03_total.d15cm_modulo4./1000)+4.093)./(1-0.009733*(coleta03_total.d15cm_modulo4./1000)-0.01205*coleta03_total.soil_temperature);

coleta03_total.d45cm_modulo1 = (3.213*(coleta03_total.d45cm_modulo1./1000)+4.093)./(1-0.009733*(coleta03_total.d45cm_modulo1./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d45cm_modulo2 = (3.213*(coleta03_total.d45cm_modulo2./1000)+4.093)./(1-0.009733*(coleta03_total.d45cm_modulo2./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d45cm_modulo3 = (3.213*(coleta03_total.d45cm_modulo3./1000)+4.093)./(1-0.009733*(coleta03_total.d45cm_modulo3./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d45cm_modulo4 = (3.213*(coleta03_total.d45cm_modulo4./1000)+4.093)./(1-0.009733*(coleta03_total.d45cm_modulo4./1000)-0.01205*coleta03_total.soil_temperature);

coleta03_total.d75cm_modulo1 = (3.213*(coleta03_total.d75cm_modulo1./1000)+4.093)./(1-0.009733*(coleta03_total.d75cm_modulo1./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d75cm_modulo2 = (3.213*(coleta03_total.d75cm_modulo2./1000)+4.093)./(1-0.009733*(coleta03_total.d75cm_modulo2./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d75cm_modulo3 = (3.213*(coleta03_total.d75cm_modulo3./1000)+4.093)./(1-0.009733*(coleta03_total.d75cm_modulo3./1000)-0.01205*coleta03_total.soil_temperature);
coleta03_total.d75cm_modulo4 = (3.213*(coleta03_total.d75cm_modulo4./1000)+4.093)./(1-0.009733*(coleta03_total.d75cm_modulo4./1000)-0.01205*coleta03_total.soil_temperature);

% filtragem de valores fora do escopo do sensor
coleta03_total.d15cm_modulo1(coleta03_total.d15cm_modulo1 < 0 | coleta03_total.d15cm_modulo1 > 200) = NaN;
coleta03_total.d15cm_modulo2(coleta03_total.d15cm_modulo2 < 0 | coleta03_total.d15cm_modulo2 > 200) = NaN;
coleta03_total.d15cm_modulo3(coleta03_total.d15cm_modulo3 < 0 | coleta03_total.d15cm_modulo3 > 200) = NaN;
coleta03_total.d15cm_modulo4(coleta03_total.d15cm_modulo4 < 0 | coleta03_total.d15cm_modulo4 > 200) = NaN;

coleta03_total.d45cm_modulo1(coleta03_total.d45cm_modulo1 < 0 | coleta03_total.d45cm_modulo1 > 200) = NaN;
coleta03_total.d45cm_modulo2(coleta03_total.d45cm_modulo2 < 0 | coleta03_total.d45cm_modulo2 > 200) = NaN;
coleta03_total.d45cm_modulo3(coleta03_total.d45cm_modulo3 < 0 | coleta03_total.d45cm_modulo3 > 200) = NaN;
coleta03_total.d45cm_modulo4(coleta03_total.d45cm_modulo4 < 0 | coleta03_total.d45cm_modulo4 > 200) = NaN;

coleta03_total.d75cm_modulo1(coleta03_total.d75cm_modulo1 < 0 | coleta03_total.d75cm_modulo1 > 200) = NaN;
coleta03_total.d75cm_modulo2(coleta03_total.d75cm_modulo2 < 0 | coleta03_total.d75cm_modulo2 > 200) = NaN;
coleta03_total.d75cm_modulo3(coleta03_total.d75cm_modulo3 < 0 | coleta03_total.d75cm_modulo3 > 200) = NaN;
coleta03_total.d75cm_modulo4(coleta03_total.d75cm_modulo4 < 0 | coleta03_total.d75cm_modulo4 > 200) = NaN;

%% filtragem geral

% removendo duas primeiras horas para começar com todos os modulos funcionando
coleta03_total(1:2,:) = [];

% removendo linhas com valores nulos
coleta03_total([23:29,45,47,49:115,297:390,511:end],:) = [];

%% substituindo NaN de temperatura do solo com as leituras anteriores
% coleta03_total.soil_temperature = fillmissing(coleta03_total.soil_temperature,'previous');