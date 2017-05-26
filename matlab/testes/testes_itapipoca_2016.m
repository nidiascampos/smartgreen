%% carregando dados e fazendo ajustes
load('logs/estacao_itapipoca_2016');
estacao_itapipoca_2016 = table2timetable(estacao_itapipoca_2016);
estacao_itapipoca_2016 = sortrows(estacao_itapipoca_2016);

%% calculando EToPM
estacao_itapipoca_2016_filtrada = retime(estacao_itapipoca_2016,'daily','mean');
estacao_itapipoca_filtrada_somatorio = retime(estacao_itapipoca_2016,'daily','sum');
estacao_itapipoca_filtrada_max = retime(estacao_itapipoca_2016,'daily','max');
estacao_itapipoca_filtrada_min = retime(estacao_itapipoca_2016,'daily','min');

% somatorio
estacao_itapipoca_2016_filtrada.radiacao = estacao_itapipoca_filtrada_somatorio.radiacao;
estacao_itapipoca_2016_filtrada.precipitacao = estacao_itapipoca_filtrada_somatorio.precipitacao;

% valores maximos
estacao_itapipoca_2016_filtrada.umid_max = estacao_itapipoca_filtrada_max.umid_max;
estacao_itapipoca_2016_filtrada.temp_max = estacao_itapipoca_filtrada_max.temp_max;
estacao_itapipoca_2016_filtrada.pto_orvalho_max = estacao_itapipoca_filtrada_max.pto_orvalho_max;
estacao_itapipoca_2016_filtrada.pressao_max = estacao_itapipoca_filtrada_max.pressao_max;

% valores minimos
estacao_itapipoca_2016_filtrada.umid_min = estacao_itapipoca_filtrada_min.umid_min;
estacao_itapipoca_2016_filtrada.temp_min = estacao_itapipoca_filtrada_min.temp_min;
estacao_itapipoca_2016_filtrada.pto_orvalho_min = estacao_itapipoca_filtrada_min.pto_orvalho_min;
estacao_itapipoca_2016_filtrada.pressao_min = estacao_itapipoca_filtrada_min.pressao_min;

% o restante utiliza médias

%% renomeando variáveis para ficar mais compreensivel
estacao_itapipoca_2016_filtrada.Properties.VariableNames{2} = 'temp_med';
estacao_itapipoca_2016_filtrada.Properties.VariableNames{5} = 'umid_med';
estacao_itapipoca_2016_filtrada.Properties.VariableNames{8} = 'pto_orvalho_med';

%% Calculo de EToPM
estacao_itapipoca_2016_filtrada.radiacao = estacao_itapipoca_2016_filtrada.radiacao./1000; % converter de kJ/m^2 para MJ^2
estacao_itapipoca_2016_filtrada.pressao = estacao_itapipoca_2016_filtrada.pressao./10; % converter de hPa para kPa

ETdelta = (4098*(0.6108*exp((17.27*estacao_itapipoca_2016_filtrada.temp_med)./(estacao_itapipoca_2016_filtrada.temp_med+237.3)))./(estacao_itapipoca_2016_filtrada.temp_med+237.3).^2);

estacao_itapipoca_altitude = 103;
tamanho = size(estacao_itapipoca_2016_filtrada,1);
% estacao_itapipoca_2016_filtrada.Patm = (((293-(estacao_itapipoca_altitude*0.0065))/293)^5.26)*101.3 * ones(15,1);
ETfluxo_calor = zeros(tamanho,1);

ETcoefPsic = 0.665*estacao_itapipoca_2016_filtrada.pressao*10^-3;

ETes = 0.6108*exp((17.27*estacao_itapipoca_2016_filtrada.temp_med)./(estacao_itapipoca_2016_filtrada.temp_med+237.3));
ETea = (ETes.*estacao_itapipoca_2016_filtrada.umid_med)/100;

estacao_itapipoca_2016_filtrada.EToPM = (((0.408*ETdelta).*(estacao_itapipoca_2016_filtrada.radiacao-ETfluxo_calor))+...
    ((ETcoefPsic*900.*estacao_itapipoca_2016_filtrada.vento_vel.*(ETes-ETea))./...
    (estacao_itapipoca_2016_filtrada.temp_med+273)))./(ETdelta+ETcoefPsic.*(1+0.34.*estacao_itapipoca_2016_filtrada.vento_vel));

%% unificando todos os parametros em uma mesma tabela
% estacao_itapipoca_2016_total_EToPM = outerjoin(estacao_itapipoca_2016_filtrada,estacao_itapipoca_2016_total_EToPM);

%% convertendo timetable em table e gerando CSV
% estacao_itapipoca_2016_total_EToPM = timetable2table(estacao_itapipoca_2016_total_EToPM);
% writetable(estacao_itapipoca_2016_total_EToPM,'logs/csv/coleta03/filtrados/estacao_itapipoca_total_EToPM.csv');

%% gerando versão com dados dos modulos após fusão
% estacao_itapipoca_2016_total_EToPM_fusao = outerjoin(total_WRKF_media,estacao_itapipoca_2016_filtrada);
estacao_itapipoca_2016_filtrada = timetable2table(estacao_itapipoca_2016_filtrada);
% writetable(estacao_itapipoca_2016_total_EToPM_fusao,'logs/csv/coleta03/filtrados/estacao_itapipoca_total_EToPM_fused.csv');