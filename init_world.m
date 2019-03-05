function [CX, conn_mx] = init_world(X_size, Y_size, num_UEs, K_b, K_u, alpha_b, alpha_u)

    % |CX| = [num_UEs + 1, 2]  => (x1,y1); (x2,y2); ... 
    % |conn_mx| = [num_UEs + 1, num_UEs + 1]
   
    % assert some input conditions
    assert(alpha_b > 0 && alpha_u > 0 && ...
           K_b > 0 && K_u > 0 && ...
           X_size > 0 && Y_size > 0, ...
           'Parameters must be positive');
       
    assert(num_UEs > 1, 'Must have at least one UE');
       
    % place base station in the center
    CX = [X_size/2, Y_size/2];
    
    % randomly distribute UEs
    for i = 1:num_UEs
        CX = [CX; rand()*X_size, rand()*Y_size];
    end
    
    % initialize connectivity matrix
    l = size(CX,1);
    conn_mx = zeros(l,l);
    
    for i = 1:l
    for j = 1:l
        
        if(i ~= j)
            
            d = distance_inv(CX(i,1),CX(i,2),CX(j,1),CX(j,2));

            % apply scaling and exponent params
            if (i == 1 || j == 1)
                d = (d .^ alpha_b) * K_b;
                if(d > K_b)
                    d = K_b;
                end
                d  = d / K_b;
            else
                d = (d .^ alpha_u) * K_u;
            end
            
            % 

            conn_mx(i,j) = d;
            
        end
    end
    end
end


function d = compute_connectivity(x1,y1,x2,y2, to_base, K_b)
    
    % connectivity is inversely proportional to distance
    d = sqrt((x1 - x2).^2 + (y1 - y2).^2);
    d = 1/d;
    
    % just in-case, don't want inf's
    % messing up the max
    if(d == inf)
        d = 0;
    end
    
    % base station connectivity parameter
    if (to_base)
        d = d * K_b;
    end
end

