% output: sensores_45cm_fusao
% size: use divvy and resize plot screen to 5 X 3 (w X h)

plot45cm = figure;
semilogy(dateRange,sensor2meanOrig);
hold on;
semilogy(dateRange,sensor2fusedBoxAdj,'LineWidth',2);
semilogy(dateRange,sensor2fusedESD,'LineWidth',2);
for i = 1:size(sensor2boxAdjOutliers,1)
    semilogy(dateRange(sensor2boxAdjOutliers(i,1)),sensor2boxAdjOutliers(i,2),'LineStyle','none','Marker','o','MarkerEdgeColor','red','MarkerSize',7)
end
for i = 1:size(sensor2ESDOutliersIndex,1)
    semilogy(dateRange(sensor2ESDOutliersIndex(i,1)),sensor2ESDOutliersIndex(i,2),'LineStyle','none','Marker','s','MarkerEdgeColor','green','MarkerSize',15)
end

hold off;
xlabel('Days');
ylabel('kPa/cbar (log)');
legend('node 1','node 2','node 3','node 4','adj. boxplot: fused data','g-ESD: fused data',...
    'adj. boxplot: outliers detected','g-ESD: outliers detected','location','northeast');
% plotar_metodo_alt_log(dateRange,sensor2meanOrig,sensor2fusedBoxAdj,...
%     '45cm_fusao_boxplotAdj','Boxplot Ajustado (45cm)',sensor2boxAdjOutliersTotal,'northwest',sensor2boxAdjOutliers);
% plotar_metodo_alt_log(dateRange,sensor2meanOrig,sensor2fusedESD,...
%     '45cm_fusao_ESD','Generalized ESD (45cm)',sensor2ESDOutliersTotal,'northeast',sensor2ESDOutliersIndex);