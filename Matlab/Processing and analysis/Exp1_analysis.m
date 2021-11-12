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
        plot(RespData.Full{ii}(tt, :))
        xticks([])
        yticks([-0.4 0 0.4])
        ylim([-0.4 0.4])
        xlim([0 size(RespData.Full{ii}, 2)])
        for ss = 1:5
            patch([(ss-1)*(stim_dur+ISI) (ss-1)*(stim_dur+ISI) (ss-1)*(stim_dur+ISI)+stim_dur (ss-1)*(stim_dur+ISI)+stim_dur],...
                [-0.4 0.4 0.4 -0.4], 'c', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
%             rectangle('Position', [(ss-1)*(stim_dur+ISI) -0.4 stim_dur 0.8])
        end
    end
end

figure
cc = 1;
respmat = cell(1, 3);
for ii = 1:3
    respmat{ii} = RespData.Full{ii}(6:9, :, :);
end
for ii = 1:3
    for tt = 1:3
        subplot(9, 1, cc)
        hold on
        plot(respmat{ii}(tt, :))
        xticks([])
        yticks([-0.4 0 0.4])
        ylim([-0.4 0.4])
        xlim([0 size(respmat{ii}, 2)])
        for ss = 1:5
            patch([(ss-1)*(stim_dur+ISI) (ss-1)*(stim_dur+ISI) (ss-1)*(stim_dur+ISI)+stim_dur (ss-1)*(stim_dur+ISI)+stim_dur],...
                [-0.4 0.4 0.4 -0.4], 'c', 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
%             rectangle('Position', [(ss-1)*(stim_dur+ISI) -0.4 stim_dur 0.8])
        end
        cc = cc+1;
    end
end

% invididual stims

respmat = RespData.Stim{3}(6:9, :, :);
figure
for tt = 1:3
    for ss = 1:5
        subplot(5, 3, tt+(ss-1)*3)
        plot(squeeze(respmat(tt, ss, :)))
        ylim([-0.4 0.4])
    end
end



% raster plots
figure
plotSpikeRaster(logical(trialSpikes{3}), 'PlotType', 'vertline');



