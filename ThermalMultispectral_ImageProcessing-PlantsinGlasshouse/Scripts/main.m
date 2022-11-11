%
%   Description: batch processing of rgb and ir coregistration
%   Author: Neelesh Sharma
%   Date: 14/12/2021
%   Comment:
%   Tests run:
% Clear command window, and erase all existing variables

clc;        % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;      % Erase all existing variables.
%%
%Load the transformation matrix
load tform_thermal.mat
load tform_gre.mat
load tform_nir.mat
load tform_red.mat
load tform_reg.mat
%Load camera params for optical distortion
load cameraParams_rgb.mat
load cameraParams_gre.mat
load cameraParams_nir.mat
load cameraParams_red.mat
load cameraParams_reg.mat
%%
% Read image data and create folders for input( thermal images) and output(calibrated data)
thermal_imageFormat= ".jpg"; % Specify the image format.
rgb_imageFormat= ".JPG"; % Specify the image format.
parentfolder = 'D:\Phd\thermal\ThermalMultispectral_ImageProcessing-PlantsinGlasshouse\Data\Images_Test'; % parent folder for i/p & o/p
thermal_myFolder = parentfolder+"\Thermal"; % Path for input data.
sequioa_myFolder = parentfolder+"\Multispectral"; % Path for input data.
%%
% Store images filenames from folder to an array
%Sort filenasme of thermal images
S = dir(fullfile(thermal_myFolder,'*.jpg'));
N = natsortfiles({S.name});
F = cellfun(@(n)fullfile(thermal_myFolder,n),N,'uni',0);
thermal_fullFileNames =  F';
thermal_numFiles = length(thermal_fullFileNames);
% Store images filenames from sequioa to an array
rgb_fullFileNames=getFullfilenames(sequioa_myFolder,"RGB","jpg")
gre_fullFileNames=getFullfilenames(sequioa_myFolder,"GRE","tif")
nir_fullFileNames=getFullfilenames(sequioa_myFolder,"NIR","tif")
red_fullFileNames=getFullfilenames(sequioa_myFolder,"RED","tif")
reg_fullFileNames=getFullfilenames(sequioa_myFolder,"REG","tif")
%%
stacked_maskedimage=[];
canopy_pixelcount_left=[];
canopy_pixelcount_right=[];
ndvi_image=[];
ci_re_image=[];
calibrated_wrappedimage=[];
ndre_image=[];
calibrated_fusedimage=[];
wrapped_image=[]; % stores the final calibrated images
numFiles = length(thermal_fullFileNames); % check the number of files same for both it and rgb
resFactor_thermal=2.5;
resFactor_sequioa=3.6;
rmse_regis =[];
rmse_seg_values=[];
rmse_seg =[];
rmse_values_coarse = [];
rmse_values_fine = [];
vegindices_cube=[];
for k = 1: numFiles

    %%Read and process RGB data
    fprintf('Now reading file %s\n', rgb_fullFileNames{k});
    rgb_data_image = imrotate(imread(rgb_fullFileNames{k}),180);
    rgb_gray_image=rgb2gray(rgb_data_image);

  
    % Read and process thermal data
    fprintf('Now reading file %s\n', thermal_fullFileNames{k});
    thermal_image = imread(thermal_fullFileNames{k});
    thermal_data_image=double(thermal_image)/255;
    thermal_data_image=thermal_data_image(:,1:640); %subset the image
    thermal_data_image=increaseResolution(thermal_data_image,resFactor_thermal);


    % Read and process GRE data
    fprintf('Now reading file %s\n', gre_fullFileNames{k});
    gre_image = imrotate(imread(gre_fullFileNames{k}),180);
    gre_image=undistortImage(gre_image,cameraParams_gre);
    minImage_gre = min(min(gre_image));maxImage_gre = max(max(gre_image));
    gre_data_image=double(gre_image);
    gre_data_image=gre_data_image/double(maxImage_gre-minImage_gre);
    gre_data_image=increaseResolution(gre_data_image,resFactor_sequioa);

    % Read and process RED data
    fprintf('Now reading file %s\n', red_fullFileNames{k});
    red_image = imrotate(imread(red_fullFileNames{k}),180);
    red_image=undistortImage(red_image,cameraParams_red);
    minImage_red = min(min(red_image));maxImage_red = max(max(red_image));
    red_data_image=double(red_image);
    red_data_image=red_data_image/double(maxImage_red-minImage_red);
    red_data_image=increaseResolution(red_data_image,resFactor_sequioa);

    % Read and process NIR data
    fprintf('Now reading file %s\n', nir_fullFileNames{k});
    nir_image = imrotate(imread(nir_fullFileNames{k}),180);
    nir_image=undistortImage(nir_image,cameraParams_nir);
    minImage_nir = min(min(nir_image));maxImage_nir = max(max(nir_image));
    nir_data_image=double(nir_image);
    nir_data_image=nir_data_image/double(maxImage_nir-minImage_nir);
    nir_data_image=increaseResolution(nir_data_image,resFactor_sequioa);

    % Read and process REG data
    fprintf('Now reading file %s\n', reg_fullFileNames{k});
    reg_image = imrotate(imread(reg_fullFileNames{k}),180);
    reg_image=undistortImage(reg_image,cameraParams_reg);
    minImage_reg = min(min(reg_image));maxImage_reg = max(max(reg_image));
    reg_data_image=double(reg_image);
    reg_data_image=reg_data_image/double(maxImage_reg-minImage_reg);
    reg_data_image=increaseResolution(reg_data_image,resFactor_sequioa);

    %%Apply transfomration matrix to the moving images(thermal,gre,reg,nir,red) image
    Roriginal = imref2d(size(rgb_data_image)); % sizr of the fixed image (rgb)
    recovered_image_thermal = imwarp(thermal_data_image,tform_thermal,'OutputView',Roriginal); % thermal
    recovered_image_gre = imwarp(gre_data_image,tform_gre,'OutputView',Roriginal); % GRE
    recovered_image_red = imwarp(red_data_image,tform_red,'OutputView',Roriginal); % RED
    recovered_image_nir = imwarp(nir_data_image,tform_nir,'OutputView',Roriginal); % NIR
    recovered_image_reg = imwarp(reg_data_image,tform_reg,'OutputView',Roriginal); % REG


    %Process for fine registraion (intensity based registraion)
    % Create a roi for images for fine registration
    rect_fixed = [1950 1250 800 800];
    %Assign fixed and moving images
    fixed = imcrop(rgb_data_image,rect_fixed); % image fixed rgb
    moving_thermal = imcrop(recovered_image_thermal(:,:,1),rect_fixed); % the moving image thermal
    moving_gre = imcrop(recovered_image_gre(:,:,1),rect_fixed); % the moving image GRE
    moving_red = imcrop(recovered_image_red(:,:,1),rect_fixed); % the moving image RED
    moving_nir = imcrop(recovered_image_nir(:,:,1),rect_fixed); % the moving image NIR
    moving_reg = imcrop(recovered_image_reg(:,:,1),rect_fixed); % the moving image REG
    %imshowpair(fixed,moving_red,"montage")

    % intensity based registration thermal
    [optimizer_thermal,metric_thermal] = imregconfig('multimodal');
    optimizer_thermal.InitialRadius = optimizer_thermal.InitialRadius/15 ; optimizer_thermal.Epsilon = optimizer_thermal.Epsilon/2;
    optimizer_thermal.GrowthFactor= optimizer_thermal.GrowthFactor ; optimizer_thermal.MaximumIterations = 100;%--1000;
    adjusted_thermal = imregister(moving_thermal,fixed(:,:,1),'Similarity',optimizer_thermal,metric_thermal,'DisplayOptimization',true);
    %imshowpair(adjusted_thermal,fixed,"montage")

    % intensity based registration gre
    [optimizer_gre,metric_gre] = imregconfig('multimodal');
    optimizer_gre.InitialRadius = optimizer_gre.InitialRadius/15 ; optimizer_gre.Epsilon = optimizer_gre.Epsilon/2;
    optimizer_gre.GrowthFactor= optimizer_gre.GrowthFactor ; optimizer_gre.MaximumIterations = 10;%--1000;
    adjusted_gre = imregister(moving_gre,fixed(:,:,2),'Similarity',optimizer_gre,metric_gre);
    %imshowpair(adjusted_gre,fixed,"montage")
    %imshowpair(adjusted_gre,fixed,"Scaling","Joint")

    %intensity based registration red
    [optimizer_red,metric_red] = imregconfig('multimodal');
    optimizer_red.InitialRadius = optimizer_red.InitialRadius/15 ; optimizer_red.Epsilon = optimizer_red.Epsilon/2;
    optimizer_red.GrowthFactor= optimizer_red.GrowthFactor ; optimizer_red.MaximumIterations = 10;%--1000;
    adjusted_red = imregister(moving_red,fixed(:,:,2),'Similarity',optimizer_red,metric_red);
    %imshowpair(adjusted_red,fixed,"falsecolor")
    %imshowpair(adjusted_red,fixed,"Scaling","Joint")
    %imshowpair(fixed,adjusted_red,"montage")

    % intensity based registration nir
    [optimizer_nir,metric_nir] = imregconfig('multimodal');
    optimizer_nir.InitialRadius = optimizer_nir.InitialRadius/100 ; optimizer_nir.Epsilon = optimizer_nir.Epsilon/2;
    optimizer_nir.GrowthFactor= optimizer_nir.GrowthFactor ; optimizer_nir.MaximumIterations = 10;%--1000;
    adjusted_nir = imregister(moving_nir,fixed(:,:,1),'Similarity',optimizer_nir,metric_nir);
    %imshowpair(adjusted_nir,fixed,"montage")
    %imshowpair(adjusted_nir,fixed,"Scaling","Joint")

    % intensity based registration reg
    [optimizer_reg,metric_reg] = imregconfig('multimodal');
    optimizer_reg.InitialRadius = optimizer_reg.InitialRadius/100 ; optimizer_reg.Epsilon = optimizer_reg.Epsilon/2;
    optimizer_reg.GrowthFactor= optimizer_reg.GrowthFactor ; optimizer_reg.MaximumIterations = 10;%--1000;
    adjusted_reg = imregister(moving_reg,fixed(:,:,1),'Similarity',optimizer_reg,metric_reg);
    %imshowpair(adjusted_reg,fixed,"montage")
    %imshowpair(adjusted_nir,fixed,"Scaling","Joint")

    % Call function minmaxcalibration: Returns min and max value of temperature in thermal image
    [minThermal,maxThermal]=getminmaxcalibration(thermal_image);
    % min and max data points(index) of the thermal image
    minData = min(min(double(thermal_image(:,:,1))));
    maxData = max(max(double(thermal_image(:,:,1))));


    %Calibrate temp data using the mathematical formula and return
    calibTempData= (double(adjusted_thermal)*((maxThermal-minThermal)/(maxData-minData)))+(minThermal);
    %imagesc(calibTempData)
  

    %Wrap all the bands together RGB,GRE,RED,NIR,REG,THERMAL
    fused_image=double(fixed);
    fused_image(:,:,4)=(adjusted_gre);
    fused_image(:,:,5)=(adjusted_red);
    fused_image(:,:,6)=(adjusted_nir);
    fused_image(:,:,7)=(adjusted_reg);
    fused_image(:,:,8)=(calibTempData);

    % save all bands in array
    wrapped_image=[wrapped_image;{fused_image}];

    %imagesc(fused_image(:,:,1))
    %imagesc(fixed)

    %Call function for illumination correction
    rect_calib= [20 20 770 770];
    %Adjust images after fine registration
    adjusted_rgb=imcrop(fixed,rect_calib);
    adjusted_rgb_c=double(adjusted_rgb);
    adjusted_red_c=imcrop(adjusted_red,rect_calib);
    adjusted_gre_c=imcrop(adjusted_gre,rect_calib);
    adjusted_nir_c=imcrop(adjusted_nir,rect_calib);
    adjusted_reg_c=imcrop(adjusted_reg,rect_calib);
    calibTempData_c=imcrop(calibTempData,rect_calib);

    %imshow((adjusted_rgb))

    [calibrated_rgb,calibrated_red,calibrated_gre,calibrated_nir,calibrated_reg] = getilluminationadjustment(adjusted_rgb_c,adjusted_red_c,adjusted_gre_c,adjusted_nir_c,adjusted_reg_c);
   
    calibrated_fusedimage(:,:,1:3)=calibrated_rgb;
    calibrated_fusedimage(:,:,4)=calibrated_gre;
    calibrated_fusedimage(:,:,5)=calibrated_red;
    calibrated_fusedimage(:,:,6)=calibrated_nir;
    calibrated_fusedimage(:,:,7)=calibrated_reg;
    calibrated_fusedimage(:,:,8)=calibTempData_c;
    
    calibrated_wrappedimage=[calibrated_wrappedimage;{calibrated_fusedimage}];

    %imagesc(calibrated_fusedimage(:,:,8))

    %segmentation process
    foreground_image=im2double(adjusted_rgb(:,:,1));
    background_mask= imbinarize(foreground_image(:,:,1),'adaptive','ForegroundPolarity','dark');
    foreground_mask= double(~background_mask);
    foreground_mask(foreground_mask==0)=NaN;

    %Mask all the bands together RGB,GRE,RED,NIR,REG,THERMAL
    masked_Image = calibrated_fusedimage.*foreground_mask;
    % save masked image in array
    stacked_maskedimage=[stacked_maskedimage;{(masked_Image)}];
    %imagesc(masked_Image(:,:,6))

    %calculate vegetative parameters
    [ndvi,mcari1,mtci,ndre,rdvi,ccci,cvi,ci_green,ci_g,ci_re]  = getVegetativeIndices(masked_Image(:,:,4),masked_Image(:,:,5),masked_Image(:,:,6),masked_Image(:,:,7));
    %imagesc(ndvi)

end
