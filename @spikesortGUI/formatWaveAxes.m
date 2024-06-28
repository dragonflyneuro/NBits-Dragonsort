function [] = formatWaveAxes(app,ax,yRange)
ax.Position = [0.1, 0.1, 0.85, 0.86];
xlabel(ax,'Samples');
ylabel(ax,'Amplitude');
xlim(ax,[-app.m.spikeWidth, app.m.spikeWidth]);
set(ax, 'YGrid', 'on', 'XGrid', 'off');

ylTemp = [app.yLimLowField.Value, app.yLimHighField.Value];
yl = [yRange(1)-50, yRange(2)+50];
yl(~isinf(ylTemp)) = ylTemp(~isinf(ylTemp));
step = 50*ceil((yl(2) - yl(1))/500);
ticks = unique([0:-step:50*floor(yl(1)/50), 0:step:50*floor(yl(2)/50)]);
ylim(ax,yl);
yticks(ax,ticks);
end