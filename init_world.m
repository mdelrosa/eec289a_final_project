function [coordinates, connectivity, avg_msgs] = init_world(type, radius, num_UEs, D_p1, K_b, K_u, K_f, alpha_b, alpha_u, alpha_f)

    % assert some input conditions
    assert(alpha_b > 0 && alpha_u > 0 && ...
           K_b > 0 && K_u > 0 && ...
           radius > 0, ...
           'Parameters must be positive');
    
    if(type == 0)
        [coordinates, heads, avg_msgs] = uniform_init(radius * 2, radius * 2, num_UEs);
    elseif(type == 1)
        [coordinates, heads, avg_msgs] = cluster_init(radius, num_UEs);
    end
    
    % compute connectivity
    SNR = compute_connectivity(coordinates, heads, D_p1, ...
                        K_b, K_u, K_f, alpha_b, alpha_u, alpha_f);
                    
    len = length(coordinates);
end

function [coordinates, heads, avg_msgs] = cluster_init(radius, num_UEs)
    
    % require multiple of 4 UEs
    assert(mod(num_UEs,4) == 0, 'Number of UEs must a multiple of 4');
    assert(num_UEs > 3, 'Must have at least four UE');

    % base station index = 1
    coordinates = zeros(num_UEs + 1,2);
    avg_msgs = zeros(num_UEs,1);

    % place base station in the center
    coordinates(1,:) = [0, 0];

    cluster_size = floor(num_UEs / 4);
    cluster_x = radius * 0.3;
    cluster_y = radius * 0.3;
    
    xs = [-cluster_x, +cluster_x, -cluster_x, +cluster_x];
    ys = [+cluster_y, +cluster_y, -cluster_y, -cluster_y];
    
    heads = zeros(1,4);
      
    % for each quadrant
    for i = 1:4
        
        % place fog node in center
        coordinates((i - 1) * cluster_size + 2,:) = [xs(i), ys(i)];
        avg_msgs((i - 1) * cluster_size + 1) = (5 - i) * 250;
        heads(i) = (i - 1) * cluster_size + 2;
        
        % place rest of cluster around in guassian distribution
        for j = 2:cluster_size
            coordinates((i - 1) * cluster_size + j + 1,:) =  ...
                [xs(i) + round(randn()*radius*0.1), ...
                 ys(i) + round(randn()*radius*0.1) ];
             
            avg_msgs((i - 1) * cluster_size + j) = (5 - i) * 250;
        end
    end
    
    % make all coordinates positive
    coordinates = coordinates + radius;
end

function [coordinates, heads, avg_msgs] = uniform_init(X_size, Y_size, num_UEs)

    % |CX| = [num_UEs + 1, 2]  => (x1,y1); (x2,y2); ...
    % |conn_mx| = [num_UEs + 1, num_UEs + 1]
    
    % base station index = 1
    coordinates = zeros(num_UEs + 1,2);

    % place base station in the center
    coordinates(1,:) = [X_size/2, Y_size/2];

    % randomly distribute UEs
    for i = 2:num_UEs+1
        coordinates(i,:) = [rand()*X_size, rand()*Y_size];
    end
    
    heads = [];
    
    % # of average messages ranges from [0,1000]
    avg_msgs = randi(1001,num_UEs,1) - 1;
end

function connectivity = compute_connectivity(coordinates, heads, D_p1, ...
                        K_b, K_u, K_f, alpha_b, alpha_u, alpha_f)
                    
    % initialize connectivity matrix
    l = size(coordinates,1);
    connectivity = zeros(l,l);

    for i = 1:l
    for j = 1:l

        if(i ~= j)

            d = distance_inv(coordinates(i,1),coordinates(i,2),coordinates(j,1),coordinates(j,2));

            % account for max distance of p(success) = 1
            d = d / D_p1;

            % avoid inf
            if(d == inf)
                d = 0;
            end

            % apply scaling and exponent params
            if (i == 1 || j == 1)
                d = (d .^ alpha_b) * K_b;
            elseif(ismember(i,heads) || ismember(j,heads))
                d = (d .^ alpha_f) * K_f;
            else
                d = (d .^ alpha_u) * K_u;
            end

            mx = max([K_b, K_u, K_f]);

            % apply scaled trunctation for distances within D_p1
            if(d > D_p1 * mx)
                d = D_p1 * mx;
            end

            % make sure all results are within [0,1]
            d = d / (D_p1 * mx);

            connectivity(i,j) = d;
        end
    end
    end
end

function d = distance_inv(x1,y1,x2,y2)

    % connectivity is inversely proportional to distance
    d = sqrt((x1 - x2).^2 + (y1 - y2).^2);
    d = 1/d;

end
