function scatterH = updateView(h, posData, sel, choice, mSize)
[caz,cel] = view(h);
cla(h)

posDataTemp = cellfun(@(x) x(:,choice),posData,'UniformOutput',false);

scatterH = scatterDK(posDataTemp,h,[0,0,0; getColour(sel)],...
    [".", getMarker(sel)],mSize*ones(size(posDataTemp)));

if length(choice) > 2
    if caz == 0 && cel == 90
        view(h,[-5 2 5]);
    end
else
    view(h,2);
end

end