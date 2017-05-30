%% carregando dados e fazendo ajustes
load('logs/estacao_itapipoca_2016');
estacao_itapipoca_2016 = table2timetable(estacao_itapipoca_2016);
estacao_itapipoca_2016 = sortrows(estacao_itapipoca_2016);

%% Calculo de EToPM
estacao_itapipoca_2016_filtrada = estacao_itapipoca_2016;
estacao_itapipoca_2016_filtrada.radiacao = estacao_itapipoca_2016_filtrada.radiacao./1000; % converter de kJ/m^2 para MJ^2
estacao_itapipoca_2016_filtrada.pressao = estacao_itapipoca_2016_filtrada.pressao./10; % converter de hPa para kPa

ETdelta = (4098*(0.6108*exp((17.27*estacao_itapipoca_2016_filtrada.temp_inst)./(estacao_itapipoca_2016_filtrada.temp_inst+237.3)))./(estacao_itapipoca_2016_filtrada.temp_inst+237.3).^2);

estacao_itapipoca_altitude = 103;
tamanho = size(estacao_itapipoca_2016_filtrada,1);
% estacao_itapipoca_2016_filtrada.Patm = (((293-(estacao_itapipoca_altitude*0.0065))/293)^5.26)*101.3 * ones(15,1);
ETfluxo_calor = zeros(tamanho,1);

ETcoefPsic = 0.665*estacao_itapipoca_2016_filtrada.pressao*10^-3;

ETes = 0.6108*exp((17.27*estacao_itapipoca_2016_filtrada.temp_inst)./(estacao_itapipoca_2016_filtrada.temp_inst+237.3));
ETea = (ETes.*estacao_itapipoca_2016_filtrada.umid_inst)/100;

for i = 1:size(estacao_itapipoca_2016_filtrada,1)
    hora = estacao_itapipoca_2016_filtrada.data(i).Hour;
    if hora > 4 && hora < 18
        Cn = 37;
        Cd = 0.24;
    else
        Cn = 37;
        Cd = 0.96;
    end
    
    estacao_itapipoca_2016_filtrada.EToPM(i) = (((0.408*ETdelta(i)).*(estacao_itapipoca_2016_filtrada.radiacao(i)-ETfluxo_calor(i)))+...
        ((ETcoefPsic(i)*Cn.*estacao_itapipoca_2016_filtrada.vento_vel(i).*(ETes(i)-ETea(i)))./...
        (estacao_itapipoca_2016_filtrada.temp_inst(i)+273)))./(ETdelta(i)+ETcoefPsic(i).*(1+Cd.*estacao_itapipoca_2016_filtrada.vento_vel(i)));
end

% estacao_itapipoca_2016_filtrada.EToPM = (((0.408*ETdelta).*(estacao_itapipoca_2016_filtrada.radiacao-ETfluxo_calor))+...
%     ((ETcoefPsic*900.*estacao_itapipoca_2016_filtrada.vento_vel.*(ETes-ETea))./...
%     (estacao_itapipoca_2016_filtrada.temp_med+273)))./(ETdelta+ETcoefPsic.*(1+0.34.*estacao_itapipoca_2016_filtrada.vento_vel));

%% unificando todos os parametros em uma mesma tabela
% estacao_itapipoca_2016_total_EToPM = outerjoin(estacao_itapipoca_2016_filtrada,estacao_itapipoca_2016_total_EToPM);

%% convertendo timetable em table e gerando CSV
% estacao_itapipoca_2016_total_EToPM = timetable2table(estacao_itapipoca_2016_total_EToPM);
% writetable(estacao_itapipoca_2016_total_EToPM,'logs/csv/coleta03/filtrados/estacao_itapipoca_total_EToPM.csv');

%% gerando versão com dados dos modulos após fusão
% estacao_itapipoca_2016_total_EToPM_fusao = outerjoin(total_WRKF_media,estacao_itapipoca_2016_filtrada);
estacao_itapipoca_2016_filtrada = timetable2table(estacao_itapipoca_2016_filtrada);
writetable(estacao_itapipoca_2016_filtrada,'logs/csv/coleta03/filtrados/estacao_itapipoca_2016_EToPM.csv');