%
%   Description: Function to Calibrate Thermal Images and exctrect min max temp
%
%   Author: Neelesh
%   
%   Date: 14/12/2021
%
%   Comment: 
%
%   Tests run:
% Clear command window, and erase all existing variables

function [calibrated_rgb,calibrated_red,calibrated_gre,calibrated_nir,calibrated_reg] = getilluminationadjustment(rgb,red,gre,nir,reg)
%Read data
rgb_image=rgb;
red_image=red;
gre_image=gre;
nir_image=nir;
reg_image=reg;
%%Load all the parameters for dark refrence
%Load the transformation matrix
load tform_thermal.mat;
load tform_gre.mat;
load tform_nir.mat;
load tform_red.mat;
load tform_reg.mat;
%Load camera params for optical distortion
load cameraParams_rgb.mat;
load cameraParams_gre.mat;
load cameraParams_nir.mat;
load cameraParams_red.mat;
load cameraParams_reg.mat;

%% Read Dark Refrence Images
% darkReference_rgb_image=imread("D:\Data\illumination correction\0215\IMG_160101_000614_0000_RGB.JPG");
% darkReference_nir_image=imread("D:\Data\illumination correction\0215\IMG_160101_000614_0000_NIR.TIF");
% darkReference_red_image=imread("D:\Data\illumination correction\0215\IMG_160101_000614_0000_RED.TIF");
% darkReference_reg_image=imread("D:\Data\illumination correction\0215\IMG_160101_000614_0000_REG.TIF");
% darkReference_gre_image=imread("D:\Data\illumination correction\0215\IMG_160101_000614_0000_GRE.TIF");
% % rotate the image
% darkReference_rgb_image=imrotate(darkReference_rgb_image,180);
% darkReference_gre_image=imrotate(darkReference_gre_image,180);
% darkReference_red_image=imrotate(darkReference_red_image,180);
% darkReference_nir_image=imrotate(darkReference_nir_image,180);
% darkReference_red_image=imrotate(darkReference_red_image,180);
% % apply distortion correction
% darkReference_gre_image=undistortImage(darkReference_gre_image,cameraParams_gre);
% darkReference_reg_image=undistortImage(darkReference_reg_image,cameraParams_reg);
% darkReference_red_image=undistortImage(darkReference_red_image,cameraParams_red);
% darkReference_nir_image=undistortImage(darkReference_nir_image,cameraParams_nir);
% % apply tform to the dark refrence images
% Roriginal = imref2d(size(darkReference_rgb_image));
% darkReference_gre = imwarp(darkReference_gre_image,tform_gre,'OutputView',Roriginal); % GRE
% darkReference_red = imwarp(darkReference_red_image,tform_red,'OutputView',Roriginal); % RED
% darkReference_nir = imwarp(darkReference_nir_image,tform_nir,'OutputView',Roriginal); % NIR
% darkReference_reg = imwarp(darkReference_reg_image,tform_reg,'OutputView',Roriginal); % REG
% % convert to double
% darkReference_rgb = double(darkReference_rgb_image); % GRE
% darkReference_gre = double(darkReference_gre); % GRE
% darkReference_red = double(darkReference_red); % RED
% darkReference_nir = double(darkReference_nir); % NIR
% darkReference_reg = double(darkReference_reg); % REG
% % make dark refrence similar size of the refrence images
% rect_moving = [1600 1100 1461 1000];
% darkReference_rgb= imcrop(darkReference_rgb,rect_moving);
% darkReference_nir= imcrop(darkReference_nir,rect_moving);
% darkReference_reg= imcrop(darkReference_reg,rect_moving);
% darkReference_red= imcrop(darkReference_red,rect_moving);
% darkReference_gre= imcrop(darkReference_gre,rect_moving);

%% Convert refrence data to double
referenceData_rgb=rgb_image;
referenceData_nir=nir_image;
referenceData_reg=reg_image;
referenceData_gre=gre_image;
referenceData_red=red_image;  
% % imagesc(referenceData_red)

