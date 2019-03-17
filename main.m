%% Setup env
clear;
clc;

% environment parameters

radius = 500;   % base station radius
num_UE = 40;    % best to use multiples of 4
setup_type = 1; % cluster UEs for simulation
r_f = 0.9;      % distance to center of clusters
r_c = 0.05;     % distribution of UEs around clusers
K_b = 37.6;     % multiplicative base-station parameter
K_u = 40;       % multiplicative UE parameter
K_f = 38.8;     % multiplicative fog node parameter
C_b = 15.3;     % exponential base-station parameter
C_u = 28;       % exponential UE parameter
C_f = 21.65;    % exponential fog node parameter
sigma2 = 50;   % variance of # of msgs sent by UEs around averages

params = [radius, num_UE, setup_type, K_b, K_u, K_f, C_b, C_u, C_f, r_f, r_c];

world_x = radius*2;
world_y = radius*2;

% Generate a simulation world with given parameters
[coordinates, connectivity, avg_msgs] = init_world(params);


%% Test init_world 
%plot_conn(coordinates,connectivity,world_x,world_y);
% test_environment(coordinates, connectivity, avg_msgs, sigma2, radius);
%return;

%% episode iteration
use_UCB = 1;
epi_count=1;
n_heads=1;
epi_lim=500;
eps=0.1;
alpha=0.01;
run_count=1;
run_lim=2000;
optimal_action=1; % optimal action based on cluster setup
c = 2;

[c_x, c_y, eps_x, eps_y] = find_optimal(num_UE,connectivity, avg_msgs, sigma2);

figure(4); clf;
semilogx(c_x,c_y); hold on;
semilogx(eps_x,eps_y);
legend('UCB','epsilon');
hold off;

[run_actions, run_val_act, run_rewards, val_act, heads, rewards, n_act] = ...
    rl_iteration(use_UCB,eps,c,run_lim,epi_lim,num_UE,connectivity, avg_msgs, sigma2);

[run_actionsB, run_val_actB, run_rewardsB, val_actB, headsB, rewardsB, n_actB] = ...
    rl_iteration(~use_UCB,eps,c,run_lim,epi_lim,num_UE,connectivity, avg_msgs, sigma2);


%% Find avg run performance
avg_opt_act=zeros(1,epi_lim);
avg_val_act=zeros(1,num_UE);

avg_opt_actB=zeros(1,epi_lim);
avg_val_actB=zeros(1,num_UE);

for i=(1:epi_lim)
    avg_opt_act(i)=length(find(run_actions(:,i)==optimal_action))/run_lim;
    avg_opt_actB(i)=length(find(run_actionsB(:,i)==optimal_action))/run_lim;
end
for i=(1:num_UE)
   avg_val_act(i)=mean(run_val_act(:,i));
   avg_val_actB(i)=mean(run_val_actB(:,i));
end

%% Plot avg % optimal action
figure(5);clf;hold on;
% subplot(2,1,1);
plot(avg_opt_actB); hold on;
plot(avg_opt_act);
title("Average Optimal Cluster Head");
xlabel("Step [#]");
ylabel("Optimal Action [%]");
legend("$\varepsilon$-greedy: $\varepsilon=0.1$","UCB: $c = 2$","Interpreter","latex","Location","southeast");
% figure(6);clf;hold on;
% subplot(2,1,2);hold on;
% stem(avg_val_actB);
% stem(avg_val_act);
% title("Action Value");
% xlabel("UE [#]");
% ylabel("Avg Action Value");
% legend("$\varepsilon=0.1$","Interpreter","latex");

%% plot results over time for latest episode
figure(2);clf;hold on;
subplot(3,1,1);
plot((1:epi_lim),heads);
subplot(3,1,2);hold on;
% stem((1:num_UE),n_act);
stem((1:num_UE),avg_msgs);
stem((1:num_UE),val_act);
legend('Avg Msgs', 'Action Values');
subplot(3,1,3);
plot((1:epi_lim),rewards);hold on;
plot((1:epi_lim),rewardsB);hold on;
[~,head]=max(n_act);
% plot_conn(coordinates,connectivity,world_x,world_y,head);
% figure(3);
% surf(connectivity);
% colorbar;

%% Testbed for helper functions
% test=0;
% if test
%     % Test base station
%     test_base(num_UE);
% 
%     % Test environment 
%     test_environment(coordinates, connectivity, avg_msgs, sigma2, radius);
% end
