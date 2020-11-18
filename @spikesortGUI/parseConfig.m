function [] = parseConfig(app)

fid = fopen("startup.conf",'r');
tline = fgetl(fid);
while ischar(tline)
    eval(tline);
    tline = fgetl(fid);
end

fclose(fid);

end