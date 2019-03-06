function test_environment(coordinates,connectivity, avg_msgs, sigma2)

    num_UE = length(connectivity) - 1;
    
    mx = 0;
    index = 0;
    
    for i = 1:num_UE
        action = zeros(1,num_UE);
        action(i) = 1;
        
        [~, selection] = environment(action,connectivity,avg_msgs,sigma2);
        
        count = length(find(selection > 1));
        
        if(count > mx)
            mx = count;
            index = i;
        end
    end
    
    disp(index);
    action = zeros(1,num_UE);
    action(index) = 1;
    
    [~, selection] = environment(action,connectivity,avg_msgs,sigma2);
    
    figure(3);clf;hold on;
    
    % plot all points
    for p = 1:length(coordinates)
        x = coordinates(p,1);
        y = coordinates(p,2);
        plot(x,y,'-o');
        hold on;
    end
    
    % plot connections within cluster
    for i = find(selection > 1)
        other = selection(i);
        x = [coordinates(i+1,1), coordinates(other,1)];
        y = [coordinates(i+1,2), coordinates(other,2)];
        plot(x,y,'-o');
        hold on;
    end
    hold off;
    

end

