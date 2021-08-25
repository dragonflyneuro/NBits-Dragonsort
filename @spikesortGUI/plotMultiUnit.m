function hMulti = plotMultiUnit(app, hMulti, unitNum, plottedWaves)

% subplott = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05]);

nCh = size(app.xi,1);
chToPlot = 1:nCh;

ax = hMulti.Children.Children;
for ii = chToPlot
    cla(ax(ii));
    if ~isempty(plottedWaves)
        line(ax(ii), -app.m.spikeWidth:app.m.spikeWidth, plottedWaves(:,:,ii)');
    end
    if ii == app.m.mainCh
        title(ax(ii), "MAIN Ch "+string(ii));
    else
        title(ax(ii), "Ch "+string(ii));
    end
    
end
if ~isempty(plottedWaves)
    if ~isinf(app.yLimLowField.Value)
        yl(1) = app.yLimLowField.Value;
    else
        yl(1) = min(plottedWaves,[],'all')-50;
    end
    if ~isinf(app.yLimHighField.Value)
        yl(2) = app.yLimHighField.Value;
    else
        yl(2) = max(plottedWaves,[],'all')+50;
    end
    
    for ii = chToPlot
        step = 50*ceil((yl(2) - yl(1))/500);
        ticks = unique([0:-step:50*floor(yl(1)/50), 0:step:50*floor(yl(2)/50)]);
        ylim(ax(ii),yl);
        yticks(ax(ii),ticks);
        set(ax(ii), 'YGrid', 'on', 'XGrid', 'off')
    end
end

end

%% Callbacks
% function transp(~, ~, hMulti, t, ax)
% % remove spikes before/after set timepoint in unit scrubbing window
% function transp(~, ~, hMulti, t, ax)
%     currentPos = hMulti.Position;
%     t.OuterPosition = [0,0,length(ax)-0.5,1];
%     hMulti.Position = [currentPos(1) currentPos(2) currentPos(4) currentPos(3)];
%     for ii = 2:length(ax)
%         ax(ii).Layout.Tile = 1+(ii-1)*length(ax);
%     end
% end