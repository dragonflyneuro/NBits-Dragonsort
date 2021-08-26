function [waves, W] = getPCs(u, selection)

allClust = [];
waves = cell(length(selection),1);

for ii=1:length(selection)
    waves{ii} = u(selection(ii)).waves(:,:);
    allClust = cat(1,allClust, waves{ii});
end

W = pca(allClust);

end