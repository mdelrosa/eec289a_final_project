function [CX, conn_mx] = init_world(X_size, Y_size, num_UEs, K_b)

    % |CX| = [num_UEs + 1, 2]  => (x1,y1); (x2,y2); ... 
    % |conn_mx| = [num_UEs + 1, num_UEs + 1]
    
    % place basestation in the center
    CX = [X_size/2, Y_size/2];
    
    for i = 1:num_UEs
        CX = [CX; rand()*X_size, rand()*Y_size];
    end
    
    l = size(CX,1);
    
    conn_mx = zeros(l,l);
    
    for i = 1:l
    for j = 1:l
        d = distance(CX(i,1),CX(i,2),CX(j,1),CX(j,2));
        if (i == 1 || j == 1)
            d = d * K_b;
        end
        conn_mx(i,j) = d;
    end
    end
end


function d = distance(x1,y1,x2,y2)
    d = sqrt((x1 - x2).^2 + (y1 - y2).^2);
    d = 1/d;
    if(d == inf)
        d = 0;
    end
end

