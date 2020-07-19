function disparity = batchmatching(left_im, right_im, d_max)

% convert the color image to gary scale
left_im = rgb_to_gray(left_im);
right_im = rgb_to_gray(right_im);

left_im = double(left_im)/255;
right_im = double(right_im)/255;


% compute the height and width of the image
H = size(left_im,1);
W = size(left_im,2);

% set the window length
window_length=6;

% supplement of the image
W_mod = mod(W, 2*window_length+1);
H_mod = mod(H, 2*window_length+1);
W_edge = 2*window_length+1-W_mod;
H_edge = 2*window_length+1-H_mod;

left_new = [left_im zeros(H,W_edge)];
left_new = [left_new; zeros(H_edge,size(left_new,2))];

right_new = [right_im zeros(H,W_edge)];
right_new = [right_new; zeros(H_edge,size(right_new,2))];


disparity=zeros(size(right_new));

% use SAD algorithm to match the similar block
 for i = 1+window_length:2*window_length+1:size(right_new,1)
     for j = 1+window_length:2*window_length+1:size(right_new,2)
         
         block_right = right_new(i-window_length:i+window_length, j-window_length:j+window_length);
         
         block_diff = [];
         
         for d = 0:min(d_max, size(right_new,2)-j-window_length)
             block_left = left_new(i-window_length:i+window_length,j-window_length+d:j+window_length+d);
             block_diff(d+1, 1) = sum(abs(block_left(:) - block_right(:)));
         end
         [~, dis]=min(block_diff);
         disparity(i-window_length:i+window_length, j-window_length:j+window_length) = dis -1;
                 
     end
 end
 
disparity = disparity(1:H,1:W);
 
sigma=window_length;
window=double(uint8(3*sigma)*2+1);

%H=fspecial('gaussian', window, sigma);
%disparity=imfilter(disparity,H,'replicate');
H = guassian_filter(window, sigma)
disparity = two_d_filter(disparity, H);
 
end