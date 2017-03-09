% assign data to vars
sensor1 = sensor1fusedESD';
sensor2 = sensor2fusedESD';
sensor3 = sensor3fusedESD';
% python list objects
scale_space01 = py.scale_space.run(sensor1,3);
scale_space02 = py.scale_space.run(sensor2,3);
scale_space03 = py.scale_space.run(sensor3,3);
% convert to matlab array
temp = cell(scale_space01);
scale_space01 = cellfun(@double,temp)';
temp = cell(scale_space02);
scale_space02 = cellfun(@double,temp)';
temp = cell(scale_space03);
scale_space03 = cellfun(@double,temp)';
% save variables to file
save('data/scale_space.mat','scale_space01','scale_space02','scale_space03');