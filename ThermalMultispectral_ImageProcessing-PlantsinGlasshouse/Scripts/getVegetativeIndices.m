function  [ndvi,ndre,rdvi,cvi,ci_green,ci_re]  = getVegetativeIndices(gre_image,red_image,nir_image,reg_image)
    %rgb=rgb_image;
    gre=gre_image;
    red=red_image;
    nir=nir_image;
    reg=reg_image;
   % thermal=thermal_image;
    %% vegeation indices formulas
    ndvi = (nir - red) ./ (nir + red);
    ndre = (nir - reg)./(nir + reg);
    rdvi = (nir - red)./sqrt(nir + red);
    cvi = nir.*(red ./ (gre .* gre));
    ci_green = (nir./gre) - 1;
    ci_re = (nir./reg) - 1;
%     gdvi2 = (nir.^2 - red.^2) ./ (nir.^2 + red.^2);
%     gndvi = (nir - gre)./(nir + gre);
 %   ccci = ((nir - reg) ./ (nir + reg)) ./ ((nir - red) ./ (nir + red));
%     grvi = (gre - red)./(gre + red);
%     osavi = (nir - red)./(nir + red + 0.16);
%     gosavi = (gre - red)./(gre + red + 0.16);
%     gsavi = 1.5*((nir - gre)./(nir + gre + 0.5));
%     msr = ((nir./red)-1)./(sqrt(nir./red)+1);
%     mcari1 = (1.2*(2.5*(nir - red) - 1.3*(nir - gre)));
%  %   mcari2 = (1.2*(2.5*(nir - red) - 1.3*(nir - green)))./sqrt(2*(nir+1)**2 - (6*nir-5*(sqrt(red))-0.5));
%     mtvi1 = 1.2*(1.2*(nir - gre) - 2.5*(red - gre));
%   %  mtvi2 = (1.5*(1.2*(nir - green) - 2.5*(red - green)))./sqrt(2*(nir+1)**2 - (6*nir-5*(sqrt(red))-0.5));
%     pssra = nir./red;
%     rvi = red./nir;

end