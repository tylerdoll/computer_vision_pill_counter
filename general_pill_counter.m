clear all;
close all;

setShowIntermediateImages(0);

images = dir('pills/*.jpg');
for ii=1:size(images,1)
    image = images(ii);
    I = imread(strcat(image.folder, '/', image.name));
    I = im2double(I);
    C = imcomplement(I); % Makes pills standout more if they are colored
    
    [H, S, V] = getHsvChannels(C);
    B = toBw(H, S, V);
    N = reduceNoise(B);
    markPills(I, N);
end

function markPills(I, B)
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
end

function N = reduceNoise(B)
    O = imopen(B,strel("disk", 30));
    E = imerode(O,strel("disk", 30));
    
    % Remove large blobs that can't be pills
    % TODO This was removing too much, find a better way to do this.
%     L = bwlabel(E,4);
%     props = regionprops(L, 'Area');
%     areas = [props.Area];
%     nonLargeBlobs = areas < 7000;
%     nonLargeBlobs = find(nonLargeBlobs);
%     NLB = ismember(L, nonLargeBlobs) > 0;
    
    N = E;
    
    if getShowIntermediateImages() == 1
        figure, montage([B O E NLB]), title('BW, Opened, Eroded, Non Large Blobs');
    end
end

function G = toBw(H, S, V)
    % Weights H, S, V according to how important they are in distinguishing
    % pills from the background.
    I = (0.5*H + 3*S + V) / 3;
    g = graythresh(I);
    G = imbinarize(I, g);
end

function [H, S, V] = getHsvChannels(I)
    % Currently not actually thresholding anything, but still useful to get
    % HSV vectors.
    HSV = rgb2hsv(I);
    minHue = 0;
    maxHue = 1;
    minSat = 0;
    maxSat = 1;
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
    
    if getShowIntermediateImages() == 1
        figure, montage([H S V]), title('H, S, V');
    end
end

% Globals
function setShowIntermediateImages(val)
    global showIntermediateImages
    showIntermediateImages = val;
end

function r = getShowIntermediateImages()
    global showIntermediateImages
    r = showIntermediateImages;
end
