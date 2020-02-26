function [spike_clusters2,k] = TemplateDist2(m, c, t, rawWaves, rawSpikeTimes, X, spikeWidth, StD_Threshold, sRate)
(c, t, templateUnits, templateBatches, orphanWaves, sRate, mainCh, numTemplates, fuzzyBool)
%%%% The second round of spike distribution is currently commented out for
%%%% simplicity. In case it is reactivated, StD_Threshold requires two
%%%% numbers.

nCh = 1; Bug_dt=1000/sRate;
spike_clusters=ones(length(rawSpikeTimes),1)*0; % initialize the cluster assignment
for cc=1:length(c.clusters)
	clu_type{cc,1}=str2double(c.clusters(cc));
	clu_type{cc,2}='good';
end
% Pix_SS = get(0,'screensize');
%% redistribute all spikes
total_spikes = length(rawSpikeTimes); %number of channels
spike_check = rawWaves; %s.Uspikes;
% tempSpikes = rawSpikeTimes; %s.Ucell;
sim_matrix=nan(size(rawWaves,1),length(c.clusters)); %initialize the similarity matrix
for ii=1:total_spikes % go through each spike
	if nCh >1
		trace=spike_check(:,:,ii); %check one spike at a time
	else
		trace=spike_check(ii,:);
	end
	s_tempWaves=[]; s_tempSpikes=[]; s_simInd=[];
	for jj=1:length(c.clusters) %one template at a time
		clus_name=c.clusters(jj);
		if isfield(c,"waves_"+clus_name)
			tempWaves = c.("waves_"+clus_name);
			if isfield(t,("importedTemplateMapping")) && any(strcmp(clus_name, t.importedTemplateMapping{2}(:,1)))
				tempWaves = [t.("template_"+t.importedTemplateMapping{2}(strcmp(clus_name, t.importedTemplateMapping{2}(:,1)),2)); tempWaves];
			end
			if size(tempWaves,1)>40
				tempWaves = tempWaves(end-40+1:end,:,:);
			end
			[~,template,similarity] = TemplateMatch5(trace,tempWaves,sRate,StD_Threshold^2); %TemplateMatch2(trace,tempWaves,sRate);
			temp_p2p(jj)=peak2peak(template(m.mainCh,:));
			sim_matrix(ii,jj)=similarity/temp_p2p(jj); %log deviation normalized to template p2p amplitude
			template_all(jj,:,:)=permute(template,[3 2 1]);
		end
	end
end
sim_matrix=sim_matrix.*median(temp_p2p); %complete the similarity p2p correction

%% determine the similarity cutoff
[redis,col] = find( sim_matrix < StD_Threshold^2);
sim_matrix_temp = sim_matrix(redis,:);
[M,redis_clus] = min(sim_matrix_temp,[],2);

for ii=1:size(redis,1) % go through each spike that can be distributed
	if nCh >1
		trace=spike_check(:,:,redis(ii)); %check one spike at a time
		trace2=permute(trace, [3 2 1]);
	else
		trace=spike_check(redis(ii),:);
		trace2=trace;
	end
	
	clus_name=c.clusters(redis_clus(ii));
	spike_clusters(redis(ii))=clu_type{redis_clus(ii),1};
end

