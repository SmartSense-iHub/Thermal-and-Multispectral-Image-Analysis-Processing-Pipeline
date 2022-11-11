%
%   Description: batch processing of rgb and ir coregistration
%   Author: Neelesh
%   Date: 14/12/2021
%   Comment:
%   Tests run:
% Clear command window, and erase all existing variables

clc;        % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;      % Erase all existing variables.

my_folder="D:\Phd\thermal\ThermalMultispectralImageAnalysis\Data\Images_GetDistortion Parameters";
%my_folder="C:\Users\neele\OneDrive - VicGov\Myworkspace\Data\data_distortion_31012022";
%%
% Store images filenames from sequioa to an cell
% Store images filenames from sequioa to an cell
rgb_fullFileNames1=getFullfilenames(my_folder,"RGB","jpg")
gre_fullFileNames1=getFullfilenames(my_folder,"GRE","tif")
nir_fullFileNames1=getFullfilenames(my_folder,"NIR","tif")
red_fullFileNames1=getFullfilenames(my_folder,"RED","tif")
reg_fullFileNames1=getFullfilenames(my_folder,"REG","tif")
%%
rgb_fullFileNames = rgb_fullFileNames1(cellfun('isempty', strfind(rgb_fullFileNames1,'.thumb'))) ;
gre_fullFileNames = gre_fullFileNames1(cellfun('isempty', strfind(gre_fullFileNames1,'.thumb'))) ;
nir_fullFileNames = nir_fullFileNames1(cellfun('isempty', strfind(nir_fullFileNames1,'.thumb'))) ;
red_fullFileNames = red_fullFileNames1(cellfun('isempty', strfind(red_fullFileNames1,'.thumb'))) ;
reg_fullFileNames = reg_fullFileNames1(cellfun('isempty', strfind(reg_fullFileNames1,'.thumb'))) ;
%%
% Store images to datastore 
images_rgb = imageDatastore(rgb_fullFileNames);
images_gre = imageDatastore(gre_fullFileNames);
images_nir = imageDatastore(nir_fullFileNames);
images_red = imageDatastore(red_fullFileNames);
images_reg = imageDatastore(reg_fullFileNames);
%%
[imagePoints_rgb,boardSize] = detectCheckerboardPoints(images_rgb.Files);
[imagePoints_gre,boardSize] = detectCheckerboardPoints(images_gre.Files);
[imagePoints_nir,boardSize] = detectCheckerboardPoints(images_nir.Files);
[imagePoints_red,boardSize] = detectCheckerboardPoints(images_red.Files);
[imagePoints_reg,boardSize] = detectCheckerboardPoints(images_reg.Files);
%%
squareSize = 50;
worldPoints = generateCheckerboardPoints(boardSize,squareSize);
%%
I_rgb = readimage(images_rgb,1); 
I_rgb = imrotate(I_rgb,180);
imageSize_rgb = [size(I_rgb,1),size(I_rgb,2)];
cameraParams_rgb = estimateCameraParameters(imagePoints_rgb,worldPoints, ...
                                  'ImageSize',imageSize_rgb);

%%
I_nir = readimage(images_nir,1); 
I_nir = imrotate(I_nir,180);
imageSize_nir = [size(I_nir,1),size(I_nir,2)];
cameraParams_nir = estimateCameraParameters(imagePoints_nir,worldPoints, ...
                                  'ImageSize',imageSize_nir);
%%
I_gre = readimage(images_gre,1); 
I_gre = imrotate(I_gre,180);
imageSize_gre = [size(I_gre,1),size(I_gre,2)];
cameraParams_gre = estimateCameraParameters(imagePoints_gre,worldPoints, ...
                                  'ImageSize',imageSize_gre);
%%
I_red = readimage(images_red,1); 
I_red = imrotate(I_red,180);
imageSize_red = [size(I_red,1),size(I_red,2)];
cameraParams_red = estimateCameraParameters(imagePoints_red,worldPoints, ...
                                  'ImageSize',imageSize_red);
%%
I_reg = readimage(images_reg,1); 
I_reg = imrotate(I_reg,180);
imageSize_reg = [size(I_reg,1),size(I_reg,2)];
cameraParams_reg = estimateCameraParameters(imagePoints_reg,worldPoints, ...
                                  'ImageSize',imageSize_reg);
