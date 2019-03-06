%% Setup env
clear;
clc;

% environment parameters
world_x = 10;
world_y = 10;
num_UE = 50;
K_b = 1.5;        % multiplicative base-station parameter
K_u = 1;        % multiplicative UE parameter
alpha_b = 1;    % exponential base-station parameter
alpha_u = 1;    % exponential UE parameter
D_p1 = 1;       % normalized distance within which p(success) = 1.0
sigma2 = 2;     % variance of # of msgs sent by UEs around averages


% Generate a simulation world with given parameters
[coordinates, connectivity, avg_msgs] = init_world(world_x, world_y, num_UE, ...
                                         D_p1, K_b, K_u, alpha_b, alpha_u);

%% Test init_world 
plot_conn(coordinates,connectivity,world_x,world_y);

%% Test base station
test_base(num_UE);

%% Test environment 
test_environment(coordinates, connectivity, avg_msgs, sigma2);
