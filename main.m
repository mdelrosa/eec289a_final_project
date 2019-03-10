%% Setup env
clear;
clc;

% environment parameters

radius = 500;   % base station radius
num_UE = 12;    % best to use multiples of 4
setup_type = 1; % cluster UEs for simulation
K_b = 3;        % multiplicative base-station parameter
K_u = 1;        % multiplicative UE parameter
K_f = 2;        % multiplicative fog node parameter
alpha_b = 1;    % exponential base-station parameter
alpha_u = 1;    % exponential UE parameter
alpha_f = 1;    % exponential fog node parameter
D_p1 = 1;       % normalized distance within which p(success) = 1.0
sigma2 = 2;     % variance of # of msgs sent by UEs around averages

world_x = radius*2;
world_y = radius*2;

% Generate a simulation world with given parameters
[coordinates, connectivity, avg_msgs] = init_world( ...
    setup_type, radius, num_UE, D_p1, K_b, K_u, K_f, alpha_b, alpha_u, alpha_f ...
);

%% Test init_world 
% plot_conn(coordinates,connectivity,world_x,world_y);

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
[~,head]=max(n_act);
plot_conn(coordinates,connectivity,world_x,world_y,head);
%% Testbed for helper functions
test=0;
if test
    % Test base station
    test_base(num_UE);

    % Test environment 
    test_environment(coordinates, connectivity, avg_msgs, sigma2);
end
