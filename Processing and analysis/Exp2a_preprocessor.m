function Exp2a_preprocessor
clear
sample_rate = 25150;
stim_dur = floor(30*sample_rate);         % duration of a single stimulus
trial_delay = 30*sample_rate;       % duration of pre-trial delay
num_stim = 5;                       % number of stimulations per trial
trial_dur = stim_dur + trial_delay;    % full duration of each trial

% import all datafiles to combine
fprintf('Select all recording files.\n');
[fns, ~] = uigetfile('.mat', 'MultiSelect', 'on');
if iscell(fns)
    num_recs = length(fns);
else
    num_recs = 1;
end

% for every recording, import its corresponding stimdata file, ask for timepoint of first trial, sort into [trials x time]
RespData.Full = [];
RespData.Stim = [];
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

    for ss = 1:num_stim
        if ss == 2
            currFrame = (ss-1)*trial_dur+1-0.1*sample_rate;
        else
            currFrame = (ss-1)*trial_dur+1;
        end
        meanOffResp = mean(response(currFrame:currFrame+trial_delay));
        % Response matrix of each trial (all stims)
        full_Resp(ss, :) = response(currFrame:currFrame+trial_dur) - meanOffResp; 
        stim_Resp(ss, :) = response(currFrame+trial_delay:currFrame+trial_dur) - meanOffResp;
    end
    
    % add to pooled data
    RespData.Full = cat(1, RespData.Full, full_Resp);
    RespData.Stim = cat(1, RespData.Stim, stim_Resp);
end

save Exp2a_RespData RespData
end
    
    
    