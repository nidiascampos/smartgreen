modulo1.d15cm_bias = [];
modulo1.d45cm_bias = [];
modulo1.d75cm_bias = [];
modulo1.battery = [];

modulo2.d15cm_bias = [];
modulo2.d45cm_bias = [];
modulo2.d75cm_bias = [];
modulo2.battery = [];

modulo3.d15cm_bias = [];
modulo3.d45cm_bias = [];
modulo3.d75cm_bias = [];
modulo3.battery = [];

modulo4.d15cm_bias = [];
modulo4.d45cm_bias = [];
modulo4.d75cm_bias = [];
modulo4.battery = [];

modulo5.Properties.VariableNames{2} = 'wetness_modulo5';
modulo5.Properties.VariableNames{4} = 'temperature_modulo5';
modulo5.battery = [];
modulo5.rain = [];

total12 = outerjoin(modulo1,modulo2);
total34 = outerjoin(modulo3,modulo4);

total = outerjoin(total12,total34);
total = outerjoin(total,modulo5);
total = outerjoin(total,estacao_itapipoca);

% EToPM = table(estacao_itapipoca_filtrada.data,estacao_itapipoca_filtrada.EToPM);
% EToPM = table2timetable(EToPM);
% total = outerjoin(total,EToPM);

total = timetable2table(total)
% csvwrite('graphs/coleta03/total.csv',total)
writetable(total,'logs/csv/coleta03/filtrados/total.csv')