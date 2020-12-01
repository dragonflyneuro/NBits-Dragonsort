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
app.TZoomMenu.UserData = 1;
app.TResetMenu.UserData = 1;
app.TPanMenu.UserData = 1;
app.TPointerMenu.UserData = 1;
app.LZoomMenu.UserData = 2;
app.LResetMenu.UserData = 2;
app.LPanMenu.UserData = 2;
app.LPointerMenu.UserData = 2;

% basic ops
app.RemovespikeMenu.UserData = {@spikeRemover, "remove"};
app.RemovespikeButton.UserData = {@spikeRemover, "remove"};
app.SplitMenu.UserData = {@unitSplitter, "split"};
app.SplitButton.UserData = {@unitSplitter, "split"};
app.MergeMenu.UserData = {@unitMerger, "merge"};
app.MergeButton.UserData = {@unitMerger, "merge"};
app.AutosplitMenu.UserData = {@unitSplitter, "split"};
app.AutosplitButton.UserData = {@unitSplitter, "split"};
app.AutomergeMenu.UserData = {@unitMerger, "merge"};
app.AutomergeButton.UserData = {@unitMerger, "merge"};

% sorting ops
app.AutosortButton.UserData = 0;
app.AutosortbatchButton.UserData = 1;
end