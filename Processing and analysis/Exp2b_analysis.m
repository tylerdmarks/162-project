clear
sample_rate = 25850;
event_thresh = 0.025;
dead_time = 2;          % ms
stim_dur = floor(3*sample_rate);         % duration of a single stimulus
ISI = floor(1.5*sample_rate);
stim_period = stim_dur+ISI;
num_stim = 30;                       % number of stimulations per trial

% Select data
fprintf('Select data.\n');
fn = uigetfile('.mat');

% import 
data = importdata(fn);          
full_resp = data.Full;          %[trials x samples], 30 stims per trial
stim_resp = data.Stim;          %[trials x stims x samples]
fullSpikes = zeros(size(full_resp, 1), size(full_resp, 2));
stimSpikes = zeros(size(stim_resp, 1), size(stim_resp, 2));

for tt = 1:size(full_resp, 1)
    % for every trial, detect events in full trial trace
    events = spikeDetector(full_resp(tt, :), sample_rate, event_thresh, dead_time);
    fullSpikes(tt, events) = 1;        % logical vector indicating locations of spikes
    for ss = 1:num_stim
        events = spikeDetector(squeeze(stim_resp(tt, ss, :)), sample_rate, event_thresh, dead_time);
        stimSpikes(tt, ss, events) = 1;
    end
end

% visualize responses
figure
for tt = 1:size(full_resp, 1)
    subplot(size(full_resp, 1), 1, tt)
    hold on
    for ss = 1:num_stim
        patch([(ss-1)*(stim_dur+ISI)/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate+stim_dur/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate+stim_dur/sample_rate],...
            [-0.4 0.4 0.4 -0.4], 'c', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    end
    plot(linspace(0, size(full_resp, 2)/sample_rate, size(full_resp, 2)), full_resp(tt, :));
%     xticks([])
    yticks([-0.4 0 0.4])
    ylim([-0.4 0.4])
end
% 
% % spike rasters
% figure
% plotSpikeRaster(logical(fullSpikes), 'PlotType', 'vertline');
% xlabel('Time')
% ylabel('Trial')


% bin spikes into bins (full trace)
bin_size = 0.5;         % seconds
frame_bin_size = bin_size*sample_rate;
nbins = floor(size(fullSpikes, 2)/frame_bin_size);
binned_spikes = zeros(size(fullSpikes, 1), nbins);
for nn = 1:nbins
    curr_frame = (nn-1)*frame_bin_size+1;
    binned_spikes(:, nn) = sum(fullSpikes(:, curr_frame:curr_frame+frame_bin_size-1), 2);
end
binned_spikerate = binned_spikes/bin_size;

figure
imagesc(binned_spikerate)
colormap jet
colorbar
xlabel('Time (bin)')
ylabel('Trial')

% binning spikes by stimulus
binned_stim_spikerate = sum(stimSpikes, 3)/3;
rel_stim_spikerate = binned_stim_spikerate./binned_stim_spikerate(:, 1);
% mean_sr = mean(rel_stim_spikerate, 1);
mean_sr = mean(rel_stim_spikerate(1:end~=4, :), 1);           % exclude the weird trial
% se_sr = std(rel_stim_spikerate, 1)/sqrt(size(rel_stim_spikerate, 1));
se_sr = std(rel_stim_spikerate(1:end~=4, :), 1)/sqrt(size(rel_stim_spikerate, 1)-1);      % exclude the weird trial

figure
hold on
for ss = 1:size(rel_stim_spikerate, 1)
    p = plot(rel_stim_spikerate(ss, :), 'LineWidth', 2);
end
plot(1:size(rel_stim_spikerate, 2), mean_sr, 'Color', 'k', 'LineWidth', 3);
xlabel('Stimulus repeat')
ylabel('Normalized spike rate')

    
    
    
    
    
    
    