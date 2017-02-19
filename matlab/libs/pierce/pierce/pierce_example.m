% generate random data:

pop_mean = 20; 
pop_sd = 2;

% 1) to see how method works on random samples drawn from a normal distribution, use 
% this dataset 
sample_data1 = pop_mean + pop_sd*randn(1, 25);

% 2) to see how method works on random data that has built-in tendency to 
% include outliers, use this method 
sample_data2 = pop_mean + pop_sd*randn(1, 20); 
% add in 1-4 obs of potentially outlying data 
funny_data1 = pop_mean + 2*pop_sd + 3*pop_sd*rand(1, 2 + round(rand(1))); 
funny_data2 = pop_mean + 4*pop_sd*randn(1,4);

sample_data2 = [sample_data2 funny_data2];

% 3) Ross example data; contains 2 points which will be rejected by Peirce's 
% method

Ross_data = [101.2, 90.0, 99.0, 102.0, 103.0, 100.2, 89.0, 98.1, 101.5, 102.0]; 

% pick which dataset should be used

% mydata = Ross_data; 
% mydata = sample_data2;

% testando com meus dados dos sensores de 15cm
% mydata = sensor1mean(:,63)
mydata = sensor1meanT(63,:)

% shuffle data, for the fun of it 
% mydata = mydata(randperm(length(mydata)));

% apply peirce criterion

[cleaned_data outlier_data] = apply_peirce(mydata);

% prep data for display

% make filter -- to help with display purposes -- (might want to make this 
% part of apply_peirce.m) 
pass_peirce = zeros(size(mydata)); 
for j=1:length(cleaned_data) 
pass_peirce = pass_peirce | mydata == cleaned_data(j); 
end

obs_index = 1:length(mydata);

% plot data (kept == blue circles) and outliers (red x's)

figure(1);

plot(obs_index, mydata, '.k'); 
hold on; 
plot(obs_index(pass_peirce), mydata(pass_peirce), 'ob', 'MarkerSize', 10); 
plot(obs_index(~pass_peirce), mydata(~pass_peirce), 'xr', 'MarkerSize', 15); 
hold off;

set(gca, 'XLim', [0 length(mydata)+1]); 
set(gca, 'YLim', [min(mydata)-1 max(mydata)+1]);

xlabel('Observation Index'); 
ylabel('Variable of Interest');

title('Sample Data as Categorized by Peirce Criterion') 
legend('datapoint', 'included', 'outlier', 'Location', 'SouthOutside')