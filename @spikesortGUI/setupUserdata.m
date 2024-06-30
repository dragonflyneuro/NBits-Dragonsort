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
app.RemovespikeMenu.UserData.fcn = @spikeRemover;
app.RemovespikeMenu.UserData.label = "remove";
app.RemovespikeButton.UserData.fcn = @spikeRemover;
app.RemovespikeButton.UserData.label = "remove";
app.SplitMenu.UserData.fcn = @unitSplitter;
app.SplitMenu.UserData.label ="split";
app.SplitButton.UserData.fcn = @unitSplitter;
app.SplitButton.UserData.label ="split";
app.MergeMenu.UserData.fcn = @unitMerger;
app.MergeMenu.UserData.label = "merge";
app.MergeButton.UserData.fcn = @unitMerger;
app.MergeButton.UserData.label = "merge";
app.AutosplitMenu.UserData.fcn = @unitSplitter;
app.AutosplitMenu.UserData.label = "split";
app.AutosplitButton.UserData.fcn = @unitSplitter;
app.AutosplitButton.UserData.label = "split";
app.AutomergeMenu.UserData.fcn = @unitMerger;
app.AutomergeMenu.UserData.label = "merge";
app.AutomergeButton.UserData.fcn = @unitMerger;
app.AutomergeButton.UserData.label = "merge";


% sorting ops
app.AutosortButton.UserData = 0;
app.AutosortbatchButton.UserData = 1;
app.AutocreateunitsButton.UserData = 0;
% app.AutocreatejunkunitsButton.UserData = 1;
end