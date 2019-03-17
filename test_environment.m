function test_environment(coordinates,connectivity, avg_msgs, sigma2, radius)

    num_UE = length(connectivity) - 1;
    
    mx = 0;
    index = 0;
    
    rs = zeros(1,num_UE);
    users = zeros(1,num_UE);
    
    for i = 1:num_UE
        action = zeros(1,num_UE);
        action(i) = 1;
        
        [r, selection] = environment(action,connectivity,avg_msgs,sigma2);
        rs(i) = r;
        count = length(find(selection > 1));
        users(i) = count;
        
        if(count > mx)
            mx = count;
            index = i;
        end
    end
    
    if(index == 0)
        disp('Resorting to default index = 1');
        index = 1;
    end
    
    disp(index);
    action = zeros(1,num_UE);
    action(index) = 1;
    
    [~, selection] = environment(action,connectivity,avg_msgs,sigma2);
    
    figure(4);clf;hold on;
    
    % plot all points
    for p = 1:length(coordinates)
        x = coordinates(p,1);
        y = coordinates(p,2);
        plot(x,y,'o');
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
    plot(coordinates(other,1),coordinates(other,2),'*');
    title('Plot of Best Cluster Head Assignment');
    ylim([0 (2*radius)]);
    xlim([0 (2*radius)]);
    hold off;
    
    figure(5);clf;hold on;
    subplot(2,1,1);
    stem(rs);
    title('throughput vs cluster head assignment');
    subplot(2,1,2);
    stem(users);
    title('size of cluster vs cluster head assignment');
    hold off;

end

