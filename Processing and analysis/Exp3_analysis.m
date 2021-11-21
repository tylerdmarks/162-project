clear
sample_rate = 25200;
lower_event_thresh = 0.04;
upper_event_thresh = 0.11;
dead_time = 2;          % ms
stim_dur = floor(3*sample_rate);         % duration of a single stimulus
ISI = floor(5*sample_rate);              % duration of interval after each stim
trial_delay = 30*sample_rate;       % duration of pre-trial delay
num_stim = 3;                       % number of stimulations per trial
stim_period = num_stim*(stim_dur + ISI);        % duration of full stimulation period for each trial
trial_dur = stim_period + trial_delay;    % full duration of each trial


% Select data
fprintf('Select data.\n');
fn = uigetfile('.mat');


% import 
data = importdata(fn);
full_resp = data.Full;
stim_resp = data.Stim;

% Detect events 
trialSpikes = zeros(size(full_resp, 1), size(full_resp, 2));
stimSpikes = zeros(size(stim_resp, 1), size(stim_resp, 2), size(stim_resp, 3));
for tt = 1:size(full_resp, 1)
    % for every trial, detect events in full trial trace
    events = spikeDetector(full_resp(tt, :), sample_rate, lower_event_thresh, dead_time);
    trialSpikes(tt, events) = 1;        % logical vector indicating locations of spikes

    for ss = 1:size(stim_resp, 2)
        events = spikeDetector(squeeze(stim_resp(tt, ss, :)), sample_rate, lower_event_thresh, dead_time);
        stimSpikes(tt, ss, events) = 1;
    end
end


%% visualization

