% dados: livro de kalman para python
% formula: http://stackoverflow.com/a/20301772/481690

% mu = 10;
% sigma = 1;

mu1 = 28.5908;
sigma1 = 0.8775;
x1 = linspace (mu1-4*sigma1, mu1+4*sigma1, 10000);

mu2 = 36.3279;
sigma2 = 4.2008;
x2 = linspace (mu2-4*sigma1, mu2+4*sigma1, 10000);

mu3 = 26.6373;
sigma3 = 0.24;
x3 = linspace (mu3-4*sigma1, mu3+4*sigma1, 10000);

mu4 = 11.7604;
sigma4 = 0.40;
% sigma4 = 0.4;
x4 = linspace (mu4-4*sigma1, mu4+4*sigma1, 10000);

figure
hold on
plot(x1, normpdf (x1,mu1,sigma1))
plot(x2, normpdf (x2,mu2,sigma2))
plot(x3, normpdf (x3,mu3,sigma3))
plot(x4, normpdf (x4,mu4,sigma4))
% xlim([4  16])
% ylim([0 .5])
hold off

% figure
% plot(x, normcdf (x,mu,sigma))
% hold on