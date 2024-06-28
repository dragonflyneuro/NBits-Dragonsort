function [] = setupUserdata(app)
% allows distinguishing of operation modes
app.AddspikeMenu.UserData = 0;
app.AddspikeButton.UserData = 0;
app.ForceaddMenu.UserData = 1;
app.ForceaddButton.UserData = 1;
app.UndoMenu.UserData = 1;
app.RedoMenu.UserData = -1;

% navigation
app.NextbatchMenu.UserData = 1;
app.NextbatchButton.UserData = 1;
app.PreviousbatchMenu.UserData = -1;
app.PreviousbatchButton.UserData = -1;
app.GotobatchButton.UserData = 0;

% figures
app.TZoomMenu.UserData = 't';
app.TPanMenu.UserData = 't';
app.TPointerMenu.UserData = 't';
app.LZoomMenu.UserData = 'l';
app.LPanMenu.UserData = 'l';
app.LPointerMenu.UserData = 'l';

% basic ops
app.RemovespikeMenu.UserData.fnc = @spikeRemover;
app.RemovespikeMenu.UserData.label = "remove";
app.RemovespikeButton.UserData.fnc = @spikeRemover;
app.RemovespikeButton.UserData.label = "remove";
app.SplitMenu.UserData.fnc = @unitSplitter;
app.SplitMenu.UserData.label ="split";
app.SplitButton.UserData.fnc = @unitSplitter;
app.SplitButton.UserData.label ="split";
app.MergeMenu.UserData.fnc = @unitMerger;
app.MergeMenu.UserData.label = "merge";
app.MergeButton.UserData.fnc = @unitMerger;
app.MergeButton.UserData.label = "merge";
app.AutosplitMenu.UserData.fnc = @unitSplitter;
app.AutosplitMenu.UserData.label = "split";
app.AutosplitButton.UserData.fnc = @unitSplitter;
app.AutosplitButton.UserData.label = "split";
app.AutomergeMenu.UserData.fnc = @unitMerger;
app.AutomergeMenu.UserData.label = "merge";
app.AutomergeButton.UserData.fnc = @unitMerger;
app.AutomergeButton.UserData.label = "merge";


% sorting ops
app.AutosortButton.UserData = 0;
app.AutosortbatchButton.UserData = 1;
app.AutocreateunitsButton.UserData = 0;
% app.AutocreatejunkunitsButton.UserData = 1;
end