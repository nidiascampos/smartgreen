%% funcao de plotar e gravar
function plotar_grafico_coleta03(periodo,sensor,nome,titulo,labelY,exibirPlot)
    grafico = figure('visible',exibirPlot);
    hold on
    grid on
    plot(periodo,sensor,'*-');
    hold off
    methodName = sprintf('%s',titulo);
    title(methodName);
    xlabel('Período (dias)');
    ylabel(labelY);
%     ylim([-200 7000]);
%     legend('nó 1','nó 2','nó 3','nó 4','fusão','outlier','location',posicaoLegenda)
    filename = sprintf('graphs/coleta03/%s',nome);
    saveas(grafico,filename,'png');
end