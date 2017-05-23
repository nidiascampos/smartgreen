function plotar_metodo_alt(period,sensor,methodData,type,graphTitle,outlierCount,legendPosition,outlierIndex)
    grafico = figure;
    hold on
    plot(period,sensor);
    plot(period,methodData,'LineWidth',4);
    for i = 1:size(outlierIndex,1)
        plot(period(outlierIndex(i,1)),outlierIndex(i,2),'LineStyle','none','Marker','o','MarkerEdgeColor','red')
    end
    hold off
    titleOutliers = sprintf('Total de outliers removidos: %d',outlierCount);
    methodName = sprintf('Fusão utilizando método %s',graphTitle);
    title({methodName,titleOutliers});
    xlabel('Período (dias)');
    ylabel('kPa/cbar');
    legend('nó 1','nó 2','nó 3','nó 4','fusão','outlier','location',legendPosition)
    filename = sprintf('graphs/sensores_%s',type);
    saveas(grafico,filename,'png');
end