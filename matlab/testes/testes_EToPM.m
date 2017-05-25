estacao_itapipoca_filtrada = retime(estacao_itapipoca,'daily','mean');
estacao_itapipoca_filtrada_somatorio = retime(estacao_itapipoca,'daily','sum');
estacao_itapipoca_filtrada.radiacao = estacao_itapipoca_filtrada_somatorio.radiacao;
estacao_itapipoca_filtrada(:,'umid_max') = [];
estacao_itapipoca_filtrada(:,'umid_min') = [];
estacao_itapipoca_filtrada(:,'temp_max') = [];
estacao_itapipoca_filtrada(:,'temp_min') = [];
estacao_itapipoca_filtrada.Properties.VariableNames{2} = 'temp';
estacao_itapipoca_filtrada.Properties.VariableNames{3} = 'umid';
estacao_itapipoca_filtrada.Properties.VariableNames{4} = 'pto_orvalho';
estacao_itapipoca_filtrada(:,'pto_orvalho_max') = [];
estacao_itapipoca_filtrada(:,'pto_orvalho_min') = [];
estacao_itapipoca_filtrada(:,'pressao_max') = [];
estacao_itapipoca_filtrada(:,'pressao_min') = [];
estacao_itapipoca_filtrada(:,'codigo_estacao') = [];
estacao_itapipoca_filtrada.radiacao = estacao_itapipoca_filtrada.radiacao./1000; % converter de kJ/m^2 para MJ^2
% estacao_itapipoca_filtrada.delta = (4098*(0.6108*exp((17.27*estacao_itapipoca_filtrada.temp)/(estacao_itapipoca_filtrada.temp+237.3))))/(teste.temp+237.2);
estacao_itapipoca_filtrada.delta = (4098*(0.6108*exp((17.27*estacao_itapipoca_filtrada.temp)./(estacao_itapipoca_filtrada.temp+237.3)))./(estacao_itapipoca_filtrada.temp+237.3).^2);

estacao_itapipoca_altitude = 103;
tamanho = size(estacao_itapipoca_filtrada,1);
% estacao_itapipoca_filtrada.Patm = (((293-(estacao_itapipoca_altitude*0.0065))/293)^5.26)*101.3 * ones(15,1);
estacao_itapipoca_filtrada.fluxo_calor = zeros(tamanho,1);
estacao_itapipoca_filtrada.pressao = estacao_itapipoca_filtrada.pressao./10; % converter de hPa para kPa
estacao_itapipoca_filtrada.coefPsic = 0.665*estacao_itapipoca_filtrada.pressao*10^-3;

estacao_itapipoca_filtrada.es = 0.6108*exp((17.27*estacao_itapipoca_filtrada.temp)./(estacao_itapipoca_filtrada.temp+237.3));
estacao_itapipoca_filtrada.ea = (estacao_itapipoca_filtrada.es.*estacao_itapipoca_filtrada.umid)/100;

estacao_itapipoca_filtrada.EToPM = (((0.408*estacao_itapipoca_filtrada.delta).*(estacao_itapipoca_filtrada.radiacao-estacao_itapipoca_filtrada.fluxo_calor))+...
    ((estacao_itapipoca_filtrada.coefPsic*900.*estacao_itapipoca_filtrada.vento_vel.*(estacao_itapipoca_filtrada.es-estacao_itapipoca_filtrada.ea))./...
    (estacao_itapipoca_filtrada.temp+273)))./(estacao_itapipoca_filtrada.delta+estacao_itapipoca_filtrada.coefPsic.*(1+0.34.*estacao_itapipoca_filtrada.vento_vel));

estacao_itapipoca_filtrada = timetable2table(estacao_itapipoca_filtrada);
writetable(estacao_itapipoca_filtrada,'logs/csv/coleta03/filtrados/estacao_itapipoca_EToPM.csv');