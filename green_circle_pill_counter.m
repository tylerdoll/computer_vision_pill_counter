clear all;
close all;

I = imread('green_circles.JPG');
I = im2double(I);
figure, imshow(I), title('Original Image');

% Threshold values out, only tested with green thus far
HSV = rgb2hsv(I);
minHue = 0.2;
maxHue = .3;
minSat = 0;
maxSat = 0.3;
minVal = 0;
maxVal = 1;
for r=1:size(HSV,1)
    for c=1:size(HSV,2)
        if HSV(r,c,1) < minHue || HSV(r,c,1) > maxHue
            HSV(r,c,1) = 0;
        end
        if HSV(r,c,2) < minSat || HSV(r,c,2) > maxSat
            HSV(r,c,2) = 0;
        end
        if HSV(r,c,3) < minVal || HSV(r,c,3) > maxVal
            HSV(r,c,3) = 0;
        end
    end
end
H = HSV(:,:,1);
S = HSV(:,:,2);
V = HSV(:,:,3);
figure, montage([H S V]), title('H, S, V');

% Saturation seems to matter the most here, at least for green pills
G = (H + 4*S + V) / 2;
figure, imshow(G), title('Weighted HSV to Grayscale');

% Global thresholding as lighting should be pretty consistant
g = graythresh(G);
B = imbinarize(G,g);

% Clean up noise
O = imopen(B,strel("disk", 40));
E = imerode(O,strel("disk", 40));
figure, montage([B O E]), title('Binarized, Opened, Eroded');
B = E;

% label blobs
L = bwlabel(B,4);
figure, imshow(label2rgb(L)), title('Blobs');

% Find circular objects
props = regionprops(B, 'Area', 'Perimeter');
perimeters = [props.Perimeter];
areas = [props.Area];
circularities = perimeters.^2 ./ (4*pi*areas);
pills = circularities < 2;
pills = find(pills);
B = ismember(L, pills) > 0;
figure, imshow(B), title('Just pills');

% Plot and mark circular objects as pills
props = regionprops(B, 'Centroid');
I = insertText(I, [100 100], size(props,1), 'FontSize', 80);
figure, imshow(I), title('Counted pills');
for i=1:size(props,1)
    d = 80; % Length of each line in the crosshair
    c = props(i).Centroid;
    line([c(1)-d c(1)+d], [c(2) c(2)], 'Color', 'r');
    line([c(1) c(1)], [c(2)-d c(2)+d], 'Color', 'r');
end
