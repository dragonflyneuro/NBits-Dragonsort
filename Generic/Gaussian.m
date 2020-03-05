function [y]=Gaussian(x,mu,sigma,A)
% HTL
% Creates a Gaussian

y=A*exp(-((x-mu)/sigma).^2);

end