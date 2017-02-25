function [sensorFused] = basicFusion(sensor,method)
% fuses sensors data by using a regular median averaging
%
% sensorFused = the fused data
%

% prealocando tamanho da variavel com o mesmo tamanho do array de dados
% dos sensores, para otimizar o acesso/gravacao dos dados
sensorFused = zeros(size(sensor,1),1);

for i = 1:size(sensor,1)
    switch method
        case 'median'
            sensorFused(i) = median(sensor(i,:),'omitnan');
        case 'mean'
            sensorFused(i) = mean(sensor(i,:),'omitnan');
        otherwise
            sensorFused = [];
    end 
end

end