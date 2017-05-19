%% LIMPAR WORKSPACE
clear;
% clf;

%% CARREGAR DADOS
load('logs/coleta03_watermarks');
load('logs/coleta03_watermarks_thingspeak');
load('logs/coleta03_tensiometros');
load('logs/coleta03_estacao_paraipaba');
load('logs/coleta03_estacao_itapipoca');
load('logs/coleta03_estacao_fazgranjeiro_2017');

%% Removendo dados antes dos sensores estarem conectados
modulo1(1:4,:) = [];
modulo2(1:9,:) = [];
modulo1(1:4,:) = [];
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

%% modulo5: substituir -127 por NaN
modulo5.temperature(modulo5.temperature == -127) = NaN;

%% Determinar período de tempo a ser utilizado e filtrar tabelas
range = timerange('2017-04-25', '2017-05-16');
% periodoComparacao = datetime({'27/04/2017' '09/05/2017'});

modulo1_filtrado = modulo1(range,:);
modulo2_filtrado = modulo2(range,:);
modulo3_filtrado = modulo3(range,:);
modulo4_filtrado = modulo4(range,:);
tensiometro1 = tensiometro1(range,:);
tensiometro2 = tensiometro2(range,:);
tensiometro4 = tensiometro4(range,:);
tensiometro5 = tensiometro5(range,:);
estacao_itapipoca = estacao_itapipoca(range,:);
estacao_paraipaba = estacao_paraipaba(range,:);

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

%% Resample dos dados para horas homogeneas
% teste1 = retime(modulo1,'hourly','linear');
% teste2 = retime(modulo1,'hourly','spline');

% modulo1 = retime(modulo1,'hourly','pchip'); % 'pchip' foi a interpolacao mais interessante, depois do linear
% modulo2 = retime(modulo2,'hourly','pchip');
% modulo3 = retime(modulo3,'hourly','pchip');
% modulo4 = retime(modulo4,'hourly','pchip');
% modulo5 = retime(modulo5,'hourly','pchip');

%% plotar graficos
%% Watermarks
% 15cm
plotar_grafico_coleta03(modulo1.when,modulo1.d15cm,'separados/15cm_watermark_modulo1','Modulo 1: wm à 15cm','Ohm','off');
plotar_grafico_coleta03(modulo2.when,modulo2.d15cm,'separados/15cm_watermark_modulo2','Modulo 2: wm à 15cm','Ohm','off');
plotar_grafico_coleta03(modulo3.when,modulo3.d15cm,'separados/15cm_watermark_modulo3','Modulo 3: wm à 15cm','Ohm','off');
plotar_grafico_coleta03(modulo4.when,modulo4.d15cm,'separados/15cm_watermark_modulo4','Modulo 4: wm à 15cm','Ohm','off');
% 15cm unificado
grafico = figure('visible','off');
hold on;
grid on;
plot(modulo1.when,modulo1.d15cm,'o-','DisplayName','modulo 1');
plot(modulo2.when,modulo2.d15cm,'o-','DisplayName','modulo 2');
plot(modulo3.when,modulo3.d15cm,'o-','DisplayName','modulo 3');
plot(modulo4.when,modulo4.d15cm,'o-','DisplayName','modulo 4');
title('Watermark: 15cm');
legend('show');
saveas(grafico,'graphs/coleta03/15cm_watermark_unificado','png');

