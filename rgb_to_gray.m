function gray_image = rgb_to_gray(input_image)
    % Diese Funktion soll ein RGB-Bild in ein Graustufenbild umwandeln. Falls
    % das Bild bereits in Graustufen vorliegt, soll es direkt zurueckgegeben werden.
    
    % HA 1.1
    % ob das Bild in Graustufen vorliegt   
    if numel(size(input_image))==2
        gray_image=input_image;
    else
        image_double=double(input_image);
        image_double_r=image_double(:,:,1);
        image_double_g=image_double(:,:,2);
        image_double_b=image_double(:,:,3);
        gray_image=0.299 * image_double_r + 0.587 * image_double_g + 0.114 * image_double_b;
        gray_image=uint8(gray_image);
        
    end
end