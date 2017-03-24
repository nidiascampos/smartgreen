function dayIndx = dayGroups(timestamps)
% Label the input timestamps into a day index.
% The input timestamps have to be MATLAB(R) datetime type.

%   Copyright 2015 The MathWorks, Inc.

% If input is not datetime type then generate error.
if ~isdatetime(timestamps)
    error('Please provide timestamps input as a datetime array');
end

% Find the days in the vector

dayTimeStamps = datetime(timestamps.Year, timestamps.Month, timestamps.Day);

% Find the unique days in dayTimeStamps

uniqueDayTimeStamps = unique(dayTimeStamps);

% For each element of uniqueDayTimeStamps, index the values in
% dayTimeStamps
dayIndx = zeros(size(timestamps));
for iDays = 1:numel(uniqueDayTimeStamps)
   dayIndx(dayTimeStamps == uniqueDayTimeStamps(iDays)) = iDays;
end
