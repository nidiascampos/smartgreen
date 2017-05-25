function plotar_scatter_periodo(dia_inicial, dia_final, tabela_A, parametro_A, tabela_B, parametro_B, titulo, nome_arquivo, exibir_plot)

% dia_inicial = datetime('2017-05-01');
% dia_final = datetime('2017-05-10');
duracao = between(dia_inicial,dia_final);
[~,~,D,~,~,~] = datevec(duracao);
% periodo = linspace(dia_inicial,dia_final,D);

% dias = zeros(1,D);

for i = 1:D
    if i > 1
        dia_inicial = dia_fim;
    end
    dia_fim = datenum(dia_inicial);
    dia_fim = addtodate(dia_fim, 1, 'day');
    dia_fim = datestr(dia_fim);

    periodo_timerange = timerange(dia_inicial, dia_fim);
    
    % falta aumentar o dia inicial no loop
    
    temp_A = tabela_A(periodo_timerange,:);
    temp_B = tabela_B(periodo_timerange,:);

    tabela_A_filtrada = temp_A.(parametro_A);
    tabela_B_filtrada = temp_B.(parametro_B);

    grafico_scatter = figure('visible',exibir_plot);
    hold on;
    scatter(tabela_A_filtrada,tabela_B_filtrada);
    lsline;
    clear title;
%     title({dia_inicial,titulo});
    title({datestr(dia_inicial),titulo});
    nome_arquivo_data = [datestr(dia_inicial) '_' nome_arquivo];
    nome_arquivo_completo = sprintf('graphs/coleta03/scatter/%s',nome_arquivo_data);
    saveas(grafico_scatter,nome_arquivo_completo,'png');
end