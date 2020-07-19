function [T, R] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K1, K2)
    %% 4.2 Preparation
    
    T_cell = {T1, T2, T1, T2};
    R_cell = {R1, R1, R2, R2};
    
    N = size(Korrespondenzen,2);
    x1_uncalibrited = [Korrespondenzen(1:2,:);ones(1,N)];
    x1 = K1^-1*x1_uncalibrited;
    
    x2_uncalibrited = [Korrespondenzen(3:4,:);ones(1,N)];
    x2 = K2^-1*x2_uncalibrited;
    
    d_cell = {zeros(N,2), zeros(N,2), zeros(N,2), zeros(N,2)};
    
    %% 4.3 Rekonstruktion
    T = 0;
    R = 0;
    lambda = 0;
    M1 = 0;
    M2 = 0;
    
    N = size(Korrespondenzen,2);
    
    % initialize some cells for the later M matrix computation
    diag_cell_1 = cell(1,N);
    diag_cell_2 = cell(1,N);
    column_cell_1 = cell(N,1);
    column_cell_2 = cell(N,1);
    M_all = cell(2,4);
    
    
    for i = 1:4
        for j = 1:N
            
            % compute the diagnal part of the M matrix
            diag_cell_1{j} = cross(x2(:,j),R_cell{i}*x1(:,j));
            diag_cell_2{j} = cross(x1(:,j),R_cell{i}'*x2(:,j));
            
            % compute the column part of M matrix
            column_cell_1{j} = cross(x2(:,j),T_cell{i});
            column_cell_2{j} = -cross(x1(:,j),R_cell{i}'*T_cell{i});
        end
       
        M1_diag = blkdiag(diag_cell_1{:});
        M2_diag = blkdiag(diag_cell_2{:});
        column_1 = cell2mat(column_cell_1);
        column_2 = cell2mat(column_cell_2);
        
        M1 = [M1_diag, column_1];
        M2 = [M2_diag, column_2];
        
        % store M1 and M2 in all_M         
        M_all{1,i} = M1;
        M_all{2,i} = M2;
        
        [~, ~, V1] = svd(M1);
        [~, ~, V2] = svd(M2);
        
        % extract the last column of right singular matrix of M
        d1 = V1(:,end);
        d2 = V2(:,end);
        
        % normalization 
        d1 = d1/d1(end);
        d2 = d2/d2(end);
        
        % copy d1,d2 to d_cells
        d_cell{i}(:,1) = d1(1:end-1);
        d_cell{i}(:,2) = d2(1:end-1);
    end
    
    % find the index of the combination of R and T, which has most positive number of lamda
    positive_num = [length(find(d_cell{1}>0)),length(find(d_cell{2}>0)),length(find(d_cell{3}>0)),length(find(d_cell{4}>0))];
    [num, index] = max(positive_num);
    
    T = T_cell{index};
    R = R_cell{index};
    if det(R)<0
        R = abs(R);
    end
    if T(1)>0
        T = -T;
    end

end