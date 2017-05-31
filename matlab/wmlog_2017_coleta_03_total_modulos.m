%% PASSO 2 / 4

modulo1.d15cm_bias = [];
modulo1.d45cm_bias = [];
modulo1.d75cm_bias = [];
modulo1.d15cm_kPa = [];
modulo1.d45cm_kPa = [];
modulo1.d75cm_kPa = [];
modulo1.battery = [];

modulo2.d15cm_bias = [];
modulo2.d45cm_bias = [];
modulo2.d75cm_bias = [];
modulo2.d15cm_kPa = [];
modulo2.d45cm_kPa = [];
modulo2.d75cm_kPa = [];
modulo2.battery = [];

modulo3.d15cm_bias = [];
modulo3.d45cm_bias = [];
modulo3.d75cm_bias = [];
modulo3.d15cm_kPa = [];
modulo3.d45cm_kPa = [];
modulo3.d75cm_kPa = [];
modulo3.battery = [];

modulo4.d15cm_bias = [];
modulo4.d45cm_bias = [];
modulo4.d75cm_bias = [];
modulo4.d15cm_kPa = [];
modulo4.d45cm_kPa = [];
modulo4.d75cm_kPa = [];
modulo4.battery = [];

modulo5.Properties.VariableNames{2} = 'wetness_modulo5';
modulo5.Properties.VariableNames{4} = 'temperature_modulo5';
modulo5.battery = [];
modulo5.rain = [];

total12 = outerjoin(modulo1,modulo2);
total34 = outerjoin(modulo3,modulo4);

total_modulos = outerjoin(total12,total34);
total_modulos = outerjoin(total_modulos,modulo5);
% total = outerjoin(total,estacao_itapipoca);

% removendo linhas que contem apenas NaN
total_modulos(115,:) = [];

% EToPM = table(estacao_itapipoca_filtrada.data,estacao_itapipoca_filtrada.EToPM);
% EToPM = table2timetable(EToPM);
% total = outerjoin(total,EToPM);
total_modulos = timetable2table(total_modulos);

%% gravar dados
% csvwrite('graphs/coleta03/total.csv',total)
% writetable(total_modulos,'logs/csv/coleta03/filtrados/modulos_total.csv');