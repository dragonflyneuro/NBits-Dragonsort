function out = getMarker(maxN, n)
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
		out = "*";
	case 1
		out = "+";
	case 2
		out = "square";
	case 3
		out = "p";
	case 4
		out = "diamond";
end

end