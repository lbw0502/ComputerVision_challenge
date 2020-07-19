function sd = sampson_dist(F, x1_pixel, x2_pixel)
    % Diese Funktion berechnet die Sampson Distanz basierend auf der
    % Fundamentalmatrix F
    
    % 3.5
    e3 = [0;0;1];
    e3_hat = [0,-1,0;1,0,0;0,0,0];
    
    % use vectorized computation rather than loop
    denominator = sum((e3_hat*F*x1_pixel).^2) + sum(((x2_pixel'*F*e3_hat).^2)');   % the dimension of denominator is 1*n
    numerator = diag(x2_pixel'*F*x1_pixel)'.^2;           % the dimension of numerator is 1*n
    
    sd = numerator./denominator;

end