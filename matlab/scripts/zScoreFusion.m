function [sensorFused, sensorOutliers, sensorOutliersTotal] = zScoreFusion(sensor,period) 
% applies Z-score outlier detection method and fuses the remaining data
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
sensorOutliers = [];
for i = 1:size(sensor,1)
    [~, ~, ~, Zoutnum] = zzscore(sensor(i,:),period);
    sensorOutliers = [sensorOutliers; Zoutnum(2)];
end

% verifica se foi detectado outlier nos dados atuais
% se sim, remove o outlier e faz a m?dia do restante
% se nao, faz uma media com os dados dos 4 nos
sensorFused = zeros((size(sensor,1)),1);
for i = 1:size(sensor,1)
    if (sensorOutliers(i) == 0)
        sensorFused(i,1) = mean(sensor(i,:));
    else
        j = sensorOutliers(i);
        sensorFused(i,1) = (sum(sensor(i,:)) - sensor(i,j))/3;
    end
end

% total de outliers detectados
sensorOutliersTotal = sum(sensorOutliers ~= 0);

end