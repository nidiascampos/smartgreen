function [sensorFused, sensorOutliers, sensorOutliersTotal, sensorMZscores] = mzScoreFusion(sensor,period,thresh)
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
sensorMZscores = [];
sensorOutliers = [];

for i = 1:size(sensor,1)
    % verifica se existe um NaN e o remove dos dados
    sensorClean = sensor(i,:);
    sensorClean = sensorClean(~isnan(sensorClean));
    % aplica o m?todo nos dados dos n?s
    %[MZscore, ~, ~, MZoutnum] = mzscore(sensor(i,:),period,thresh);
    [~, ~, ~, MZoutnum] = mzscore(sensorClean,period,thresh);
    %sensorMZscores = [sensorMZscores; MZscore];
    sensorOutliers = [sensorOutliers; MZoutnum(2)];
end

% verifica se foi detectado outlier nos dados atuais
% se sim, remove o outlier e faz a m?dia do restante
% se nao, faz uma media com os dados dos 4 nos
sensorFused = zeros((size(sensor,1)),1);
for i = 1:size(sensor,1)
    % FIXME: e se ouver mais de 1 outlier?
    if (sensorOutliers(i) == 0)
        sensorFused(i,1) = mean(sensor(i,:),'omitnan');
    else
        j = sensorOutliers(i);
        if isnan(sensor(i,j))
            sensorFused(i,1) = mean(sensor(i,:),'omitnan');
        else
            sensorFused(i,1) = (sum(sensor(i,:),'omitnan') - sensor(i,j))/3;
        end
    end
end

% total de outliers detectados
sensorOutliersTotal = sum(sensorOutliers ~= 0);

end