% http://matlaboratory.blogspot.co.uk/2015/04/alternative-function-moving-average.html

function [output, weights] = movAv2(y,n,lag,weights)

% Calculate lag
lead = n-(n-lag);

% If no weights specified, assume equal
if ~exist('weights', 'var')
    weights = ones(1,n);
end

% If weights have been specified as a character, created required
if ischar(weights)
    switch weights
        case {'exp', 'Exp'}
            weights=logspace(0,1,round(n));
        case 'symExp'
            weights=[logspace(0,1,round(n/2)),logspace(1,0,round(n/2))];
        case 'linInc'
            weights=1:n;
        case 'rand'
            weights=rand(1,n);
        otherwise
            weights = ones(1,n);
    end
else
    % Weights specified as a vector
end

% Normalise weights to 0 to 1;
weights = weights./sum(weights);

% Preallocate output
output=NaN(1,numel(y));
% For length of input, minus n
for a = 1:length(y)-n
    % Find index range to take average over
    b=a+n-1;
    % Calculate mean
    output(a+lead) = sum(y(a:b).*weights);
end
end