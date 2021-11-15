clear
sample_rate = 25350;
event_thresh = 0.03;
dead_time = 2;          % ms
stim_dur = floor(3*sample_rate);         % duration of a single stimulus
ISI = floor(1.5*sample_rate);              % duration of interval after each stim
trial_delay = 30*sample_rate;       % duration of pre-trial delay
num_stim = 5;                       % number of stimulations per trial
stim_period = num_stim*(stim_dur + ISI);        % duration of full stimulation period for each trial
trial_dur = stim_period + trial_delay;    % full duration of each trial


% Select data
fprintf('Select low intensity data.\n');
low = uigetfile('.mat');
fprintf('Select medium intensity data.\n');
med = uigetfile('.mat');
fprintf('Select high intensity data.\n');
high = uigetfile('.mat');

% import and add to cell array for each intensity
currdata = importdata(low);
RespData.Full{1} = currdata.Full;       % [trials x trial waveform]   
RespData.Stim{1} = currdata.Stim;       % [trials x stim x stim waveform]
% discard 8th trial for low intensity (timing is off)
RespData.Full{1}(8, :) = [];
RespData.Stim{1}(8, :, :) = [];

currdata = importdata(med);
RespData.Full{2} = currdata.Full;
RespData.Stim{2} = currdata.Stim;
currdata = importdata(high);
RespData.Full{3} = currdata.Full;
RespData.Stim{3} = currdata.Stim;

% Detect events for each intensity
trialSpikes = cell(1, 3);
stimSpikes = cell(1, 3);
for ii = 1:3
    trialSpikes{ii} = zeros(size(RespData.Full{ii}, 1), size(RespData.Full{ii}, 2));
    stimSpikes{ii} = zeros(size(RespData.Stim{ii}, 1), size(RespData.Stim{ii}, 2), size(RespData.Stim{ii}, 3));
    for tt = 1:size(RespData.Full{ii}, 1)
        % for every trial, detect events in full trial trace
        events = spikeDetector(RespData.Full{ii}(tt, :), sample_rate, event_thresh, dead_time);
        trialSpikes{ii}(tt, events) = 1;        % logical vector indicating locations of spikes
        
        for ss = 1:size(RespData.Stim{ii}, 2)
            events = spikeDetector(squeeze(RespData.Stim{ii}(tt, ss, :)), sample_rate, event_thresh, dead_time);
            stimSpikes{ii}(tt, ss, events) = 1;
        end
    end
end


%% visualization

% plot raw traces

