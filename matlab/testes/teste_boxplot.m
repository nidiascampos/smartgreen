sensor = sensor2meanOrig;
k = 3.5;

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

sensorOutliersTotal = size(sensorOutliers,1);
sensorFused = mean(sensor,2,'omitnan');