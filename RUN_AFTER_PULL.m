p = pwd + string(filesep);
f = ["spikesortGUI", "initialisePopup", "refineGUI"];
for ii = 1:length(f)
    zip(f(ii), p + f(ii) + string(filesep)...
        + ["matlab","metadata","_rels","appdesigner","[Content_Types].xml"]);
    movefile(p + f(ii) + ".zip", p + f(ii) +  ".mlapp");
end