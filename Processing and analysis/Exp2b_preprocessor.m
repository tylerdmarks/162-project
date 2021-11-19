function Exp2b_preprocessor
clear
sample_rate = 25850;
stim_dur = floor(3*sample_rate);         % duration of a single stimulus
ISI = floor(1.5*sample_rate);              % duration of interval after each stim
num_stim = 30;                       % number of stimulations per trial
stim_period = stim_dur+ISI;
trial_delay = floor(5*sample_rate);
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
    first_trial_sample = floor(sample_rate*rec_beginning)+trial_delay;
    try
        curr_data = importdata(fns{rr});
    catch
        curr_data = importdata(fns);
    end
    response = (curr_data.Y(first_trial_sample:end));       % excise beginning of recording leading up to first trial
    full_Resp = response(1:(stim_period*num_stim));
    stim_Resp = [];
   
    for ss = 1:num_stim
        currFrame = (ss-1)*stim_period+1;
        % Response matrix of inidividual stims on each trial
        stim_Resp(ss, :) = response(currFrame:currFrame+stim_dur);     
    end
    
    % add to pooled data
    RespData.Full(rr, :) = full_Resp;
    RespData.Stim(rr, :, :) = stim_Resp;
end

save Exp2b_RespData RespData
end
    
    
    