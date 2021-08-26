function [] = updateUnassignedSelection(app,selectedIdx)
h = app.Trace;
if ~isempty(app.tracePC) && ishandle(app.tracePC)
    hPC = app.tracePC;
end

for qq = 1:length(selectedIdx)
    alreadySelectedBool = ismember(h.UserData,selectedIdx(qq));
    
    if ~any(alreadySelectedBool)
        if ~isempty(app.tracePC) && ishandle(app.tracePC)
            app.pSelectedPC(end+1) = plot(hPC, X(selectedIdx(qq)),Y(selectedIdx(qq)),'ro');
        end
        app.pSelected(end+1) = plot(h, X(selectedIdx(qq)),Y(selectedIdx(qq)),'ro');
        h.UserData = [h.UserData, selectedIdx(qq)];
        h.Children = h.Children([2:end-(length(app.pEvent)+1), 1, end-(length(app.pEvent)):end]);
    else
        if ~isempty(app.tracePC) && ishandle(app.tracePC)
            delete(app.pSelectedPC(alreadySelectedBool))
            app.pSelectedPC(alreadySelectedBool) = [];
        end
        delete(app.pSelected(alreadySelectedBool))
        app.pSelected(alreadySelectedBool) = [];
        h.UserData(alreadySelectedBool) = [];
    end
end
end