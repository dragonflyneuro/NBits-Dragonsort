p = pwd + string(filesep);
f = ["spikesortGUI", "initialisePopup", "@spikesortGUI"+string(filesep)+"refineGUI", "tagManager", "weightDesigner"];
for ii = 1:length(f)
    unzip(p + f(ii) + ".mlapp",p + f(ii));
end