function [waves, transformed, W] = getPCs(u, selection, maxNum)

if ~exist('maxNum','var') || isempty(maxNum)
    maxNum = 0;
end
allClust = [];
waves = cell(length(selection),1);

for ii=1:length(selection)
    waves{ii} = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh);
    if ~isempty(waves{ii})
        allClust = cat(1,allClust, waves{ii});
        rp = randperm(size(waves{ii},1));
        if maxNum ~= 0 && length(rp) > maxNum  % don't plot too many
            rp = rp(1:maxNum);
        end
        waves{ii} = waves{ii}(sort(rp),:,:);
    end
end

W = pca(allClust);
for ii=1:length(selection)
    transformed{ii} = waves{ii}*W(:,1:3);
end

end