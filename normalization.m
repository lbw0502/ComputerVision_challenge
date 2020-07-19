function image_norm = normalization(image)

image_min = min(image(:));
image_max = max(image(:));

image_norm = floor((image - image_min)/(image_max - image_min)*255);

end