% plot raw traces
figure;
for tt = 1:size(full_resp, 1)
    subplot(10, 1, tt)
    hold on
    for ss = 1:num_stim
        patch([(ss-1)*(stim_dur+ISI)/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate+stim_dur/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate+stim_dur/sample_rate],...
            [-0.4 0.4 0.4 -0.4], 'c', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    end
    plot(linspace(0, size(full_resp, 2)/sample_rate, size(full_resp, 2)), full_resp(tt, :));
    xticks([])
    yticks([-0.4 0 0.4])
    ylim([-0.4 0.4])
    xlim([0 size(full_resp, 2)/sample_rate])
end

% plot raw traces, example trial
example_trial = 2;
figure
for ss = 1:3
    subplot(3, 1, ss)
    plot(linspace(0, size(stim_resp, 3)/sample_rate, size(stim_resp, 3)), squeeze(stim_resp(example_trial, ss, :)));
    xticks([])
    yticks([-0.3 0 0.3])
    ylim([-0.3 0.3])
    xlim([0 size(stim_resp, 3)/sample_rate])
end
    

%% quantifying spike rates for each population during each stimulation period
pop1_spikes = zeros(size(stimSpikes));      % spikes representing population 1 (upper < amplitude)
pop2_spikes = zeros(size(stimSpikes));      % spikes representing population 2 (lower < amplitude < upper)

for tt = 1:size(stim_resp, 1)
    for ss = 1:size(stim_resp, 2)
        pop1_events = spikeDetector(squeeze(stim_resp(tt, ss, :)), sample_rate, upper_event_thresh, dead_time);
        pop2_events = spikeDetector(squeeze(stim_resp(tt, ss, :)), sample_rate, lower_event_thresh, dead_time, upper_event_thresh);
        pop1_spikes(tt, ss, pop1_events) = 1;
        pop2_spikes(tt, ss, pop2_events) = 1;
    end
end

pop1_spikerate = sum(pop1_spikes, 3)/3;
pop2_spikerate = sum(pop2_spikes, 3)/3;

pop1_color = [112, 31, 96]/255;
pop2_color = [124, 185, 173]/255;
figure
hold on
for ss = 1:3
    violinplot(ss-0.15, pop1_spikerate(:, ss), {}, 'Width', 0.15, 'ViolinColor', pop1_color, 'ShowViolin', false, 'DataAlpha', 0.9);
    violinplot(ss+0.15, pop2_spikerate(:, ss), {}, 'Width', 0.15, 'ViolinColor', pop2_color, 'ShowViolin', false, 'DataAlpha', 0.9);
end
   
xticks(1:3)
for ss = 1:3
    labels{ss} = num2str(ss);
end
xticklabels(labels);

p_p1b1vp1simul = signrank(pop1_spikerate(:, 1), pop1_spikerate(:, 3));
p_p2b2vp2simul = signrank(pop2_spikerate(:, 2), pop2_spikerate(:, 3));
p_p2b1vp2simul = signrank(pop2_spikerate(:, 1), pop2_spikerate(:, 3));

%% comparing waveform patterns for each population during each stimulation period
% 2ms waveforms, 1ms on either side of event peak
wave_size = floor(0.002*sample_rate);
% extract waveforms from each pop (pop 1 in barb 1, pop 2 in barb 2)
pop1_barb1_waveforms = [];            % [num_waveforms x 2ms]   
pop2_barb2_waveforms = [];            % [num_waveforms x 2ms]   
pop1_simul_waveforms = [];            % [num_waveforms x 2ms]   
pop2_simul_waveforms = [];            % [num_waveforms x 2ms]   

for tt = 1:size(pop1_spikes, 1)
    %pop 1 in barb 1
    curr_events = find(squeeze(pop1_spikes(tt, 1, :)));
    for cc = 1:length(curr_events)
        curr_frame = curr_events(cc);
        if curr_frame > wave_size/2 && curr_frame < size(stim_resp, 3) - wave_size
            pop1_barb1_waveforms = cat(1, pop1_barb1_waveforms, squeeze(stim_resp(tt, 1, curr_frame-wave_size/2:curr_frame+wave_size/2))');
        end
    end
    %pop 2 in barb 2
    curr_events = find(squeeze(pop2_spikes(tt, 2, :)));
    for cc = 1:length(curr_events)
        curr_frame = curr_events(cc);
        if curr_frame > wave_size/2 && curr_frame < size(stim_resp, 3) - wave_size
            pop2_barb2_waveforms = cat(1, pop2_barb2_waveforms, squeeze(stim_resp(tt, 2, curr_frame-wave_size/2:curr_frame+wave_size/2))');
        end
    end
    %pop 1 in simultaneous stim
    curr_events = find(squeeze(pop1_spikes(tt, 3, :)));
    for cc = 1:length(curr_events)
        curr_frame = curr_events(cc);
        if curr_frame > wave_size/2 && curr_frame < size(stim_resp, 3) - wave_size
            pop1_simul_waveforms = cat(1, pop1_simul_waveforms, squeeze(stim_resp(tt, 3, curr_frame-wave_size/2:curr_frame+wave_size/2))');
        end
    end
    %pop 2 in simultaneous stim
    curr_events = find(squeeze(pop2_spikes(tt, 3, :)));
    for cc = 1:length(curr_events)
        curr_frame = curr_events(cc);
        if curr_frame > wave_size/2 && curr_frame < size(stim_resp, 3) - wave_size
            pop2_simul_waveforms = cat(1, pop2_simul_waveforms, squeeze(stim_resp(tt, 3, curr_frame-wave_size/2:curr_frame+wave_size/2))');
        end
    end
end

figure
subplot(3, 2, 1)
hold on
for ii = 1:size(pop1_barb1_waveforms, 1)
    plot(pop1_barb1_waveforms(ii, :), 'k')
end
plot(mean(pop1_barb1_waveforms, 1), 'r')
title('Barb 1, pop 1')
ylim([-0.3 0.3])

subplot(3, 2, 2)
hold on
for ii = 1:size(pop2_barb2_waveforms, 1)
    plot(pop2_barb2_waveforms(ii, :), 'k')
end
plot(mean(pop2_barb2_waveforms, 1), 'r')
title('Barb 2, pop 2')
ylim([-0.3 0.3])

subplot(3, 2, 3)
hold on
for ii = 1:size(pop1_simul_waveforms, 1)
    plot(pop1_simul_waveforms(ii, :), 'k')
end
plot(mean(pop1_simul_waveforms, 1), 'r')
title('Simultaneous, pop 1')
ylim([-0.3 0.3])

subplot(3, 2, 4)
hold on
for ii = 1:size(pop2_simul_waveforms, 1)
    plot(pop2_simul_waveforms(ii, :), 'k')
end
plot(mean(pop2_simul_waveforms, 1), 'r')
title('Simultaneous, pop 2')
ylim([-0.3 0.3])

subplot(3, 2, 5)
hold on
plot(mean(pop1_barb1_waveforms, 1), 'b')
plot(mean(pop1_simul_waveforms, 1), 'g')
ylim([-0.2 0.2])

subplot(3, 2, 6)
hold on
plot(mean(pop2_barb2_waveforms, 1), 'b')
plot(mean(pop2_simul_waveforms, 1), 'g')
ylim([-0.2 0.2])





       








