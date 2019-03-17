%% Main Function: base station / RL agent
function [action,i_UE] = base_station(type,val_act,n_act,n_heads, num_UEs,eps,c,t)

    % Inputs:
    % -> val_act = action value estimates; assume that each entry
    % corresponds to single UE being promoted to a cluster head
    % -> num_heads = number of cluster heads to assign
    % -> num_UEs = number of UEs in network
    % -> eps = parameter for epsilon-greedy action
    % Outputs:
    % -> action = [a_1, a_2, ... a_n] where n=num_UEs, a_i in [0,1]
    
    % take UCB/epsilon-greedy action
    
    if(type == 0) 
        r=rand();
        action = (r>=eps) * greedy_action(val_act,n_heads,num_UEs) + ...
                 (r< eps) * random_action(n_heads,num_UEs);
             
    elseif (type == 1)
        action = UCB_action(val_act,n_act,c,n_heads,num_UEs,t);
    end
    
    i_UE=find(action==1);
end

%% Helper Function: UCB action
function action = UCB_action(val_act,n_act,c,n_heads,num_UEs,t)
    
    vals = val_act + (c .* sqrt(t./n_act));

    % TO-DO: Handle larger # of cluster heads
    action=zeros(1,num_UEs);
    i_action=find(vals==max(vals));
    
    if length(i_action) > 1
       i_action = i_action(randi(length(i_action)));
    end
    
    action(i_action)=1;
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

