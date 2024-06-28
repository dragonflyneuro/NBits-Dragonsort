function [] = redrawMetric(app, varargin)
if nargin > 1
    targetIdx = varargin{1};
else
    targetIdx = 1:length(app.Metrics.dropDownArr);
end

% if isempty(app.unitArray(leftUnit).spikeTimes)
%     app.StatusLabel.Value = "Left unit is empty!";
%     return;
% end
for ii = targetIdx
    switch app.Metrics.dropDownArr(ii).Value
        case 'None'
            delete(app.Metrics.panelArr(ii).Children);
            delete(app.Metrics.controlGridArr(ii).Children);
            app.Metrics.controlGridArr(ii).UserData = 'None';
        case 'Waveforms (left)'
            scrubUnit(app,ii);
        case 'ISI (left)'
            showISI(app,ii, 'left');
        case 'ISI (right)'
            showISI(app,ii, 'right');
        case 'Temporal Stability (global)'
            showTemporalStability(app,ii)
        case 'Cross-correlogram'
            showXCorr(app,ii)
        case 'Cross-correlogram (global)'
            showXCorrAll(app,ii)
        case 'Deviation Template'
            break;
        case 'Mean'
            break;
    end
end

app.StatusLabel.Value = "Ready";
end