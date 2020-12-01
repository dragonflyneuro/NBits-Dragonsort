function v = parseToArray(v)

N = regexp(v,'\d*','Match');
v = '';
for ii = 1:length(N)
    v = [v num2str(N{ii}) ','];
end
v = ['[' v(1:end-1) ']'];
end