%% measure illumination difference against the reference dataset across four corners
[rows,cols,~]=size(referenceData_rgb);
% spectrum at specific point - 4x4 pixel starting at topLeft (1,1) location
illuminationDifference_rgb(1,1,:)=mean(mean(referenceData_rgb(1:4,1:4,:)));
illuminationDifference_nir(1,1,:)=mean(mean(referenceData_nir(1:4,1:4,:)));
illuminationDifference_reg(1,1,:)=mean(mean(referenceData_reg(1:4,1:4,:)));
illuminationDifference_gre(1,1,:)=mean(mean(referenceData_gre(1:4,1:4,:)));
illuminationDifference_red(1,1,:)=mean(mean(referenceData_red(1:4,1:4,:)));
% spectrum at specific point - 4x4 pixel starting at topRight (1,2) location
illuminationDifference_rgb(1,cols,:)=mean(mean(referenceData_rgb(1:4,cols-4:cols,:)));
illuminationDifference_nir(1,cols,:)=mean(mean(referenceData_nir(1:4,cols-4:cols,:)));
illuminationDifference_reg(1,cols,:)=mean(mean(referenceData_reg(1:4,cols-4:cols,:)));
illuminationDifference_gre(1,cols,:)=mean(mean(referenceData_gre(1:4,cols-4:cols,:)));
illuminationDifference_red(1,cols,:)=mean(mean(referenceData_red(1:4,cols-4:cols,:)));
% spectrum at specific point - 4x4 pixel starting at bottomLeft (1,2) location
illuminationDifference_rgb(rows,1,:)=mean(mean(referenceData_rgb(rows-4:rows,1:4,:)));
illuminationDifference_nir(rows,1,:)=mean(mean(referenceData_nir(rows-4:rows,1:4,:)));
illuminationDifference_reg(rows,1,:)=mean(mean(referenceData_reg(rows-4:rows,1:4,:)));
illuminationDifference_gre(rows,1,:)=mean(mean(referenceData_gre(rows-4:rows,1:4,:)));
illuminationDifference_red(rows,1,:)=mean(mean(referenceData_red(rows-4:rows,1:4,:)));
% spectrum at specific point - 4x4 pixel starting at bottomRight (1,2) location
illuminationDifference_rgb(rows,cols,:)=mean(mean(referenceData_rgb(rows-4:rows,cols-4:cols,:)));
illuminationDifference_nir(rows,cols,:)=mean(mean(referenceData_nir(rows-4:rows,cols-4:cols,:)));
illuminationDifference_reg(rows,cols,:)=mean(mean(referenceData_reg(rows-4:rows,cols-4:cols,:)));
illuminationDifference_gre(rows,cols,:)=mean(mean(referenceData_gre(rows-4:rows,cols-4:cols,:)));
illuminationDifference_red(rows,cols,:)=mean(mean(referenceData_red(rows-4:rows,cols-4:cols,:)));
%Convert all the zero pixels to NaN except the corner pixels
illuminationDifference_rgb(illuminationDifference_rgb==0)=NaN; % convert all zeros to NaN
illuminationDifference_gre(illuminationDifference_gre==0)=NaN; % convert all zeros to NaN
illuminationDifference_reg(illuminationDifference_reg==0)=NaN; % convert all zeros to NaN
illuminationDifference_red(illuminationDifference_red==0)=NaN; % convert all zeros to NaN
illuminationDifference_nir(illuminationDifference_nir==0)=NaN; % convert all zeros to NaN
%% interpolate the illumination difference matrix (hypercube) 
%RGB
illuminationDifference_rgb=fillmissing(illuminationDifference_rgb,'spline',1);
illuminationDifference_rgb=fillmissing(illuminationDifference_rgb,'spline',2);
%GRE
illuminationDifference_gre=fillmissing(illuminationDifference_gre,'spline',1);
illuminationDifference_gre=fillmissing(illuminationDifference_gre,'spline',2);
%REG
illuminationDifference_reg=fillmissing(illuminationDifference_reg,'spline',1);
illuminationDifference_reg=fillmissing(illuminationDifference_reg,'spline',2);
%RED
illuminationDifference_red=fillmissing(illuminationDifference_red,'spline',1);
illuminationDifference_red=fillmissing(illuminationDifference_red,'spline',2);
%NIR
illuminationDifference_nir=fillmissing(illuminationDifference_nir,'spline',1);
illuminationDifference_nir=fillmissing(illuminationDifference_nir,'spline',2);
%% Calculate min max values of interpolated images for each channels
minvalue_rgb_red=min(min(illuminationDifference_rgb(:,:,1)));
minvalue_rgb_green=min(min(illuminationDifference_rgb(:,:,2)));
minvalue_rgb_blue=min(min(illuminationDifference_rgb(:,:,3)));
minvalue_red=min(min(illuminationDifference_red));
minvalue_gre=min(min(illuminationDifference_gre));
minvalue_reg=min(min(illuminationDifference_reg));
minvalue_nir=min(min(illuminationDifference_nir));
%% Calculate the difference from the min values in each pixels for each channels
illuminationDifference_rgb_min(:,:,1)=illuminationDifference_rgb(:,:,1)-minvalue_rgb_red;
illuminationDifference_rgb_min(:,:,2)=illuminationDifference_rgb(:,:,2)-minvalue_rgb_green;
illuminationDifference_rgb_min(:,:,3)=illuminationDifference_rgb(:,:,3)-minvalue_rgb_blue;
illuminationDifference_gre_min=illuminationDifference_gre-minvalue_gre;
illuminationDifference_red_min=illuminationDifference_red-minvalue_red;
illuminationDifference_nir_min=illuminationDifference_nir-minvalue_nir;
illuminationDifference_reg_min=illuminationDifference_reg-minvalue_reg;
%% Subtract the original image from the illuminationDifference_min to get corrected gradient
correctedData_rgb(:,:,1)=referenceData_rgb(:,:,1)-illuminationDifference_rgb_min(:,:,1);
correctedData_rgb(:,:,2)=referenceData_rgb(:,:,2)-illuminationDifference_rgb_min(:,:,2);
correctedData_rgb(:,:,3)=referenceData_rgb(:,:,3)-illuminationDifference_rgb_min(:,:,3);
correctedData_gre=referenceData_gre-illuminationDifference_gre_min;
correctedData_red=referenceData_red-illuminationDifference_red_min;
correctedData_nir=referenceData_nir-illuminationDifference_nir_min;
correctedData_reg=referenceData_reg-illuminationDifference_reg_min;
%% Interpolate a white refrence image from the gradient corrected data smilar process as above
% measure illumination difference against the reference dataset across four corners
% spectrum at specific point - 4x4 pixel starting at topLeft (1,1) location
whiteReference_rgb(1,1,:)=mean(mean(correctedData_rgb(1:4,1:4,:)));
whiteReference_nir(1,1,:)=mean(mean(correctedData_nir(1:4,1:4,:)));
whiteReference_reg(1,1,:)=mean(mean(correctedData_reg(1:4,1:4,:)));
whiteReference_gre(1,1,:)=mean(mean(correctedData_gre(1:4,1:4,:)));
whiteReference_red(1,1,:)=mean(mean(correctedData_red(1:4,1:4,:)));
% spectrum at specific point - 4x4 pixel starting at topRight (1,2) location
whiteReference_rgb(1,cols,:)=mean(mean(correctedData_rgb(1:4,cols-4:cols,:)));
whiteReference_nir(1,cols,:)=mean(mean(correctedData_nir(1:4,cols-4:cols,:)));
whiteReference_reg(1,cols,:)=mean(mean(correctedData_reg(1:4,cols-4:cols,:)));
whiteReference_gre(1,cols,:)=mean(mean(correctedData_gre(1:4,cols-4:cols,:)));
whiteReference_red(1,cols,:)=mean(mean(correctedData_red(1:4,cols-4:cols,:)));
% spectrum at specific point - 4x4 pixel starting at bottomLeft (1,2) location
whiteReference_rgb(rows,1,:)=mean(mean(correctedData_rgb(rows-4:rows,1:4,:)));
whiteReference_nir(rows,1,:)=mean(mean(correctedData_nir(rows-4:rows,1:4,:)));
whiteReference_reg(rows,1,:)=mean(mean(correctedData_reg(rows-4:rows,1:4,:)));
whiteReference_gre(rows,1,:)=mean(mean(correctedData_gre(rows-4:rows,1:4,:)));
whiteReference_red(rows,1,:)=mean(mean(correctedData_red(rows-4:rows,1:4,:)));
% spectrum at specific point - 4x4 pixel starting at bottomRight (1,2) location
whiteReference_rgb(rows,cols,:)=mean(mean(correctedData_rgb(rows-4:rows,cols-4:cols,:)));
whiteReference_nir(rows,cols,:)=mean(mean(correctedData_nir(rows-4:rows,cols-4:cols,:)));
whiteReference_reg(rows,cols,:)=mean(mean(correctedData_reg(rows-4:rows,cols-4:cols,:)));
whiteReference_gre(rows,cols,:)=mean(mean(correctedData_gre(rows-4:rows,cols-4:cols,:)));
whiteReference_red(rows,cols,:)=mean(mean(correctedData_red(rows-4:rows,cols-4:cols,:)));
%Convert all the zero pixels to NaN except the corner pixels
whiteReference_rgb(whiteReference_rgb==0)=NaN; % convert all zeros to NaN
whiteReference_gre(whiteReference_gre==0)=NaN; % convert all zeros to NaN
whiteReference_reg(whiteReference_reg==0)=NaN; % convert all zeros to NaN
whiteReference_red(whiteReference_red==0)=NaN; % convert all zeros to NaN
whiteReference_nir(whiteReference_nir==0)=NaN; % convert all zeros to NaN
%% interpolate the white refrence difference matrix (hypercube) for each band
%RGB
whiteReference_rgb=fillmissing(whiteReference_rgb,'spline',1);
whiteReference_rgb=fillmissing(whiteReference_rgb,'spline',2);
%GRE
whiteReference_gre=fillmissing(whiteReference_gre,'spline',1);
whiteReference_gre=fillmissing(whiteReference_gre,'spline',2);
%REG
whiteReference_reg=fillmissing(whiteReference_reg,'spline',1);
whiteReference_reg=fillmissing(whiteReference_reg,'spline',2);
%RED
whiteReference_red=fillmissing(whiteReference_red,'spline',1);
whiteReference_red=fillmissing(whiteReference_red,'spline',2);
%NIR
whiteReference_nir=fillmissing(whiteReference_nir,'spline',1);
whiteReference_nir=fillmissing(whiteReference_nir,'spline',2);
%%



