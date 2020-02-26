%%%% Gaussian
%%%% HTL

function [y]=Gaussian(x,mu,sigma,A)
y=A*exp(-((x-mu)/sigma).^2);

end