function [dnew,fmax] = tconv(data,kernel,cmid)
%
% conv data with kernel and compensate for time-shift
% induced by convolution
%
% length(dnew) = length(data)
%
% assume kernel center is at max unless cmid=1
%
%IN: data = time series to be convolved
%   kernel = convolution kernel
%   cmid = assume middle of kernel is center (ie for derivative)
%          use cmid = 0 for standard spectral filtering
%
%OUT: dnew = convolved, time-shifted data
%     fmax = center of kernel
%
% AL, Caltech, 8/00
%
% [dnew,fmax] = tconv(data,kernel,cmid)
%

dnew = conv(data,kernel);
if cmid == 0
    fmax = find(kernel == max(kernel,[],2),1);
    fmax = fmax(1);
else
    fmax = round(length(kernel)/2);
end
dnew = dnew(fmax:fmax+length(data)-1);

% recenter even-length (non-symmetric) filter with cmid centering)
if (mod(length(kernel),2) == 0) && cmid == 1
    dnewi = interpSimple(dnew,2);
    dnew = dnewi(2:2:end);
end
