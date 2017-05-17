%% funcao de plotar e gravar
function plotar_grafico(periodo,sensor,nome,titulo,labelY,exibirPlot)
    grafico = figure('visible',exibirPlot);
    hold on
    grid on
    plot(periodo,sensor,'*-');
%     for i = 1:size(outlierIndex,1)
%         plot(periodo(outlierIndex(i,1)),outlierIndex(i,2),'LineStyle','none','Marker','o','MarkerEdgeColor','red')
%     end
    hold off
%     titleOutliers = sprintf('Total de outliers removidos: %d',outlierCount);
    methodName = sprintf('%s',titulo);
    title(methodName);
    xlabel('Período (dias)');
    ylabel(labelY);
%     legend('nó 1','nó 2','nó 3','nó 4','fusão','outlier','location',posicaoLegenda)
    filename = sprintf('graphs/coleta03/%s',nome);
    saveas(grafico,filename,'png');
end