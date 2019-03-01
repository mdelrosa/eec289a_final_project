clear;
clc;

% parameters
world_x = 10;
world_y = 10;
num_UE = 15;
base_station_gain = 2; % base station has double strength

[coordinates, connectivity] = init_world(world_x, world_y, num_UE, base_station_gain);

% plots all UEs in space with lines showing strongest
% connection to a given UE
plot_conn(coordinates,connectivity,world_x,world_y);

