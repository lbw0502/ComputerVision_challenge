function [EF] = achtpunktalgorithmus(Korrespondenzen, K1, K2)
    % Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix
    % mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K'
    % vorliegt oder nicht
  
    %% 3.1 Anfang Achtpunktalgorithmus 
    % Bekannte Variablen: 
    % x1    homogene (kalibrierte) Koordinaten
    % x2    homogene (kalibrierte) Koordinaten
    % A     A Matrix f¨¹r den Achtpunktalgorithmus
    % V     Rechtsseitige Singul?rvektoren
    
    EF ={0, 0, 0 ,0};
    num = size(Korrespondenzen,2);   % number of the points
    

    % extract the coordinates in image1 and image2
    Korrespondenzen1 = Korrespondenzen(1:2,:);
    Korrespondenzen2 = Korrespondenzen(3:4,:);
    
    % convert the normal coordinates to homogeneous coordinates
    x1 = [Korrespondenzen1;ones(1,num)];
    x2 = [Korrespondenzen2;ones(1,num)];
    
    % if K exists, calibrate the coordinates
    if exist('K1','var')
        x1 = K1^-1*x1;
        x2 = K2^-1*x2;
    end
    
    % compute A matrix
    A = zeros(num,9);
    for i = 1:num
        a = [x1(1,i)*x2(:,i);x1(2,i)*x2(:,i);x1(3,i)*x2(:,i)];
        A(i,:) = a;
    end
   
    [~,~,V]=svd(A);
    %% 3.2 Schaetzung der Matrizen
    
    EF = 0;

    G_s = V(:,end);
    
    G = reshape(G_s,3,3);
    [G_U, G_Sigma, G_V] = svd(G);

    
    if exist('K1','var')
        E = G_U*diag([1,1,0])*G_V';
        EF =E;
    else
        F = G_U*diag([G_Sigma(1,1),G_Sigma(2,2),0])*G_V';
        EF = F;
    end
    
        
end