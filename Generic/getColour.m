function out = getColour(num)
% gives nice colours for anything really
cmap = distinguishable_colors(28);
cmap = cmap([2:3, 5:18, 20:end],:); %remove colours that are too similar
out = cmap(rem(num-1,25)+1,:);

end