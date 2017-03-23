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
semilogy(dateRange,sensor2fusedPeirce,'LineWidth',2,'MarkerIndices',1:9:length(sensor2fusedPeirce),'MarkerSize',10,'color',C(1,:));
semilogy(dateRange,sensor2fusedMZScore,'LineWidth',2,'MarkerIndices',1:10:length(sensor2fusedMZScore),'MarkerSize',10,'color',C(2,:));
for i = 1:size(sensor2peirceOutliers,1)
    semilogy(dateRange(sensor2peirceOutliers(i,1)),sensor2peirceOutliers(i,2),'LineStyle','none','Marker','o','MarkerEdgeColor','red','MarkerSize',7)
end
for i = 1:size(sensor2fusedMZScore,1)
    if (sensor2mzScoreOutliersIndex(i) ~= 0)
        plot(dateRange(i),sensor2meanOrig(i,sensor2mzScoreOutliersIndex(i)),'LineStyle','none','Marker','s','MarkerEdgeColor','green','MarkerSize',15);
    end
end

hold off;
xlabel('Days');
ylabel('kPa/cbar (log)');
legend({'node 1','node 2','node 3','node 4','Peirce: fused data','mod. Z-Score: fused data',...
    'Peirce: outliers detected ','mod. Z-Score: outliers detected'},'location','southoutside','orientation','horizontal','Box','off');
% legend({'node 1','node 2','node 3','node 4','Peirce: fused data','mod. Z-Score: fused data',...
%     'Peirce: outliers detected ','mod. Z-Score: outliers detected'},'location','northeast');

% plot(dateRange,sensor1fusedPeirce,'LineWidth',2);
% plot(dateRange,sensor1fusedMZScore,'LineWidth',2);
% for i = 1:size(sensor1peirceOutliers,1)
%     plot(dateRange(sensor1peirceOutliers(i,1)),sensor1peirceOutliers(i,2),'LineStyle','none','Marker','o','MarkerEdgeColor','red','MarkerSize',7)
% end
% for i = 1:size(sensor1fusedMZScore,1)
%     if (sensor1mzScoreOutliersIndex(i) ~= 0)
%         plot(dateRange(i),sensor1meanOrig(i,sensor1mzScoreOutliersIndex(i)),'LineStyle','none','Marker','s','MarkerEdgeColor','magenta','MarkerSize',7);
%     end
% end