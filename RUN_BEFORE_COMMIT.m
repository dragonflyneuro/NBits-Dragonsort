p = pwd + string(filesep);
f = ["spikesortGUI", "initialisePopup", "refineGUI"];
for ii = 1:length(f)
    unzip(p + f(ii) + ".mlapp",p + f(ii));
end