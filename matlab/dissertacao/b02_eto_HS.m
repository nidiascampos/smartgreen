%% TESTE: ETo de Hargreaves-Samani

%% carregar dados
% dados da estacao meteorologica
EToNovo = table;
teste_EToPM = retime(EToPM_hora,'daily','sum');
teste_max = retime(EToPM_hora,'daily','max');
teste_min = retime(EToPM_hora,'daily','min');
% teste_tempSoloMax = retime(coleta03_total,'daily','max');
% teste_tempSoloMin = retime(coleta03_total,'daily','min');
% teste_tempSoloAvg = retime(coleta03_total,'daily','mean');
% teste_tempSolo = timetable(teste_tempSoloMax.when, teste_tempSoloMax.soil_temperature, teste_tempSoloMin.soil_temperature, teste_tempSoloAvg.soil_temperature);

EToNovo.date = teste_EToPM.data;
EToNovo.EToPM = teste_EToPM.EToPM;
EToNovo.tempMax = teste_max.temp_max;
EToNovo.tempMin = teste_min.temp_min;

% K = 0.162; % regioes continentais
% K = 0.19; % regioes costeiras

% radiacao solar extraterrestre, baseado em dados de tabela
Qo = [15.5; 15.8; 15.6; 14.9; 13.8; 13.2; 13.4; 14.3; 15.1; 15.6; 15.5; 15.4];

%% calcular EToHS

for i = 1:size(EToNovo,1)
    RadSolar = Qo(EToNovo.date.Month,:);
    EToNovo.tempAvg = (EToNovo.tempMax + EToNovo.tempMin) .* 0.5;
    K = 0.00185 * EToNovo.tempAvg(i,:)^2 - 0.0433 * EToNovo.tempAvg(i,:) + 0.4023;
    EToNovo.EToHS = 0.0135 * K * RadSolar .* sqrt(EToNovo.tempMax - EToNovo.tempMin) .* (EToNovo.tempAvg + 17.8);
%     teste.EToHS = 0.0023 * (teste.tempMax - teste.tempMin).^0.5 .* (teste.tempAvg + 17.8) .* RadSolar * 0.408;
%     teste.EToHS = 0.0023 * (teste.tempMax - teste.tempMin).^0.5 .* (teste.tempAvg + 17.8) .* RadSolar;
%     teste.EToHS = 0.0135 * K .* (teste.tempAvg + 17.8) .* (teste.tempMax - teste.tempMin).^0.5 .* RadSolar;
%     teste.EToHS = 0.0135 * K .* (teste.tempAvg + 17.8) .* (teste.tempMax - teste.tempMin).^0.5 .* RadSolar * 0.408;
end

%% juntando com os dados de fusao
total_fused_diario = retime(total_fused,'daily');

testeNovo = table2timetable(EToNovo);
testeNovo = outerjoin(testeNovo,total_fused_diario);
% testeNovo = outerjoin(testeNovo,teste_tempSolo);
% testeNovo.Properties.VariableNames{9} = 'tempSoloMax';
% testeNovo.Properties.VariableNames{10} = 'tempSoloMin';
% testeNovo.Properties.VariableNames{11} = 'tempSoloAvg';
testeNovo = timetable2table(testeNovo);
testeNovo([1,4:10,19:24,30:end],:) = [];

% mover coluna de EToPM para o final da tabela
testeNovo = testeNovo(:,[1 3:9 2]);

%% gerando csv
writetable(testeNovo,'dissertacao/logs/EToHS.csv');

testeNovo2 = table2timetable(EToNovo);
temp = retime(coleta03_total,'daily');
testeNovo2 = outerjoin(testeNovo2,temp);
testeNovo2 = timetable2table(testeNovo2);