function [N ,out1] = spike_times2(trace,threshold1,polarity1)

%   This function detects and locates the time points of action potentials in a trace of
%   membrane potential as a function of time in a neuron. The trace should represent
%   a current clamp recording from a neuron.
%   Input:
%   "trace" is the membrane voltage array of the neuron
%   "Theshold" is the value for the spike to cross to be detected.
%   "polarity1" is either +1 or -1 which set the threshold crossing type
%   Output:
%   The output array is the index location of spikes.
%
%   Rune W. Berg 2006
%   rune@berg-lab.net
%   www.berg-lab.net
%   Modified by Rune Berg May 2015
%   Modified by Huai-Ti Lin Mar 2016

gim=polarity1*trace;
threshold=polarity1*threshold1;

set_crossgi=find(gim(1:end) > threshold)  ;  % setting the threshold

if ~isempty(set_crossgi)     % This to make sure there is a spike otherwise the code below gives problems. There is an empty else statement below.
	
	index_shift_posgi(1)=min(set_crossgi);
	index_shift_neggi(length(set_crossgi))=max(set_crossgi);
	
	for i=1:length(set_crossgi)-1
		if set_crossgi(i+1) > set_crossgi(i)+1
			index_shift_posgi(i+1)=true;
			index_shift_neggi(i)=true;
		end
	end
	
	%Identifying up and down slopes:
	
	set_cross_plusgi=  set_crossgi(find(index_shift_posgi));   % find(x) returns nonzero arguments.
	set_cross_minusgi=  set_crossgi(find(index_shift_neggi));   % find(x) returns nonzero arguments.
	set_cross_minusgi(length(set_cross_plusgi))= set_crossgi(end);
	nspikes= length(set_cross_plusgi); % Number of pulses, i.e. number of windows.
	
	%% Getting the spike coords
	
	for i=1:nspikes
		spikemax(i)=min(find(gim(set_cross_plusgi(i):set_cross_minusgi(i)) == max(gim(set_cross_plusgi(i):set_cross_minusgi(i))))) +set_cross_plusgi(i)-1;
	end
	
else
	spikemax=[];
	display('no spikes in trace')
end

%figure; plot(trace); hold on; plot(spikemax, trace(spikemax),'or');hold off


N=length(spikemax) ;

out1=spikemax;