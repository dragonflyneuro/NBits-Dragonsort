function y = SlopedBoxCar(width,bias,sigma,A,B)
% Daniel Ko (dsk13@ic.ac.uk) [Feb 2020]
% Generates a side guassian-sloped boxcar function
% 
% INPUT
% width = width of boxcar function in samples
% bias = centre of boxcar shift in samples
% sigma = STD of side guassian
% A = amplitude of unity gain region
% B = length of unity gain region in samples
% 
% OUTPUT
% y = boxcar function

if B > width
	B = width/2;
end
x = -1000:0;
g = A*exp(-((x/sigma).^2)/2);
y = [g(1:end-1) A*ones(1,round(B)) g(end-1:-1:1)];
y = y(round(bias)+((ceil(length(y)/2)-floor(width/2):ceil(length(y)/2)+floor(width/2))));
if width ~= length(y)
	y = y(1:width);
end

end
