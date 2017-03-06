function [z,t] = createTerrain()


slope1 = linspace(100,0);
time1 = 0:99;
slope2 = zeros(1,50);
time2 = 100:149;
slope3 = linspace(0,45,20);
time3 = 150:169;
slope4 = ones(1,20)*45;
time4 = 170:189;
slope5 = linspace(45,0,30);
time5 = 190:219;
slope6 = linspace(0,90,80);
time6 = 220:299;

z = [slope1 slope2 slope3 slope4 slope5 slope6];
t = [time1 time2 time3 time4 time5 time6];