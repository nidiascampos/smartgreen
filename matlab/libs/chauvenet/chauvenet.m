function [clean,outlier,index] = chauvenet(x)

% INPUT = column/row vector
% OUTPUT
% clean = column vector of cleaned x
% outlier = value(s) of outliers
% index = index(es) of outliers
% 1.0, Nov 2016, Rod Letchford
% 2.0, Jan 2017, Rod Letchford

tau = (x-mean(x))./std(x);
chauv = norminv(1-1/4/length(x));
clean = [];
outlier = [];
index = [];

for n = 1:length(x)
    if tau(n) < chauv
        clean = vertcat(clean,[x(n)]);
    else
        outlier = vertcat(outlier,[x(n)]);
    index = vertcat(index,[n]);
    end
end