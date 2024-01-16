function [] = showXCorr(u, selection, sRate)

% plot unit waveforms in popout figure
subplott = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.05 0.1], [0.05 0.05]);

figure('Name','Cross-correlogram'); set(gcf, 'Position',  [300, 200, 800, 700]);
ax = gobjects(length(selection),length(selection));
sgtitle("Cross Correlogram");

for ii = 1:length(selection)
    for jj = 1:length(selection)
        ax(ii,jj) = subplott(length(selection),length(selection),length(selection)*(ii-1)+jj);
        t1 = u(selection(jj)).spikeTimes;
        t2 = u(selection(ii)).spikeTimes;
        bSize = 1*sRate/1000; % in ms
        maxLag = 50*sRate/1000; % in ms
        
        bE = -maxLag:bSize:maxLag;
        bC = bE(1:end-1) + diff(bE(1:2))/2;
        cC = zeros(size(bC));
        
        for kk = 1:length(t1)
            lag = t1(kk) - t2;
            if ii == jj
                cC = cC + histcounts(lag(lag~=0), bE);
            else
                cC = cC + histcounts(lag, bE);
            end
        end
        cC = cC / max(cC);
        bar(ax(ii,jj), bC*1000/sRate, cC,'Linestyle','none','BarWidth', 1);
        ylim([0,1.1]);

        if ii == 1
            title('Unit '+string(selection(jj)),'Color', getColour(jj));
        end
        if ii == length(selection)
            xlabel('Lag (ms)');
        end
        if jj == 1
            ylabel('Unit '+string(selection(ii)),'Color',getColour(ii));
        end
    end

end