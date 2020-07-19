function [D, R, T] = disparity_map(scene_path)
% This function receives the path to a scene folder and calculates the
% disparity map of the included stereo image pair. Also, the Euclidean
% motion is returned as Rotation R and Translation T.
%% extract the information in calib.txt 
hwait=waitbar(0,'loading the data');


fid = fopen([scene_path, '/calib.txt']);
cal_data = textscan(fid,'%s','delimiter','');
fclose(fid);

left_image = imread([scene_path, '/im0.png']);
right_image = imread([scene_path, '/im1.png']);

cam1_str = cal_data{1,1}{1}(7:end-1);
cam2_str = cal_data{1,1}{2}(7:end-1);
cam1 = str2num(cam1_str);
cam2 = str2num(cam2_str);

baseline_str =  cal_data{1,1}{4}(10:end);
baseline = str2num(baseline_str);

ndisp_str = cal_data{1,1}{7}(7:end);
ndisp = str2num(ndisp_str);

%% compute R and T
close(hwait)
hwait=waitbar(0.33,'computing R and T');


IGray1 = rgb_to_gray(left_image);
IGray2 = rgb_to_gray(right_image);

% Harris-Merkmale berechnen
Merkmale1 = harris_detektor(IGray1,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);
Merkmale2 = harris_detektor(IGray2,'segment_length',9,'k',0.05,'min_dist',50,'N',20,'do_plot',false);

Korrespondenzen = punkt_korrespondenzen(IGray1,IGray2,Merkmale1,Merkmale2,'window_length',25,'min_corr', 0.90,'do_plot',false);

%  Finde robuste Korrespondenzpunktpaare mit Hilfe des RANSAC-Algorithmus
Korrespondenzen_robust = F_ransac(Korrespondenzen, 'tolerance', 0.04);
E = achtpunktalgorithmus(Korrespondenzen_robust, cam1, cam2);
[T1, R1, T2, R2]=TR_aus_E(E);
[T, R] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen_robust, cam1, cam2);


% show T in meter
T = T*baseline*(-1)/1000;

%% computation of disparity map
close(hwait);
hwait=waitbar(0.66,'computing disparity and PSNR');

if ndisp > 500;
    ndisp = 40;
end

disparity_left = batchmatching_inv(fliplr(right_image), fliplr(left_image), ndisp);

D =normalization(disparity_left);

close(hwait);
hwait=waitbar(1,'finished');
close(hwait);


end