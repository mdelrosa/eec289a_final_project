function reward = environment(action,connectivity,avg_msgs,sigma2)

    num_UE = length(connectivity) - 1;
    
    % make sure inputs are row-vectors
    action = reshape(action,[1,length(action)]);
    avg_msgs = reshape(avg_msgs,[1,length(avg_msgs)]);

    % find number of messages sent at this time-step
    messages = generate_messages(avg_msgs,sigma2);
    
    % select heads, including base-station
    heads = [1, find(action) + 1];          % offset for base-station
    choices = connectivity(heads,2:num_UE);
    
    % multiply connectivity through head by head connectivity
    if(length(heads) > 1)
        for i = 2:length(heads)
            choices(i,:) = choices(i,:) * connectivity(1,heads(i)); 
        end
    end
    
    % pick best connectivities
    best = max(choices,[],1);
    
    % multiply by #messages and sum (vector mult)
    reward = best * messages';
    
    % sanity check
    assert(isequal(size(reward),[1 1]), 'reward isnt a single number!');
end

function messages = generate_messages(avg_msgs,sigma2)

    % add sigma2 variance to avg and round
    messages = round(rand(size(avg_msgs))*sigma2) + avg_msgs;
    
    % don't send negative amount of messages
    for i = 1:length(avg_msgs)
        if (messages(i) < 0)
            messages(i) = 0;
        end
    end
end