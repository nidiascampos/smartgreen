function [sensorFused, sensorScores, sensorOutliers, sensorOutliersTotal] = adjboxplotFusion2(sensor,k)
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
sensorScores = [];
sensorOutliers = [];
sensorOutliersTotal = [];

for i = 1:size(sensor,1)
    [Q1, Q3, MC, sensorOutlier] = adjboxplot_alt(sensor(i,:),k);
    if ~isempty(sensorOutlier)
        sensorScores = [sensorScores; i Q1 Q3 MC];
        id = sensorOutlier(1);
        sensorOutliers = [sensorOutliers; i sensor(i,id)];
        sensor(i,id) = NaN;
    end
end

sensorFused = mean(sensor,2,'omitnan');

% total de outliers detectados
sensorOutliersTotal = size(sensorOutliers,1);

end