clear
sample_rate = 25150;
event_thresh = 0.025;
dead_time = 2;          % ms
stim_dur = floor(30*sample_rate);         % duration of a single stimulus
trial_delay = 30*sample_rate;       % duration of pre-trial delay
num_stim = 5;                       % number of stimulations per trial
trial_dur = stim_dur + trial_delay;    % full duration of each trial

% Select data
fprintf('Select data.\n');
fn = uigetfile('.mat');

% import 
data = importdata(fn);          % [stims x samples] each stim is 30s long
full_resp = data.Full;
stim_resp = data.Stim;
fullSpikes = zeros(size(full_resp, 1), size(full_resp, 2));
stimSpikes = zeros(size(stim_resp, 1), size(stim_resp, 2));

for ss = 1:size(full_resp, 1)
    % for every trial, detect events in full trial trace
    events = spikeDetector(full_resp(ss, :), sample_rate, event_thresh, dead_time);
    fullSpikes(ss, events) = 1;        % logical vector indicating locations of spikes
end



%% visualization

% plot raw traces

figure

for ss = 1:size(full_resp, 1)
    subplot(5, 1, ss)
    hold on
    patch([trial_delay/sample_rate trial_delay/sample_rate trial_dur/sample_rate trial_dur/sample_rate],...
                [-0.4 0.4 0.4 -0.4], 'c', 'FaceAlpha', 0.1, 'EdgeAlpha', 0);
    plot(linspace(0, size(full_resp, 2)/sample_rate, size(full_resp, 2)), full_resp(ss, :));
    xticks([])
    yticks([-0.4 0 0.4])
    ylim([-0.4 0.4])
    xlim([15 size(full_resp, 2)/sample_rate])
end

% spike raster
figure
plotSpikeRaster(logical(fullSpikes), 'PlotType', 'vertline');
xlim([15*sample_rate 60*sample_rate])
xlabel('Time')
ylabel('Trial')

% bin spikes into bins
bin_size = 0.5;         % seconds
frame_bin_size = bin_size*sample_rate;
nbins = floor(size(fullSpikes, 2)/frame_bin_size);
binned_spikes = zeros(num_stim, nbins);
for nn = 1:nbins
    curr_frame = (nn-1)*frame_bin_size+1;
    binned_spikes(:, nn) = sum(fullSpikes(:, curr_frame:curr_frame+frame_bin_size), 2);
end
binned_spikerate = binned_spikes/bin_size;

% plot the decay (mean +- s.e.m. patch)
mean_spike_rate = mean(binned_spikerate, 1);
se_spike_rate = std(binned_spikerate, 1)/sqrt(size(binned_spikerate, 1));
figure
patch([1:nbins fliplr(1:nbins)], [mean_spike_rate+se_spike_rate fliplr(mean_spike_rate-se_spike_rate)], 'r', 'FaceAlpha', 0.2);
hold on
plot(1:nbins, mean_spike_rate, 'r')
xlabel('Time (500ms bins)')
ylabel('Spike rate (hz)')

