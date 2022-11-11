
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
% Read RGB and Thermal images

%read rgb image
rgb=imread("D:\Phd\thermal\final codes\Data\Images_GetTransformationMatrix\multispectral\0278\IMG_221111_025316_0000_RGB.JPG");    % Optical RGB
%%Preprocess RGBImage, rotate image A due to multispectral camera orientataion
rgb = imrotate(rgb, 180);
rgb_image=rgb2gray(rgb);
imshow(rgb_image)
%%
% read thermal imgae
thermal_image=imread("D:\Phd\thermal\final codes\Data\Images_GetTransformationMatrix\thermal\IR_11173.jpg");    % Thermal

% Preprocess thermal image
resFactor=2.5;
thermal_image=double(thermal_image)/255;
thermal_image=thermal_image(:,1:640); %subset the image
thermal_image=imcomplement(thermal_image);
thermal_image=increaseResolution(thermal_image,resFactor);
imshow(thermal_image)
%%

%%
% Process to get tform.
imgA = rgb_image; % the fixed image
imgB=  thermal_image;  % image to be transformed

imshowpair(imgA,imgB)
%%
pointsA = detectHarrisFeatures(imgA,'ROI', [2318,1482,400,400],'MinQuality',0.010,'FilterSize',11); % detect features in A
% Display corners found in images A and B.
figure; imshow(imgA); hold on;
plot(pointsA);
title('Corners in A');
%%
pointsB = detectHarrisFeatures(imgB,'ROI', [732,463,400,400],'MinQuality',0.009,'FilterSize',15); % detect features in B
figure; imshow(imgB); hold on;
plot(pointsB);
title('Corners in B');
%%
% Extract FREAK descriptors for the corners
[featuresA, pointsA] = extractFeatures(imgA, pointsA,'Upright',true,'BlockSize',35,'FeatureSize',128);
[featuresB, pointsB] = extractFeatures(imgB, pointsB,'Upright',true,'BlockSize',35,'FeatureSize',128);
indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);
figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
legend('A', 'B');
%%
% calculate transformation matrix.
[tform_thermal, inlierIdx] = estimateGeometricTransform2D(...
    pointsB, pointsA, 'affine');
pointsBm = pointsB(inlierIdx, :);
pointtformsAm = pointsA(inlierIdx, :);
% save tform
save('tform_thermal.mat', 'tform_thermal');
%% TEST

Roriginal = imref2d(size(imgA)); % sizr of the fixed image (rgb)
recovered_image_thermal = imwarp(imgB,tform_thermal,'OutputView',Roriginal);

imshowpair(imgA,recovered_image_thermal,"montage")
imshowpair(imgA,recovered_image_thermal,"falsecolor")
imshowpair(imgA,recovered_image_thermal,"Scaling","Joint")
