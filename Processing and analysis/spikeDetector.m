function event_locs = spikeDetector(signal, samplerate, thresh, deadtime, cutoff_thresh)
    % signal = timeseries signal vector
    % samplerate = sampling rate (hz)
    % thresh = minimum signal threshold for peak detection
    % deadtime = minimum amount of time in between spikes (ms)
    % cutoff_thresh = maximum amplitude of included spikes (if you only want spikes of a certain amplitude)
    
    min_distance = (deadtime/1000)*samplerate;
    
    % findpeaks has everything built in, returns indices of peaks based on given criteria
    [pks, event_locs] = findpeaks(signal', 'MinPeakHeight', thresh, 'MinPeakDistance', min_distance);
    
    % if a cutoff threshold is provided, exclude peaks above the cutoff
    if nargin > 4
        event_locs(pks > cutoff_thresh) = [];
    end

    
end

