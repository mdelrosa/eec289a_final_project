%% Setup env
clear;
clc;

% environment parameters
world_x = 10;
world_y = 10;
num_UE = 50;
K_b = 2;        % multiplicative base-station parameter
K_u = 1;        % multiplicative UE parameter
alpha_b = 1;    % exponential base-station parameter
alpha_u = 1;    % exponential UE parameter
D_p1 = 1;       % normalized distance within which p(success) = 1.0

% Generate a simulation world with given parameters
[coordinates, connectivity] = init_world(world_x, world_y, num_UE, ...
                                         D_p1, K_b, K_u, alpha_b, alpha_u);

%% plots all UEs in space with lines showing strongest
% connection to a given UE
plot_conn(coordinates,connectivity,world_x,world_y);

%% Test base station
val_act=randi(num_UE,1,num_UE);
val_act(floor(num_UE/2))=num_UE+1;
n_heads=1; % should be able to choose more cluster heads eventually; set to 1 for now
epi_count=1;
epi_lim=500;
eps=0.1;
actions=zeros(1,epi_lim); % preallocate action log vector
% for now, use fixed act_val estimate to test out base_station
while epi_count <= epi_lim
    actions(epi_count) = find(base_station(val_act, n_heads, num_UE,eps)==1);
    epi_count=epi_count+1;
end
%% Plot action selected per episode on eps-greedy basis.
figure(2);clf;hold on;
plot((1:epi_lim),actions);
title('Cluster Head Selection');
xlabel('Episode #');
ylabel('Cluster Head');
