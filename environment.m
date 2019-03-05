function [reward, selection] = environment(action,connectivity,avg_msgs,sigma2)
    
    % find number of UEs 
    num_UE = length(connectivity) - 1;
    
    % make sure inputs are row-vectors
    action = reshape(action,[1,length(action)]);
    avg_msgs = reshape(avg_msgs,[1,length(avg_msgs)]);

    % Sanity check dimensions
    assert(length(action) == num_UE, 'action and connectivity dimensions do not agree');
    assert(length(avg_msgs) == num_UE, 'action and connectivity dimensions do not agree');
    
    % find number of messages sent at this time-step
    messages = generate_messages(avg_msgs,sigma2);
    
    % select heads, including base-station
    heads = [1, find(action) + 1];          % offset for base-station
    choices = connectivity(heads,2:num_UE+1);
    
    % multiply connectivity through head by head connectivity
    if(length(heads) > 1)
        
        % remove other heads from selection to update connectivities
        selectors = 2:num_UE+1;
        selectors(heads(2:length(heads))) = [];
        selectors = selectors - 1;
        
        for i = 2:length(heads)
            choices(i,selectors) = choices(i,selectors) * connectivity(1,heads(i)); 
        end
    end
    
    % pick best connectivities
    [best, selection] = max(choices,[],1);
    
    % multiply by #messages and sum (vector mult)
    reward = best * messages';
    
    % sanity check
    assert(isequal(size(reward),[1 1]), 'reward isnt a single number!');
end

function messages = generate_messages(avg_msgs,sigma2)

    % add sigma2 variance to avg and round
    messages = round(randn(size(avg_msgs))*sigma2) + avg_msgs;
    
    % don't send negative amount of messages
    for i = 1:length(avg_msgs)
        if (messages(i) < 0)
            messages(i) = 0;
        end
    end
end