function [sensorFused, sensorOutliers, sensorOutliersTotal] = peirceFusion(sensor)
% applies Peirce's outlier detection criterion and fuses the remaining data
%
% aplica o metodo nos dados dos 4 nos e caso algum outlier seja 
% detectado ele eh adicionado em uma variavel e posteriormente removido
% dos dados principais
%
% sensorFused = the fused data, without detected outliers (if any)
% sensorOutliers = detected outliers position and value
% sensorOutliersTotal = count of detected outliers (for graphing purposes)
%

% prealocando tamanho da variavel com o mesmo tamanho do array de dados
% dos sensores, para otimizar o acesso/gravacao dos dados
sensorFused = zeros((size(sensor,1)),1);

% criando a variavel de outliers (nao criei com tamanho pre-determinado
% pois nao tenho como saber a quantidade aproximada de outliers)
sensorOutliers = [];

for i = 1:size(sensor,1)
    % aplica o metodo de pierce nos dados dos 4 nos, caso um outlier seja detectado ele eh removido
    [or_data, outliers] = apply_peirce(sensor(i,:));
    if size(outliers) ~= 0
        % caso exista um outlier, ? gravado a posi??o do outlier e seu valor
        sensorOutliers = [sensorOutliers; i, outliers];
    end
    % media dos dados
    sensorFused(i,1) = mean(or_data,'omitnan');
end

% total de outliers detectados
sensorOutliersTotal = size(sensorOutliers,1);

end