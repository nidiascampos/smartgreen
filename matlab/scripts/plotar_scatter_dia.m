function plotar_scatter_dia(dia_inicial, dia_final, tabela_A, parametro_A, tabela_B, parametro_B, titulo, nome_arquivo, exibir_plot)

range = timerange(dia_inicial, dia_final);
temp_A = tabela_A(range,:);
temp_B = tabela_B(range,:);

item_A = temp_A.(parametro_A);
item_B = temp_B.(parametro_B);

grafico_scatter = figure('visible',exibir_plot);
hold on;
scatter(item_A,item_B);
lsline;
clear title;
dias = [dia_inicial ' a ' dia_final];
title({dias,titulo});
nome_arquivo = sprintf('graphs/coleta03/scatter/%s',nome_arquivo);
saveas(grafico_scatter,nome_arquivo,'png');