%% PASSO 4b / 4

%% removendo atributo desnecessario
estacao_itapipoca(:,'codigo_estacao') = [];

%% Calculo de EToPM
estacao_itapipoca_total_EToPM_hora = estacao_itapipoca;
estacao_itapipoca_total_EToPM_hora.radiacao = estacao_itapipoca_total_EToPM_hora.radiacao./1000; % converter de kJ/m^2 para MJ^2
estacao_itapipoca_total_EToPM_hora.pressao = estacao_itapipoca_total_EToPM_hora.pressao./10; % converter de hPa para kPa

ETdelta = (4098*(0.6108*exp((17.27*estacao_itapipoca_total_EToPM_hora.temp_inst)./(estacao_itapipoca_total_EToPM_hora.temp_inst+237.3)))./(estacao_itapipoca_total_EToPM_hora.temp_inst+237.3).^2);

estacao_itapipoca_altitude = 103;
tamanho = size(estacao_itapipoca_total_EToPM_hora,1);
% estacao_itapipoca.Patm = (((293-(estacao_itapipoca_altitude*0.0065))/293)^5.26)*101.3 * ones(15,1);
ETfluxo_calor = zeros(tamanho,1);

ETcoefPsic = 0.665*estacao_itapipoca_total_EToPM_hora.pressao*10^-3;

ETes = 0.6108*exp((17.27*estacao_itapipoca_total_EToPM_hora.temp_inst)./(estacao_itapipoca_total_EToPM_hora.temp_inst+237.3));
ETea = (ETes.*estacao_itapipoca_total_EToPM_hora.umid_inst)/100;

for i = 1:size(estacao_itapipoca_total_EToPM_hora,1)
    hora = estacao_itapipoca_total_EToPM_hora.data(i).Hour;
    if hora > 4 && hora < 18
        Cn = 37;
        Cd = 0.24;
    else
        Cn = 37;
        Cd = 0.96;
    end
    
    estacao_itapipoca_total_EToPM_hora.EToPM(i) = (((0.408*ETdelta(i)).*(estacao_itapipoca_total_EToPM_hora.radiacao(i)-ETfluxo_calor(i)))+...
        ((ETcoefPsic(i)*Cn.*estacao_itapipoca_total_EToPM_hora.vento_vel(i).*(ETes(i)-ETea(i)))./...
        (estacao_itapipoca_total_EToPM_hora.temp_inst(i)+273)))./(ETdelta(i)+ETcoefPsic(i).*(1+Cd.*estacao_itapipoca_total_EToPM_hora.vento_vel(i)));
end

%% unificando todos os parametros em uma mesma tabela

estacao_itapipoca_total_EToPM_hora = outerjoin(modulo5,estacao_itapipoca_total_EToPM_hora);
total1234 = outerjoin(total12,total34);
estacao_itapipoca_total_EToPM_hora = outerjoin(total1234,estacao_itapipoca_total_EToPM_hora);

%% SE for coleta03_alt
% linhas removidas por falta de dados dos modulos
estacao_itapipoca_total_EToPM_hora(50:74,:) = [];
estacao_itapipoca_total_EToPM_hora(113:188,:) = [];
estacao_itapipoca_total_EToPM_hora(396:end,:) = [];

estacao_itapipoca_total_EToPM_hora(75:79,:) = [];
estacao_itapipoca_total_EToPM_hora(384:386,:) = [];
estacao_itapipoca_total_EToPM_hora = timetable2table(estacao_itapipoca_total_EToPM_hora);
writetable(estacao_itapipoca_total_EToPM_hora,'logs/csv/coleta03/filtrados/estacao_itapipoca_total_EToPM_hora.csv');

%% convertendo timetable em table e gerando CSV
% estacao_itapipoca_total_EToPM_hora = timetable2table(estacao_itapipoca_total_EToPM_hora);
% estacao_itapipoca_total_EToPM_hora(100:104,:) = [];
% writetable(estacao_itapipoca_total_EToPM_hora,'logs/csv/coleta03/filtrados/estacao_itapipoca_total_EToPM_hora.csv');

%% gerando versão com dados dos modulos após fusão
total_WRKF_timetable = table2timetable(total_WRKF);
estacao_itapipoca_total_EToPM_hora_fusao = outerjoin(modulo5,estacao_itapipoca_total_EToPM_hora);
estacao_itapipoca_total_EToPM_hora_fusao = outerjoin(total_WRKF_timetable,estacao_itapipoca_total_EToPM_hora_fusao);
estacao_itapipoca_total_EToPM_hora_fusao = timetable2table(estacao_itapipoca_total_EToPM_hora_fusao);
% remover linhan NaN causadas por falta de dados da estacao
estacao_itapipoca_total_EToPM_hora_fusao(100:104,:) = [];
estacao_itapipoca_total_EToPM_hora_fusao(495:497,:) = [];
% remover linhan NaN causadas por falta de dados dos modulos
estacao_itapipoca_total_EToPM_hora_fusao(50:73,:) = [];
estacao_itapipoca_total_EToPM_hora_fusao(109:171,:) = [];
estacao_itapipoca_total_EToPM_hora_fusao(110:121,:) = [];
estacao_itapipoca_total_EToPM_hora_fusao(400:end,:) = [];
writetable(estacao_itapipoca_total_EToPM_hora_fusao,'logs/csv/coleta03/filtrados/estacao_itapipoca_total_EToPM_hora_fused.csv');