% Semish 2017
% output: outliers_15cm_peirce_mzscore
% size: use divvy and resize plot screen to 5 X 3 (w X h)

peircePlot15cm = figure;
N = 8;
C = linspecer(N); 
plot(dateRange,sensor1meanOrig(:,1),'--','color',C(7,:));
hold on;
plot(dateRange,sensor1meanOrig(:,2),'--','color',C(6,:));
plot(dateRange,sensor1meanOrig(:,3),'--','color',C(3,:));
plot(dateRange,sensor1meanOrig(:,4),'--','color',C(4,:));
plot(dateRange,sensor1fusedPeirce,'LineWidth',2,'MarkerIndices',1:9:length(sensor1fusedPeirce),'MarkerSize',10,'color',C(1,:));
plot(dateRange,sensor1fusedMZScore,'LineWidth',2,'MarkerIndices',1:10:length(sensor1fusedMZScore),'MarkerSize',10,'color',C(2,:));
for i = 1:size(sensor1peirceOutliers,1)
    plot(dateRange(sensor1peirceOutliers(i,1)),sensor1peirceOutliers(i,2),'LineStyle','none','Marker','o','MarkerEdgeColor','r','MarkerSize',7)
end
% for i = 1:size(sensor1mzScoreOutliersIndex,1)
%     plot(dateRange(sensor1mzScoreOutliersIndex(i,1)),sensor1mzScoreOutliersIndex(i,2),'LineStyle','none','Marker','s','MarkerEdgeColor','green')
% end
for i = 1:size(sensor1fusedMZScore,1)
    if (sensor1mzScoreOutliersIndex(i) ~= 0)
        plot(dateRange(i),sensor1meanOrig(i,sensor1mzScoreOutliersIndex(i)),'LineStyle','none','Marker','s','MarkerEdgeColor','g','MarkerSize',15);
    end
end

hold off;
% grid on;
xlabel('Days');
ylabel('kPa/cbar');
% legend({'node 1','node 2','node 3','node 4','Peirce: fused data','mod. Z-Score: fused data',...
%     'Peirce: outliers detected ','mod. Z-Score: outliers detected'},'location','southoutside','orientation','horizontal','Box','off');
legend({'node 1','node 2','node 3','node 4','Peirce: fused data','mod. Zscore: fused data','Peirce: outliers detected','mod. Z-Score: outliers detected'},...
    'location','southoutside','orientation','horizontal','Box','off');
% plotar_metodo(dateRange,sensor1meanOrig,sensor1fusedMZScore,...
%     '15cm_fusao_ZScoreModif','Z-Score Modificado (15cm)',sensor1mzScoreOutliersTotal,'northwest',sensor1mzScoreOutliersIndex);

% 
% plotar_metodo_alt(dateRange,sensor1meanOrig,sensor1fusedPeirce,...
%     '15cm_fusao_peirce','Critério de Peirce (15cm)',sensor1peirceOutliersTotal,'northwest',sensor1peirceOutliers);

% function plotar_metodo(period,sensor,methodData,type,graphTitle,outlierCount,legendPosition,outlierIndex)
%     if nargin < 8
%         outlierIndex = NaN;
%     end
%     
%     grafico = figure;
% %     semilogy(period,sensor);
%     hold on
%     plot(period,sensor);
%     plot(period,methodData,'LineWidth',4);
%     if ~isnan(outlierIndex)
%         for i = 1:size(sensor,1)
%         	if (outlierIndex(i) ~= 0)
%         		plot(period(i),sensor(i,outlierIndex(i)),'LineStyle','none','Marker','o','MarkerEdgeColor','red');
%         	end
%         end
%     end
%     hold off
%     titleOutliers = sprintf('Total de outliers removidos: %d',outlierCount);
%     methodName = sprintf('Fusão utilizando método %s',graphTitle);
%     title({methodName,titleOutliers});
%     xlabel('Período (dias)');
%     ylabel('kPa/cbar');
%     legend('nó 1','nó 2','nó 3','nó 4','fusão','outlier','location',legendPosition)
%     filename = sprintf('graphs/sensores_%s',type);
%     saveas(grafico,filename,'png');
% end
% 
% function plotar_metodo_alt(period,sensor,methodData,type,graphTitle,outlierCount,legendPosition,outlierIndex)
%     grafico = figure;
%     hold on
%     plot(period,sensor);
%     plot(period,methodData,'LineWidth',4);
%     for i = 1:size(outlierIndex,1)
%         plot(period(outlierIndex(i,1)),outlierIndex(i,2),'LineStyle','none','Marker','o','MarkerEdgeColor','red')
%     end
%     hold off
%     titleOutliers = sprintf('Total de outliers removidos: %d',outlierCount);
%     methodName = sprintf('Fusão utilizando método %s',graphTitle);
%     title({methodName,titleOutliers});
%     xlabel('Período (dias)');
%     ylabel('kPa/cbar');
%     legend('nó 1','nó 2','nó 3','nó 4','fusão','outlier','location',legendPosition)
%     filename = sprintf('graphs/sensores_%s',type);
%     saveas(grafico,filename,'png');
% end