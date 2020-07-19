%% Computer Vision Challenge 2019

% Group number:
group_number = 36;

% Group members:
members = {'Bowen Li', 'Chensheng Chen', 'Tao Tang', 'Helin Cao'};

% Email-Address (from Moodle!):
mail = {'bowen.d.li@tum.de', 'ge49fuf@mytum.de', 'ga84zes@mytum.de', 'helin.cao@tum.de'};

%% Start timer here
tic

%% Disparity Map
% Specify path to scene folder containing img0 img1 and calib
 scene_path = 'terrace'
% 
% Calculate disparity map and Euclidean motion
[D, R, T] = disparity_map(scene_path);

%% Validation
% Specify path to ground truth disparity map
% gt_path = 'paht\to\ground\truth'
%
% Load the ground truth
G = readpfm([scene_path,'/disp0.pfm']);
G = normalization(G);
% 
% Estimate the quality of the calculated disparity map
p = verify_dmap(D,G);

%% Stop timer here
elapsed_time = toc;


%% Print Results
% R, T, p, elapsed_time
disp('Rotation Matrix R is')
disp(R)
disp('Translation Vectro T(in meter) is')
disp(T)
disp(['PSNR is ',num2str(p),'dB'])
disp(['Elapsed time is ',num2str(elapsed_time),'s'])


%% Display Disparity
imshow(D,[])
colormap jet
colorbar