k = [];
% sim_matrix_u = sim_matrix;
% sim_matrix_u(redis,:) = []; %the real leftover matrix
% OrphanCount_post=size(sim_matrix_u,1);
% sortingState1 = [size(redis,1) OrphanCount_post]
% 
% %% plotting
% figure(3); N_tele=size(X,2); tSer3=(0:N_tele-1)*Bug_dt;
% plot(tSer3,X,'b'); hold on
% template_match_StD = []; mid_sample = ceil(size(spike_check,2)/2);
% half_ind=ceil(0.5*spikeWidth/Bug_dt);
% cmap = colormap(lines(20)); %[166,206,227; 31,120,180; 178,223,138; 51,160,44; 251,154,153; 227,26,28; 253,191,111; 255,127,0; 202,178,214; 106,61,154]./255; %
% 
% clusterN=length(c.clusters); figure(3); set(gcf,'Position',[0,400,Pix_SS(3),ceil(Pix_SS(4)/3)]); figure(4); set(gcf,'Position',[0,200,Pix_SS(3),ceil(Pix_SS(4)/3)]);
% for cc=1:clusterN % go through each cluster
% 	clus_name = c.clusters(cc);
% 	Spike_raw_t = rawSpikeTimes(find(spike_clusters==str2num(clus_name))); %-rec_offset use
% 	spike_wave = rawWaves(find(spike_clusters==str2num(clus_name)),:);
% 	ISI_raw = diff(Spike_raw_t);
% 	k.([ 'ISI_', clus_name ]) = Spike_raw_t;
% 	k.([ 'ISI_', clus_name ]) = ISI_raw;
% 	k.([ 'waves_', clus_name ]) = spike_wave; %
% 	figure(3); CMap=cmap(cc,:);
% 	for pp=1:length(Spike_raw_t)
% 		spike_win=Spike_raw_t(pp)-round(0.2/Bug_dt):Spike_raw_t(pp)+round(0.2/Bug_dt);
% 		plot(tSer3(spike_win),X(spike_win),'color',CMap); hold on;
% 	end
% 	figure(4); subplot(2,clusterN,cc)
% 	plot(spike_wave');
% 	subplot(2,clusterN,cc+clusterN); histogram(ISI_raw*Bug_dt,[0:0.5:10])
% 	template_match_StD(cc) = sum(std(spike_wave(:,mid_sample-half_ind:mid_sample+half_ind),0,1))/peak2peak(template_all(cc,:));
% end

% Ucell_raw = rawSpikeTimes(find(spike_clusters==0));
% spike_win =[]; figure(3);
% for uu = 1:length(Ucell_raw)
%     spike_win = Ucell_raw(uu)-round(0.1/Bug_dt):Ucell_raw(uu)+round(0.1/Bug_dt);
%     plot(tSer3(spike_win),NeuralData(spike_win),'color',[0.5 0.5 0.5]); hold on
% end
% % figure(3); plot(tSer3(spike_win),NeuralData(spike_win),'color',[0.5 0.5 0.5]);
% disp('plotting unlabeled spikes')

% %% redo the similarity cutoff
% template_match_StD
% good_level = input('which template should be the reference? empty will skip the threshold adjustment')
% if ~isempty(good_level)
%     thr_scale = input('scaling factor for the threshold?')
%     Template_threshold = thr_scale*StD_Threshold(2)./template_match_StD*template_match_StD(good_level);
%     match_matrix = zeros(size(rawWaves,1),length(v.clusters)); %initialize the match matrix
%     spike_clusters2 = zeros(length(rawSpikeTimes),1); % initialize the cluster assignment
%     for cc=1:clusterN % go through each cluster to do individual threshold
%         clus_name = v.clusters(cc);
%         redis2 = find( sim_matrix(:,cc) < Template_threshold(cc)^2 );
%         match_matrix(redis2,cc)=ones(length(redis2),1); % mark as one if match
%     end
%     redis3 = find(sum(match_matrix,2)==1); % find spikes that have only one matching assignment
%     for ss=1:length(redis3) % distribute each spike with single match
%         ind = find(match_matrix(redis3(ss),:)==1);
%         spike_clusters2(redis3(ss))=clu_type{ind,1};
%     end
%
%     redis4 = find(sum(match_matrix,2)>1); % find spikes that have at least two matching assignments
%     sim_matrix_temp = sim_matrix(redis4,:);
%     [M,redis_clus] = min(sim_matrix_temp,[],2); % find the most similar cluster for the overlap spikes
%     for ss=1:length(redis4) % distribute each spike with multiple matches
%         spike_clusters2(redis4(ss))=clu_type{redis_clus(ss),1};
%     end
%     sortingState2 = [size(redis3,1) size(redis4,1) total_spikes-size(redis3,1)-size(redis4,1)]
% else
spike_clusters2=spike_clusters;
% end
% %% plotting
% figure(5); set(gcf,'Position',[0,400,Pix_SS(3),ceil(Pix_SS(4)/3)]); plot(tSer3,X,'b'); ylim([-0.4 0.4]); hold on
% figure(6); set(gcf,'Position',[0,200,Pix_SS(3),ceil(Pix_SS(4)/3)]);
% for cc=1:clusterN % go through each cluster
%     clus_name = v.clusters(cc);
%     Spike_raw_t = rawSpikeTimes(find(spike_clusters2==str2num(clus_name))); %-rec_offset use
%     spike_wave = rawWaves(find(spike_clusters2==str2num(clus_name)),:);
%     ISI_raw = diff(Spike_raw_t);
%     k.([ 'ISI_', clus_name ]) = Spike_raw_t;
%     k.([ 'ISI_', clus_name ]) = ISI_raw;
%     k.([ 'waves_', clus_name ]) = spike_wave; %
%
%     figure(5); CMap=cmap(cc,:);
%     for pp=1:length(Spike_raw_t)
%        spike_win=Spike_raw_t(pp)-round(0.2/Bug_dt):Spike_raw_t(pp)+round(0.2/Bug_dt);
%        plot(tSer3(spike_win),X(spike_win),'color',CMap); hold on;
%     end
%     figure(6);  subplot(2,clusterN,cc)
%     plot(spike_wave'); ylim([-0.4 0.4])
%     subplot(2,clusterN,cc+clusterN); histogram(ISI_raw*Bug_dt,[0:0.5:10])
%     template_match_StD(cc) = sum(std(spike_wave(:,mid_sample-half_ind:mid_sample+half_ind),0,1))/peak2peak(template_all(cc,:));
% end