d = 1:10e7;
f = 1:400;
tic
q = splitconv(d,f);
toc
% tic
% q = splitconv_mex(d,f);
% toc