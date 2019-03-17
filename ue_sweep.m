% ue_sweep.m

%% Setup env
clear;
clc;

% environment parameters

radius = 500;   % base station radius
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

world_x = radius*2;
world_y = radius*2;

%% Iterate over number of UEs, compare system throughput
use_UCB = 1;
epi_count=1;
n_heads=1;
epi_lim=500;
eps=0.1;
alpha=0.01;
run_count=1;
run_lim=500;
optimal_action=1; % optimal action based on cluster setup
c = 2;

num_UEs=(20:4:100);
rewards_eps=zeros(1,length(num_UEs));
rewards_ucb=zeros(1,length(num_UEs));
rewards_rand=zeros(1,length(num_UEs));
i=1;
for n=(20:4:100)
    fprintf('Number of UEs: %d\n',n);
    params = [radius, n, setup_type, K_b, K_u, K_f, C_b, C_u, C_f, r_f, r_c];
    % Generate a simulation world with given parameters
    [coordinates, connectivity, avg_msgs] = init_world(params);

%     [c_x, c_y, eps_x, eps_y] = find_optimal(num_UE,connectivity, avg_msgs, sigma2);
    fprintf('->UCB for %d UEs\n',n);
    [run_actions, run_val_act, run_rewards, val_act, heads, rewards, n_act] = ...
        rl_iteration(use_UCB,eps,c,run_lim,epi_lim,n,connectivity, avg_msgs, sigma2);
    fprintf('->Epsilon-Greedy for %d UEs\n',n);
    [run_actionsB, run_val_actB, run_rewardsB, val_actB, headsB, rewardsB, n_actB] = ...
        rl_iteration(~use_UCB,eps,c,run_lim,epi_lim,n,connectivity, avg_msgs, sigma2);
    fprintf('->Random for %d UEs\n',n);
    [run_actionsC, run_val_actC, run_rewardsC, val_actC, headsC, rewardsC, n_actC] = ...
        rl_iteration(2,eps,c,run_lim,epi_lim,n,connectivity, avg_msgs, sigma2);

    rewards_ucb(i)=mean(rewards);
    rewards_eps(i)=mean(rewardsB);
    rewards_rand(i)=mean(rewardsC);
    i=i+1;
end

%% Plot average rewards for different num_UE
figure(1);clf;hold on;
plot(num_UEs,rewards_ucb);
plot(num_UEs,rewards_eps);
plot(num_UEs,rewards_rand);
legend('Epsilon-greedy ($\varepsilon=0.1$)','UCB ($c=2.0$)','Random Allocation',"Interpreter","latex","Location","northwest");
xlabel('Number of UEs');
ylabel('Average Reward/Step');