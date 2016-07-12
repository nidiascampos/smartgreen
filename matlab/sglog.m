clear;
load('sglog-7a13');

% dias = [8:13];
% ultimo_dia = 13;
% for i=8:ultimo_dia
%     filtro = SGLOG.dia == i;
%     dia(i) = SGLOG(filtro, :);
% end

filtro = SGLOG.dia == 9;
teste = SGLOG(filtro, :);

% plot(SGLOG.sensorValor);
plot(teste.sensorValor);