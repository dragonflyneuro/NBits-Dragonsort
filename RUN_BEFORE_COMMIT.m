p = pwd + string(filesep);
f = ["spikesortGUI", "initialisePopup", "refineGUI", "tagManager"];
for ii = 1:length(f)
    unzip(p + f(ii) + ".mlapp",p + f(ii));
end