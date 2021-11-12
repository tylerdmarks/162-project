function event_locs = spikeDetector(signal, samplerate, thresh, deadtime)
    % signal = timeseries signal vector
    % samplerate = sampling rate (hz)
    % thresh = minimum signal threshold for peak detection
    % deadtime = minimum amount of time in between spikes (ms)
    
    min_distance = (deadtime/1000)*samplerate;
    
    % findpeaks has everything built in, returns indices of peaks based on given criteria
    [~, event_locs] = findpeaks(signal', 'MinPeakHeight', thresh, 'MinPeakDistance', min_distance);

    
end

