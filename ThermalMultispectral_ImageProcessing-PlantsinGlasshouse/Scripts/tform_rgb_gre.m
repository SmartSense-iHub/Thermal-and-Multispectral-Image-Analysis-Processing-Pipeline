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
% Read RGB and gre images
%read rgb image
rgb=imread("D:\Phd\thermal\final codes\Data\Images_GetTransformationMatrix\multispectral\0278\IMG_221111_025316_0000_RGB.JPG");    % Optical RGB
%%Preprocess RGBImage, rotate image A due to multispectral camera orientataion
rgb = imrotate(rgb, 180);
rgb_image=rgb2gray(rgb);
imshow(rgb_image)
%%
% read gre imgae
gre_image=imread("D:\Phd\thermal\final codes\Data\Images_GetTransformationMatrix\multispectral\0278\IMG_221111_025316_0000_GRE.TIF");  % Green band image
% Preprocess gre image
%%
%read rgb image
load cameraParams_gre.mat
gre_image = imrotate(gre_image, 180);
gre_image=undistortImage(gre_image,cameraParams_gre);
imshow(gre_image)
%%
%Calculate mim max image pixels
minImage = min(min(gre_image));
maxImage = max(max(gre_image));
%%
gre_image=double(gre_image);
%thermal_image=thermal_image/(65472-5440);
gre_image=gre_image/double(maxImage-minImage);
imshow(gre_image)
%%
resFactor=3.6;% board and image
gre_image=increaseResolution(gre_image,resFactor);
imshow(gre_image)
%%
% Process to get tform.
imgA = rgb_image; % the fixed image
imgB=  gre_image;  % image to be transformed
%%
pointsA = detectHarrisFeatures(imgA,'ROI', [2190,1398,600,600],'MinQuality',0.10,'FilterSize',13); % detect features in A
% Display corners found in images A and B.
figure; imshow(imgA); hold on;
plot(pointsA);
title('Corners in A');
%%
pointsB = detectHarrisFeatures(imgB,'ROI', [2129,1461,450,450],'MinQuality',0.1,'FilterSize',13); % detect features in B
% Display corners found in images A and B.
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
% calculate transformation matrix
[tform_gre, inlierIdx] = estimateGeometricTransform2D(...
    pointsB, pointsA, 'affine');
pointsBm = pointsB(inlierIdx, :);
pointtformsAm = pointsA(inlierIdx, :);
% save tform
save('tform_gre.mat', 'tform_gre');

%% TEST

Roriginal = imref2d(size(imgA)); % sizr of the fixed image (rgb)
recovered_image = imwarp(imgB,tform_gre,'OutputView',Roriginal);
imshowpair(imgA,recovered_image,"blend")
recovered_image = imwarp(imgB,tform_nir,'OutputView',Roriginal);
imshowpair(imgA,recovered_image,"montage")
imshowpair(imgA,recovered_image,"falsecolor")
imshowpair(imgA,recovered_image,"Scaling","Joint")