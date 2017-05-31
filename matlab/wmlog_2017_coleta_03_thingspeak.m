%% Periodo de dados a obter
% a partir do dia 18/05 o modulo1 não funcionou mais corretamente (sempre
% envia o mesmo valor) e o modulo4 passou a passar dados erráticos
range = datetime({'27/04/2017' '30/05/2017'});


%% Modulo 1
% Channel ID to read data from
wmChannelID = 41313;
readAPIKey = '';

% debug:
% [thingspeakData, thingspeakTime, channelInfo] = thingSpeakRead(wmChannelID, 'ReadKey', readAPIKey);

[thingspeakData, thingspeakTime] = thingSpeakRead(wmChannelID, 'ReadKey', readAPIKey, 'DateRange', range);
modulo1_thingspeak = table(thingspeakTime, thingspeakData(:,1), thingspeakData(:,2),...
    thingspeakData(:,3), thingspeakData(:,4), thingspeakData(:,5), thingspeakData(:,6),...
    thingspeakData(:,7), 'VariableNames', {'when', 'battery', 'd15cm', 'd15cm_bias', 'd45cm', 'd45cm_bias','d75cm', 'd75cm_bias'});

%% Modulo 2
% Channel ID to read data from
wmChannelID = 255953;
readAPIKey = '';

[thingspeakData, thingspeakTime] = thingSpeakRead(wmChannelID, 'ReadKey', readAPIKey, 'DateRange', range);
modulo2_thingspeak = table(thingspeakTime, thingspeakData(:,1), thingspeakData(:,2),...
    thingspeakData(:,3), thingspeakData(:,4), thingspeakData(:,5), thingspeakData(:,6),...
    thingspeakData(:,7), 'VariableNames', {'when', 'battery', 'd15cm', 'd15cm_bias', 'd45cm', 'd45cm_bias','d75cm', 'd75cm_bias'});

%% Modulo 3
% Channel ID to read data from
wmChannelID = 256208;
readAPIKey = '';

[thingspeakData, thingspeakTime] = thingSpeakRead(wmChannelID, 'ReadKey', readAPIKey, 'DateRange', range);
modulo3_thingspeak = table(thingspeakTime, thingspeakData(:,1), thingspeakData(:,2),...
    thingspeakData(:,3), thingspeakData(:,4), thingspeakData(:,5), thingspeakData(:,6),...
    thingspeakData(:,7), 'VariableNames', {'when', 'battery', 'd15cm', 'd15cm_bias', 'd45cm', 'd45cm_bias','d75cm', 'd75cm_bias'});

%% Modulo 4
% Channel ID to read data from
wmChannelID = 256209;
readAPIKey = 'BDIT5EHZGANY1MOV';

[thingspeakData, thingspeakTime] = thingSpeakRead(wmChannelID, 'ReadKey', readAPIKey, 'DateRange', range);
modulo4_thingspeak = table(thingspeakTime, thingspeakData(:,1), thingspeakData(:,2),...
    thingspeakData(:,3), thingspeakData(:,4), thingspeakData(:,5), thingspeakData(:,6),...
    thingspeakData(:,7), 'VariableNames', {'when', 'battery', 'd15cm', 'd15cm_bias', 'd45cm', 'd45cm_bias','d75cm', 'd75cm_bias'});

%% Modulo 5
% Channel ID to read data from
wmChannelID = 258089;
readAPIKey = '';

[thingspeakData, thingspeakTime] = thingSpeakRead(wmChannelID, 'ReadKey', readAPIKey, 'DateRange', range);
modulo5_thingspeak = table(thingspeakTime, thingspeakData(:,1), thingspeakData(:,2), thingspeakData(:,3), thingspeakData(:,4),...
    'VariableNames', {'when', 'battery', 'temperature', 'wetness', 'rain'});

%% Convertendo tabelas em timetables
modulo1_thingspeak = table2timetable(modulo1_thingspeak);
modulo2_thingspeak = table2timetable(modulo2_thingspeak);
modulo3_thingspeak = table2timetable(modulo3_thingspeak);
modulo4_thingspeak = table2timetable(modulo4_thingspeak);
modulo5_thingspeak = table2timetable(modulo5_thingspeak);
