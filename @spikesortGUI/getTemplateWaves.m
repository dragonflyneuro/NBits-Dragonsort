function templateWaves = getTemplateWaves(app, uIdx, varargin)

batchRange = getBatchRange(app);
if nargin > 2
    refTime = varargin{1};
else
    refTime = mean(batchRange);
end

uA = app.unitArray(uIdx);
numTemplates = app.SpikesusedEditField.Value;

[templateTimes,templateWaves,~] = uA.getAssignedSpikes(batchRange);
if size(templateWaves,1) < numTemplates
    templateBatches = [-app.PastbatchesTField.Value, app.FuturebatchesTField.Value];  % batches to make templates from
    templateRange = getBatchRange(app, app.currentBatch+templateBatches);
    [templateTimes,templateWaves,~] = uA.getAssignedSpikes(templateRange);
end

extraTempRequired = numTemplates - size(templateWaves,1);
if extraTempRequired > 0 && ~isempty(uA.loadedTemplateWaves)
    r = randperm(size(uA.loadedTemplateWaves,1));
    templateWaves = [templateWaves; uA.loadedTemplateWaves(r(1:extraTempRequired))];
elseif extraTempRequired < 0
    [~, refTimeProximityRank] = sort(abs(templateTimes - refTime));
    templateWaves = templateWaves(refTimeProximityRank(1:numTemplates),:,:);
end

end