function [matches, templateMean, deviationIdx] = deviationTemplateMatch(rawWaves,templateWaves, sRate, threshold, varargin)
% Daniel Ko (dsk13@ic.ac.uk), Huai-Ti Lin [Feb 2020]
% Matches unassigned waves to a set of templateWaves using a deviation
% metric - lower deviation means more similar
% 
% INPUT
% rawWaves = waves to match to templateWaves 
%		FORMAT rows: observations, columns: time samples, pages: channels
% templateWaves = waves to match rawWaves to
%		FORMAT rows: observations, columns: time samples, pages: channels
% sRate = sampling rate of recording
% threshold = threshold for accepting rawWaves as similar enough to templateWaves
% fuzzyBool = allows adjustment of threshold based on deviation metric distribution
% 		FORMAT {1, 0}
% 
% OUTPUT
% matches = index within rows of rawWaves of waves that match templateWaves
% templateMean = mean template used for template matching
% deviationIdx = deviation metric of each row of rawWaves used in matching

if nargin > 5
    cropFactor = varargin{2};
else
    cropFactor = 1;
end

if nargin > 4
    fuzzyBool = varargin{1};
else
    fuzzyBool = 1;
end

%% acquire template info
nCh = size(rawWaves,3); %number of channels

% crop template shorter for more accurate matching
cropSize = round(cropFactor*(size(templateWaves,2)-1)/2); %samples to get before and after the peak
peakSample = ceil(size(templateWaves,2)/2); % by default the extract wave's peak is centered about the peak
cropRange = peakSample-cropSize:peakSample+cropSize;

rawWaves = rawWaves(:, cropRange, :); %crop the trace as short as the template
templateWaves = templateWaves(:, cropRange, :);

% find template metrics - mean, P2P and STD
templateMean = mean(templateWaves,1);
templateP2p = peak2peak(templateMean,2);
if size(templateWaves,1) == 1
	templateSTD = 0.1*templateP2p.*ones(1,size(templateMean,2),nCh); % assume 10% of peak-to-peak for each channel
else
	templateSTD = std(templateWaves,0,1);
end

% reformat template into 2D matrix for analysis purpose
templateMean = permute(templateMean, [3 2 1]); templateMean = templateMean(:,:,1);% rows: channels, columns: time samples, pages: observations
templateP2p = permute(templateP2p, [3 2 1]); templateP2p = templateP2p(:,:,1);% rows: channels, columns: peak-peak value
templateSTD = permute(templateSTD, [3 2 1]); templateSTD = templateSTD(:,:,1);% rows: channels, columns: std value
rawWaves = permute(rawWaves, [3 2 1]);

templateLength=size(templateMean,2);

%% generate weighing function
if nargin > 6 && ~isempty(varargin{3})
    sampleWeights = varargin{3};
    truncWeights = sampleWeights(cropRange);
else
    uniformLength = 0.4; % the width of uniform gain in ms. Used when weighing samples around the spike time
    bias = 0.1; % sample weighting function centreing bias
    truncWeights = SlopedBoxCar(templateLength, floor(bias*sRate/1000), 4, 0.6, floor(uniformLength*sRate/1000)); % weigh each sample by a modified boxcar function
end

chWeight = templateP2p./sum(templateP2p); % weigh each channel by the P2P value (higher P2P - weighted more)

%% match parameters
signalDiff = abs(rawWaves-templateMean);
deviation = sum(signalDiff.*truncWeights./templateSTD,2)/size(templateMean,2); % find summed deviation of rawWaves from templateMean, then average
deviationIdx = squeeze(sum(deviation.*chWeight,1)); % sum deviation through the channels
if fuzzyBool
	threshold = autoThreshold(threshold^2,deviationIdx);
else
	threshold = threshold^2;
end
matches = find(deviationIdx < threshold); %compare weighted average devation to threshold

end