% 45cm
plotar_grafico_coleta03(modulo1.when,modulo1.d45cm,'separados/45cm_watermark_modulo1','Modulo 1: wm à 45cm','Ohm','off');
plotar_grafico_coleta03(modulo2.when,modulo2.d45cm,'separados/45cm_watermark_modulo2','Modulo 2: wm à 45cm','Ohm','off');
plotar_grafico_coleta03(modulo3.when,modulo3.d45cm,'separados/45cm_watermark_modulo3','Modulo 3: wm à 45cm','Ohm','off');
plotar_grafico_coleta03(modulo4.when,modulo4.d45cm,'separados/45cm_watermark_modulo4','Modulo 4: wm à 45cm','Ohm','off');
% 45cm unificado
grafico = figure('visible','off');
hold on;
grid on;
plot(modulo1.when,modulo1.d45cm,'o-','DisplayName','modulo 1');
plot(modulo2.when,modulo2.d45cm,'o-','DisplayName','modulo 2');
plot(modulo3.when,modulo3.d45cm,'o-','DisplayName','modulo 3');
plot(modulo4.when,modulo4.d45cm,'o-','DisplayName','modulo 4');
title('Watermark: 45cm');
legend('show');
saveas(grafico,'graphs/coleta03/45cm_watermark_unificado','png');

% 75cm
plotar_grafico_coleta03(modulo1.when,modulo1.d75cm,'separados/75cm_watermark_modulo1','Modulo 1: wm à 75cm','Ohm','off');
plotar_grafico_coleta03(modulo2.when,modulo2.d75cm,'separados/75cm_watermark_modulo2','Modulo 2: wm à 75cm','Ohm','off');
plotar_grafico_coleta03(modulo3.when,modulo3.d75cm,'separados/75cm_watermark_modulo3','Modulo 3: wm à 75cm','Ohm','off');
plotar_grafico_coleta03(modulo4.when,modulo4.d75cm,'separados/75cm_watermark_modulo4','Modulo 4: wm à 75cm','Ohm','off');
% 75cm unificado
grafico = figure('visible','off');
hold on;
grid on;
plot(modulo1.when,modulo1.d75cm,'o-','DisplayName','modulo 1');
plot(modulo2.when,modulo2.d75cm,'o-','DisplayName','modulo 2');
plot(modulo3.when,modulo3.d75cm,'o-','DisplayName','modulo 3');
plot(modulo4.when,modulo4.d75cm,'o-','DisplayName','modulo 4');
title('Watermark: 75cm');
legend('show');
saveas(grafico,'graphs/coleta03/75cm_watermark_unificado','png');

%% Tensiometros
% 15cm
plotar_grafico_coleta03(tensiometro1.when,tensiometro1.d15cm,'separados/15cm_tensiometro1','Tensiometro 1 à 15cm','kPa','off');
plotar_grafico_coleta03(tensiometro2.when,tensiometro2.d15cm,'separados/15cm_tensiometro2','Tensiometro 2 à 15cm','kPa','off');
plotar_grafico_coleta03(tensiometro4.when,tensiometro4.d15cm,'separados/15cm_tensiometro3','Tensiometro 4 à 15cm','kPa','off');
plotar_grafico_coleta03(tensiometro5.when,tensiometro5.d15cm,'separados/15cm_tensiometro4','Tensiometro 5 à 15cm','kPa','off');
% 15cm unificado
grafico = figure('visible','off');
hold on;
grid on;
plot(tensiometro1.when,tensiometro1.d15cm,'o-','DisplayName','tensiometro 1');
plot(tensiometro2.when,tensiometro2.d15cm,'o-','DisplayName','tensiometro 2');
plot(tensiometro4.when,tensiometro4.d15cm,'o-','DisplayName','tensiometro 4');
plot(tensiometro5.when,tensiometro5.d15cm,'o-','DisplayName','tensiometro 5');
title('Tensiometros: 15cm');
legend('show','Location','best');
saveas(grafico,'graphs/coleta03/15cm_tensiometro_unificado','png');