%% measure dark difference against the reference dataset across four corners
%[rows,cols,~]=size(darkReference_rgb);
% spectrum at specific point - 4x4 pixel starting at topLeft (1,1) location
% darkref_rgb(1,1,:)=mean(mean(darkReference_rgb(1:4,1:4,:)));
% darkref_nir(1,1,:)=mean(mean(darkReference_nir(1:4,1:4,:)));
% darkref_reg(1,1,:)=mean(mean(darkReference_reg(1:4,1:4,:)));
% darkref_gre(1,1,:)=mean(mean(darkReference_gre(1:4,1:4,:)));
% darkref_red(1,1,:)=mean(mean(darkReference_red(1:4,1:4,:)));
% spectrum at specific point - 4x4 pixel starting at topRight (1,2) location
% darkref_rgb(1,cols,:)=mean(mean(darkReference_rgb(1:4,cols-4:cols,:)));
% darkref_nir(1,cols,:)=mean(mean(darkReference_nir(1:4,cols-4:cols,:)));
% darkref_reg(1,cols,:)=mean(mean(darkReference_reg(1:4,cols-4:cols,:)));
% darkref_gre(1,cols,:)=mean(mean(darkReference_gre(1:4,cols-4:cols,:)));
% darkref_red(1,cols,:)=mean(mean(darkReference_red(1:4,cols-4:cols,:)));
% spectrum at specific point - 4x4 pixel starting at bottomLeft (1,2) location
% darkref_rgb(rows,1,:)=mean(mean(darkReference_rgb(rows-4:rows,1:4,:)));
% darkref_nir(rows,1,:)=mean(mean(darkReference_nir(rows-4:rows,1:4,:)));
% darkref_reg(rows,1,:)=mean(mean(darkReference_reg(rows-4:rows,1:4,:)));
% darkref_gre(rows,1,:)=mean(mean(darkReference_gre(rows-4:rows,1:4,:)));
% darkref_red(rows,1,:)=mean(mean(darkReference_red(rows-4:rows,1:4,:)));
% spectrum at specific point - 4x4 pixel starting at bottomRight (1,2) location
% darkref_rgb(rows,cols,:)=mean(mean(darkReference_rgb(rows-4:rows,cols-4:cols,:)));
% darkref_nir(rows,cols,:)=mean(mean(darkReference_nir(rows-4:rows,cols-4:cols,:)));
% darkref_reg(rows,cols,:)=mean(mean(darkReference_reg(rows-4:rows,cols-4:cols,:)));
% darkref_gre(rows,cols,:)=mean(mean(darkReference_gre(rows-4:rows,cols-4:cols,:)));
% darkref_red(rows,cols,:)=mean(mean(darkReference_red(rows-4:rows,cols-4:cols,:)));
% %Convert all the zero pixels to NaN except the corner pixels
% darkref_rgb(darkref_rgb==0)=NaN; % convert all zeros to NaN
% darkref_gre(darkref_gre==0)=NaN; % convert all zeros to NaN
% darkref_reg(darkref_reg==0)=NaN; % convert all zeros to NaN
% darkref_red(darkref_red==0)=NaN; % convert all zeros to NaN
% darkref_nir(darkref_nir==0)=NaN; % convert all zeros to NaN
%% interpolate the dark difference matrix (hypercube) 
% %RGB
% darkref_rgb=fillmissing(darkref_rgb,'spline',1);
% darkref_rgb=fillmissing(darkref_rgb,'spline',2);
% %GRE
% darkref_gre=fillmissing(darkref_gre,'spline',1);
% darkref_gre=fillmissing(darkref_gre,'spline',2);
% %REG
% darkref_reg=fillmissing(darkref_reg,'spline',1);
% darkref_reg=fillmissing(darkref_reg,'spline',2);
% %RED
% darkref_red=fillmissing(darkref_red,'spline',1);
% darkref_red=fillmissing(darkref_red,'spline',2);
% %NIR
% darkref_nir=fillmissing(darkref_nir,'spline',1);
% darkref_nir=fillmissing(darkref_nir,'spline',2);
%%
darkReference_rgb = rand(size(correctedData_rgb));

