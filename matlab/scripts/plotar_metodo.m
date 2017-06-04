function plotar_metodo(period,sensor,methodData,type,graphTitle,outlierCount,legendPosition,outlierIndex)
    if nargin < 8
        outlierIndex = NaN;
    end
    
    grafico = figure;
%     semilogy(period,sensor);
    hold on
    plot(period,sensor);
    plot(period,methodData,'LineWidth',4);
    if ~isnan(outlierIndex)
        for i = 1:size(sensor,1)
        	if (outlierIndex(i) ~= 0)
        		plot(period(i),sensor(i,outlierIndex(i)),'LineStyle','none','Marker','o','MarkerEdgeColor','red');
        	end
        end
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