% 45cm
plotar_grafico_coleta03(tensiometro1.when,tensiometro1.d45cm,'separados/45cm_tensiometro1','Tensiometro 1 à 45cm','kPa','off');
plotar_grafico_coleta03(tensiometro2.when,tensiometro2.d45cm,'separados/45cm_tensiometro2','Tensiometro 2 à 45cm','kPa','off');
plotar_grafico_coleta03(tensiometro4.when,tensiometro4.d45cm,'separados/45cm_tensiometro3','Tensiometro 4 à 45cm','kPa','off');
plotar_grafico_coleta03(tensiometro5.when,tensiometro5.d45cm,'separados/45cm_tensiometro4','Tensiometro 5 à 45cm','kPa','off');
% 45cm unificado
grafico = figure('visible','off');
hold on;
grid on;
plot(tensiometro1.when,tensiometro1.d45cm,'o-','DisplayName','tensiometro 1');
plot(tensiometro2.when,tensiometro2.d45cm,'o-','DisplayName','tensiometro 2');
plot(tensiometro4.when,tensiometro4.d45cm,'o-','DisplayName','tensiometro 4');
plot(tensiometro5.when,tensiometro5.d45cm,'o-','DisplayName','tensiometro 5');
title('Tensiometros: 45cm');
legend('show','Location','best');
saveas(grafico,'graphs/coleta03/45cm_tensiometro_unificado','png');

% 75cm
plotar_grafico_coleta03(tensiometro1.when,tensiometro1.d75cm,'separados/75cm_tensiometro1','Tensiometro 1 à 75cm','kPa','off');
plotar_grafico_coleta03(tensiometro2.when,tensiometro2.d75cm,'separados/75cm_tensiometro2','Tensiometro 2 à 75cm','kPa','off');
plotar_grafico_coleta03(tensiometro4.when,tensiometro4.d75cm,'separados/75cm_tensiometro3','Tensiometro 4 à 75cm','kPa','off');
plotar_grafico_coleta03(tensiometro5.when,tensiometro5.d75cm,'separados/75cm_tensiometro4','Tensiometro 5 à 75cm','kPa','off');
% 75cm unificado
grafico = figure('visible','off');
hold on;
grid on;
plot(tensiometro1.when,tensiometro1.d75cm,'o-','DisplayName','tensiometro 1');
plot(tensiometro2.when,tensiometro2.d75cm,'o-','DisplayName','tensiometro 2');
plot(tensiometro4.when,tensiometro4.d75cm,'o-','DisplayName','tensiometro 4');
plot(tensiometro5.when,tensiometro5.d75cm,'o-','DisplayName','tensiometro 5');
title('Tensiometros: 75cm');
legend('show','Location','best');
saveas(grafico,'graphs/coleta03/75cm_tensiometro_unificado','png');

%% watermarks + tensiometros
% 15cm
grafico = figure('visible','off');
hold on;
grid on;
plot(tensiometro1.when,tensiometro1.d15cm,'x-','DisplayName','tensiometro 1');
plot(tensiometro2.when,tensiometro2.d15cm,'x-','DisplayName','tensiometro 2');
plot(tensiometro4.when,tensiometro4.d15cm,'x-','DisplayName','tensiometro 4');
plot(tensiometro5.when,tensiometro5.d15cm,'x-','DisplayName','tensiometro 5');
plot(modulo1.when,modulo1.d15cm_kPa,'o-','DisplayName','watermark 1');
plot(modulo2.when,modulo2.d15cm_kPa,'o-','DisplayName','watermark 2');
plot(modulo3.when,modulo3.d15cm_kPa,'o-','DisplayName','watermark 3');
plot(modulo4.when,modulo4.d15cm_kPa,'o-','DisplayName','watermark 4');
title('Watermarks e Tensiometros: 15cm');
legend('show','Location','best');
saveas(grafico,'graphs/coleta03/15cm_unificado','png');

% 15cm
grafico = figure('visible','off');
hold on;
grid on;
plot(tensiometro1.when,tensiometro1.d45cm,'x-','DisplayName','tensiometro 1');
plot(tensiometro2.when,tensiometro2.d45cm,'x-','DisplayName','tensiometro 2');
plot(tensiometro4.when,tensiometro4.d45cm,'x-','DisplayName','tensiometro 4');
plot(tensiometro5.when,tensiometro5.d45cm,'x-','DisplayName','tensiometro 5');
plot(modulo1.when,modulo1.d45cm_kPa,'o-','DisplayName','watermark 1');
plot(modulo2.when,modulo2.d45cm_kPa,'o-','DisplayName','watermark 2');
plot(modulo3.when,modulo3.d45cm_kPa,'o-','DisplayName','watermark 3');
plot(modulo4.when,modulo4.d45cm_kPa,'o-','DisplayName','watermark 4');
title('Watermarks e Tensiometros: 45cm');
legend('show','Location','best');
saveas(grafico,'graphs/coleta03/45cm_unificado','png');

