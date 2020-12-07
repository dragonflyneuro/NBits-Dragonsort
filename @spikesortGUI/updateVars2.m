function e = updateVars2(app, newM, newT, newS)
e = 0;
%    user input data
app.StatusLabel.Value = "Loading...";
drawnow

% find dataset
fileNotFound = 1;
while fileNotFound ~= 0
    try
        app.fm = memmapfile(newM.fN,'Format','int16','Writable',false);
        fileNotFound = 0;
    catch
        try
            app.fm = memmapfile([newM.fP newM.fN],'Format','int16','Writable',false);
            fileNotFound = 0;
        catch
            fileNotFound = -1;
        end
    end
    if fileNotFound == -1
        [newM.fN, newM.fP] = uigetfile('*.bin',"Couldn't open binary file or wrong file size! Please reselect");
        figure(app.UIBase);
        if newM.fN < 1
            app.m = [];
            e = 1;
            return;
        end
    else
        if numel(app.fm.Data)*2 == newM.fileSizeBytes
            fileNotFound = 0;
        else
            fileNotFound = -1;
        end
    end
end
try
    app.fm = memmapfile(newM.fN,...
        'Format',{'int16',[newM.nChans, newM.fileSizeBytes/(newM.dbytes*newM.nChans)],'d'},...
        'Writable',false);
catch
    app.fm = memmapfile([newM.fP newM.fN],...
        'Format',{'int16',[newM.nChans, newM.fileSizeBytes/(newM.dbytes*newM.nChans)],'d'},...
        'Writable',false);
end
app.fid = app.fm.Data.d;

% legacy checks
[app.m,app.t,app.unitArray] = convertToUnit(newM,newT,newS);

app.currentBatch = 1;

app.msConvert = 1000/app.m.sRateHz;
if ~isempty(app.t.saveNameSuffix)
    suffix = "_"+app.t.saveNameSuffix;
else
    suffix = "";
end

%    update gui fields
app.BatchsizeEditField.Value = app.t.batchSize;
app.OldField.Value = app.t.add2UnitThr(1);
app.NewField.Value = app.t.add2UnitThr(2);
app.DetectThr1EditField.Value = app.t.detectThr(1);
app.DetectThr2EditField.Value = app.t.detectThr(2);
app.BinaryEditField.Value = app.m.fN;
app.SavenameEditField.Value ="sorting_" + erase(app.m.fN,'.bin') + suffix;
app.LeftUnitDropDown.Items = "1";
app.RightUnitDropDown.Items = "1";
app.LeftUnitDropDown.Value = "1";
app.RightUnitDropDown.Value = "1";
app.VieweventmarkersButton.Value = 0;

%    read and plot data
app.readFilter2(app.currentBatch)
switchButtons(app,3)

updateDropdown(app);
app.LeftUnitDropDown.Value = "1";
app.RightUnitDropDown.Value = "1";

app.historyStack = [];

standardUpdate(app);

end