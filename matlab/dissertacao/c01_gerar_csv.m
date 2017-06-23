%% CSV
% gerar arquivo com dados de todos os sensores, para uso no Weka

%% gerando versão com dados dos modulos após fusão
dissertacao_fusao = coleta03_total;
dissertacao_fusao(:,1:12) = []; % removendo colunas de dados brutos
dissertacao_fusao = outerjoin(dissertacao_fusao,EToPM_hora);
dissertacao_fusao = outerjoin(total_fused,dissertacao_fusao);

% filtrando o periodo desejado
range = timerange('2017-04-25 15:00', '2017-05-23 11:00');
dissertacao_fusao = dissertacao_fusao(range,:);

% removendo linhas sem leitura de pelo menos um dos modulos
dissertacao_fusao([23:29,45,47,49:209,391:540],:) = [];

% convertendo em tabela para poder gerar csv
dissertacao_fusao = timetable2table(dissertacao_fusao);

% gravando arquivo
writetable(dissertacao_fusao,'dissertacao/logs/dissertacao_fusao.csv');