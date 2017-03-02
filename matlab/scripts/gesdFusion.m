function [sensorFused, sensorOutliers, sensorOutliersTotal] = gesdFusion(sensor,period,maxoutliers)
% applies modified Z-score outlier detection method and fuses the remaining data
%    
% aplica o metodo nos dados dos 4 nos e caso algum outlier seja 
% detectado ele eh adicionado em uma variavel e posteriormente removido
% dos dados principais
%
% sensorFused = the fused data, without detected outliers (if any)
% sensorOutliers = detected outliers position and value
% sensorOutliersTotal = count of detected outliers (for graphing purposes)
%

% criando a variavel de outliers (nao criei com tamanho pre-determinado
% pois nao tenho como saber a quantidade aproximada de outliers)
% sensorESD = [];
sensorOutliers = [];

% dados devem estar no seguinte formato (rows), pois ele vai calcular pelas colunas:
% n? 1: dado 1, dado 2, dado 3, ...
% n? 2: dado 1, dado 2, dado 3, ...
% n? 3: dado 1, dado 2, dado 3, ...
[~, ~, ~, ~, sensorOutliers] = gesd(sensor',period,maxoutliers);

if sensorOutliers ~= 0
%     total = size(sensor,1) - size(sensorOutliers,1);
    for i = 1:size(sensorOutliers,1)
        id = sensorOutliers(i,1);
        outlier = sensorOutliers(i,2);
        sensorOutliers(i,1) = sensorOutliers(i,2);
        sensorOutliers(i,2) = sensor(outlier,id);
        sensor(outlier,id) = NaN;
%         sensorFused(id) = sensorFused(id) - sensor(outlier,id)
    end
%     sensorFused = sum(sensor,2)/total;
%     sensorFused = sensorFused/total;
% else
%     sensorFused = mean(sensor,2);
end

sensorFused = mean(sensor,2,'omitnan');

% total de outliers detectados
sensorOutliersTotal = size(sensorOutliers,1);

end