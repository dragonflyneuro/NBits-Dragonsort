function [dev_matrix,template_all, tempWavesSet]=devMatrix2(m, c, t, currentBatch, oWaves, sRate)

numTemplates = 60;
tempWavesSet = cell(1,length(c.clusters));
total_spikes = size(oWaves,1); %number of channels
dev_matrix = nan(total_spikes,length(c.clusters)); %initialize the similarity matrix
for ii=1:length(c.clusters) %one template at a time
	n = c.clusters(ii);
	tempWaves = c.("waves_"+n)(t.("spikeBatchNum_"+n) <= currentBatch + 1 & t.("spikeBatchNum_"+n) >= currentBatch - 2,:,:);
	% 		tempWaves = c.("waves_"+n);
	if isfield(t,("importedTemplateMapping")) && any(strcmp(n, t.importedTemplateMapping{2}(:,1)))...
			&& size(c.("waves_"+n),1) < numTemplates
		tempWaves = [t.("template_"+t.importedTemplateMapping{2}(strcmp(n, t.importedTemplateMapping{2}(:,1)),2)); tempWaves];
	end
	if size(tempWaves,1)>numTemplates
		% 			r = randperm(size(tempWaves,1));
		tempWaves = tempWaves(end-numTemplates+1:end,:,:);
	end
	if ~isempty(tempWaves)
		for jj=1:total_spikes % go through each spike
			trace=oWaves(jj,:,:);
			
			[~,template,deviation] = TemplateMatch5(trace,tempWaves,sRate,m.oldTempSTDThreshold^2); %TemplateMatch2(trace,tempWaves,sRate);
			temp_p2p(ii)=peak2peak(template(m.mainCh,:));
			dev_matrix(jj,ii)=deviation/temp_p2p(ii); %log deviation normalized to template p2p amplitude
			% 			template_all(jj,:)=template;
		end
	else
		dev_matrix(1:total_spikes,ii)=inf; %log deviation normalized to template p2p amplitude
		% 			template_all(jj,:)=[];
	end
	tempWavesSet{ii} = tempWaves;
end
template_all = [];
dev_matrix=dev_matrix.*median(temp_p2p(temp_p2p ~= 0)); %complete the deviation p2p correction