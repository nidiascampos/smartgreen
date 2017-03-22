% size: use divvy and resize plot screen to 4 X 5 (w X h)

clf % clear current figure
medias_originais = figure;
a = subplot(3,1,1);
hold on
plot(dateRange,sensor1meanOrig)
plot(dateRange,sensor1fusedMean,'LineWidth',4,'LineStyle','-.')
vline(dateSensorDeath,'k:'); % indicativo da morte do nó 3
legend('node 1','node 2','node 3','node 4','fused mean','location','northwest')
ylabel('kPa/cbar')
xlabel('Days')
title('Depth: 15cm');
hold off

b = subplot(3,1,2);
semilogy(dateRange,sensor2meanOrig)
hold on
semilogy(dateRange,sensor2fusedMean,'LineWidth',4,'LineStyle','-.')
vline(dateSensorDeath,'k:'); % indicativo da morte do nó 3
% legend('node 1','node 2','node 3','node 4','fused mean','location','northeast')
ylabel('kPa/cbar (log)')
xlabel('Days')
title('Depth: 45cm');
hold off

c = subplot(3,1,3);
hold on
plot(dateRange,sensor3meanOrig)
plot(dateRange,sensor3fusedMean,'LineWidth',4,'LineStyle','-.')
vline(dateSensorDeath,'k:'); % indicativo da morte do nó 3
% legend('node 1','node 2','node 3','node 4','fused mean','location','southeast')
ylabel('kPa/cbar')
xlabel('Days')
title('Depth: 75cm');
hold off

% figtitle('Raw data (mean) provided by sensor nodes');
% medias_originais.PaperUnits = 'centimeters';
% medias_originais.PaperPosition = [0 0 5 15];
% filename = ('graphs/semish/nodes-means');
% saveas(medias_originais,filename,'png')