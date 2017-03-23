% size: use divvy and resize plot screen to 4 X 5 (w X h)

%clf % clear current figure
medias_originais = figure;
a = subplot(3,1,1);
hold on
plot(dateRange,sensor1meanOrig(:,1),'Color',[0 0 1]);
plot(dateRange,sensor1meanOrig(:,2),'Color',[1 0 0]);
plot(dateRange,sensor1meanOrig(:,3),'Color',[1 0 1]);
plot(dateRange,sensor1meanOrig(:,4),'Color',[0.87058824300766 0.490196079015732 0]);
plot(dateRange,sensor1fusedMean,'--d','LineWidth',2,'MarkerIndices',1:7:length(sensor1fusedMean),'MarkerSize',10)
vline(dateSensorDeath,'k:'); % indicativo da morte do nó 3
legend('node 1','node 2','node 3','node 4','fused mean','location','northwest')
ylabel('kPa/cbar')
xlabel('Days')
title('Depth: 15cm');
hold off

b = subplot(3,1,2);
semilogy(dateRange,sensor2meanOrig(:,1),'Color',[0 0 1]);
hold on
semilogy(dateRange,sensor2meanOrig(:,2),'Color',[1 0 0]);
semilogy(dateRange,sensor2meanOrig(:,3),'Color',[1 0 1]);
semilogy(dateRange,sensor2meanOrig(:,4),'Color',[0.87058824300766 0.490196079015732 0]);
semilogy(dateRange,sensor2fusedMean,'--d','LineWidth',2,'MarkerIndices',1:7:length(sensor2fusedMean),'MarkerSize',10)
vline(dateSensorDeath,'k:'); % indicativo da morte do nó 3
% legend('node 1','node 2','node 3','node 4','fused mean','location','northeast')
ylabel('kPa/cbar (log)')
xlabel('Days')
title('Depth: 45cm');
hold off

c = subplot(3,1,3);
hold on
plot(dateRange,sensor3meanOrig(:,1),'Color',[0 0 1]);
plot(dateRange,sensor3meanOrig(:,2),'Color',[1 0 0]);
plot(dateRange,sensor3meanOrig(:,3),'Color',[1 0 1]);
plot(dateRange,sensor3meanOrig(:,4),'Color',[0.87058824300766 0.490196079015732 0]);
plot(dateRange,sensor3fusedMean,'--d','LineWidth',2,'MarkerIndices',1:7:length(sensor3fusedMean),'MarkerSize',10)
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

% Create textarrow
annotation(medias_originais,'textarrow',[0.710758377425044 0.727807172251617],...
    [0.900610017889088 0.901610017889088],'String',{'Death of node 3'},...
    'HeadStyle','vback3',...
    'FontSize',11);

annotation(medias_originais,'textarrow',[0.710758377425044 0.727807172251617],...
    [0.587550983899822 0.588550983899822],'String',{'Death of node 3'},...
    'HeadStyle','vback3',...
    'FontSize',11);

annotation(medias_originais,'textarrow',[0.710758377425044 0.727807172251617],...
    [0.30132558139535 0.30232558139535],'String',{'Death of node 3'},...
    'HeadStyle','vback3',...
    'FontSize',11);