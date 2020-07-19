function plot_3D(scene_path)
hwait=waitbar(0,'plot the 3D point cloud');
%% Read a Pair of Images
% Load a pair of images into the workspace.
path1 = [scene_path '/im0.png'];
path2 = [scene_path '/im1.png'];
I1 = imread(path1);
I2 = imread(path2);
load CameraParameters.mat 

%% Find Point Correspondences Between The Images
IGray1 = rgb_to_gray(I1);
IGray2 = rgb_to_gray(I2);

% Calculate Harris-Merkmale
Merkmale1 = harris_detektor(IGray1,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);
Merkmale2 = harris_detektor(IGray2,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);

Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',25,'min_corr', 0.90,'do_plot',false);

matchedPoints1 = Korrespondenzen(1:2,:).';
matchedPoints2 = Korrespondenzen(3:4,:).';
%% Estimate the Essential Matrix
% Estimate the essential matrix
[E, epipolarInliers] = estimateEssentialMatrix(matchedPoints1, matchedPoints2, cameraParams, 'Confidence', 99.99);

% Find epipolar inliers
inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

%% Compute the Camera Pose
% Compute the location and orientation of the second camera relative to the
% first one. 
[orient, loc] = relativeCameraPose(E, cameraParams, inlierPoints1, inlierPoints2);

close(hwait)
hwait=waitbar(0.33,'plot the 3D point cloud');
%% Reconstruct the 3-D Locations of Matched Points
% Re-detect points in the first image using lower |'MinQuality'| to get
% more points. Track the new points into the second image. Estimate the 
% 3-D locations corresponding to the matched points using the |triangulate|
% function. Place the origin at the optical center of the camera
% corresponding to the first image.

% Detect dense feature points. Use an ROI to exclude points close to the
% image edges.
roi = [30, 30, size(I1, 2)-30, size(I1, 1)-30];
imagePoints1 = detectMinEigenFeatures(rgb2gray(I1), 'ROI', roi, 'MinQuality', 0.001);

% Create the point tracker
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);

% Initialize the point tracker
imagePoints1 = imagePoints1.Location;
initialize(tracker, imagePoints1, I1);

% Track the points
[imagePoints2, validIdx] = step(tracker, I2);
matchedPoints1 = imagePoints1(validIdx, :);
matchedPoints2 = imagePoints2(validIdx, :);

% Compute the camera matrices for each position of the camera
camMatrix1 = cameraMatrix(cameraParams, eye(3), [0 0 0]);

% Compute extrinsics of the second camera
[R, t] = cameraPoseToExtrinsics(orient, loc);
camMatrix2 = cameraMatrix(cameraParams, R, t);

% Compute the 3-D points and centralize those points
points3D = triangulate(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);
points3D = points3D - mean(points3D);

% Get the color of each reconstructed point
numPixels = size(I1, 1) * size(I1, 2);
allColors = reshape(I1, [numPixels, 3]);
colorIdx = sub2ind([size(I1, 1), size(I1, 2)], round(matchedPoints1(:,2)), round(matchedPoints1(:,1)));
color = allColors(colorIdx, :);

% Create the point cloud
ptCloud = pointCloud(points3D, 'Color', color);

% Denoise and delete the outliers
if contains(scene_path,'terrace') || contains(scene_path,'playground')
    for i = 1:3
        ptCloud = pcdenoise(ptCloud);
    end
elseif contains(scene_path,'motorcycle')
    ptCloud = ptCloud;
else
    ptCloud = pcdenoise(ptCloud);
end
close(hwait)
hwait=waitbar(0.66,'plot the 3D point cloud');
%% Display the 3-D Point Cloud
% Visualize the point cloud
figure
pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', 'MarkerSize', 45);

% Label the axes
xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');

title('Up to Scale Reconstruction of the Scene');

close(hwait)
hwait=waitbar(0.99,'plot the 3D point cloud');
close(hwait);
end