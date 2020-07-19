function p = verify_dmap(D, G)

diff = D - G;
MSE = sum(sum(diff.^2))/numel(diff);
p = 10*log10(255^2/MSE);

end