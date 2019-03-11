%% Setup env
clear;
clc;

% environment parameters

radius = 500;   % base station radius
num_UE = 24;    % best to use multiples of 4
setup_type = 1; % cluster UEs for simulation
r_f = 0.9;      % distance to center of clusters
r_c = 0.05;     % distribution of UEs around clusers
K_b = 37.6;     % multiplicative base-station parameter
K_u = 40;       % multiplicative UE parameter
K_f = 38.8;     % multiplicative fog node parameter
C_b = 15.3;     % exponential base-station parameter
C_u = 28;       % exponential UE parameter
C_f = 21.65;    % exponential fog node parameter
sigma2 = 2;     % variance of # of msgs sent by UEs around averages

params = [radius, num_UE, setup_type, K_b, K_u, K_f, C_b, C_u, C_f, r_f, r_c];

world_x = radius*2;
world_y = radius*2;

% Generate a simulation world with given parameters
[coordinates, connectivity, avg_msgs] = init_world(params);


%% Test init_world 
%plot_conn(coordinates,connectivity,world_x,world_y);
test_environment(coordinates, connectivity, avg_msgs, sigma2);
return;

%% episode iteration
val_act=ones(1,num_UE)*1200;
n_act=zeros(1,num_UE); % # of times action was taken
epi_count=1;
n_heads=1;
epi_lim=500;
eps=0.1;
alpha=0.01;
actions=zeros(1,epi_lim); % preallocate action log vector
rewards=zeros(1,epi_lim);
heads=zeros(1,epi_lim);
while epi_count<epi_lim
	[action,i_UE]=base_station(val_act, n_heads, num_UE,eps);
	[reward,selection]=environment(action,connectivity,avg_msgs,sigma2);
    n_act(i_UE)=n_act(i_UE)+1;
%     val_act(i_UE)=val_act(i_UE)+(1/n_act(i_UE))*(reward-val_act(i_UE)/n_act(i_UE));
    val_act(i_UE)=val_act(i_UE)+alpha*(reward-val_act(i_UE)/n_act(i_UE));
	epi_count=epi_count+1;
    actions(epi_count)=i_UE; % keep track of which UE we chose
    rewards(epi_count)=reward;
    heads(epi_count)=i_UE;
end
%% plot results over time
figure(2);clf;hold on;
subplot(3,1,1);
plot((1:epi_lim),heads);
subplot(3,1,2);hold on;
% stem((1:num_UE),n_act);
stem((1:num_UE),avg_msgs);
stem((1:num_UE),val_act);
legend('Avg Msgs', 'Action Values');
subplot(3,1,3);
plot((1:epi_lim),rewards);
figure(3);
surf(connectivity);
colorbar;
plot_conn(coordinates,connectivity,world_x,world_y,i_UE);
%% Testbed for helper functions
test=0;
if test
    % Test base station
    test_base(num_UE);

    % Test environment 
    test_environment(coordinates, connectivity, avg_msgs, sigma2);
end
