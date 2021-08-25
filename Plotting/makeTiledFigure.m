function h = makeTiledFigure(nAx, pos, titleTxt, varargin)
   
h = uifigure;
h.Name = titleTxt;
h.Position = pos;

if nargin > 3 && strcmpi(varargin{1}, 'vertical')
    t = tiledlayout(h,nAx,1);
else
    t = tiledlayout(h,1,nAx);
end
%     t = tiledlayout(h,nAx,nAx);
%     t.OuterPosition = [0,-nAx+1.15,1,nAx];

ax = gobjects(nAx,1);
for ii = 1:nAx
    ax(ii) = axes(t);
    ax(ii).Layout.Tile = ii;
end

h.Children.Children = flipud(h.Children.Children);

end