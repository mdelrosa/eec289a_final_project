%% Main Function: base station / RL agent
function [action,i_UE] = base_station(val_act, n_heads, num_UEs,eps)

    % Inputs:
    % -> val_act = action value estimates; assume that each entry
    % corresponds to single UE being promoted to a cluster head
    % -> num_heads = number of cluster heads to assign
    % -> num_UEs = number of UEs in network
    % -> eps = parameter for epsilon-greedy action
    % Outputs:
    % -> action = [a_1, a_2, ... a_n] where n=num_UEs, a_i in [0,1]
    
    % take epsilon-greedy action
    r=rand();
    action = (r>=eps)*greedy_action(val_act,n_heads,num_UEs)+(r<eps)*random_action(n_heads,num_UEs);
    i_UE=find(action==1);
end
%% Helper Function: greedy action
function action = greedy_action(val_act,n_heads,num_UEs)
    % TO-DO: Handle larger # of cluster heads
    action=zeros(1,num_UEs);
    i_action=find(val_act==max(val_act));
    if length(i_action) > 1
       i_action = i_action(randi(length(i_action)));
    end
    action(i_action)=1;
end
%% Helper Function: random action for epsilon greedy
function action = random_action(n_heads,num_UEs)
    % TO-DO: Handle larger # of cluster heads
    action=zeros(1,num_UEs);
    r=randi(num_UEs);
    action(r)=1;
end

