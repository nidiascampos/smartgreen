% Semish 2017
% output: outliers_45cm_fusao_adjboxplot_esd
% size: use divvy and resize plot screen to 5 X 3 (w X h)

plot45cm = figure;
N = 8;
C = linspecer(N); 
semilogy(dateRange,sensor2meanOrig(:,1),'--','color',C(7,:));
hold on;
semilogy(dateRange,sensor2meanOrig(:,2),'--','color',C(6,:));
semilogy(dateRange,sensor2meanOrig(:,3),'--','color',C(3,:));
semilogy(dateRange,sensor2meanOrig(:,4),'--','color',C(4,:));
semilogy(dateRange,sensor2fusedBoxAdj,'LineWidth',2,'MarkerIndices',1:9:length(sensor2fusedBoxAdj),'MarkerSize',10,'color',C(1,:));
semilogy(dateRange,sensor2fusedESD,'LineWidth',2,'MarkerIndices',1:10:length(sensor2fusedESD),'MarkerSize',10,'color',C(2,:));
for i = 1:size(sensor2boxAdjOutliers,1)
    semilogy(dateRange(sensor2boxAdjOutliers(i,1)),sensor2boxAdjOutliers(i,2),'LineStyle','none','Marker','o','MarkerEdgeColor','r','MarkerSize',7)
end
for i = 1:size(sensor2ESDOutliersIndex,1)
    semilogy(dateRange(sensor2ESDOutliersIndex(i,1)),sensor2ESDOutliersIndex(i,2),'LineStyle','none','Marker','s','MarkerEdgeColor','g','MarkerSize',15)
end

hold off;
xlabel('Days');
ylabel('kPa/cbar (log)');
% legend({'node 1','node 2','node 3','node 4','adj. boxplot: fused data','g-ESD: fused data',...
%     'adj. boxplot: outliers detected','g-ESD: outliers detected'},'location','southoutside','orientation','horizontal','Box','off');
legend({'node 1','node 2','node 3','node 4','adj. boxplot: fused data','g-ESD: fused data',...
    'adj. boxplot: outliers detected','g-ESD: outliers detected'},'location','northeastoutside','Box','off');
% plotar_metodo_alt_log(dateRange,sensor2meanOrig,sensor2fusedBoxAdj,...
%     '45cm_fusao_boxplotAdj','Boxplot Ajustado (45cm)',sensor2boxAdjOutliersTotal,'northwest',sensor2boxAdjOutliers);
% plotar_metodo_alt_log(dateRange,sensor2meanOrig,sensor2fusedESD,...
%     '45cm_fusao_ESD','Generalized ESD (45cm)',sensor2ESDOutliersTotal,'northeast',sensor2ESDOutliersIndex);