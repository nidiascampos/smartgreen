%% LIMPAR WORKSPACE
clear;
% clf;

%% CARREGAR DADOS
load('logs/coleta03_watermarks');
load('logs/coleta03_tensiometros');
load('logs/coleta03_estacao_paraipaba');
load('logs/coleta03_estacao_itapipoca');

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

%% modulo5: substituir -127 por NaN
modulo5.temperature(modulo5.temperature == -127) = NaN;

%% Determinar período de tempo a ser utilizado e filtrar tabelas
range = timerange('2017-04-27', '2017-05-09');

%% Converter Ohm para kPa
modulo1.d15cm_kPa = (3.213*(modulo1.d15cm./1000)+4.093)./(1-0.009733*(modulo1.d15cm./1000)-0.01205*28);
modulo2.d15cm_kPa = (3.213*(modulo2.d15cm./1000)+4.093)./(1-0.009733*(modulo2.d15cm./1000)-0.01205*28);
modulo3.d15cm_kPa = (3.213*(modulo3.d15cm./1000)+4.093)./(1-0.009733*(modulo3.d15cm./1000)-0.01205*28);
modulo4.d15cm_kPa = (3.213*(modulo4.d15cm./1000)+4.093)./(1-0.009733*(modulo4.d15cm./1000)-0.01205*28);

modulo1.d45cm_kPa = (3.213*(modulo1.d45cm./1000)+4.093)./(1-0.009733*(modulo1.d45cm./1000)-0.01205*28);
modulo2.d45cm_kPa = (3.213*(modulo2.d45cm./1000)+4.093)./(1-0.009733*(modulo2.d45cm./1000)-0.01205*28);
modulo3.d45cm_kPa = (3.213*(modulo3.d45cm./1000)+4.093)./(1-0.009733*(modulo3.d45cm./1000)-0.01205*28);
modulo4.d45cm_kPa = (3.213*(modulo4.d45cm./1000)+4.093)./(1-0.009733*(modulo4.d45cm./1000)-0.01205*28);

modulo1.d75cm_kPa = (3.213*(modulo1.d75cm./1000)+4.093)./(1-0.009733*(modulo1.d75cm./1000)-0.01205*28);
modulo2.d75cm_kPa = (3.213*(modulo2.d75cm./1000)+4.093)./(1-0.009733*(modulo2.d75cm./1000)-0.01205*28);
modulo3.d75cm_kPa = (3.213*(modulo3.d75cm./1000)+4.093)./(1-0.009733*(modulo3.d75cm./1000)-0.01205*28);
modulo4.d75cm_kPa = (3.213*(modulo4.d75cm./1000)+4.093)./(1-0.009733*(modulo4.d75cm./1000)-0.01205*28);

%% Resample dos dados para horas homogeneas
% teste1 = retime(modulo1,'hourly','linear');
% teste2 = retime(modulo1,'hourly','spline');
modulo1 = retime(modulo1,'hourly','pchip'); % 'pchip' foi a interpolacao mais interessante, depois do linear
modulo2 = retime(modulo2,'hourly','pchip');
modulo3 = retime(modulo3,'hourly','pchip');
modulo4 = retime(modulo4,'hourly','pchip');
modulo5 = retime(modulo5,'hourly','pchip');

%% Plotar
plot(modulo2.when,modulo2.d15cm,'DisplayName','modulo2.d15cm');
hold on;
plot(modulo2.when,modulo2.d45cm,'DisplayName','modulo2.d45cm');
plot(modulo2.when,modulo2.d75cm,'DisplayName','modulo2.d75cm');
hold off;

%% 15cm (Ohm)
plot(modulo1.when,modulo1.d15cm,'DisplayName','modulo1.d15cm');
hold on;
plot(modulo2.when,modulo2.d15cm,'DisplayName','modulo2.d15cm');
plot(modulo3.when,modulo3.d15cm,'DisplayName','modulo3.d15cm');
plot(modulo4.when,modulo4.d15cm,'DisplayName','modulo4.d15cm');
hold off;

%% 15cm (kPa)
plot(modulo1.when,modulo1.d15cm_kPa,'DisplayName','modulo1.d15cm');
hold on;
plot(modulo2.when,modulo2.d15cm_kPa,'DisplayName','modulo2.d15cm');
plot(modulo3.when,modulo3.d15cm_kPa,'DisplayName','modulo3.d15cm');
plot(modulo4.when,modulo4.d15cm_kPa,'DisplayName','modulo4.d15cm');
plot(tensiometro1.when,tensiometro1.d15cm,'--','DisplayName','tensiometro1.d15cm');
plot(tensiometro2.when,tensiometro2.d15cm,'--','DisplayName','tensiometro2.d15cm');
plot(tensiometro4.when,tensiometro4.d15cm,'--','DisplayName','tensiometro4.d15cm');
plot(tensiometro5.when,tensiometro5.d15cm,'--','DisplayName','tensiometro5.d15cm');
hold off;

%% 45cm (kPa)
plot(modulo1.when,modulo1.d45cm_kPa,'DisplayName','modulo1.d45cm');
hold on;
plot(modulo2.when,modulo2.d45cm_kPa,'DisplayName','modulo2.d45cm');
plot(modulo3.when,modulo3.d45cm_kPa,'DisplayName','modulo3.d45cm');
plot(modulo4.when,modulo4.d45cm_kPa,'DisplayName','modulo4.d45cm');
plot(tensiometro1.when,tensiometro1.d45cm,'DisplayName','tensiometro1.d45cm');
plot(tensiometro2.when,tensiometro2.d45cm,'DisplayName','tensiometro2.d45cm');
plot(tensiometro4.when,tensiometro4.d45cm,'DisplayName','tensiometro4.d45cm');
plot(tensiometro5.when,tensiometro5.d45cm,'DisplayName','tensiometro5.d45cm');
hold off;

%% 75cm (kPa)
plot(modulo1.when,modulo1.d75cm_kPa,'DisplayName','modulo1.d75cm');
hold on;
plot(modulo2.when,modulo2.d75cm_kPa,'DisplayName','modulo2.d75cm');
plot(modulo3.when,modulo3.d75cm_kPa,'DisplayName','modulo3.d75cm');
plot(modulo4.when,modulo4.d75cm_kPa,'DisplayName','modulo4.d75cm');
plot(tensiometro1.when,tensiometro1.d75cm,'DisplayName','tensiometro1.d75cm');
plot(tensiometro2.when,tensiometro2.d75cm,'DisplayName','tensiometro2.d75cm');
plot(tensiometro4.when,tensiometro4.d75cm,'DisplayName','tensiometro4.d75cm');
plot(tensiometro5.when,tensiometro5.d75cm,'DisplayName','tensiometro5.d75cm');
hold off;