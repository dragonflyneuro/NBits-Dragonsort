pixPerDeg = [0.2:0.1:5];
degPerPix = 1./pixPerDeg;
fps = [60:10:360]';
degSize = 3;
degSpeed = 100;
degPerFrame = degSpeed./fps;
bodyLengthsPerFrame = degPerFrame./degSize;
movementPerFrame = [];
averageOver = 1;
for ii = 1:length(pixPerDeg)
    slice = round(averageOver*degPerFrame*pixPerDeg(ii))/averageOver;
    slice(slice == 0) = 1;
    slice = slice/pixPerDeg(ii);
    movementPerFrame(:,ii) = slice;
end
%%
figure('Position', [10 10 900 600])
imagesc(pixPerDeg,fps,movementPerFrame)
set(gca,'YDir','normal')
yticks([60:30:360])
ylabel('Temporal resolution (frames per second)','FontSize',16)
xlabel('Spatial resolution (pixels/degree)','FontSize',16)
cb = colorbar();
ylabel(cb,'Target travel per change frame (degrees)','FontSize',16,'Rotation',270)
title('Target moving at 100deg/s','FontSize',16)
ax = gca;
ax.FontSize = 16;
%%
figure('Position', [10 10 900 600])
limit = degSize/3;
movementPerFrameNew = (movementPerFrame>limit) - (movementPerFrame<limit);
imagesc(pixPerDeg,fps,movementPerFrameNew)
cmap = [0 0 1 ; 0 0 0] ;
colormap(cmap)
caxis([-1,1])
set(gca,'YDir','normal')
yticks([60:30:360])
ylabel('Temporal resolution (frames per second)','FontSize',16)
xlabel('Spatial resolution (pixels/degree)','FontSize',16)
title('3 deg target moving at 100deg/s acceptable zone','FontSize',16)
ax = gca;
ax.FontSize = 16;