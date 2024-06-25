figure
subplot(3,4,1)
plot(unitArray(1).waves(:,:,1)')
hold on

for ii = [1,2,3]
    subplot(3,4,ii)
    plot(mean(unitArray(ii).waves(:,:,1))','LineWidth',2,'Color','k')
    ylim([-250,110])
    xlim([1,81])
end
subplot(3,4,4)
plot(unitArray(3).waves(4,:,1)')
ylim([-250,110])
xlim([1,81])
for ii = [1,2,3]
    subplot(3,4,4+ii)
    area(mean(unitArray(ii).waves(:,:,1))','EdgeColor','none','FaceAlpha',0.3)
    hold on
    area(unitArray(3).waves(4,:,1)','EdgeColor','none','FaceAlpha',0.3)
    plot(mean(unitArray(ii).waves(:,:,1))')
    plot(unitArray(3).waves(4,:,1)')
    ylim([-250,110])
    xlim([1,81])
end
for ii = [1,2,3]
    subplot(3,4,8+ii)
    plot((unitArray(3).waves(4,:,1)'-mean(unitArray(ii).waves(:,:,1))').^2)
    ylim([0,8000])
    xlim([1,81])
end
subplot(3,4,8)
plot(-40:40,[zeros(1,25),ones(1,40),zeros(1,16)])
ylim([-0.5,1.5])
xlim([-40,40])
%%
figure
for ii = [1,2,3]
    subplot(3,4,ii)
    plot(std(unitArray(ii).waves(:,:,1))')
    ylim([0,40])
    xlim([1,81])
end