%%
% save camera Parameters 
save('cameraParams_rgb.mat', 'cameraParams_rgb');
save('cameraParams_gre.mat', 'cameraParams_gre');
save('cameraParams_nir.mat', 'cameraParams_nir');
save('cameraParams_red.mat', 'cameraParams_red');
save('cameraParams_reg.mat', 'cameraParams_reg');
%%
I_rgb = images_rgb.readimage(24);
I_rgb = imrotate(I_rgb,180);
J_rgb = undistortImage(I_rgb,cameraParams_rgb);
figure; imshowpair(I_rgb,J_rgb,'montage');
title('Original Image (left) vs. Corrected Image (right)');
%%
I_gre = images_gre.readimage(24);
I_gre = imrotate(I_gre,180);
J_gre = undistortImage(I_gre,cameraParams_gre);
figure; imshowpair(I_gre,J_gre,'montage');
title('Original Image (left) vs. Corrected Image (right)');
%%
I_nir = images_nir.readimage(24);
I_nir = imrotate(I_nir,180);
J_nir = undistortImage(I_nir,cameraParams_nir);
figure; imshowpair(I_nir,J_nir,'montage');
title('Original Image (left) vs. Corrected Image (right)');
%%
I_red = images_red.readimage(24);
I_red = imrotate(I_red,180);
J_red = undistortImage(I_red,cameraParams_red);
figure; imshowpair(I_red,J_red,'montage');
title('Original Image (left) vs. Corrected Image (right)');
%%
I_reg = images_reg.readimage(24);
I_reg = imrotate(I_reg,180);
J_reg = undistortImage(I_reg,cameraParams_reg);
figure; imshowpair(I_reg,J_reg,'montage');
title('Original Image (left) vs. Corrected Image (right)');
%%

imshow(imrotate(J_nir,180))
imshow(images_nir.readimage(1))
%%

A_nir = images_nir.readimage(1);
%A_nir = imrotate(A_nir,180);
imshow(A_nir)
%%
B_nir = undistortImage(A_nir,cameraParams_nir_new);
imshow(B_nir)
%%
%R_rgb = corr2(I_rgb,J_rgb);
corr_red = corr2(I_red,J_red);
corr_nir = corr2(I_nir,J_nir);
corr_reg = corr2(I_reg,J_reg);
corr_gre = corr2(I_gre,J_gre);
corr_rgb = corr2(I_rgb(:,:,1),J_rgb(:,:,1));
%%
figure; 

showExtrinsics(cameraParams_nir, 'PatternCentric');
 % v = [0 0 -90];
 %[caz,cel] = view(v);
view(-180,-90)
camproj('perspective')
%%
%displayErrors(estimationErrors, cameraParams_nir_new);
%%
[nir_params, ~, nir_estimationErrors] = estimateCameraParameters(imagePoints_nir,worldPoints, ...
                                  'ImageSize',imageSize_nir);
[red_params, ~, red_estimationErrors] = estimateCameraParameters(imagePoints_red,worldPoints, ...
                                  'ImageSize',imageSize_red);
[reg_params, ~, reg_estimationErrors] = estimateCameraParameters(imagePoints_reg,worldPoints, ...
                                  'ImageSize',imageSize_gre);
[gre_params, ~,gre_estimationErrors] = estimateCameraParameters(imagePoints_gre,worldPoints, ...
                                  'ImageSize',imageSize_gre);
[rgb_params, ~, rgb_estimationErrors] = estimateCameraParameters(imagePoints_rgb,worldPoints, ...
                                  'ImageSize',imageSize_rgb);
%%
figure; 
showReprojectionErrors(rgb_params);
%%
displayErrors(nir_estimationErrors, nir_params);
%%
displayErrors(nir_estimationErrors, cameraParams_nir);
figure; 
showReprojectionErrors(cameraParams_rgb_new);
%%
displayErrors(red_estimationErrors, cameraParams_red);
figure; 
showReprojectionErrors(cameraParams_red);
%%
displayErrors(reg_estimationErrors, cameraParams_reg);
figure; 
showReprojectionErrors(cameraParams_reg);
%%
displayErrors(gre_estimationErrors, cameraParams_gre);
figure; 
showReprojectionErrors(cameraParams_gre);
