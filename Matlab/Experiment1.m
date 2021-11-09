function Experiment1()
clear
% create arduino object at appropriate port
ard = arduino('COM3', 'Uno', 'Libraries', 'Servo');

% create servo object
servo_pin = 'D13';
% may need to edit these pulse durations after testing
min_pulse = 1*10^-3;        % seconds
max_pulse = 2*10^-3;
s = servo(ard, servo_pin, 'MinPulseDuration', min_pulse, 'MaxPulseDuration', max_pulse);

% parameters
stimdata.initial_pos = 0.5;           % starting position for servo (degrees, 0.5 = center)
stimdata.intensities = [2 4 6];      % stimulus intensities, represented by degrees of motion for the servo arm
stimdata.num_trials = 2;             % number of trials for each intensity
stimdata.total_trials = stimdata.num_trials*length(stimdata.intensities);
stimdata.num_stim = 5;               % number of stimulation periods per trial
stimdata.stim_duration = 2.5;        % seconds, duration of each stimulus
stimdata.ISI = 2.0;                  % seconds, duration of each insterstimulus interval
stimdata.trial_delay = 30.0;         % seconds, time in between trials

% generate random trial order
stimOrder = [];
for ii = 1:length(stimdata.intensities)
    stimOrder = [stimOrder ii*ones(1, stimdata.num_trials)];
end
shuffle = randperm(length(stimOrder));
stimOrder = stimOrder(shuffle);
stimdata.stimOrder = stimOrder;

% set servo to initial position
writePosition(s, stimdata.initial_pos);

% Timer to sync stimulation with recording
syncTimer(5);

for tt = 1:stimdata.total_trials
    curr_intensity = stimdata.intensities(stimOrder(tt))/180;        % get stimulus intensity for this trial
    
    % pretrial delay
    pause(stimdata.trial_delay);
    
    % begin trial
    for ss = 1:stimdata.num_stim
        writePosition(s, stimdata.initial_pos+curr_intensity);
        pos = readPosition(s);
        fprintf('%d\n', pos);
        pause(stimdata.stim_duration);
        
        writePosition(s, stimdata.initial_pos);
        pos = readPosition(s);
        fprintf('%d\n', pos);
        pause(stimdata.ISI);
    end
end  

% save stimulus data
uisave('stimdata')

end


