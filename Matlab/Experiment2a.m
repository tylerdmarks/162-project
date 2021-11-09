function Experiment2a()
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
stimdata.intensity = 4/180;               % stimulus intensity, represented by degrees of motion for the servo arm
stimdata.stim_duration = 60;        % seconds, duration of each stimulus

% set servo to initial position
writePosition(s, stimdata.initial_pos);

% Timer to sync stimulation with recording
syncTimer(5);

% start stimulation
writePosition(s, stimdata.initial_pos+stimdata.intensity);
pos = readPosition(s);
fprintf('%d\n', pos);
pause(stimdata.stim_duration);

% stop stimulation
writePosition(s, stimdata.initial_pos);
pos = readPosition(s);
fprintf('%d\n', pos);


% save stimulus data
uisave('stimdata')

end


