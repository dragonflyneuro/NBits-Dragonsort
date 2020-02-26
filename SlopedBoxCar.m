function y = SlopedBoxCar(x,mu,sigma,A,uniformLength)
g=A*exp(-((x-mu)/sigma).^2);
y = [g(1:(mu-1)) A*ones(1,uniformLength) g((mu+1):end)];
y = y(1:length(x));
end
