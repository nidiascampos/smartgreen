%% Modulos (exceto 4 pois tem poucos dados)
plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd15cm', modulo2, 'd15cm', 'Dispersão: Modulo 1 e Modulo 2, 15cm', '15cm_mod1_mod2','off');
plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd45cm', modulo2, 'd45cm', 'Dispersão: Modulo 1 e Modulo 2, 45cm', '45cm_mod1_mod2','off');
plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd75cm', modulo2, 'd75cm', 'Dispersão: Modulo 1 e Modulo 2, 75cm', '75cm_mod1_mod2','off');

plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd15cm', modulo3, 'd15cm', 'Dispersão: Modulo 1 e Modulo 3, 15cm', '15cm_mod1_mod3','off');
plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd45cm', modulo3, 'd45cm', 'Dispersão: Modulo 1 e Modulo 3, 45cm', '45cm_mod1_mod3','off');
plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd75cm', modulo3, 'd75cm', 'Dispersão: Modulo 1 e Modulo 3, 75cm', '75cm_mod1_mod3','off');

% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd15cm', modulo4, 'd15cm', 'Dispersão: Modulo 1 e Modulo 4, 15cm', '15cm_mod1_mod4','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd45cm', modulo4, 'd45cm', 'Dispersão: Modulo 1 e Modulo 4, 45cm', '45cm_mod1_mod4','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo1, 'd75cm', modulo4, 'd75cm', 'Dispersão: Modulo 1 e Modulo 4, 75cm', '75cm_mod1_mod4','off');

plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd15cm', modulo3, 'd15cm', 'Dispersão: Modulo 2 e Modulo 3, 15cm', '15cm_mod2_mod3','off');
plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd45cm', modulo3, 'd45cm', 'Dispersão: Modulo 2 e Modulo 3, 45cm', '45cm_mod2_mod3','off');
plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd75cm', modulo3, 'd75cm', 'Dispersão: Modulo 2 e Modulo 3, 75cm', '75cm_mod2_mod3','off');

% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd15cm', modulo4, 'd15cm', 'Dispersão: Modulo 2 e Modulo 4, 15cm', '15cm_mod2_mod4','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd45cm', modulo4, 'd45cm', 'Dispersão: Modulo 2 e Modulo 4, 45cm', '45cm_mod2_mod4','off');
% plotar_scatter_periodo(datetime('2017-04-25'), datetime('2017-05-10'), modulo2, 'd75cm', modulo4, 'd75cm', 'Dispersão: Modulo 2 e Modulo 4, 75cm', '75cm_mod2_mod4','off');

%% Estacao Itapipoca

plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'temp_med', 'Dispersão: Estacao Itapipoca, EToPM e Temp. Media', 'estacao/EToPM_temp_media','off')
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'temp_min', 'Dispersão: Estacao Itapipoca, EToPM e Temp. Min', 'estacao/EToPM_temp_min','off')
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'temp_max', 'Dispersão: Estacao Itapipoca, EToPM e Temp. Max', 'estacao/EToPM_temp_max','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Estacao Itapipoca, EToPM e Umid. Media', 'estacao/EToPM_umid_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'umid_min', 'Dispersão: Estacao Itapipoca, EToPM e Umid. Min', 'estacao/EToPM_umid_min','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'umid_max', 'Dispersão: Estacao Itapipoca, EToPM e Umid. Max', 'estacao/EToPM_umid_max','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'pto_orvalho_med', 'Dispersão: Estacao Itapipoca, EToPM e Pto Orvalho Medio', 'estacao/EToPM_orvalho_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'pto_orvalho_min', 'Dispersão: Estacao Itapipoca, EToPM e Pto Orvalho Min', 'estacao/EToPM_orvalho_min','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'pto_orvalho_max', 'Dispersão: Estacao Itapipoca, EToPM e Pto Orvalho Max', 'estacao/EToPM_orvalho_max','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Estacao Itapipoca, EToPM e Pressão Media', 'estacao/EToPM_pressao_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'pressao_min', 'Dispersão: Estacao Itapipoca, EToPM e Pressão Min', 'estacao/EToPM_pressao_min','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'pressao_max', 'Dispersão: Estacao Itapipoca, EToPM e Pressão Max', 'estacao/EToPM_pressao_max','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'vento_vel', 'Dispersão: Estacao Itapipoca, EToPM e Vel. Vento Media', 'estacao/EToPM_vento_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Estacao Itapipoca, EToPM e Radiação Solar', 'estacao/EToPM_radiacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Estacao Itapipoca, EToPM e Precipitação', 'estacao/EToPM_precipitacao','off');

