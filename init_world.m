function [coordinates, connectivity, avg_msgs] = init_world(params)

    radius      = params(1);
    num_UEs      = params(2);
    setup_type  = params(3);
    K_b         = params(4);
    K_u         = params(5);
    K_f         = params(6);
    C_b         = params(7);
    C_u         = params(8);
    C_f         = params(9);
    r_f         = params(10);
    r_c         = params(11);

    % assert some input conditions
    assert(C_b > 0 && C_u > 0 && ...
           K_b > 0 && K_u > 0 && ...
           radius > 0, ...
           'Parameters must be positive');
    
    if(setup_type == 0)
        [coordinates, heads, avg_msgs] = uniform_init(radius * 2, radius * 2, num_UEs);
    elseif(setup_type == 1)
        [coordinates, heads, avg_msgs] = cluster_init(radius, num_UEs, r_f, r_c);
    end
    
    % compute connectivity
    connectivity = compute_connectivity(coordinates, heads, ...
                        K_b, K_u, K_f, C_b, C_u, C_f);
                    
end

function [coordinates, heads, avg_msgs] = cluster_init(radius, num_UEs, r_f, r_c)
    
    % require multiple of 4 UEs
    assert(mod(num_UEs,4) == 0, 'Number of UEs must a multiple of 4');
    assert(num_UEs > 3, 'Must have at least four UE');

    % base station index = 1
    coordinates = zeros(num_UEs + 1,2);
    avg_msgs = zeros(num_UEs,1);

    % place base station in the center
    coordinates(1,:) = [0, 0];
    
    cluster_size = floor(num_UEs / 4);
    cluster_d = sqrt(((r_f * radius).^2) / 2);
    
    xs = [-cluster_d, +cluster_d, -cluster_d, +cluster_d];
    ys = [+cluster_d, +cluster_d, -cluster_d, -cluster_d];
    
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
                [xs(i) + round(randn()*radius*r_c), ...
                 ys(i) + round(randn()*radius*r_c) ];
             
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

function connectivity = compute_connectivity(coordinates, heads, ...
                        K_b, K_u, K_f, C_b, C_u, C_f)
                    
    % compute distance between all nodes
    connectivity = distance(coordinates);
    
    len = size(connectivity,1);
    
    % convert dist->PathLoss
    for i = 1:len
    for j = 1:len
        
        d = connectivity(i,j);
        
       % B-u connection
       if(i == 1 || j == 1)
           K = K_b;
           C = C_b;
           %A = toGain(17);
       
       % connection to fog node
       elseif (ismember(i,heads) || ismember(j,heads))
           K = K_f;
           C = C_f;
           %A = toGain(4);
           
       % D2D connection
       else
           K = K_u;
           C = C_u;
           %A = toGain(4);
       end
       
       %N = toGain(-116);
       %P = toGain(23);
       
       % dist -> PathLoss
       d = C + K * log10(d/1000);
       
       % PathLoss -> Gain
       d = toGain(-d);
       
       % Compute SNR (power, antenna, pathloss gain, noise)
       %d = P * A * d * N; 
           
       % SNR -> BER
       d = ((3)/(sqrt(2*pi*d))) * exp(-0.5 * d);
       
       connectivity(i,j) = d;
    end
    end
    
    connectivity = connectivity / 2;
    %f = find(connectivity > 1);
    connectivity(connectivity > 1) = 1;
    
    connectivity = 1 - connectivity;
    
    disp(connectivity);

end

function g = toGain(SNR)
    g = 10^(SNR/10);
end

function D = distance(coordinates)
    
    l = size(coordinates,1);
    D = zeros(l,l);

    for i = 1:l
    for j = 1:l

        d = dist(coordinates(i,:),coordinates(j,:));
        D(i,j) = d;
        
    end
    end
end

% compute euclidian distance of two points
function d = dist(P1,P2)

    d = sqrt((P2(1) - P1(1)).^2 + (P2(2) - P1(2)).^2);
    if(d == 0)
        d = inf;
    end
    %d = sqrt((x1 - x2).^2 + (y1 - y2).^2);

end
