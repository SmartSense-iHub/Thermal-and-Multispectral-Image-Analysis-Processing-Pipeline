
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

function [minThermal,maxThermal] = getminmaxcalibration(data_image)
    
    % Read Image files
    dataX=data_image;

    data_image = (data_image);

    rect_max = [552 88 70 37];
    rect_min = [552 355 70 37];
    %Assign fixed and moving images
  
   % fixed = imcrop(thermal_data_image,rect_fixed); % image fixed rgb
    maxTempImage = imcrop(data_image(:,:,1),rect_max); % the moving image thermal

    minTempImage = imcrop(data_image(:,:,1),rect_min); % the moving image thermal

    %Crop image for mintemprange
%     minTempImage = imcorp( data,[550 350 70 70]);
%     maxTempImage = imcorp( data,[550 90 70 70]);

   % imshowpair(minTempImage,maxTempImage)

    %  minTempImage = dataX(353:394,549:623);
    %maxTempImage = dataX(85:127,549:623);
% 
%       maxTempImage = dataX(1308:1420,2939:3125);
%       minTempImage = dataX(1980:2102,2939:3125);

    % perform thresholding for number pixel
    image_thresholded_min = minTempImage;
    image_thresholded_min(minTempImage<180) = 0;
    image_thresholded_max = maxTempImage;
    image_thresholded_max(maxTempImage<180) = 0;

    % extract min max temperature
    ocrResults_min = ocr(image_thresholded_min,CharacterSet="1234567890.");
    recognizedText_min = ocrResults_min.Text;
    %recognizedText_min;
    ocrResults_max = ocr(image_thresholded_max,CharacterSet="1234567890.");
    recognizedText_max = ocrResults_max.Text;
   
    %Calibrate rgb to thermal
    minThermal_data = str2double(recognizedText_min);
    maxThermal_data = str2double(recognizedText_max);
% 
%     minData = min(min(data_image));
%     maxData = max(max(data_image));
% 
%     %calibrate temp data using the mathematical formula and return
%     %calibrated data, min and max thermal 
%     calibTempData= data_image*((maxThermal_data-minThermal_data)/(maxData-minData))+minThermal_data;
    minThermal=double(minThermal_data);
    maxThermal=double(maxThermal_data);

end