% 75cm
grafico = figure('visible','off');
hold on;
grid on;
plot(tensiometro1.when,tensiometro1.d75cm,'x-','DisplayName','tensiometro 1');
plot(tensiometro2.when,tensiometro2.d75cm,'x-','DisplayName','tensiometro 2');
plot(tensiometro4.when,tensiometro4.d75cm,'x-','DisplayName','tensiometro 4');
plot(tensiometro5.when,tensiometro5.d75cm,'x-','DisplayName','tensiometro 5');
plot(modulo1.when,modulo1.d75cm_kPa,'o-','DisplayName','watermark 1');
plot(modulo2.when,modulo2.d75cm_kPa,'o-','DisplayName','watermark 2');
plot(modulo3.when,modulo3.d75cm_kPa,'o-','DisplayName','watermark 3');
plot(modulo4.when,modulo4.d75cm_kPa,'o-','DisplayName','watermark 4');
title('Watermarks e Tensiometros: 75cm');
legend('show','Location','best');
saveas(grafico,'graphs/coleta03/75cm_unificado','png');

%% estacao itapipoca
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.precipitacao,'estacao_itapipoca_precipitacao','Estação Itapipoca: Precipitação','mm','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.pressao,'estacao_itapipoca_pressao','Estação Itapipoca: Pressão (Instantanea)','hPa','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.pressao_max,'estacao_itapipoca_pressao_max','Estação Itapipoca: Pressão (Máxima)','hPa','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.pressao_min,'estacao_itapipoca_pressao_min','Estação Itapipoca: Pressão (Mínima)','hPa','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.pto_orvalho_inst,'estacao_itapipoca_pto_orvalho_inst','Estação Itapipoca: Ponto de orvalho (Instantanea)','Celsius','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.pto_orvalho_max,'estacao_itapipoca_pto_orvalho_max','Estação Itapipoca: Ponto de orvalho (Máxima)','Celsius','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.pto_orvalho_min,'estacao_itapipoca_pto_orvalho_min','Estação Itapipoca: Ponto de orvalho (Mínima)','Celsius','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.temp_inst,'estacao_itapipoca_temp_inst','Estação Itapipoca: Temperatura (Instantanea)','Celsius','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.temp_max,'estacao_itapipoca_temp_max','Estação Itapipoca: Temperatura (Máxima)','Celsius','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.temp_min,'estacao_itapipoca_temp_min','Estação Itapipoca: Temperatura (Mínima)','Celsius','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.umid_inst,'estacao_itapipoca_umid_inst','Estação Itapipoca: Umidade (Instantanea)','mm','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.umid_max,'estacao_itapipoca_umid_max','Estação Itapipoca: Umidade (Máxima)','mm','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.umid_min,'estacao_itapipoca_umid_min','Estação Itapipoca: Umidade (Mínima)','mm','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.radiacao,'estacao_itapipoca_radiacao','Estação Itapipoca: Radiação','kJ/m^2','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.vento_vel,'estacao_itapipoca_vento_vel','Estação Itapipoca: Vento (Velocidade)','m/s','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.vento_rajada,'estacao_itapipoca_vento_rajada','Estação Itapipoca: Vento (Rajada)','m/s','off');
plotar_grafico_coleta03(estacao_itapipoca.data,estacao_itapipoca.vento_direcao,'estacao_itapipoca_vento_direcao','Estação Itapipoca: Vento (Direção)','graus','off');