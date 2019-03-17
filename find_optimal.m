function [c_x,c_y,eps_x,eps_y] = find_optimal(num_UE,connectivity, avg_msgs, sigma2)

use_UCB = 1;
epi_lim=500;
run_lim=1;

n_trials = 2000;

c = 2;
eps=0.1;

c_array = 1:0.2:4;
eps_array = 0.01:0.01:0.25;
c_avg = zeros(size(c_array));
eps_avg = zeros(size(eps_array));

for i = 1:length(c_array)
   c_avg(i) = avg_reward(n_trials,use_UCB,eps,c_array(i),run_lim,epi_lim,num_UE,connectivity, avg_msgs, sigma2);
   disp(i/(2*length(c_array)));
end

for i = 1:length(eps_array)
   eps_avg(i) = avg_reward(n_trials,use_UCB,eps_array(i),c,run_lim,epi_lim,num_UE,connectivity, avg_msgs, sigma2);
   disp((i+length(c_array))/(2*length(c_array)));
end

c_x = c_array;
eps_x = eps_array;
c_y = c_avg;
eps_y = eps_avg;
end


%% Helper function: Find avg reward

function avg = avg_reward(n_trials,use_UCB,eps,c,run_lim,epi_lim,num_UE,connectivity, avg_msgs, sigma2)

avg = 0;
for i = 1:n_trials

    [a0, a1, a2, a3, rewards, a4] = ...
    rl_iteration(use_UCB,eps,c,run_lim,epi_lim,num_UE,connectivity, avg_msgs, sigma2);

    avg = avg + mean(rewards);
    
%     if(mod(i,10) == 0)
%         disp((i/(n_trials*2))*100);
%     end

end
avg = avg / n_trials;

end
