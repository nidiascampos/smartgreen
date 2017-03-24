function [outputTS, iDate] = changeGranularity(timeVec, dataVec, requestedGranularity, requestedAbstraction)
% CHANGEGRANULARITY function accepts time series data and then changes the
% sampling granularity to the required level, for eg: from seconds to an
% hour. This function implicitly identifies the time granularity in the time
% vector and appropriately changes it based on the requestedAbstraction.
% REQUESTEDGRANULARITY can be {'second', 'minute', 'hour', 'day', 'month'}
% REQUESTEDABSTRACTION can be {'sum', 'mean', 'median', 'max', 'min', 'first'}
%
% Example:
%
% [cokeHourly, hourlyTimeStamps] = changeGranularity(timeStamps,cokeData,'hour','sum');
%
%   Copyright 2014 The MathWorks, Inc.

% Convert the time vector to datevec format
timevector = datevec(timeVec);

% Check the lowest granularity in the timeVec vector:
secondGranular = find(timevector(:,6)>0);

timeGranularity = 1; %'second';

% Identify the granularity of the input time series
if isempty(secondGranular) 
    % Check for minute granularity
    minuteGranular = find(timevector(:,5)>0);
    timeGranularity = 2; %'minute';
    % If minute granularity is empty
    if isempty(minuteGranular)
       % Check for hourly granularity
       hourGranular = find(timevector(:,4)>0);
       timeGranularity = 3; %'hour';       
       if isempty(hourGranular)
           % Check for day granularity
           dayGranular = find(timevector(:,3)>0);
           timeGranularity = 4; % 'day'
           if isempty(dayGranular)
               % Check for month granularity
               monthGranular = find(timevector(:,2)>0);
               timeGranularity = 5; %month
           end           
       end           
    end
end
    
% Check if requestedGranularity is lower than supported granularity
switch requestedGranularity
    case 'second'
        requestedGran = 1;
    case 'minute'
        requestedGran = 2;
    case 'hour'
        requestedGran = 3;
    case 'day'
        requestedGran = 4;
    case 'month'
        requestedGran = 5;
    otherwise
        error('Only {second, minute, hour} granularities supported');
end

if requestedGran < timeGranularity
    error('Requested granularity cannot be submitted');
end

% Check if the abstraction function is supported

if (sum(strcmpi(requestedAbstraction, {'sum', 'mean', 'median', 'max', 'min', 'first'})) == 0)
    error('Only {sum, mean, median, max, min} optios are supported');
end

%% Apply the abstraction and provide a higher level granularity

% Find start time and end time
startTime = timeVec(1);
endTime = timeVec(end);

% Create the new time vector

if requestedGran == 1
    interval = 1/(24*60*60); % seconds
    columnIndx = 6;% column of datevec for SS
elseif requestedGran == 2
    interval = 1/(24*60); % minutes    
    columnIndx = 5;% column of datevec for MN
elseif requestedGran == 3
    interval = 1/24; % hourly 
    columnIndx = 4;% column of datevec for HH
elseif requestedGran == 4
    interval = 1; % daily    
    columnIndx = 3;% column of datevec for DD
elseif requestedGran == 5
    interval = 30; %monthly
    columnIndx = 2;% column of datevec for MM
end

iDate = datevec(startTime:interval:endTime);

% Apply the requested abstraction
switch requestedAbstraction
    case {'sum'}
        outputTS = granularityFcn(dataVec, iDate, datevec(timeVec), columnIndx, 'sum');
    case {'mean'}
        outputTS = granularityFcn(dataVec, iDate, datevec(timeVec), columnIndx, 'mean');
    case {'median'}
        outputTS = granularityFcn(dataVec, iDate, datevec(timeVec), columnIndx, 'median');
    case {'max'}
        outputTS = granularityFcn(dataVec, iDate, datevec(timeVec), columnIndx, 'max');
    case {'min'}
        outputTS = granularityFcn(dataVec, iDate, datevec(timeVec), columnIndx, 'min');
    case {'first'}
        outputTS = granularityFcn(dataVec, iDate, datevec(timeVec), columnIndx, 'first');
end

iDate = datetime(iDate);

function [outTSValue] = granularityFcn(tsValue, iDate, timeVec, columnIndx, abstractFn)

% For the granularity requested look through the iDate vector and find all
% values of timeVec and apply abstraction function
for iDatenum = 1:size(iDate, 1)
    granularityDatePick = iDate(iDatenum, 1:columnIndx);
    indxDepth = 1:size(timeVec, 1);
    for iCol = 1:columnIndx
        indxDepth = indxDepth(timeVec(indxDepth, iCol) == granularityDatePick(iCol));
    end
            
    switch abstractFn
        case 'sum'
            outTSValue(iDatenum) = sum(tsValue(indxDepth));
        case 'mean'
            outTSValue(iDatenum) = mean(tsValue(indxDepth));
        case 'median'
            outTSValue(iDatenum) = median(tsValue(indxDepth));
        case 'max'
            if isempty(indxDepth)
                outTSValue(iDatenum) = NaN;
            else
                outTSValue(iDatenum) = max(tsValue(indxDepth));
            end
        case 'min'
            if isempty(indxDepth)
                outTSValue(iDatenum) = NaN;
            else
                outTSValue(iDatenum) = min(tsValue(indxDepth));
            end
        case 'first'
            outTSValue(iDatenum) = max(tsValue(indxDepth, 1));            
    % now that we have the data, let us apply the abstraction function
    end    
end
   