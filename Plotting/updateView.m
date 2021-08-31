function scatterH = updateView(h, posData, sel, choice, mSize)
[caz,cel] = view(h);
cla(h)

posDataTemp = cellfun(@(x) x(:,choice),posData,'UniformOutput',false);

if length(posData) == length(sel)+1
    scatterH = scatterDK(posDataTemp,h,[0,0,0; getColour(sel)],...
        [".", getMarker(sel)],mSize*ones(size(posDataTemp)));
else
    scatterH = scatterDK(posDataTemp,h,getColour(sel),...
        getMarker(sel),mSize*ones(size(posDataTemp)));
end

if length(choice) > 2
    if caz == 0 && cel == 90
        view(h,[-5 2 5]);
    end
else
    view(h,2);
end

end