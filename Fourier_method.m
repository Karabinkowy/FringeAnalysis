%% Fourier transform of generated Custom fringes  
clc;
clear;
close all;

% create fringe pattern: a(x, y) + b(x, y)cos(fi(x, y)) + n(x, y)
[x,y] = meshgrid(1:1:512);
background = gradient(peaks(512));
noise = 0.1.*randn(512);

period = 25;
orient = pi/3;
carrier_fringes = (2*pi/period)*(x*cos(orient)+y*sin(orient));

phase_modulation = peaks(512);
amp = linspace(0,1,512);
fringe_pattern = 3.*background + amp.*cos(carrier_fringes+phase_modulation) + noise;


input = fftshift(fft2(fringe_pattern));
input_clean = fftshift(fft2(3.*background + amp.*cos(carrier_fringes+phase_modulation)))

% change mask coordinates to where spectre of fringe pattern is
mask = zeros(512, 512);
mask_x = 19;
mask_y = 11;

% 275, 267 (mask coordinates)
mask(size(mask, 1) / 2 + mask_x, size(mask, 2) / 2 + mask_y) = 1; 
h = fspecial('gaussian',512,7);
gaussian_mask = imfilter(mask, h);

% phase is the angle of the imaginary number
wr_phase = angle(ifft2(ifftshift(input.*gaussian_mask)));
unw_phase = double(Miguel_2D_unwrapper(single(wr_phase))); 
output = plane(unw_phase);

nexttile
imagesc(fringe_pattern); 
title("Fringe pattern");

nexttile
imagesc(abs(input));
title("Fourier transform of an image");


nexttile
imagesc(log(1+abs(input))); 
title("Enhanced Fourier transform");

nexttile
imagesc(gaussian_mask);
title("Gaussian mask");

nexttile
imagesc(wr_phase) 
title("Wrapped phase");

nexttile
imagesc(output)
title("Unwrapped phase");

%% Find images hidden in amplitude or phase of fringes
% First use Fourier transform to see images hidden in phase, then use
% 4-frame algorithm to see sharp image hidden in the amplitude and in the
% phase.

clc;
clear;
close all;

% check if the path is alright
FT1 = imread("images\im1.bmp");
FT2 = imread("images\im2.bmp");
FT3 = imread("images\im3.bmp");
FT4 = imread("images\im4.bmp");

% tranform data points to 0-1 range
I(:,:,1) = double(rgb2gray(FT1))./ 255.0;
I(:,:,2) = double(rgb2gray(FT2))./ 255.0;
I(:,:,3) = double(rgb2gray(FT3))./ 255.0;
I(:,:,4) = double(rgb2gray(FT4))./ 255.0;

I_amp(:, :, 1) = zeros(512);
I_amp(:, :, 2) = zeros(512);
I_amp(:, :, 3) = zeros(512);
I_amp(:, :, 4) = zeros(512);

for i = 1:4

    input = fftshift(fft2(I(:, :, i)));

    figure
    colormap gray
    tiledlayout(1,4)

    % show enhanced Fourier spectre
    nexttile 
    imagesc(log(1+abs(input)));

    mask = zeros(size(I(:,:,i), 1),size(I(:,:,i), 2));
    
    % change mask coordinates so that the center is in the middle of the
    % spectre of the image
    mask_x = 60;
    mask_y = 7;
    
    % pixel with the center of the mask is 1, the rest is 0
    mask(size(I(:,:,i))/ 2 + mask_y, size(I(:,:,i))/ 2 + mask_x) = 1;

    % create gaussian filter
    gaussian_mask = imfilter(mask,fspecial('gaussian',size(I(:,:,i)),5));

    fTransform = ifft2(ifftshift(input.*gaussian_mask));
    
    % calculate phase from the angle of the imaginary number
    wr_phase = angle(fTransform);
    unw_phase = double(Miguel_2D_unwrapper(single(wr_phase))); 
    % used plane algorithm to subtract plane
    % used to get 
    %check if the plan.m script is in the working directory
    output = plane(unw_phase);

    nexttile    
    imagesc(wr_phase);
    title 'Wrapped phase'

    nexttile
    imagesc(unw_phase);
    title 'Unwrapped phase'

    nexttile
    imagesc(output);
    title 'Unwrapped minus plane'

end

figure
colormap gray
tiledlayout(1,3)

% used 4-frame algorithm to receive a sharp image
wrapped_phase = atan2((I(:,:,4) - I(:,:,2)), (I(:,:,1) - I(:,:,3)));
unwrapped_phase = double(Miguel_2D_unwrapper(single(wrapped_phase)));
image_phase = plane(unwrapped_phase);

nexttile
imagesc(unwrapped_phase);
title 'Unwrapped phase'

nexttile
imagesc(image_phase);
title 'Phase image'

% used to see the image hidden in amplitude
image_amp = sqrt((I(:, :, 4) - I(:, :, 2)).^2 + (I(:, :, 1) - I(:, :, 3)).^2);

nexttile
imagesc(image_amp);
title 'Amplitude image'
