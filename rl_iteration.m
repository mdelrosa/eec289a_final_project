function [run_actions, run_val_act, run_rewards, val_act, heads, rewards, n_act] = rl_iteration(type,epsilon,c,runs,steps,num_UE,connectivity, avg_msgs, sigma2)
    
    n_heads=1;
    run_count=1;
    
    epi_lim=steps;
    eps=epsilon;
    run_lim=runs;
    
    run_actions=zeros(run_lim,epi_lim);
    run_val_act=zeros(run_lim,num_UE);
    run_rewards=zeros(run_lim,epi_lim);
    
    
    for run_count = 1:run_lim
    
        % progress report
        if mod(run_count,100)==0
            fprintf("Run #%d\n",run_count);
        end
        
        % initialize run
        epi_count=1;
        
        % allocations for run
        val_act = ones(1,num_UE) * (500*(num_UE/4));  %optimistic start
        n_act=zeros(1,num_UE);      % # of times action was taken
        actions=zeros(1,epi_lim);   % preallocate action log vector
        rewards=zeros(1,epi_lim);
        heads=zeros(1,epi_lim);
        
        
        while (epi_count < epi_lim)
            
            % values -> action -> reward
            [action, i_UE] = base_station(type,val_act,n_act,n_heads, num_UE, eps,c,epi_count);
            [reward, ~] = environment(action, connectivity, avg_msgs, sigma2);
            
            % update values and counts
            n_act(i_UE) = n_act(i_UE) + 1;
            val_act(i_UE) = val_act(i_UE) + (1/n_act(i_UE))*(reward-val_act(i_UE));
            epi_count = epi_count + 1;
            
            % track results
            actions(epi_count) = i_UE; % keep track of which UE we chose
            rewards(epi_count) = reward;
            heads(epi_count) = i_UE;
        end
        
        % track results over runs
        run_actions(run_count,:) = actions;
        run_val_act(run_count,:) = val_act;
        run_rewards(run_count,:) = rewards;
        % increment counter
        run_count = run_count + 1;

    end
end
