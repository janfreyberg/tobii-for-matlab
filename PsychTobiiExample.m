try

try
tetio_init;
tetio_connectTracker('TT120-301-10900819'); % <===== this is specific to a scanner
eyetracking = 1;
catch tobiiErr
rethrow(tobiiErr);
end

scr = Screen('OpenWindow', 0, 127.5);
screen_size = Screen('Rect', scr);
HideCursor;

% Set sample rate
tetio_setFrameRate(120);

% Mirror the eyes. Make sure both eyes are visible & green
PsychTobiiMirrorEyes(scr);

% Calibrate the tobii. This is a 9-point calibration routine
PsychTobiiCalibrate(scr);



% Sampling Demonstration

Screen('Flip', scr);
WaitSecs(1);

% Draw Picture
imarray = imread(fullfile(pwd, '33.jpg'));
imarray = imresize(imarray, 1.5);
Screen('PutImage', scr, imarray);
Screen('Flip', scr);

% Start recording. Tobii will record all data into is buffer.
tetio_startTracking;

WaitSecs(4);

% Read all the data from the tobii's buffer
[gaze.lefteye, gaze.righteye, gaze.timestamp, ~] = tetio_readGazeData;
% Stop recording
tetio_stopTracking;



Screen('Flip', scr);
WaitSecs(1);

% Extract the coordinates of where you were looking. Read SDK PDF for more
% info, but X is column 7, and Y is column 8
x = gaze.lefteye(:, 7) * screen_size(3);
y = gaze.lefteye(:, 8) * screen_size(4);


% This loop just displays a green dot wherever the person was looking!
for i = 1:numel(x);
    Screen('PutImage', scr, imarray);
    Screen('FillOval', scr, [125 255 125], [x(i)-10 y(i)-10 x(i)+10 y(i)+10]);
    if i > 1
        last10 = i-1:-1:i-10;
        last10(last10<1)=[];
    for ii = last10
        alphaV = 255 - (i-ii)*0.1*255;
        Screen('FillOval', scr, [125 255 125 alphaV], [x(ii)-10 y(ii)-10 x(ii)+10 y(ii)+10]);
    end
    end
    Screen('Flip', scr, times(i));
end

sca; % clear all screen windows

% Shut down the Tobii Server
tetio_cleanUp;

catch err
    % Shutdown Routine in case an error occurs
    sca;
    
    % Shut down the tobii server
    tetio_cleanUp;
    
    rethrow(err);
end