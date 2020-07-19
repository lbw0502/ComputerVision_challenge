function [T1, R1, T2, R2]=TR_aus_E(E)
    % 4.1
    % Diese Funktion berechnet die moeglichen Werte fuer T und R
    % aus der Essentiellen Matrix
    [U, Sigma, V] = svd(E);
    
    % make sure that U and V from svd of E is rotation matrix
    % which means det(U) and det(V) is 1
    if det(U)<0
        U = U*[1,0,0;0,1,0;0,0,-1];             
        V = V*[1,0,0;0,1,0;0,0,-1];
    end
    
    RZ_positive = [0,-1,0;1,0,0;0,0,1];
    RZ_negative = [0,1,0;-1,0,0;0,0,1];
    
    R1 = U*RZ_positive'*V';
    T1_dach = U*RZ_positive*Sigma*U';
    T1=[-T1_dach(2,3);T1_dach(1,3);-T1_dach(1,2)];
    
    R2 = U*RZ_negative'*V';
    T2_dach = U*RZ_negative*Sigma*U';
    T2=[-T2_dach(2,3);T2_dach(1,3);-T2_dach(1,2)];
    
end