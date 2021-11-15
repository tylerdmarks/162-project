function Experiment2b()
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
stimdata.intensity = 4/180;      % stimulus intensity, represented by degrees of motion for the servo arm
stimdata.num_stim = 100;               % number of stimulation periods
stimdata.stim_duration = 2.5;        % seconds, duration of each stimulus
stimdata.ISI = 2.0;                  % seconds, duration of each insterstimulus interval

% set servo to initial position
writePosition(s, stimdata.initial_pos);

% Timer to sync stimulation with recording
syncTimer(5);

% begin stimulations
for ss = 1:stimdata.num_stim
    writePosition(s, stimdata.initial_pos+stimdata.intensity);
    pos = readPosition(s);
    fprintf('%d\n', pos);
    pause(stimdata.stim_duration);

    writePosition(s, stimdata.initial_pos);
    pos = readPosition(s);
    fprintf('%d\n', pos);
    pause(stimdata.ISI);
end


% save stimulus data
uisave('stimdata')

end


