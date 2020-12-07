function y = splitconv(d,f)
%
% convolution with minimized edge artifacts
% assumes length(d) >> length(f)
%
%IN: d = time series (vector)
%    f = kernel
%
%OUT: y = filtered d
%
% AL, janelia; 11/09
%
%y = splitconv(d,f)
%

y = zeros(size(d));
for ii = 1:size(d,1)
    dmid = round(size(d,1)/2);
    da = d(ii,:) - d(ii,1);
    db = d(ii,:) - d(ii,end);
    daf = tconv(da,f,0) + d(ii,1);
    dbf = tconv(db,f,0) + d(ii,end);
    daf = daf(:);
    dbf = dbf(:);
    y(ii,:) = [daf(1:dmid)' dbf(dmid+1:end)'];
end

end