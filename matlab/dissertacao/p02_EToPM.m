%% PASSO 2 / 4

%% Calculo de EToPM
estacao_itapipoca_total_EToPM_hora = estacao_itapipoca;

% ajuste de valores fora do escopo
estacao_itapipoca_total_EToPM_hora.radiacao(estacao_itapipoca_total_EToPM_hora.radiacao < 0 ) = 0;

estacao_itapipoca_total_EToPM_hora.radiacao = estacao_itapipoca_total_EToPM_hora.radiacao./1000; % converter de kJ/m^2 para MJ^2
estacao_itapipoca_total_EToPM_hora.pressao = estacao_itapipoca_total_EToPM_hora.pressao./10; % converter de hPa para kPa
estacao_itapipoca_total_EToPM_hora.pressao_max = estacao_itapipoca_total_EToPM_hora.pressao_max./10; % converter de hPa para kPa
estacao_itapipoca_total_EToPM_hora.pressao_min = estacao_itapipoca_total_EToPM_hora.pressao_min./10; % converter de hPa para kPa

% calculando temperatura media
estacao_itapipoca_total_EToPM_hora.temp_media = (estacao_itapipoca_total_EToPM_hora.temp_max + estacao_itapipoca_total_EToPM_hora.temp_min) * 0.5;

ETdelta = (4098*(0.6108*exp((17.27*estacao_itapipoca_total_EToPM_hora.temp_media)./(estacao_itapipoca_total_EToPM_hora.temp_media+237.3)))./(estacao_itapipoca_total_EToPM_hora.temp_media+237.3).^2);

estacao_itapipoca_altitude = 103;
tamanho = size(estacao_itapipoca_total_EToPM_hora,1);
% estacao_itapipoca.Patm = (((293-(estacao_itapipoca_altitude*0.0065))/293)^5.26)*101.3 * ones(15,1);
ETfluxo_calor = zeros(tamanho,1);

ETcoefPsic = 0.665*estacao_itapipoca_total_EToPM_hora.pressao*10^-3;

ETes = 0.6108*exp((17.27*estacao_itapipoca_total_EToPM_hora.temp_media)./(estacao_itapipoca_total_EToPM_hora.temp_media+237.3));
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
        (estacao_itapipoca_total_EToPM_hora.temp_media(i)+273)))./(ETdelta(i)+ETcoefPsic(i).*(1+Cd.*estacao_itapipoca_total_EToPM_hora.vento_vel(i)));
end