%% PASSOS 1 / 4

%% LIMPAR WORKSPACE
clear;
% clf;

%% CARREGAR DADOS
load('logs/coleta03_watermarks_alt');
load('logs/coleta03_watermarks_thingspeak_30may');
load('logs/coleta03_tensiometros');
%load('logs/coleta03_estacao_paraipaba'); % estacao da FUNCEME
load('logs/coleta03_estacao_itapipoca_29may'); % estacao do INMET
%load('logs/coleta03_estacao_fazgranjeiro_2017'); % estacao local

%% removendo atributo desnecessario
estacao_itapipoca(:,'codigo_estacao') = [];

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
estacao_itapipoca = sortrows(estacao_itapipoca);

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
estacao_itapipoca = table2timetable(estacao_itapipoca);
%estacao_paraipaba = table2timetable(estacao_paraipaba);

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

%% FILTRAGEM: removendo leituras erroneas
% substituindo valores nulos por NaN
modulo1 = standardizeMissing(modulo1,-1);
modulo2 = standardizeMissing(modulo2,-1);
modulo3 = standardizeMissing(modulo3,-1);
modulo4 = standardizeMissing(modulo4,-1);
modulo5 = standardizeMissing(modulo5,-1);
modulo1_thingspeak = standardizeMissing(modulo1_thingspeak,-1);
modulo2_thingspeak = standardizeMissing(modulo2_thingspeak,-1);
modulo3_thingspeak = standardizeMissing(modulo3_thingspeak,-1);
modulo4_thingspeak = standardizeMissing(modulo4_thingspeak,-1);
modulo5_thingspeak = standardizeMissing(modulo5_thingspeak,-1);

% modulos 1 a 4
modulo1.d15cm(modulo1.d15cm < 0 | modulo1.d15cm > 28000) = NaN;
modulo1.d45cm(modulo1.d45cm < 0 | modulo1.d45cm > 28000) = NaN;
modulo1.d75cm(modulo1.d75cm < 0 | modulo1.d75cm > 28000) = NaN;

modulo2.d15cm(modulo2.d15cm < 0 | modulo2.d15cm > 28000) = NaN;
modulo2.d45cm(modulo2.d45cm < 0 | modulo2.d45cm > 28000) = NaN;
modulo2.d75cm(modulo2.d75cm < 0 | modulo2.d75cm > 28000) = NaN;

modulo3.d15cm(modulo3.d15cm < 0 | modulo3.d15cm > 28000) = NaN;
modulo3.d45cm(modulo3.d45cm < 0 | modulo3.d45cm > 28000) = NaN;
modulo3.d75cm(modulo3.d75cm < 0 | modulo3.d75cm > 28000) = NaN;

modulo4.d15cm(modulo4.d15cm < 0 | modulo4.d15cm > 28000) = NaN;
modulo4.d45cm(modulo4.d45cm < 0 | modulo4.d45cm > 28000) = NaN;
modulo4.d75cm(modulo4.d75cm < 0 | modulo4.d75cm > 28000) = NaN;

modulo1_thingspeak.d15cm(modulo1_thingspeak.d15cm < 0 | modulo1_thingspeak.d15cm > 28000) = NaN;
modulo1_thingspeak.d45cm(modulo1_thingspeak.d45cm < 0 | modulo1_thingspeak.d45cm > 28000) = NaN;
modulo1_thingspeak.d75cm(modulo1_thingspeak.d75cm < 0 | modulo1_thingspeak.d75cm > 28000) = NaN;

modulo2_thingspeak.d15cm(modulo2_thingspeak.d15cm < 0 | modulo2_thingspeak.d15cm > 28000) = NaN;
modulo2_thingspeak.d45cm(modulo2_thingspeak.d45cm < 0 | modulo2_thingspeak.d45cm > 28000) = NaN;
modulo2_thingspeak.d75cm(modulo2_thingspeak.d75cm < 0 | modulo2_thingspeak.d75cm > 28000) = NaN;

modulo3_thingspeak.d15cm(modulo3_thingspeak.d15cm < 0 | modulo3_thingspeak.d15cm > 28000) = NaN;
modulo3_thingspeak.d45cm(modulo3_thingspeak.d45cm < 0 | modulo3_thingspeak.d45cm > 28000) = NaN;
modulo3_thingspeak.d75cm(modulo3_thingspeak.d75cm < 0 | modulo3_thingspeak.d75cm > 28000) = NaN;

modulo4_thingspeak.d15cm(modulo4_thingspeak.d15cm < 0 | modulo4_thingspeak.d15cm > 28000) = NaN;
modulo4_thingspeak.d45cm(modulo4_thingspeak.d45cm < 0 | modulo4_thingspeak.d45cm > 28000) = NaN;
modulo4_thingspeak.d75cm(modulo4_thingspeak.d75cm < 0 | modulo4_thingspeak.d75cm > 28000) = NaN;

% modulo 5
% FIXME: dados de wetness e rain do modulo5_1 não estão batendo, um dos
% dois está errado
modulo5.temperature(modulo5.temperature < 20 | modulo5.temperature > 32) = NaN;
modulo5.wetness(modulo5.wetness > 1023 | modulo5.wetness < 0) = NaN;

