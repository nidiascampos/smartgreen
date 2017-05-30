%% PASSO 4 / 4

%% gerando médias, máximos, minimos e somatórios
estacao_itapipoca_filtrada = retime(estacao_itapipoca,'daily','mean');
estacao_itapipoca_filtrada_somatorio = retime(estacao_itapipoca,'daily','sum');
estacao_itapipoca_filtrada_max = retime(estacao_itapipoca,'daily','max');
estacao_itapipoca_filtrada_min = retime(estacao_itapipoca,'daily','min');

% somatorio
estacao_itapipoca_filtrada.radiacao = estacao_itapipoca_filtrada_somatorio.radiacao;
estacao_itapipoca_filtrada.precipitacao = estacao_itapipoca_filtrada_somatorio.precipitacao;

% valores maximos
estacao_itapipoca_filtrada.umid_max = estacao_itapipoca_filtrada_max.umid_max;
estacao_itapipoca_filtrada.temp_max = estacao_itapipoca_filtrada_max.temp_max;
estacao_itapipoca_filtrada.pto_orvalho_max = estacao_itapipoca_filtrada_max.pto_orvalho_max;
estacao_itapipoca_filtrada.pressao_max = estacao_itapipoca_filtrada_max.pressao_max;

% valores minimos
estacao_itapipoca_filtrada.umid_min = estacao_itapipoca_filtrada_min.umid_min;
estacao_itapipoca_filtrada.temp_min = estacao_itapipoca_filtrada_min.temp_min;
estacao_itapipoca_filtrada.pto_orvalho_min = estacao_itapipoca_filtrada_min.pto_orvalho_min;
estacao_itapipoca_filtrada.pressao_min = estacao_itapipoca_filtrada_min.pressao_min;

% o restante utiliza médias

%% média dos modulos de umidade de solo e temperatura
modulo1_media = retime(modulo1,'daily','mean');
modulo2_media = retime(modulo2,'daily','mean');
modulo3_media = retime(modulo3,'daily','mean');
modulo4_media = retime(modulo4,'daily','mean');
modulo5_media = retime(modulo5,'daily','mean');

%% media dos dados fusionados dos modulos
total_WRKF_media = table2timetable(total_WRKF);
total_WRKF_media = retime(total_WRKF_media,'daily','mean');

%% renomeando variáveis para ficar mais compreensivel
estacao_itapipoca_filtrada.Properties.VariableNames{2} = 'temp_med';
estacao_itapipoca_filtrada.Properties.VariableNames{5} = 'umid_med';
estacao_itapipoca_filtrada.Properties.VariableNames{8} = 'pto_orvalho_med';

%% removendo atributo desnecessario
% estacao_itapipoca_filtrada(:,'codigo_estacao') = [];

%% Calculo de EToPM
estacao_itapipoca_filtrada.radiacao = estacao_itapipoca_filtrada.radiacao./1000; % converter de kJ/m^2 para MJ^2
estacao_itapipoca_filtrada.pressao = estacao_itapipoca_filtrada.pressao./10; % converter de hPa para kPa

ETdelta = (4098*(0.6108*exp((17.27*estacao_itapipoca_filtrada.temp_med)./(estacao_itapipoca_filtrada.temp_med+237.3)))./(estacao_itapipoca_filtrada.temp_med+237.3).^2);

estacao_itapipoca_altitude = 103;
tamanho = size(estacao_itapipoca_filtrada,1);
% estacao_itapipoca_filtrada.Patm = (((293-(estacao_itapipoca_altitude*0.0065))/293)^5.26)*101.3 * ones(15,1);
ETfluxo_calor = zeros(tamanho,1);

ETcoefPsic = 0.665*estacao_itapipoca_filtrada.pressao*10^-3;

ETes = 0.6108*exp((17.27*estacao_itapipoca_filtrada.temp_med)./(estacao_itapipoca_filtrada.temp_med+237.3));
ETea = (ETes.*estacao_itapipoca_filtrada.umid_med)/100;

estacao_itapipoca_filtrada.EToPM = (((0.408*ETdelta).*(estacao_itapipoca_filtrada.radiacao-ETfluxo_calor))+...
    ((ETcoefPsic*900.*estacao_itapipoca_filtrada.vento_vel.*(ETes-ETea))./...
    (estacao_itapipoca_filtrada.temp_med+273)))./(ETdelta+ETcoefPsic.*(1+0.34.*estacao_itapipoca_filtrada.vento_vel));

%% unificando todos os parametros em uma mesma tabela
total12_media = outerjoin(modulo1_media,modulo2_media);
total34_media = outerjoin(modulo3_media,modulo4_media);

estacao_itapipoca_total_EToPM = outerjoin(total12_media,total34_media);
estacao_itapipoca_total_EToPM = outerjoin(estacao_itapipoca_total_EToPM,modulo5_media);
estacao_itapipoca_total_EToPM = outerjoin(estacao_itapipoca_total_EToPM,estacao_itapipoca_filtrada);

%% convertendo timetable em table e gerando CSV
estacao_itapipoca_total_EToPM = timetable2table(estacao_itapipoca_total_EToPM);
writetable(estacao_itapipoca_total_EToPM,'logs/csv/coleta03/filtrados/estacao_itapipoca_total_EToPM.csv');

%% gerando versão com dados dos modulos após fusão
estacao_itapipoca_total_EToPM_fusao = outerjoin(total_WRKF_media,estacao_itapipoca_filtrada);
estacao_itapipoca_total_EToPM_fusao = timetable2table(estacao_itapipoca_total_EToPM_fusao);
writetable(estacao_itapipoca_total_EToPM_fusao,'logs/csv/coleta03/filtrados/estacao_itapipoca_total_EToPM_fused.csv');