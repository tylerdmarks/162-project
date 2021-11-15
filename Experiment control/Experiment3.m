function Experiment3()
clear
% create arduino object at appropriate port
ard = arduino('COM3', 'Uno', 'Libraries', 'Servo');

% create servo object
servo1_pin = 'D13';  % signal pin for servo 1
servo2_pin = 'D4';   % signal pin for servo 2
% may need to edit these pulse durations after testing
min_pulse = 1*10^-3;        % seconds
max_pulse = 2*10^-3;
s1 = servo(ard, servo1_pin, 'MinPulseDuration', min_pulse, 'MaxPulseDuration', max_pulse);
s2 = servo(ard, servo2_pin, 'MinPulseDuration', min_pulse, 'MaxPulseDuration', max_pulse);

% parameters
stimdata.s1_initial_pos = 0.5;           % starting position for servo 1, 0.5 = center
stimdata.s2_initial_pos = 0.5;           % starting position for servo 2
stimdata.intensity = 4/180;                 % stimulus intensity
stimdata.num_trials = 2;             % number of trials for each intensity
stimdata.num_stim = 3;               % number of stimulation periods per trial (one of each type)
stimdata.stim_duration = 2.5;        % seconds, duration of each stimulus
stimdata.ISI = 2.0;                  % seconds, duration of each insterstimulus interval
stimdata.trial_delay = 30.0;         % seconds, time in between trials

% generate random trial order
stimOrder = zeros(stimdata.num_trials, 3);      % [trials x stim_type] where stim_type denotes the kind of stimulation(1 == barb 1 only, 2 == barb 2 only, 3 == both)
for ii = 1:size(stimOrder, 1)
    stimOrder(ii, :) = randperm(3);
end
stimdata.stimOrder = stimOrder;

% set servos to initial position
writePosition(s1, stimdata.s1_initial_pos);
writePosition(s2, stimdata.s2_initial_pos);

% Timer to sync stimulation with recording
syncTimer(5);

for tt = 1:stimdata.num_trials
    curr_stimorder = stimOrder(tt, :);
    
    % pretrial delay
    pause(stimdata.trial_delay);
    
    % begin trial
    for ss = 1:stimdata.num_stim
        curr_stim = curr_stimorder(ss);
        
        % stimulate according to current stimulus type
        switch curr_stim
        case 1          % stimulate only barb 1
            writePosition(s1, stimdata.s1_initial_pos+intensity);
            pos = readPosition(s1);
            fprintf('%d\n', pos);
            pause(stimdata.stim_duration);

            writePosition(s1, stimdata.s1_initial_pos);
            pos = readPosition(s1);
            fprintf('%d\n', pos);
            pause(stimdata.ISI);
        case 2          % stimulate only barb 2
            writePosition(s2, stimdata.s2_initial_pos+intensity);
            pos = readPosition(s2);
            fprintf('%d\n', pos);
            pause(stimdata.stim_duration);

            writePosition(s2, stimdata.s2_initial_pos);
            pos = readPosition(s2);
            fprintf('%d\n', pos);
            pause(stimdata.ISI);
        case 3           % stimulate both simultaneously
            writePosition(s1, stimdata.s1_initial_pos+intensity);
            writePosition(s2, stimdata.s2_initial_pos+intensity);
            pos = readPosition(s2);
            fprintf('%d\n', pos);
            pause(stimdata.stim_duration);

            writePosition(s1, stimdata.s1_initial_pos);
            writePosition(s2, stimdata.s2_initial_pos);
            pos = readPosition(s2);
            fprintf('%d\n', pos);
            pause(stimdata.ISI);
        end
    end
end


% save stimulus data
uisave('stimdata')

end


