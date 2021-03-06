%% Image Classification Using Imported Network with Custom Layers
% Import a TensorFlow model as a DAGNetwork with autogenerated custom
% layers, and use the imported network to classify an image.

%% Download and Save Model
% This Python script instantiates the model and then, saves it to the
% TensorFlow SavedModel format. 
if ~isfolder("EfficientNetV2L")
    pyrunfile("getefficientnetv2l.py");
end

%% Specify Class Names
% The EfficientNetV2L model is trained with images from the ImageNet
% database. Get the class names from squeezenet, which is also trained with
% ImageNet images.
squeezeNet = squeezenet;
ClassNames = squeezeNet.Layers(end).Classes;

%% Import Network
% Import the TensorFlow model EfficientNetV2L in the saved model format. By
% default, importTensorFlowNetwork imports the network as a DAGNetwork
% object. Specify the output layer type for an image classification
% problem. 
% Note that when you import the network, the software will throw warnings.
% The network is importable!

net = importTensorFlowNetwork("EfficientNetV2L",...
    OutputLayerType="classification",...
    Classes=ClassNames);

% Find the autogenerated custom layers.
PackageName = '+EfficientNetV2L';
s = what(['.\' PackageName]);

ind = zeros(1,length(s.m));
for i = 1:length(net.Layers)
    for j = 1:length(s.m)
        if strcmpi(class(net.Layers(i)),[PackageName(2:end) '.' s.m{j}(1:end-2)])
            ind(j) = i;
        end
    end
end
disp(ind);
disp(net.Layers(ind));

% Analyze the imported network.
analyzeNetwork(net)

%% Read and Preprocess Image
% Read the image you want to classify and display the size of the image.

Im = imread("images\mydog.jpg");
size(Im)
InputSize = net.Layers(1).InputSize;

% Resize the image to the input size of the network.
Im = imresize(Im,InputSize(1:2));

% The inputs to EfficientNetV2L require further preprocessing. Rescale the
% image. Normalize the image by subtracting the training images mean and
% dividing by the training images standard deviation.

ImProcessed = rescale(Im,0,1);
meanIm = [0.485 0.456 0.406];
stdIm = [0.229 0.224 0.225];
ImProcessed = (ImProcessed-reshape(meanIm,[1 1 3]))./reshape(stdIm,[1 1 3]);

%% Classify Image
% Predict and plot image with classification label.
tic
label = classify(net,ImProcessed);
toc

imshow(Im)
title(strcat("Predicted label: ",string(label)))
