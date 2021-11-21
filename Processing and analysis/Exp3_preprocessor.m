function Exp3_preprocessor
clear
sample_rate = 25200;
stim_dur = floor(3*sample_rate);         % duration of a single stimulus
ISI = floor(5*sample_rate);              % duration of interval after each stim
trial_delay = 30*sample_rate;       % duration of pre-trial delay
num_stim = 3;                       % number of stimulations per trial
stim_period = num_stim*(stim_dur + ISI);        % duration of full stimulation period for each trial
trial_dur = stim_period + trial_delay;    % full duration of each trial

% import all datafiles to combine
fprintf('Select all recording files.\n');
[fns, ~] = uigetfile('.mat', 'MultiSelect', 'on');
if iscell(fns)
    num_recs = length(fns);
else
    num_recs = 1;
end

% for every recording, import its corresponding stimdata file, ask for timepoint of first trial, sort into [trials x time]
RespData.Full = [];     % [trials x response], pooled data
RespData.Stim = [];     % [trials x stim x response], pooled data
for rr = 1:num_recs
    
    % get sync data 
    rec_beginning = input('Enter timepoint (s) of beginning of recording:');
    first_trial_sample = floor(sample_rate*rec_beginning);
    try
        curr_data = importdata(fns{rr});
    catch
        curr_data = importdata(fns);
    end
    response = (curr_data.Y(first_trial_sample:end));       % excise beginning of recording leading up to first trial
    num_trials = input('Enter number of trials for this recording:');
    full_Resp = [];
    stim_Resp = [];
    for tt = 1:num_trials
        currFrame = (tt-1)*trial_dur+1;
        meanOffResp = mean(response(currFrame:currFrame+trial_delay));
        % Response matrix of each trial (all stims)
        full_Resp(tt, :) = response(currFrame+trial_delay+1:currFrame+trial_delay+stim_period) - meanOffResp;   
        for ss = 1:num_stim
            currFrame = (ss-1)*(stim_dur+ISI)+1;
            % Response matrix of inidividual stims on each trial
            stim_Resp(tt, ss, :) = full_Resp(tt, currFrame:currFrame+stim_dur-1);
        end
    end
    
    % add to pooled data
    RespData.Full = cat(1, RespData.Full, full_Resp);
    RespData.Stim = cat(1, RespData.Stim, stim_Resp);
end

save Exp3_RespData RespData
end
    
    
    