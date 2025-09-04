%% ===============================
% Minimal Dolphin/Noise Classifier (4+4 files)
clc; clear; close all;

%% 1️⃣ Data
categories = {'Dolphin','Noise'};
ads = audioDatastore(categories, ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

[adsTrain, ~] = splitEachLabel(ads,0.8,'randomized');

%% 2️⃣ Feature Extraction
numBands = 64; targetWidth = 128; % CNN input size
numFiles = numel(adsTrain.Files);

XTrain = zeros(numBands,targetWidth,1,numFiles); % pre-allocate
YTrain = zeros(numFiles,1);

idx = 1;
reset(adsTrain);
while hasdata(adsTrain)
    [x, info] = read(adsTrain);
    x = x(:);
    x = resample(x,16000,info.SampleRate);
    
    % mel-spectrogram
    mel = melSpectrogram(x,16000,'NumBands',numBands);
    mel = log10(mel+1e-6);
    mel = imresize(mel,[numBands targetWidth]); % fix width
    
    XTrain(:,:,1,idx) = mel; % assign
    if info.Label=="Dolphin"
        YTrain(idx) = 1;
    else
        YTrain(idx) = 2;
    end
    idx = idx + 1;
end

YTrain = categorical(YTrain); % convert to categorical

%% 3️⃣ CNN Layers
layers = [
    imageInputLayer([numBands targetWidth 1])
    convolution2dLayer(3,16,'Padding','same')
    reluLayer
    maxPooling2dLayer(2)
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',5, ...
    'MiniBatchSize',2, ...
    'Verbose',true);

%% 4️⃣ Train
net = trainNetwork(XTrain,YTrain,layers,options);

%% 5️⃣ Test on new audio
[audioTest,fs] = audioread('Dolphins Clicks-SoundBible.com-1458516263.wav');
audioTest = resample(audioTest,16000,fs);
audioTest = audioTest(:);

melTest = melSpectrogram(audioTest,16000,'NumBands',numBands);
melTest = log10(melTest+1e-6);
melTest = imresize(melTest,[numBands targetWidth]);
melTest = reshape(melTest,[numBands targetWidth 1 1]);

pred = classify(net,melTest);
disp(['Predicted label: ', char(pred)]);

