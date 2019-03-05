function [CX, conn_mx, avg_msgs] = init_world(X_size, Y_size, num_UEs, D_p1, K_b, K_u, alpha_b, alpha_u)

    % |CX| = [num_UEs + 1, 2]  => (x1,y1); (x2,y2); ...
    % |conn_mx| = [num_UEs + 1, num_UEs + 1]
    % base station index = 1
   
    % assert some input conditions
    assert(alpha_b > 0 && alpha_u > 0 && ...
           K_b > 0 && K_u > 0 && ...
           X_size > 0 && Y_size > 0, ...
           'Parameters must be positive');
    
    assert(num_UEs > 1, 'Must have at least one UE');
    
    CX = zeros(num_UEs,2);
    
    % place base station in the center
    CX(1,:) = [X_size/2, Y_size/2];
    
    % randomly distribute UEs
    for i = 1:num_UEs
        CX(i,:) = [rand()*X_size, rand()*Y_size];
    end
    
    % # of average messages ranges from [0,1000]
    avg_msgs = randi(1001,num_UEs,1) - 1;
    
    % initialize connectivity matrix
    l = size(CX,1);
    conn_mx = zeros(l,l);
    
    for i = 1:l
    for j = 1:l
        
        if(i ~= j)
            
            d = distance_inv(CX(i,1),CX(i,2),CX(j,1),CX(j,2));
            
            % account for max distance of p(success) = 1
            d = d / D_p1;
            
            % avoid inf
            if(d == inf)
                d = 0;
            end
            
            % apply scaling and exponent params
            if (i == 1 || j == 1)
                d = (d .^ alpha_b) * K_b;
                
                % apply scaled truncation for distances within D_p1
                if(d > D_p1 * K_b)
                    d = D_p1 * K_b;
                end
                
            else
                d = (d .^ alpha_u) * K_u;
                
                % apply scaled trunctation for distances within D_p1
                if(d > D_p1 * K_u)
                    d = D_p1 * K_u;
                end
            end
            
            % make sure all results are within [0,1]
            d = d / (D_p1 * max(K_b, K_u));

            conn_mx(i,j) = d;
        end
    end
    end
end

function d = distance_inv(x1,y1,x2,y2)
    
    % connectivity is inversely proportional to distance
    d = sqrt((x1 - x2).^2 + (y1 - y2).^2);
    d = 1/d;
    
end