a=0;
b=1;
darkReference_rgb = (b-a).*darkReference_rgb + a;

%% Illumination correction 
% refFactor=0.76;%Reflectivity of the background
% calibrated_rgb=((correctedData_rgb-darkref_rgb)./(whiteReference_rgb-darkref_rgb)).*255;
% calibrated_gre=((correctedData_gre-darkref_gre)./(whiteReference_gre-darkref_gre)).*refFactor;
% calibrated_red=((correctedData_red-darkref_red)./(whiteReference_red-darkref_red)).*refFactor;
% calibrated_nir=((correctedData_nir-darkref_nir)./(whiteReference_nir-darkref_nir)).*0.79463;
% calibrated_reg=((correctedData_reg-darkref_reg)./(whiteReference_reg-darkref_reg)).*refFactor;

calibrated_rgb=((correctedData_rgb-darkReference_rgb)./(whiteReference_rgb-darkReference_rgb)).*255;
calibrated_gre=((correctedData_gre)./(whiteReference_gre)).*0.79517;
calibrated_red=((correctedData_red)./(whiteReference_red)).*0.802485;
calibrated_nir=((correctedData_nir)./(whiteReference_nir)).*0.79463;
calibrated_reg=((correctedData_reg)./(whiteReference_reg)).*0.798927;

end
