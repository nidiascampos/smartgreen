function [sensorFused, sensorOutliers, sensorOutliersTotal, dadosNulos] = gesdFusion2(sensor,period)
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
% no 1: dado 1, dado 2, dado 3, ...
% no 2: dado 1, dado 2, dado 3, ...
% no 3: dado 1, dado 2, dado 3, ...

dadosNulos = isnan(sensor);

for i = 1:size(sensor,1)
    dados = sensor(~isnan(sensor(i,:)));
    maxOutliers = size(dados,2);
    
    if size(dados,2) > 1
        % fazer fusao
        [~, ~, ~, ~, sensorOutliers(i,1)] = gesd(dados,period(i,:),maxOutliers);
    else
        
    end
end
    

% maxoutliers = size(sensor,2) - 1;
% 
% [~, ~, ~, ~, sensorOutliers] = gesd(sensor',period,maxoutliers);
% 
% if sensorOutliers ~= 0
% %     total = size(sensor,1) - size(sensorOutliers,1);
%     for i = 1:size(sensorOutliers,1)
%         id = sensorOutliers(i,1);
%         outlier = sensorOutliers(i,2);
%         sensorOutliers(i,1) = sensorOutliers(i,2);
%         sensorOutliers(i,2) = sensor(outlier,id);
%         sensor(outlier,id) = NaN;
% %         sensorFused(id) = sensorFused(id) - sensor(outlier,id)
%     end
% %     sensorFused = sum(sensor,2)/total;
% %     sensorFused = sensorFused/total;
% % else
% %     sensorFused = mean(sensor,2);
% end
% 
% sensorFused = mean(sensor,2,'omitnan');
% 
% % total de outliers detectados
% sensorOutliersTotal = size(sensorOutliers,1);

end