modulo5_thingspeak.temperature(modulo5_thingspeak.temperature < 20 | modulo5_thingspeak.temperature > 32) = NaN;
modulo5_thingspeak.wetness(modulo5_thingspeak.wetness > 1023 | modulo5_thingspeak.wetness < 0) = NaN;

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

%% FILTRAGEM: removendo leituras erroneas geradas pelo retime
% substituindo valores nulos por NaN
modulo1 = standardizeMissing(modulo1,-1);
modulo2 = standardizeMissing(modulo2,-1);
modulo3 = standardizeMissing(modulo3,-1);
modulo4 = standardizeMissing(modulo4,-1);
modulo5 = standardizeMissing(modulo5,-1);

% modulos 1 a 4
modulo1.d15cm(modulo1.d15cm < 0 | modulo1.d15cm > 28000) = NaN;
modulo1.d45cm(modulo1.d45cm < 0 | modulo1.d45cm > 28000) = NaN;
modulo1.d75cm(modulo1.d75cm < 0 | modulo1.d75cm > 28000) = NaN;

modulo2.d15cm(modulo2.d15cm < 0 | modulo2.d15cm > 28000) = NaN;
modulo2.d45cm(modulo2.d45cm < 0 | modulo2.d45cm > 28000) = NaN;
modulo2.d75cm(modulo2.d75cm < 0 | modulo2.d75cm > 28000) = NaN;

modulo3.d15cm(modulo3.d15cm < 0 | modulo3.d15cm > 28000) = NaN;
modulo3.d45cm(modulo3.d45cm < 0 | modulo3.d45cm > 28000) = NaN;
modulo3.d75cm(modulo3.d75cm < 0 | modulo3.d75cm > 28000) = NaN;

modulo4.d15cm(modulo4.d15cm < 0 | modulo4.d15cm > 28000) = NaN;
modulo4.d45cm(modulo4.d45cm < 0 | modulo4.d45cm > 28000) = NaN;
modulo4.d75cm(modulo4.d75cm < 0 | modulo4.d75cm > 28000) = NaN;

modulo1_thingspeak.d15cm(modulo1_thingspeak.d15cm < 0 | modulo1_thingspeak.d15cm > 28000) = NaN;
modulo1_thingspeak.d45cm(modulo1_thingspeak.d45cm < 0 | modulo1_thingspeak.d45cm > 28000) = NaN;
modulo1_thingspeak.d75cm(modulo1_thingspeak.d75cm < 0 | modulo1_thingspeak.d75cm > 28000) = NaN;

modulo2_thingspeak.d15cm(modulo2_thingspeak.d15cm < 0 | modulo2_thingspeak.d15cm > 28000) = NaN;
modulo2_thingspeak.d45cm(modulo2_thingspeak.d45cm < 0 | modulo2_thingspeak.d45cm > 28000) = NaN;
modulo2_thingspeak.d75cm(modulo2_thingspeak.d75cm < 0 | modulo2_thingspeak.d75cm > 28000) = NaN;

modulo3_thingspeak.d15cm(modulo3_thingspeak.d15cm < 0 | modulo3_thingspeak.d15cm > 28000) = NaN;
modulo3_thingspeak.d45cm(modulo3_thingspeak.d45cm < 0 | modulo3_thingspeak.d45cm > 28000) = NaN;
modulo3_thingspeak.d75cm(modulo3_thingspeak.d75cm < 0 | modulo3_thingspeak.d75cm > 28000) = NaN;

modulo4_thingspeak.d15cm(modulo4_thingspeak.d15cm < 0 | modulo4_thingspeak.d15cm > 28000) = NaN;
modulo4_thingspeak.d45cm(modulo4_thingspeak.d45cm < 0 | modulo4_thingspeak.d45cm > 28000) = NaN;
modulo4_thingspeak.d75cm(modulo4_thingspeak.d75cm < 0 | modulo4_thingspeak.d75cm > 28000) = NaN;

% FIXME: dados de wetness e rain do modulo5_1 não estão batendo, um dos
% dois está errado
modulo5.temperature(modulo5.temperature < 20 | modulo5.temperature > 32) = NaN;
modulo5.wetness(modulo5.wetness > 1023 | modulo5.wetness < 0) = NaN;

%% renomeando variavel de temperatura do modulo5
modulo5.Properties.VariableNames{2} = 'soil_temperature';

%% unificando dados
coleta03_total_12 = outerjoin(modulo1,modulo2);
coleta03_total_34 = outerjoin(modulo3,modulo4);
coleta03_total_1234 = outerjoin(coleta03_total_12,coleta03_total_34);
coleta03_total = outerjoin(coleta03_total_1234,modulo5);

%% removendo duas primeiras horas para começar com todos os modulos funcionando
coleta03_total(1:2,:) = [];

%% substituindo NaN de temperatura do solo com as leituras anteriores
coleta03_total.soil_temperature = fillmissing(coleta03_total.soil_temperature,'previous');