clear;
load('sglog-7a13');

figure;
hold on;
grid on;
grid minor;
set(gca,'xtick',[0:1:24]);
xlabel('hora');
ylabel('valor medido pelo sensor');

for i=8:13
    filtro = SGLOG.dia == i;
    teste = SGLOG(filtro, :);
    tamanho = size(teste.sensorValor);
    plot([1:tamanho]/60,teste.sensorValor);
end

legenda = legend('08/06/2016','09/06/2016','10/06/2016','11/06/2016','12/06/2016','13/06/2016','Location','northwest');
title(legenda,'Dias');