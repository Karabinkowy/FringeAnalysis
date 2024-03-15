clc;
clear;
close all;

path_ideal = "TPS ideal\5frame_90degree\";
file = dir(path_ideal);

folder = "5shifts_75\";
angleR = convertStringsToChars(folder);

path_real = "TPS phase_shift error\" + folder;
fileR = dir(path_real);

%m - how many frames
m = input('Enter how many frames: ');

I = cell(1,5);
I_R = cell(1,5);
for i=3:(3+m-1)
    I{1,i-2} = imread(path_ideal + file(i).name);
    I{1,i-2} = single(rgb2gray(I{1,i-2})) ./ 255.0;

    I_R{1,i-2} = imread(path_real + fileR(i).name);
    I_R{1,i-2} = single(rgb2gray(I_R{1,i-2})) ./ 255.0;

end

switch m
    case 3
        wrapped_phase = atan2((I{1,3} - I{1,2}), (I{1,1} - I{1,2}));
        wrapped_phaseR = atan2((I_R{1,3} - I_R{1,2}), (I_R{1,1} - I_R{1,2}));
        images_title = "3-images";
    case 4
        wrapped_phase = atan2((I{1,4} - I{1,2}), (I{1,1} - I{1,3}));
        wrapped_phaseR = atan2((I_R{1,4} - I_R{1,2}), (I_R{1,1} - I_R{1,3}));
        images_title = "4-images";
    case 5
        wrapped_phase = atan2(2.*(I{1,4}-I{1,2}),(I{1,1}-(2.*I{1,3})+I{1,5}));
        wrapped_phaseR = atan2(2.*(I_R{1,4}-I_R{1,2}),(I_R{1,1}-(2.*I_R{1,3})+I_R{1,5}));
        images_title = "5-images";
    otherwise
        msgfig = msgbox('Wrong number','Warn','modal');
        uiwait(msgfig)
        return 
end

unwrapped_phase = Miguel_2D_unwrapper(single(wrapped_phase));
unwrapped_phaseR = Miguel_2D_unwrapper(single(wrapped_phaseR));

% 2D plot of phase
f = figure;
f.WindowState = 'maximized';
subplot(2,2,1)
colormap gray
imagesc(wrapped_phase);
title("Ideal. Wrapped phase using " + images_title + " algorithm. " + "Angle = 90");
xlabel('Pixels')
ylabel('Pixels')

%figure
subplot(2,2,2)
imagesc(unwrapped_phase);
title("Ideal. Unwrapped phase using " + images_title + " algorithm. " + "Angle = 90");
xlabel('Pixels')
ylabel('Pixels')

subplot(2,2,3)
imagesc(wrapped_phaseR);
title("Real. Wrapped phase using " + images_title + " algorithm. " + "Angle = " + angleR(9) + angleR(10));
xlabel('Pixels')
ylabel('Pixels')

subplot(2,2,4)
imagesc(unwrapped_phaseR);
title("Real. Unwrapped phase using " + images_title + " algorithm. " + "Angle = " + angleR(9) + angleR(10));
xlabel('Pixels')
ylabel('Pixels')


% 3D plot of phase

figure

subplot(1,2,1)

[M_R, N_R] = size(unwrapped_phaseR); % wymiary obrazu
[x_R, y_R] = meshgrid(1:N_R, 1:M_R);
surf(x_R,y_R, unwrapped_phaseR)

title("Real. Unwrapped phase in 3D using " + images_title + " algorithm. " + "Angle = " + angleR(9) + angleR(10))
xlabel('Pixels')
ylabel('Pixels')
zlabel('Pixels')

% linear regression

% clarify parameters_names
z_R = unwrapped_phaseR;
N = M_R;

% transform coordinates
x = single.empty;
y = single.empty;
z = double.empty;
for i = 1:N
    for j = 1:N
        x = [x; x_R(i, j);];
        y = [y; y_R(i, j);];
        z = [z; z_R(i, j);];
    end
end

uno = ones(N*N, 1);

% linear least squares z = rA
A = [x y uno];

% find r - parameters of a plane
r = inv(A'*A)*(A'*z);

linearSurface =  r(1) * x_R + r(2) * y_R + r(3);

m = [r(1); r(2); -1; r(3)];
d_rms = (1 / (m(1)^2 + m(2)^2 + m(3)^2)) * (m(1) * x_R + m(2) * y_R + m(3) * z_R + m(4)).^2;

d_rmsSum = sum(d_rms, "all")

subplot(1,2,2)
surf(x_R,y_R, linearSurface, 'FaceAlpha', 0.1)

title("Plane fitted")
xlabel('Pixels')
ylabel('Pixels')
zlabel('Pixels')

