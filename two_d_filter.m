function result = two_d_filter(image, H)
    s = size(image);
    H_size = size(H);
    r = zeros(s);
    replicate_size = (H_size(1)-1)/2;
    for i = 1:replicate_size
        image = [image(1,:); image; image(end,:)];
    end
    for i = 1:replicate_size
    	image = [image(:,1), image, image(:,end)];
    end
    for i = 1+replicate_size:s(1)+replicate_size
        for j = 1+replicate_size:s(2)+replicate_size
            temp = image(i-replicate_size:i+replicate_size, j-replicate_size:j+replicate_size) .* H;
            r(i-replicate_size, j-replicate_size) = sum(temp(:));
        end
    end
    result = r;
end