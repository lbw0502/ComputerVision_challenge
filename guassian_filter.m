function result = guassian_filter(N, sigma)
    if N % 2
        ind = -floor(N/2) : floor(N/2);
        [X, Y] = meshgrid(ind, ind);
        h = exp(-(X.^2 + Y.^2) / (2*sigma*sigma));
        result = h / sum(h(:));
    else
        disp("Please input a odd integer!!!");
        
    end

end