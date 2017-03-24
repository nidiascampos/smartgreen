%% Interpolate Missing Points Using thingSpeakRead
% This example shows how to retrieve data from ThingSpeak.com and
% interpolate missing points in the time series.
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Download the data
% View channel information.

[~,~,channelInfo] = thingSpeakRead(12397);
channelInfo

%%
% The channel information includes:
%
% * Name of the channel
% * Channel description
% * Date of creation
% * Date of last update
% * Last entry ID
% * Field descriptions
% * Associated Field IDs
%
% Let us read the last 20 points of the data 3rd field (% Humidity) of
% this channel.

[data,timestamps] = thingSpeakRead(12397, 'NumPoints', 20, 'Fields', 3);

%% Examine the data
% Retrieve the timestamps and notice gaps in time between each timestamp.

timeBetweenTimestamps = diff(timestamps)

%%
% The data shows inconsistent sample spacing. It also shows some missing data points. Plot the data.

figure
plot(timestamps,data,'ob-')
title(sprintf('ThingSpeak Channel %d\n%s',channelInfo.ChannelID,channelInfo.Name))
xlabel('Time')
ylabel('Value')
legend(channelInfo.FieldDescriptions{3}, 'Location','best');
axis tight
%%
% Interpolate and resample the data for a consistent sample spacing.

%% Create the new timestamp vector for the interpolated data
% To interpolate the data, create a new timestamp vector with equal spacing
% between timestamps using LINSPACE. Set the spacing to be equal to the
% minimum spacing between the times in the original timestamp vector.

timestampsInterp = timestamps(1):min(diff(timestamps)):timestamps(end)

%%
% The result shows consistent timestamp spacing.

diff(timestampsInterp)

%% Interpolate the data
% Use INTERP1 to resample and interpolate the data on the new timestamp vector.

dataInterp = interp1(datenum(timestamps),data,datenum(timestampsInterp).');

%% Plot the original and interpolated data
% Plot the original and interpolated data.

figure
hold on
plot(timestamps,data,'o')
plot(timestampsInterp,dataInterp,'r.-')
hold off
title(sprintf('ThingSpeak Channel %d\n%s',channelInfo.ChannelID,channelInfo.Name))
xlabel('Time')
ylabel('Value')
legend(channelInfo.FieldDescriptions{3},sprintf('%s Interpolated',channelInfo.FieldDescriptions{3}),'Location','best')
axis tight
