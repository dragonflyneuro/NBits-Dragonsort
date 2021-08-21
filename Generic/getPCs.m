function [waves, clusPC, PC] = getPCs(u, selection)

allClust = [];
waves = cell(length(selection),1);

for ii=1:length(selection)
    waves{ii} = u(selection(ii)).waves(:,:,u(selection(ii)).mainCh);
    if ~isempty(waves{ii})
        allClust = cat(1,allClust, waves{ii});
        rp = randperm(size(waves{ii},1));
        if length(rp) > 600 % don't plot too many
            rp = rp(1:600);
        end
        waves{ii} = waves{ii}(sort(rp),:,:);
    end
end

PC = pca(allClust);
for ii=1:length(selection)
    if ~isempty(waves{ii})
        clusPC{ii} = waves{ii}*PC(:,1:3);
    end
end

end