%% EToPM e Modulos
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo1_media, 'd15cm', 'Dispersão: EToPM e Modulo 1 (15cm)', 'modulos de umidade solo/EToPM_mod1_15cm','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo1_media, 'd45cm', 'Dispersão: EToPM e Modulo 1 (45cm)', 'modulos de umidade solo/EToPM_mod1_45cm','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo1_media, 'd75cm', 'Dispersão: EToPM e Modulo 1 (75cm)', 'modulos de umidade solo/EToPM_mod1_75cm','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo2_media, 'd15cm', 'Dispersão: EToPM e Modulo 2 (15cm)', 'modulos de umidade solo/EToPM_mod2_15cm','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo2_media, 'd45cm', 'Dispersão: EToPM e Modulo 2 (45cm)', 'modulos de umidade solo/EToPM_mod2_45cm','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo2_media, 'd75cm', 'Dispersão: EToPM e Modulo 2 (75cm)', 'modulos de umidade solo/EToPM_mod2_75cm','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo3_media, 'd15cm', 'Dispersão: EToPM e Modulo 3 (15cm)', 'modulos de umidade solo/EToPM_mod3_15cm','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo3_media, 'd45cm', 'Dispersão: EToPM e Modulo 3 (45cm)', 'modulos de umidade solo/EToPM_mod3_45cm','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', estacao_itapipoca_filtrada, 'EToPM', modulo3_media, 'd75cm', 'Dispersão: EToPM e Modulo 3 (75cm)', 'modulos de umidade solo/EToPM_mod3_75cm','off');

%% Modulos e Precipitacao
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd15cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 1 (15cm) e Precipitação', 'estacao e modulos de umidade de solo/mod1_15cm_precipitacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd45cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 1 (45cm) e Precipitação', 'estacao e modulos de umidade de solo/mod1_45cm_precipitacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd75cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 1 (75cm) e Precipitação', 'estacao e modulos de umidade de solo/mod1_75cm_precipitacao','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd15cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 2 (15cm) e Precipitação', 'estacao e modulos de umidade de solo/mod2_15cm_precipitacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd45cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 2 (45cm) e Precipitação', 'estacao e modulos de umidade de solo/mod2_45cm_precipitacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd75cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 2 (75cm) e Precipitação', 'estacao e modulos de umidade de solo/mod2_75cm_precipitacao','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd15cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 3 (15cm) e Precipitação', 'estacao e modulos de umidade de solo/mod3_15cm_precipitacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd45cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 3 (45cm) e Precipitação', 'estacao e modulos de umidade de solo/mod3_45cm_precipitacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd75cm', estacao_itapipoca_filtrada, 'precipitacao', 'Dispersão: Modulo 3 (75cm) e Precipitação', 'estacao e modulos de umidade de solo/mod3_75cm_precipitacao','off');

%% Modulos e Radiacao solar
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd15cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 1 (15cm) e Radiação', 'estacao e modulos de umidade de solo/mod1_15cm_radiacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd45cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 1 (45cm) e Radiação', 'estacao e modulos de umidade de solo/mod1_45cm_radiacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd75cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 1 (75cm) e Radiação', 'estacao e modulos de umidade de solo/mod1_75cm_radiacao','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd15cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 2 (15cm) e Radiação', 'estacao e modulos de umidade de solo/mod2_15cm_radiacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd45cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 2 (45cm) e Radiação', 'estacao e modulos de umidade de solo/mod2_45cm_radiacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd75cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 2 (75cm) e Radiação', 'estacao e modulos de umidade de solo/mod2_75cm_radiacao','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd15cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 3 (15cm) e Radiação', 'estacao e modulos de umidade de solo/mod3_15cm_radiacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd45cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 3 (45cm) e Radiação', 'estacao e modulos de umidade de solo/mod3_45cm_radiacao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd75cm', estacao_itapipoca_filtrada, 'radiacao', 'Dispersão: Modulo 3 (75cm) e Radiação', 'estacao e modulos de umidade de solo/mod3_75cm_radiacao','off');

%% Modulos e Umidade do ar
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd15cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 1 (15cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod1_15cm_umid_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd45cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 1 (45cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod1_45cm_umid_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd75cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 1 (75cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod1_75cm_umid_media','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd15cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 2 (15cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod2_15cm_umid_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd45cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 2 (45cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod2_45cm_umid_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd75cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 2 (75cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod2_75cm_umid_media','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd15cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 3 (15cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod3_15cm_umid_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd45cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 3 (45cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod3_45cm_umid_media','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd75cm', estacao_itapipoca_filtrada, 'umid_med', 'Dispersão: Modulo 3 (75cm) e Umidade do ar', 'estacao e modulos de umidade de solo/mod3_75cm_umid_media','off');

%% Modulos e Pressão Atm
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd15cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 1 (15cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod1_15cm_pressao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd45cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 1 (45cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod1_45cm_pressao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo1_media, 'd75cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 1 (75cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod1_75cm_pressao','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd15cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 2 (15cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod2_15cm_pressao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd45cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 2 (45cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod2_45cm_pressao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo2_media, 'd75cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 2 (75cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod2_75cm_pressao','off');

plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd15cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 3 (15cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod3_15cm_pressao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd45cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 3 (45cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod3_45cm_pressao','off');
plotar_scatter_dia('2017-04-25', '2017-05-10', modulo3_media, 'd75cm', estacao_itapipoca_filtrada, 'pressao', 'Dispersão: Modulo 3 (75cm) e Pressão Atm.', 'estacao e modulos de umidade de solo/mod3_75cm_pressao','off');