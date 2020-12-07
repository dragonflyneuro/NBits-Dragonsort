function [out, outSize] = getMarker(maxN, n)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Picks out a marker style based on the maximum number of potential plots
% 
% INPUT
% maxN = max number of plots for one marker type
% n = the index of current plot
% 
% OUTPUT
% out = marker style

switch rem(floor(n/(maxN+1)),5)
	case 0
		out = ".";
        outSize = 8;
	case 1
		out = "*";
        outSize = 6;
	case 2
		out = "+";
        outSize = 6;
	case 3
		out = "p";
        outSize = 6;
	case 4
		out = "diamond";
        outSize = 6;
end

end