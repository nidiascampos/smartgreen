# ajuste dos dados
sensor1meanT = sensor1mean'

# modified Z-score
[MZscore MZmax MZoutlier MZoutnum] = mzscore(sensor1meanT,x_date)

% data (y value for plotting)
mzplot = []
for i = 1:size(boxOUTnum,1)
    mzplot = [mzplot; sensor1meanT(boxOUTnum(i,1),boxOUTnum(i,2))]
end

% time (x value for plotting)
boxOUTtime = boxOUT(:,1)
t = datetime(boxOUTtime)

% plot
adjboxplotGraph = figure
hold on
semilogy(node1.time,sensor1meanT)
semilogy(t,mzplot,'LineStyle','none','Marker','o','MarkerEdgeColor','red')
hold off


# adjusted box plot
[boxQ1 boxQ3 boxMC boxOUT boxOUTnum] = adjboxplot(sensor1meanT,x_date,1.5)
sensor1meanT(boxOUTnum(5,1),boxOUTnum(5,2))

% data (y value for plotting)
boxOUTplot = []
for i = 1:size(boxOUTnum,1)
    boxOUTplot = [boxOUTplot; sensor1meanT(boxOUTnum(i,1),boxOUTnum(i,2))]
end

% time (x value for plotting)
boxOUTtime = boxOUT(:,1)
t = datetime(boxOUTtime)

% plot
adjboxplotGraph = figure
hold on
semilogy(node1.time,sensor1meanT)
semilogy(t,boxOUTplot,'LineStyle','none','Marker','o','MarkerEdgeColor','red')
hold off