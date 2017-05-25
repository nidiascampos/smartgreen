sensor = sensor2meanOrig;
N = size(sensor,1);
MLE = zeros(N,1);
MLEpci = zeros(N,2);
for i = 1:N
    [phat pci] = mle(sensor(i,:));
    MLE(i) = phat(1);
    MLEpci(i,:) = pci(:,1)';
%     MLEpci(i) = pci;
end