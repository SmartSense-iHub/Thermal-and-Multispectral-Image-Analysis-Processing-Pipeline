function outImage=increaseResolution(inImage,factor)
sz = size(inImage);
xg = 1:sz(1);
yg = 1:sz(2);
F = griddedInterpolant({xg,yg},double(inImage));

xq = (0:1/factor:sz(1))';
yq = (0:1/factor:sz(2))';
outImage = (F({xq,yq}));
% imshow(outImage)
% title('Higher Resolution')
end