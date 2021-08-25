function [out, outSize] = getMarker(n)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Picks out a marker style based on the maximum number of potential plots
% 
% INPUT
% maxN = max number of plots for one marker type
% n = the index of current plot
% 
% OUTPUT
% out = marker style

for ii = 1:length(n)
    switch rem(floor(n(ii)/(25+1)),5)
        case 0
            out(ii) = ".";
            outSize(ii) = 8;
        case 1
            out(ii) = "*";
            outSize(ii) = 6;
        case 2
            out(ii) = "+";
            outSize(ii) = 6;
        case 3
            out(ii) = "p";
            outSize(ii) = 6;
        case 4
            out(ii) = "diamond";
            outSize(ii) = 6;
    end
end

end