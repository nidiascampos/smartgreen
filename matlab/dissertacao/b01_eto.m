%% APP EVAPOTRANSPIRACAO - PASSOS 1 / 1
% BAIXO NÍVEL: conversão de unidades e filtragem
% MÉDIO NÍVEL: cálculo de ETo

%% carregar dados
%load('logs/coleta03_estacao_paraipaba'); % estacao da FUNCEME
load('logs/coleta03_estacao_itapipoca_29may'); % estacao do INMET
%load('logs/coleta03_estacao_fazgranjeiro_2017'); % estacao local

%% removendo atributo desnecessario
estacao_itapipoca(:,'codigo_estacao') = [];

%% ordenar dados
estacao_itapipoca = sortrows(estacao_itapipoca);

%% converter tabela em timetable
estacao_itapipoca = table2timetable(estacao_itapipoca);
%estacao_paraipaba = table2timetable(estacao_paraipaba);

%% nova tabela com nome mais logico
EToPM_hora = estacao_itapipoca;

%% DAI-DAO: coleta de dados brutos e conversão
% dados foram coletados pela estação atmosférica e já enviados nas unidades
% corretas

% filtragem de valores fora do escopo do sensor
EToPM_hora.radiacao(EToPM_hora.radiacao < 0 ) = 0;

%% DAI-FEO: calculo de ETo
% conversão de unidades
EToPM_hora.radiacao = EToPM_hora.radiacao./1000; % converter de kJ/m^2 para MJ^2
EToPM_hora.pressao = EToPM_hora.pressao./10; % converter de hPa para kPa
EToPM_hora.pressao_max = EToPM_hora.pressao_max./10; % converter de hPa para kPa
EToPM_hora.pressao_min = EToPM_hora.pressao_min./10; % converter de hPa para kPa

% calculando temperatura media
EToPM_hora.temp_media = (EToPM_hora.temp_max + EToPM_hora.temp_min) * 0.5;

% calculando delta
ETdelta = (4098*(0.6108*exp((17.27*EToPM_hora.temp_media)./(EToPM_hora.temp_media+237.3)))./(EToPM_hora.temp_media+237.3).^2);

estacao_itapipoca_altitude = 103;
tamanho = size(EToPM_hora,1);
% estacao_itapipoca.Patm = (((293-(estacao_itapipoca_altitude*0.0065))/293)^5.26)*101.3 * ones(15,1);
ETfluxo_calor = zeros(tamanho,1);

ETcoefPsic = 0.665*EToPM_hora.pressao*10^-3;

ETes = 0.6108*exp((17.27*EToPM_hora.temp_media)./(EToPM_hora.temp_media+237.3));
ETea = (ETes.*EToPM_hora.umid_inst)/100;

for i = 1:size(EToPM_hora,1)
    hora = EToPM_hora.data(i).Hour;
    if hora > 4 && hora < 18
        Cn = 37;
        Cd = 0.24;
    else
        Cn = 37;
        Cd = 0.96;
    end
    
    EToPM_hora.EToPM(i) = (((0.408*ETdelta(i)).*(EToPM_hora.radiacao(i)-ETfluxo_calor(i)))+...
        ((ETcoefPsic(i)*Cn.*EToPM_hora.vento_vel(i).*(ETes(i)-ETea(i)))./...
        (EToPM_hora.temp_media(i)+273)))./(ETdelta(i)+ETcoefPsic(i).*(1+Cd.*EToPM_hora.vento_vel(i)));
end

% filtragem de dados
% removendo linhas com dados nulos
EToPM_hora([116:120,497:499,782],:) = [];

%% FEI-DEO: decisão sobre tempo de irrigação
% calcular ETo diário
EToPM_dia = retime(EToPM_hora,'daily','sum');
% removendo colunas desnecessarias
EToPM_dia(:,{'temp_inst','temp_max','temp_min','umid_inst','umid_max','umid_min','pto_orvalho_inst','pto_orvalho_max','pto_orvalho_min','pressao','pressao_max','pressao_min','vento_vel','vento_direcao','vento_rajada','radiacao','precipitacao','temp_media'}) = [];

% coeficiente do cultivo
Kc = 0.63;

% lamina de agua
lamina_liquida = Kc * EToPM_dia.EToPM;
lamina_liquida_timetable = timetable(EToPM_dia.data,lamina_liquida);
lamina_liquida_timetable.Properties.VariableNames{1} = 'lamina_liquida';
lamina_liquida_semanal = retime(lamina_liquida_timetable,'weekly','sum');
% lamina_liquida_semanal = lamina_liquida * 7;

% eficiencia de irrigação, determinado empiricamente
eficIrrigacao = 0.8185;

% necessidade hídrica bruta do cultivo / lamina bruta
lamina_liquida_semanal.NHB = lamina_liquida_semanal.lamina_liquida / eficIrrigacao;

% tempo de irrigação ideal
lamina_liquida_semanal.tempoIrrig = lamina_liquida_semanal.NHB * 7;