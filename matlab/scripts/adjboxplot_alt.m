function [Q1 Q3 MC outlier_num] = adjboxplot_alt(x, k)
%
% The 'adjboxplotalt' improves the outlier labeling capabilities of the
% boxplot approach in the presence of skewed data. A robust measure of
% skewness, the medcouple ('MC'), is introduced in the test.
%
% Data in 'x' are organized so that columns are the time series and rows
% are the time intervals. All series contain the same number of
% observations.
%
% The parameters calibrated in the references for k=1.5 are used in this
% test. However, it is possible to define the value of k in the formula,
% though the results would not be optimal. Default value for k = 1.5. 
% 
% The 'adjboxplot' is equivalent to the 'testboxplot' for the same value of
% 'k' when MC=0, i.e., the data are symmetric.
%
% [Q1 Q3 MC outlier_num] = adjboxplotalt(...) returns the following information:
% Q1            - 25% quantile
% Q3            - 75% quantile
% MC            - Medcouple measure of skewness. MC>0 indicates right skew and
%                 MC<0 left skew.
% outlier_num   - matrix providing row and column numbers of the values in
%                 'x' considered as potential outliers.
%
% The 'adjboxplotalt' function requires the 'medcouple' or 'mc' function to be
% available.
%
% The 'medcouple' function is provided by the library created by Francisco Augusto
% Alcaraz Garcia, while 'mc' is provided by the LIBRA (Library for Robust
% Analysis) library. Download links are provided below:
% - https://www.mathworks.com/matlabcentral/fileexchange/28501-tests-to-identify-outliers-in-data-series
% - https://wis.kuleuven.be/stat/robust/LIBRA
%
% Created by Francisco Augusto Alcaraz Garcia
%            alcaraz_garcia@yahoo.com
%
% Modified by Andrei Bosco Bezerra Torres
%            andreibosco@virtual.ufc.br
%
% References:
%
% 1) E. Vanderviere; M. Huber (2004). An Adjusted Boxplot for Skewed
% Distributions. COMPSTAT'2004 Symposium, Physica-Verlag/Springer.
%
% 2) G. Brys; M. Hubert; P.J. Rousseeuw (2005). A Robustification of
% Independent Component Analysis. Journal of Chemometrics 19(5-7),
% pp. 364-375.
%
% 3) J.W. Tukey (1977). Exploratory Data Analysis. Addison Wesley.


% Check number of input arguements and define default values
if nargin == 1
    k = 1.5;
end

% Check for validity of inputs
if ~isnumeric(x)
    error('Input x must be a numeric array.')
end

k = 1.5;

n = size(x,1);

Q1 = quantile(x, 0.25);
Q3 = quantile(x, 0.75);

MC = mc(x);
% MC = medcouple(x');

IQR = Q3 - Q1;

if MC >=0
    k1 = -3.5*MC;
    k3 = 4*MC>=0;
    
    % formula original:
    % [Q1-1.5 * exp (-3.5MC) * IQR, Q3+1.5 * exp (4MC) * IQR]
    %
    % exemplo de implementa??o da formula completa
    % i3 = Q1 - k * exp(-3.5 * MC) * IQR
    % j3 = Q3 + k * exp(4 * MC) * IQR
else
     k1 = -4*MC;
    k3 = 3.5*MC;
    
    % formula original:
    % [Q1-1.5 * exp (-4MC) * IQR, Q3+1.5 * exp (3.5MC) * IQR
    %
    % exemplo de implementa??o da formula completa
    % i4 = Q1 - k * exp(-4 * MC) * IQR
    % j4 = Q3 + k * exp(3.5 * MC) * IQR
end

[i1,j1] = find(x < repmat(Q1 - k*exp(k1.*MC).*(Q3-Q1),n,1));
[i2,j2] = find(x > repmat(Q3 + k*exp(k3.*MC).*(Q3-Q1),n,1));

if (isempty(i1)+isempty(i2)) == 0
    outlier_num = [j1 i1; j2 i2];
elseif isempty(i1)
    outlier_num = [j2 i2];
elseif isempty(i2)
    outlier_num = [j1 i1];
else
%     outlier_num = ('No outliers have been identified!');
    outlier_num = [];
end