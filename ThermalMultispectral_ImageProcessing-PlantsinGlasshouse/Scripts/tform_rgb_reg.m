%
%   Description: Function to process the rgb and ir image to get
%   transformation matrix
%   Author: Neelesh
%   Date: 14/12/2021
%   Comment:
%   Tests run:
% Clear command window, and erase all existing variables
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;
%%
% Read RGB and reg images
%read rgb image
rgb=imread("D:\Phd\thermal\final codes\Data\Images_GetTransformationMatrix\multispectral\0278\IMG_221111_025316_0000_RGB.JPG");    % Optical RGB
%%Preprocess RGBImage, rotate image A due to multispectral camera orientataion
rgb = imrotate(rgb, 180);
rgb_image=rgb2gray(rgb);
imshow(rgb_image)
%%
% read reg imgae
reg_image=imread("D:\Phd\thermal\final codes\Data\Images_GetTransformationMatrix\multispectral\0278\IMG_221111_025316_0000_REG.TIF");  % regen band image
% Preprocess reg image
%%
load cameraParams_reg.mat

reg_image = imrotate(reg_image, 180);
reg_image=undistortImage(reg_image,cameraParams_reg);
imshow(reg_image)
%%
%Calculate mim max image pixels
minImage = min(min(reg_image));
maxImage = max(max(reg_image));
%%
reg_image=double(reg_image);
%thermal_image=thermal_image/(65472-5440);
reg_image=reg_image/double(maxImage-minImage);
imshow(reg_image)
%%
resFactor=3.6;% board and image
reg_image=increaseResolution(reg_image,resFactor);
imshow(reg_image)
%%
% Process to get tform
imgA = rgb_image; % the fixed image
imgB=  reg_image;  % image to be transformed
%%
pointsA = detectHarrisFeatures(imgA,'ROI', [2318,1482,450,450],'MinQuality',0.20,'FilterSize',15); % detect features in A
% Display corners found in images A and B.
figure; imshow(imgA); hold on;
plot(pointsA);
title('Corners in A');
%%
pointsB = detectHarrisFeatures(imgB,'ROI', [2120,1450,450,450],'MinQuality',0.01,'FilterSize',11); % detect features in B
% Display corners found in images A and B.
figure; imshow(imgB); hold on;
plot(pointsB);
title('Corners in B');
%%
% Extract FREAK descriptors for the corners
[featuresA, pointsA] = extractFeatures(imgA, pointsA,'Upright',true,'BlockSize',25,'FeatureSize',128);
[featuresB, pointsB] = extractFeatures(imgB, pointsB,'Upright',true,'BlockSize',25,'FeatureSize',128);
indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);
figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
legend('A', 'B');
%%
% calculate transformation matrix
[tform_reg, inlierIdx] = estimateGeometricTransform2D(...
    pointsB, pointsA, 'affine');
pointsBm = pointsB(inlierIdx, :);
pointtformsAm = pointsA(inlierIdx, :);
% save tform
save('tform_reg.mat', 'tform_reg');
%% TEST

Roriginal = imref2d(size(imgA)); % sizr of the fixed image (rgb)
recovered_image = imwarp(imgB,tform_reg,'OutputView',Roriginal);

imshowpair(imgA,recovered_image,"montage")
imshowpair(imgA,recovered_image,"falsecolor")
imshowpair(imgA,recovered_image,"Scaling","Joint")