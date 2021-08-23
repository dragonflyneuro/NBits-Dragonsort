function [] = setupHotkeys(app)

%others
app.HelpMenu.Accelerator = 'h';

%state
app.InitialiseMenu.Accelerator = 'i';
app.SaveMenu.Accelerator = 's';
app.LoadMenu.Accelerator = 'l';
app.UndoMenu.Accelerator = 'z';
app.RedoMenu.Accelerator = 'y';
app.NextbatchMenu.Accelerator = 'p';
app.PreviousbatchMenu.Accelerator = 'o';

%figures
app.TZoomMenu.Accelerator = 'q';
app.TResetMenu.Accelerator = 'w';
app.TPanMenu.Accelerator = 'e';
app.TPointerMenu.Accelerator = 'r';
app.TUnselectMenu.Accelerator = 't';
app.LZoomMenu.Accelerator = '1';
app.LResetMenu.Accelerator = '2';
app.LPanMenu.Accelerator = '3';
app.LPointerMenu.Accelerator = '4';
app.LUnselectMenu.Accelerator = '5';

app.MatchunityaxisMenu.Accelerator = 'm';

%units
app.AddspikeMenu.Accelerator = 'd';
app.ForceaddMenu.Accelerator = 'g';
app.RemovespikeMenu.Accelerator = 'f';
app.SplitMenu.Accelerator = 'c';
app.MergeMenu.Accelerator = 'v';
app.NewunitMenu.Accelerator = 'n';
app.AutosplitMenu.Accelerator = 'a';
app.AutomergeMenu.Accelerator = 'b';
app.RefinebatchMenu.Accelerator = 'x';

end