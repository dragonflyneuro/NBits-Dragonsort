function [waves, transformed, W] = getLDA(u, selection, maxNum)

if ~exist('maxNum','var') || isempty(maxNum)
    maxNum = 0;
end
allWaves = [];
assignments = [];
waves = cell(length(selection),1);

for ii=1:length(selection)
    waves{ii} = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh);
    if ~isempty(waves{ii})
        rp = randperm(size(waves{ii},1));
        if maxNum ~= 0 && length(rp) > maxNum  % don't plot too many
            rp = rp(1:maxNum);
        end
        waves{ii} = waves{ii}(sort(rp),:,:);
        allWaves = cat(1,allWaves, waves{ii});
        assignments = cat(1,assignments,ii*ones(size(waves{ii},1),1)-1);
    end
end

W = LDA(allWaves,assignments);
for ii=1:length(selection)
    transformed{ii} = [ones(size(waves{ii},1),1), waves{ii}]*W(1:min([length(selection),3]),:)';
end

end