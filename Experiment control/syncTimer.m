function syncTimer(countdown)
    % outputs a countdown in the command window
    cc = countdown;
    while cc > 0
        fprintf('%d\n', cc);
        cc = cc-1;
        beep;
        pause(1);
        
    end
    fprintf('START\n');
end