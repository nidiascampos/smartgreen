%% PASSO 4 / 4

%% SEM FUSAO DE DADOS

% unindo dados
coleta03_total_semfusao = outerjoin(coleta03_total, estacao_itapipoca_total_EToPM_hora);

% removendo linhas sem EToPM por falha de sensor da estação
coleta03_total_semfusao(116:120,:) = [];
coleta03_total_semfusao(492:494,:) = [];
coleta03_total_semfusao(774,:) = [];

% filtrando o periodo desejado
range = timerange('2017-04-25 15:00', '2017-05-29 23:00');
coleta03_total_semfusao = coleta03_total_semfusao(range,:);

% removendo linhas sem leitura de pelo menos um dos modulos
coleta03_total_semfusao(50:75,:) = [];
coleta03_total_semfusao(108:184,:) = [];
coleta03_total_semfusao(378:438,:) = [];

% convertendo de Ohm para kPa pelo metodo basico
coleta03_total_semfusao_kPa_basico = coleta03_total_semfusao;

coleta03_total_semfusao_kPa_basico.d15cm_modulo1 = (coleta03_total_semfusao_kPa_basico.d15cm_modulo1-550)./137.5;
coleta03_total_semfusao_kPa_basico.d15cm_modulo2 = (coleta03_total_semfusao_kPa_basico.d15cm_modulo2-550)./137.5;
coleta03_total_semfusao_kPa_basico.d15cm_modulo3 = (coleta03_total_semfusao_kPa_basico.d15cm_modulo3-550)./137.5;
coleta03_total_semfusao_kPa_basico.d15cm_modulo4 = (coleta03_total_semfusao_kPa_basico.d15cm_modulo4-550)./137.5;

coleta03_total_semfusao_kPa_basico.d45cm_modulo1 = (coleta03_total_semfusao_kPa_basico.d45cm_modulo1-550)./137.5;
coleta03_total_semfusao_kPa_basico.d45cm_modulo2 = (coleta03_total_semfusao_kPa_basico.d45cm_modulo2-550)./137.5;
coleta03_total_semfusao_kPa_basico.d45cm_modulo3 = (coleta03_total_semfusao_kPa_basico.d45cm_modulo3-550)./137.5;
coleta03_total_semfusao_kPa_basico.d45cm_modulo4 = (coleta03_total_semfusao_kPa_basico.d45cm_modulo4-550)./137.5;

coleta03_total_semfusao_kPa_basico.d75cm_modulo1 = (coleta03_total_semfusao_kPa_basico.d75cm_modulo1-550)./137.5;
coleta03_total_semfusao_kPa_basico.d75cm_modulo2 = (coleta03_total_semfusao_kPa_basico.d75cm_modulo2-550)./137.5;
coleta03_total_semfusao_kPa_basico.d75cm_modulo3 = (coleta03_total_semfusao_kPa_basico.d75cm_modulo3-550)./137.5;
coleta03_total_semfusao_kPa_basico.d75cm_modulo4 = (coleta03_total_semfusao_kPa_basico.d75cm_modulo4-550)./137.5;

% convertendo de Ohm para kPa utilizando a temperatura do solo
coleta03_total_semfusao_kPa_avancado = coleta03_total_semfusao;

coleta03_total_semfusao_kPa_avancado.d15cm_modulo1 = (3.213*(coleta03_total_semfusao_kPa_avancado.d15cm_modulo1./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d15cm_modulo1./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d15cm_modulo2 = (3.213*(coleta03_total_semfusao_kPa_avancado.d15cm_modulo2./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d15cm_modulo2./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d15cm_modulo3 = (3.213*(coleta03_total_semfusao_kPa_avancado.d15cm_modulo3./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d15cm_modulo3./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d15cm_modulo4 = (3.213*(coleta03_total_semfusao_kPa_avancado.d15cm_modulo4./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d15cm_modulo4./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);

coleta03_total_semfusao_kPa_avancado.d45cm_modulo1 = (3.213*(coleta03_total_semfusao_kPa_avancado.d45cm_modulo1./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d45cm_modulo1./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d45cm_modulo2 = (3.213*(coleta03_total_semfusao_kPa_avancado.d45cm_modulo2./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d45cm_modulo2./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d45cm_modulo3 = (3.213*(coleta03_total_semfusao_kPa_avancado.d45cm_modulo3./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d45cm_modulo3./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d45cm_modulo4 = (3.213*(coleta03_total_semfusao_kPa_avancado.d45cm_modulo4./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d45cm_modulo4./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);

coleta03_total_semfusao_kPa_avancado.d75cm_modulo1 = (3.213*(coleta03_total_semfusao_kPa_avancado.d75cm_modulo1./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d75cm_modulo1./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d75cm_modulo2 = (3.213*(coleta03_total_semfusao_kPa_avancado.d75cm_modulo2./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d75cm_modulo2./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d75cm_modulo3 = (3.213*(coleta03_total_semfusao_kPa_avancado.d75cm_modulo3./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d75cm_modulo3./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);
coleta03_total_semfusao_kPa_avancado.d75cm_modulo4 = (3.213*(coleta03_total_semfusao_kPa_avancado.d75cm_modulo4./1000)+4.093)./(1-0.009733*(coleta03_total_semfusao_kPa_avancado.d75cm_modulo4./1000)-0.01205*coleta03_total_semfusao_kPa_avancado.soil_temperature);

% gravando dados em csv
coleta03_total_semfusao_kPa_basico = timetable2table(coleta03_total_semfusao_kPa_basico);
writetable(coleta03_total_semfusao_kPa_basico,'logs/csv/coleta03/ok/coleta03_total_semfusao_basico.csv');

coleta03_total_semfusao_kPa_avancado = timetable2table(coleta03_total_semfusao_kPa_avancado);
writetable(coleta03_total_semfusao_kPa_avancado,'logs/csv/coleta03/ok/coleta03_total_semfusao_avancado.csv');

%% FUSAO
% gerando versão com dados dos modulos após fusão
coleta03_total_fusao = coleta03_total;
coleta03_total_fusao(:,1:12) = []; % removendo colunas de dados brutos
coleta03_total_fusao = outerjoin(coleta03_total_fusao,estacao_itapipoca_total_EToPM_hora);
coleta03_total_fusao = outerjoin(total_fused,coleta03_total_fusao);

% removendo linhas sem EToPM por falha de sensor da estação
coleta03_total_fusao(116:120,:) = [];
coleta03_total_fusao(492:494,:) = [];
coleta03_total_fusao(774,:) = [];

% filtrando o periodo desejado
range = timerange('2017-04-25 15:00', '2017-05-29 23:00');
coleta03_total_fusao = coleta03_total_fusao(range,:);

% removendo linhas sem leitura de pelo menos um dos modulos
coleta03_total_fusao(50:75,:) = [];
coleta03_total_fusao(108:184,:) = [];
coleta03_total_fusao(378:438,:) = [];

% gravando dados em csv
% coleta03_total_fusao = timetable2table(coleta03_total_fusao);
% writetable(coleta03_total_fusao,'logs/csv/coleta03/filtrados/coleta03_total_fusao_basico.csv');

coleta03_total_fusao = timetable2table(coleta03_total_fusao);
% ajustar o final do nome do arquivo de acordo com o nome da fusao
% escolhida no p03_fusao
writetable(coleta03_total_fusao,'logs/csv/coleta03/ok/coleta03_total_fusao_avancado_esd.csv');