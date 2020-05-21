p = pwd + string(filesep);
f = ["refineGUI", "initialisePopup", "@spikesortGUI"+string(filesep)+"spikesortGUI", "tagManager", "weightDesigner"];
for ii = 1:length(f)
    unzip(p + f(ii) + ".mlapp",p + f(ii));
end