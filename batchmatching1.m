function disparity = batchmatching1(left_im, right_im, d_max)

left_im = rgb2gray(left_im);
right_im = rgb2gray(right_im);

window_length=3;
H = size(left_im,1);
W = size(left_im,2);

disparity=zeros(H,W);

for i=window_length+1:H-window_length
   
    for j=window_length+1:W-window_length
        
        block_right=right_im(i-window_length:i+window_length,j-window_length:j+window_length);
        
        block_diff=[];
        
        for d=0:min(d_max,W-window_length-j)
            block_left=left_im(i-window_length:i+window_length,j-window_length+d:j+window_length+d);
            % calculate sum of absolute differences (SAD)
            block_diff(d+1, 1) = sum(abs(block_left(:) - block_right(:)));           
        end
        
        [~, dis]=min(block_diff);
        disparity(i, j) = dis -1;
    end
end

imshow(disparity,[0 255])
colormap jet
colorbar
end