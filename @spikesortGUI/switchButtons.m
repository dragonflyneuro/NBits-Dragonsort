function [] = switchButtons(app, opt)
initialMenus = [app.InitialiseMenu,...
    app.LoadMenu];

opsMenus = [app.AddspikeMenu,...
app.AutosplitMenu,...
app.ForceaddMenu,...
app.NextbatchMenu,...
app.PreviousbatchMenu,...
app.LoadtemplatesMenu,...
app.MergeMenu,...
app.NewunitMenu,...
app.RefinebatchMenu,...
app.RemovespikeMenu,...
app.SaveMenu,...
app.ScrubthroughunitMenu,...
app.SplitMenu,...
app.UndoMenu,...
app.RedoMenu,...
app.UnitfrequencyMenu];

opsButtons = [app.AddspikeButton,...
app.AutosplitButton,...
app.BinarynamecopyButton,...
app.CleanupButton,...
app.DeleteunitButton,...
app.ForceaddButton,...
app.NextbatchButton,...
app.PreviousbatchButton,...
app.GotobatchButton,...
app.MergeButton,...
app.NewunitButton,...
app.RefinebatchButton,...
app.RemovespikeButton,...
app.ResortbatchButton,...
app.SavenamecopyButton,...
app.ShowallButton,...
app.ShowloadedtemplatesButton,...
app.SplitButton,...
app.UnitfreqButton,...
app.UnitscrubButton,...
app.AutosortButton,...
app.ToggletagButton,...
app.TagmanagementButton,...
app.AutocreatejunkunitsButton,...
app.AutocreateunitsButton];

opsStateButtons = [app.VieweventmarkersButton,...
    app.SelectedButton,...
    app.PlottedButton,...
    app.BatchButton];

opsDropDowns = [app.LeftUnitDropDown,...
app.RightUnitDropDown];

switch opt
    case 0
        [initialMenus.Enable] = deal('off');
    case 1
        [initialMenus.Enable] = deal('on');
    case 2
        [opsMenus.Enable] = deal('off');
        [opsButtons.Enable] = deal('off');
        [opsStateButtons.Enable] = deal('off');
        [opsDropDowns.Enable] = deal('off');
    case 3
        [opsMenus.Enable] = deal('on');
        [opsButtons.Enable] = deal('on');
        [opsStateButtons.Enable] = deal('on');
        [opsDropDowns.Enable] = deal('on');
end
end