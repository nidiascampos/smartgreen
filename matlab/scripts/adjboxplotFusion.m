function [sensorFused, sensorScores, sensorOutliers, sensorOutliersTotal] = adjboxplotFusion(sensor,k)
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

[Q1, Q3, MC, sensorOutliers] = adjboxplot_alt(sensor,k);
sensorScores = [sensorScores; Q1 Q3 MC];

sensorFused = sum(sensor);

% verifica se foi detectado outlier nos dados atuais
% se sim, remove o outlier e faz a m?dia do restante
% se nao, faz uma media com os dados dos 4 nos

if sensorOutliers ~= 0
    total = size(sensor,1) - size(sensorOutliers,1);
    for i = 1:size(sensorOutliers,1)
        id = sensorOutliers(i,1);
        outlier = sensorOutliers(i,2);
        sensorOutliers(i,2) = sensor(outlier,id);
        sensor(outlier,id);
        sensorFused(id) = sensorFused(id) - sensor(outlier,id);
    end
    sensorFused = sensorFused/total;
else
    sensorFused = mean(sensor,'omitnan');
end

% total de outliers detectados
sensorOutliersTotal = size(sensorOutliers,1);

end