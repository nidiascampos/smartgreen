clear;
load('sglog-7a13');

% dias = [8:13];
% ultimo_dia = 13;
% for i=8:ultimo_dia
%     filtro = SGLOG.dia == i;
%     dia(i) = SGLOG(filtro, :);
% end

figure;
hold on;
grid on;
grid minor;
filtro = SGLOG.dia == 8;
teste = SGLOG(filtro, :);
% plot(SGLOG.sensorValor);
plot(teste.sensorValor);

filtro = SGLOG.dia == 9;
teste = SGLOG(filtro, :);
plot(teste.sensorValor);

filtro = SGLOG.dia == 10;
teste = SGLOG(filtro, :);
plot(teste.sensorValor);

filtro = SGLOG.dia == 11;
teste = SGLOG(filtro, :);
plot(teste.sensorValor);

filtro = SGLOG.dia == 12;
teste = SGLOG(filtro, :);
plot(teste.sensorValor);

filtro = SGLOG.dia == 13;
teste = SGLOG(filtro, :);
plot(teste.sensorValor);

legend('dia 8','dia 9','dia 10','dia 11','dia 12','dia 13');