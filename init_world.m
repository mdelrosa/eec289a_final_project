function [coordinates, connectivity] = init_world(X_size, Y_size, num_UEs, K_b)

    % |CX| = [num_UEs + 1, 2]  => (x1,y1); (x2,y2); ... 
    % |conn_mx| = [num_UEs + 1, num_UEs + 1]
    
    len = num_UEs + 1;
    
    % preallocate arrays
    coordinates = zeros(len, 2);
    connectivity = zeros(len,len);
    
    % place basestation in the center
    coordinates(1,:) = [X_size/2, Y_size/2];
    
    % generate random coordinates for UEs
    for i = 2:num_UEs+1
        coordinates(i,:) = [coordinates; rand()*X_size, rand()*Y_size];
    end
    
    % compute connectivity
    for i = 1:l
    for j = 1:l
        d = compute_connectivity(coordinates(i,1),coordinates(i,2), ...
                                 coordinates(j,1),coordinates(j,2), ...
                                 (i == 1 || j == 1), K_b);
        
        connectivity(i,j) = d;
    end
    end
end


function d = compute_connectivity(x1,y1,x2,y2, to_base, K_b)
    
    % connectivity is inversely proportional to distance
    d = sqrt((x1 - x2).^2 + (y1 - y2).^2);
    d = 1/d;
    
    % don't want inf messing up max connectivities
    if(d == inf)
        d = 0;
    end
    
    % base station connectivity parameter
    if (to_base)
        d = d * K_b;
    end
end

