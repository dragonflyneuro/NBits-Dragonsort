%%%% TemplateMatch5
%%%% Huai-Ti Lin [June 2019]
%%%% This script scan through the input trace for template waves
%%%% INPUT: temp_waves, trace [both can be a stack or single wave]
%%%% OUTPUT: matches, template, similarity_index
%%%% trace must be longer or equal length to the template
%%%% version 4 now does not use match_thd2 or amplitude threshold; instead,
%%%% it purely uses overal wavefore similarity.

function [matches, meanTemplate, deviationIdx] = TemplateMatch5(rawWaves,tempWaves,sRate,threshold, fuzzyBool)
if ~exist('threshold')   || isempty(threshold);       threshold = 4; end % StD threshold for the first round matching
if ~exist('sRate')      || isempty(sRate);          sRate = 30e3;           end % Defalt samping rate for NI-DAQ 40k; OpenEphys 30k
if ~exist('fuzzyBool')      || isempty(fuzzyBool);          fuzzyBool = 0;           end % Defalt samping rate for NI-DAQ 40k; OpenEphys 30k

t_crop_bit = 1; % 1: crop the template around peak to reduce the matching length
spikeWidth = 0.5; % ms estimated width of an spike - will crop the template to this size*2 around the peak location
uniformLength = 0.48;
% ampScalingAllowance = 0.2;

%% acquire template info
nCh=size(rawWaves,3); %check how many channels
if size(tempWaves,1)==1 %single template wave input
	meanTemplate=tempWaves; %if only the template waveform is given
	templateP2p=peak2peak(meanTemplate,2);
	templateSTD=0.1*templateP2p.*ones(1,size(meanTemplate,2),nCh); % assume 10% of peak-to-peak for each channel
else %if a pack of example waveforms were given
	meanTemplate=mean(tempWaves,1); %establish template from template waves
	templateP2p=peak2peak(meanTemplate,2);
	%     if size(temp_waves,1)<40
	templateSTD=std(tempWaves,0,1); %0.1*temp_p2p.*ones(1,size(template,2),n_ch);
	%     else
	%         temp_Std=std(temp_waves,0,1); %find the STD of the averaged wave
	%     end
end

% reformate template into 2D matrix for analysis purpose
meanTemplate = permute(meanTemplate, [3 2 1]); meanTemplate = meanTemplate(:,:,1);% rows: channels, columns: time samples, pages: observations
templateP2p = permute(templateP2p, [3 2 1]); templateP2p = templateP2p(:,:,1);% channels: peak-peak for each channel
templateSTD = permute(templateSTD, [3 2 1]); templateSTD = templateSTD(:,:,1);% rows: channels, columns: std for each channel's elements
rawWaves = permute(rawWaves, [3 2 1]);
%% crop template shorter for more accurate matching
if t_crop_bit ==1
	samplesOnSides = round((spikeWidth/(1000/sRate))/2); %samples to get before and after the peak
	peakSample = ceil(size(meanTemplate,2)/2); % by default the extract wave's peak is centered about the peak
	meanTemplate = meanTemplate(:, peakSample-samplesOnSides:peakSample+samplesOnSides );    %template(:,  peakLoc-crop_half-1:peakLoc+crop_half ); crop template to size - negative peak still at middle of this array !
	templateSTD = templateSTD(:, peakSample-samplesOnSides:peakSample+samplesOnSides ); %temp_Std(:,  peakLoc-crop_half-1:peakLoc+crop_half );
	templateP2p = peak2peak(meanTemplate,2);
	rawWaves=rawWaves(:,peakSample-samplesOnSides:peakSample+samplesOnSides,:); %crop the trace as short as the template
end
% [p2p msc]=sort(tempP2p,'descend'); % p2p actual value of p2p, msc is the original elment in temp_p2p that had that p2p value
temp_len=size(meanTemplate,2);

%% generate weighing function
chWeight=templateP2p./sum(templateP2p);
% for ww=1:n_ch
% 	amp_weight(ww,:)=abs(template(ww,:))./sum(abs(template(ww,:))); %*size(template,2)
% end
% waveWeight = 1-Gaussian(1:temp_len,ceil(temp_len/2),3,0.2); %gaussmf(temp_len,[3 ceil(temp_len/2)]);
sampleWeight = 1-SlopedBoxCar(1:temp_len,ceil(temp_len/2)-floor(0.24*sRate/1000),2,0.6,floor(uniformLength*sRate/1000));
% sampleWeight = SlopedBoxCar(1:temp_len,ceil(temp_len/2)-7,2,0.4,floor(uniformLength*sRate/1000));
% w_Std=temp_Std.*(ones(1,length(amp_weight))-(4*amp_weight.^2)); %weigh std by the amplitude
weightedSTD = sampleWeight.*templateSTD; %weigh std by the amplitude

%% match parameters
% r1=1; %ref_err=sum(abs((template+(temp_p2p/2))-template));
%% computer deviation
% 	if min(trace(ii,:)) < min(template)*(1-ampScalingAllowance)...
% 			&& min(trace(ii,:)) > min(template)*(1+ampScalingAllowance)
% 		signalDiff=abs(trace*min(template)/min(trace(ii,:))-template);
% 		deviation=sum((signalDiff./weightedSTD).^2,2)*(1+abs(1-min(trace(ii,:))/min(template)));
% 	else
signalDiff=abs(rawWaves-meanTemplate);
deviation=sum((signalDiff./weightedSTD).^2,2)/size(meanTemplate,2);
% 	end
%     deviation=sum((signalDiff./tempSTD).^2,2)/size(template,2); %r1; %
%     deviation=sum(((temp_diff./temp_Std.*amp_weight).^2),2)/size(template,2); %r1; %
%     deviation=sum(((temp_diff./temp_Std).^2).*amp_weight,2)/size(template,2); %r1; %
deviationIdx=squeeze(sum(deviation.*chWeight,1)); %
if fuzzyBool
	threshold = autoThreshold(threshold,deviationIdx);
end
matches=find(deviationIdx < threshold); %find a weighed average deviation and compare to the deviation threshold

end