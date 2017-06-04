%% Config
total_WRKF.sensor15cmWRKF_kPa = (total_WRKF.sensor15cmWRKF-550)./137.5;
total_WRKF.sensor45cmWRKF_kPa = (total_WRKF.sensor45cmWRKF-550)./137.5;
total_WRKF.sensor75cmWRKF_kPa = (total_WRKF.sensor75cmWRKF-550)./137.5;

sensor15cmfusedESD_kPa = (sensor15cmfusedESD-550)./137.5;
sensor45cmfusedESD_kPa = (sensor45cmfusedESD-550)./137.5;
sensor75cmfusedESD_kPa = (sensor75cmfusedESD-550)./137.5;

%% 15cm
figure;

plot(tensiometro1.when,tensiometro1.d15cm);
hold on;
plot(tensiometro2.when,tensiometro2.d15cm);
plot(tensiometro4.when,tensiometro4.d15cm);
plot(tensiometro5.when,tensiometro5.d15cm);

plot(total_WRKF.dateRange,total_WRKF.sensor15cmWRKF_kPa,'r*');
plot(dateRange, sensor15cmfusedESD_kPa, 'bo');

%% 45cm
figure;

plot(tensiometro1.when,tensiometro1.d45cm);
hold on;
plot(tensiometro2.when,tensiometro2.d45cm);
plot(tensiometro4.when,tensiometro4.d45cm);
plot(tensiometro5.when,tensiometro5.d45cm);

plot(total_WRKF.dateRange,total_WRKF.sensor45cmWRKF_kPa,'r*');
plot(dateRange, sensor45cmfusedESD_kPa, 'bo');

%% 75cm
figure;

plot(tensiometro1.when,tensiometro1.d75cm);
hold on;
plot(tensiometro2.when,tensiometro2.d75cm);
plot(tensiometro4.when,tensiometro4.d75cm);
plot(tensiometro5.when,tensiometro5.d75cm);

plot(total_WRKF.dateRange,total_WRKF.sensor75cmWRKF_kPa,'r*');
plot(total_WRKF.dateRange, sensor75cmfusedESD_kPa, 'bo');