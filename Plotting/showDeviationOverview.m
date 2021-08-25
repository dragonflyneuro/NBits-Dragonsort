function [] = showDeviationOverview(u, selection)

if ~isrow(selection)
    selection = selection';
end

figure; set(gcf, 'Position',  [1100, 200, 700, 600]);

uniformLength = 0.4; % the width of uniform gain in ms. Used when weighing samples around the spike time
bias = 0.1; % sample weighting function centreing bias

for ii = 1:length(selection)
    uLen = length(u(selection(ii)).spikeTimes));
    waves = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh);
    waves = permute(waves, [3 2 1]);
    if ~isempty(waves)
        iiCmap = getColour(ii);
        ms = getMarker(ii);
        meanDev = zeros(1,uLen);
        for jj = 1:uLen
            templateMean = mean(waves,3);
            templateP2p = peak2peak(templateMean,2);
            if size(templateWaves,1) == 1
                templateSTD = 0.1*templateP2p.*ones(1,size(templateMean,2),size(waves,1)); % assume 10% of peak-to-peak for each channel
            else
                templateSTD = std(templateWaves,0,1);
            end
            templateMean = permute(templateMean, [3 2 1]); templateMean = templateMean(:,:,1);% rows: channels, columns: time samples, pages: observations
            templateP2p = permute(templateP2p, [3 2 1]); templateP2p = templateP2p(:,:,1);% rows: channels, columns: peak-peak value
            templateSTD = permute(templateSTD, [3 2 1]); templateSTD = templateSTD(:,:,1);% rows: channels, columns: std value
              
            templateLength=size(templateMean,2);

            %% generate weighing function
            chWeight = templateP2p./sum(templateP2p); % weigh each channel by the P2P value (higher P2P - weighted more)
            sampleWeight = SlopedBoxCar(templateLength, floor(bias*sRate/1000), 4, 0.6, floor(uniformLength*sRate/1000)); % weigh each sample by a modified boxcar function
            sampleWeight = sampleWeight(1:templateLength);

            %% match parameters
            signalDiff = abs(waves-templateMean);
            deviation = sum(signalDiff.*sampleWeight./templateSTD,2)/size(templateMean,2); % find summed deviation of rawWaves from templateMean, then average
            meanDev(ii) = mean(squeeze(sum(deviation.*chWeight,1))); % sum deviation through the channels
        end
        plot(linspace(0,100,uLen),meanDev(ii)/max(meanDev(ii)),'Color',iiCmap,"Marker",ms);
        hold on;
    end
end

xlabel("Percentage of spikes in unit"); ylabel("Normalised deviation");
title('Units found - Deviation view');
legend("Unit " + selection);



for ii=1:length(selection)
    iiCmap = getColour(ii);
    ms = getMarker(ii);
    title(ax(ii), 'Unit '+string(selection(ii))+" "+...
        ms +" ("+length(u(selection(ii)).spikeTimes)+")",'Color',iiCmap);
    if ~isempty(u(selection(ii)).waves)
        clusPC = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh)*PC(:,1:3);
        scatter3(clusPC(:,1),clusPC(:,2),clusPC(:,3),20,repmat(iiCmap,size(clusPC,1),1),"Marker",ms); % 3D PCA plot
    end
    hold on;
end
xlabel("PC1"); ylabel("PC2"); zlabel("PC3");
title('Units found - PCs view');
legend("Unit " + selection);

end