figure
for ii = 1:3
    for tt = 1:size(RespData.Full{ii}, 1)
        subplot(10, 3, ii+(tt-1)*3)
        hold on
        for ss = 1:5
            patch([(ss-1)*(stim_dur+ISI)/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate+stim_dur/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate+stim_dur/sample_rate],...
                [-0.4 0.4 0.4 -0.4], 'c', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
        end
        plot(linspace(0, size(RespData.Full{ii}, 2)/sample_rate, size(RespData.Full{ii}, 2)), RespData.Full{ii}(tt, :));
        xticks([])
        yticks([-0.4 0 0.4])
        ylim([-0.4 0.4])
        xlim([0 size(RespData.Full{ii}, 2)/sample_rate])
        
        if tt == 1
            switch ii
                case 1
                    title('Low');
                case 2
                    title('Med');
                case 3
                    title('High');
            end
        end
        
        if tt == size(RespData.Full{ii}, 1)
            xlabel('Time (s)')
            xticks([5 10 15 20]);
            ylabel('mV');
        end
    end
end

% example trials showing within and between trial adaptation
example_trials = [3 3 6];
titles = {'Low', 'Medium', 'High'};
figure
for ii = 1:3
    subplot(3, 1, ii)
    for ss = 1:5
        patch([(ss-1)*(stim_dur+ISI)/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate+stim_dur/sample_rate (ss-1)*(stim_dur+ISI)/sample_rate+stim_dur/sample_rate],...
            [-0.4 0.4 0.4 -0.4], 'c', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    end
    hold on
    plot(linspace(0, size(RespData.Full{ii}, 2)/sample_rate, size(RespData.Full{ii}, 2)), RespData.Full{ii}(example_trials(ii), :));
    title(titles{ii})
    xlabel('Time (s)')
    xticks([5 10 15 20]);
    ylabel('Signal (mV)');
end


% raster plots
figure
for ii = 1:3
    subplot(3, 1, ii)
    for ss = 1:5
        patch([(ss-1)*(stim_dur+ISI) (ss-1)*(stim_dur+ISI) (ss-1)*(stim_dur+ISI)+stim_dur (ss-1)*(stim_dur+ISI)+stim_dur],...
            [-2 1 1 -2], 'c', 'FaceAlpha', 0.5, 'EdgeAlpha', 0);
    end
    plotSpikeRaster(logical(trialSpikes{ii}), 'PlotType', 'vertline');
    title(titles{ii})
    xlabel('Time (s)')
    xticks([5 10 15 20]*sample_rate)
    xticklabels({'5', '10', '15', '20'})
    ylabel('Trials');
end

%% quantification

% within trial adaptation
discard = 0.2*sample_rate;      % amount of time to discard at beginning of every stim
bin_size = 0.5*sample_rate;     % 500 ms bins
nbins = 5;                      % number of bins (including first)

binned_spikes = cell(1, 3);
for ii = 1:3
    respmat = stimSpikes{ii};
    num_stims = size(respmat, 1)*size(respmat, 2);          % going to pool all stims
    binned_spikes{ii} = zeros(num_stims, nbins);
    ct = 1;
    for tt = 1:size(respmat, 1)
        for ss = 1:size(respmat, 2)
            for bb = 1:nbins
                currFrame = discard+(bb-1)*bin_size+1;
                spike_count = sum(respmat(tt, ss, currFrame:currFrame+bin_size));
                if bb == 1
                    ref_count = spike_count;
                end
                binned_spikes{ii}(ct, bb) = spike_count/ref_count;
            end
        ct = ct + 1;
        end
    end
end


figure
colors(1, :) = [57, 167, 222]/255;
colors(2, :) = [95, 68, 147]/255;
colors(3, :) = [232, 73, 71]/255;
titles = {'Low', 'Med', 'High'};
for ii = 1:3
    subplot(1, 3, ii)
    hold on
    curr_spikes = binned_spikes{ii};
    for ss = 1:size(curr_spikes, 1)
        p = plot(curr_spikes(ss, :), 'Color', colors(ii, :), 'LineWidth', 2);
        p.Color(4) = 0.1;
    end
    mean_spikes = mean(curr_spikes, 1);
    se_spikes = std(curr_spikes, 1)/sqrt(size(curr_spikes, 1));
    errorbar(1:nbins, mean_spikes, se_spikes, 'LineWidth', 2, 'Color', colors(ii, :));
    ylim([0 1.2])
    xticks(1:nbins)
    xlabel('Time bin (500ms)')
    ylabel('Relative spike rate')
    title(titles{ii})
    axis square
end

figure
hold on
for ii = 1:3
    curr_spikes = binned_spikes{ii};
    mean_spikes = mean(curr_spikes, 1);
    se_spikes = std(curr_spikes, 1)/sqrt(size(curr_spikes, 1));
    errorbar(1:nbins, mean_spikes, se_spikes, 'LineWidth', 2, 'Color', colors(ii, :));
    ylim([0 1.2])
    xticks(1:nbins)
    xlabel('Time bin (500ms)')
    ylabel('Relative spike rate')
    legend({'Low', 'Med', 'High'})
    axis square
end


% between trial adaptation
binned_spikes = cell(1, 3);
rel_binned_spikes = cell(1, 3);
for ii = 1:3
    respmat = stimSpikes{ii};
    num_trials = size(respmat, 1);
    num_stims = size(respmat, 2);          % going to pool all stims
    binned_spikes{ii} = zeros(num_trials, num_stims);
    rel_binned_spikes{ii} = zeros(num_trials, num_stims);
    for tt = 1:size(respmat, 1)
        for ss = 1:size(respmat, 2)
            spike_count = sum(respmat(tt, ss, :));
            if ss == 1
                ref_count = spike_count;
            end
            binned_spikes{ii}(tt, ss) = spike_count;
            rel_binned_spikes{ii}(tt, ss) = spike_count/ref_count;
        end
    end
end

figure
% visulazation of spike counts across stims for each intensity
hold on
offsets = [-0.3 0 0.3];
for ss = 1:5
    for ii = 1:3
        violinplot(ss+offsets(ii), binned_spikes{ii}(:, ss), {}, 'Width', 0.15, 'ViolinColor', colors(ii, :), 'ShowViolin', false, 'DataAlpha', 0.6);
    end
end
for ii = 1:3
    medn = median(binned_spikes{ii}, 1);
    plot([1:5]+offsets(ii), medn, 'color', colors(ii, :), 'LineWidth', 2);
end
xticks(1:5)
for ss = 1:5
    labels{ss} = num2str(ss);
end
xticklabels(labels);
xlabel('Stimulus repeat')
ylabel('Absolute spike count')

%quantification of relative spike count across stims
figure
hold on
for ii = 1:3
    mean_trace = mean(rel_binned_spikes{ii}, 1);
    se_trace = std(rel_binned_spikes{ii}, 1)/sqrt(size(rel_binned_spikes{ii}, 1));
    errorbar(1:5, mean_trace, se_trace, 'LineWidth', 2, 'Color', colors(ii, :));
end
axis square
ylim([0 1.5])
xlabel('Stimulus repeat')
ylabel('Relative spike count')
xticks(1:5)



