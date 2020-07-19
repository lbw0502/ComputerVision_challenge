function [Korrespondenzen_robust] = F_ransac(Korrespondenzen, varargin)
    % Diese Funktion implementiert den RANSAC-Algorithmus zur Bestimmung von
    % robusten Korrespondenzpunktpaaren
    
    % 3.3    
    epsilon_default = 0.5;
    p_default = 0.5;
    tolerance_default = 0.01;
    
    epsilon_validationFcn = @(x) isnumeric(x) && x>0 && x<1;
    p_validationFcn = @(x) isnumeric(x) && x>0 && x<1;
    tolerance_validationFcn = @(x) isnumeric(x);
    
    r = inputParser;
    
    addParameter(r, 'epsilon', epsilon_default, epsilon_validationFcn);
    addParameter(r, 'p', p_default, p_validationFcn);   
    addParameter(r, 'tolerance', tolerance_default, tolerance_validationFcn);
    
    parse(r,varargin{:});
    
    x1 = Korrespondenzen(1:2,:);
    x2 = Korrespondenzen(3:4,:);
    
    x1_pixel = [x1; ones(1,size(Korrespondenzen,2))];
    x2_pixel = [x2; ones(1,size(Korrespondenzen,2))];
    
    epsilon=r.Results.epsilon;
    p=r.Results.p;
    tolerance=r.Results.tolerance;
    
    %% 3.4 RANSAC Algorithmus Vorbereitung
    
    k = 8;
    s = log(1-p)/log(1-(1-epsilon)^k);
    largest_set_size = 0;
    largest_set_dist = inf;
    largest_set_F = zeros(3,3);
 
     %% 3.6 RANSAC Algorithmus
    
    pixel_num = size(Korrespondenzen,2);
    
    for i = 1:s  
        
        % 1. randomly choose k pairs of coordinates as the Consensus Set
        %    use 8-points algorithm to estimate F matrix
        mask = randperm(pixel_num, k);       
        consensus_set = Korrespondenzen(:,mask);
        F = achtpunktalgorithmus(consensus_set);
        
        % 2. use this F matrix to compute Sampson-Distance between all coordinates
        %    the result can somehow reflect the quality of the chosen Consensus Set
        sd = sampson_dist(F, x1_pixel, x2_pixel);
        
        % 3. take the coordinates which fulfill the requirement as the inlier points
        point_mask = sd < tolerance;
        sd = sd(point_mask);
        
        % 4. compute the number of point-pair and total distance error
        set_number = length(sd);
        total_distance = sum(sd);
        
        % 5. use the threshold values to update Consensus Set,
        %    which contains more points and has smaller total distance error is preferred
        % 6. return the wanted varibles
        if set_number > largest_set_size
            largest_set_size = set_number;
            largest_set_F = F;
            final_mask = point_mask;
            %Korrespondenzen_robust = Korrespondenzen(:,point_mask);
        end
        if set_number == largest_set_size
            if total_distance < largest_set_dist
                largest_set_dist = total_distance;
                largest_set_F = F;
                final_mask = point_mask;
              
            end
        end       
    end
    Korrespondenzen_robust = Korrespondenzen(:,final_mask);
    
end