function out=plane(in)
I = in;  
[h,w] = size(I);
[X Y] = meshgrid(1:w,1:h);
%# fit a linear plane over 3D points [X Y Z], Z is the pixel intensities
coeff = [X(:) Y(:) ones(w*h,1)] \ I(:);
%# compute shading plane
shading = coeff(1).*X + coeff(2).*Y + coeff(3);
%# subtract shading from image
EE = I - shading;
out=EE;
end