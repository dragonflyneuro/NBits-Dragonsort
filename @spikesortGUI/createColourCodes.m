function h = createColourCodes(app)
for ii = 1:length(app.cmap)
    h(ii) = uibutton(app.ColourGrid, 'push');
    h(ii).BackgroundColor = app.cmap(ii,:);
    h(ii).Layout.Column = ii;
    h(ii).Text = string(ii);
    h(ii).ButtonPushedFcn = @(src,event)colourButtonPushed(src,event,app,ii,'l');
    mh = uicontextmenu(app.UIBase);
    mh.ContextMenuOpeningFcn = @(src,event)colourButtonPushed(src,event,app,ii,'r');
    h(ii).ContextMenu = mh;
end
end

function [] = colourButtonPushed(~, ~, app,num,mode)
if ~isfield(app.t,'batchLengths') || ~ismember(string(num), app.RightUnitDropDown.Items)
    return;
end
if mode == 'l'
    app.LeftUnitDropDown.Value = string(num);
    app.redrawUnitPlots(1);
elseif mode == 'r'
    app.RightUnitDropDown.Value = string(num);
    app.redrawUnitPlots(2);
end
end