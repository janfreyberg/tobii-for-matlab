function PsychTobiiCalibrate(scr)
KbName('UnifyKeyNames');
ent_key = KbName('Return'); ent_key = ent_key(1);
while 1
%% start calibration


dispSize = Screen('Rect', scr);

calibPoints = [[0.1, 0.5, 0.9, 0.1, 0.5, 0.9, 0.1, 0.5, 0.9]*dispSize(3); [0.1, 0.1, 0.1, 0.5, 0.5, 0.5, 0.9, 0.9, 0.9]*dispSize(4)];

calibOrder = randperm(9);

calibPoints = [calibPoints(1, calibOrder); calibPoints(2, calibOrder)];

Screen('DrawDots', scr, calibPoints, 20, [255 0 0]);
DrawFormattedText(scr, 'Press any key to start', 'center', 0.25*dispSize(4));
Screen('Flip', scr);
KbStrokeWait;
tetio_startCalib;
WaitSecs(0.1);

%% Display Stimuli & calibrate
dotSize = round([linspace(0.05*min(dispSize(3:4)), 0.015*min(dispSize(3:4)), 30), 0.015*min(dispSize(3:4)) - 0.005*min(dispSize(3:4))*sin(linspace(0, 4*pi, 45))]);
dotColor = [255 0 0];


for i = 1:9
    
    % move dots
    
    if i>1
        speed = round(60 * ( sqrt( (calibPoints(1, i-1)-calibPoints(1, i))^2 +  (calibPoints(2, i-1)-calibPoints(2, i))^2)/(0.4*dispSize(4)) ));
        movePoint = [linspace(calibPoints(1, i-1), calibPoints(1, i), speed); linspace(calibPoints(2, i-1), calibPoints(2, i), speed)];
    else
        speed = round(60 * ( sqrt( (calibPoints(1, 9)-calibPoints(1, 1))^2 +  (calibPoints(2, 9)-calibPoints(2, 1))^2)/(0.4*dispSize(4))));
        movePoint = [linspace(calibPoints(1, 9), calibPoints(1, 1), speed); linspace(calibPoints(2, 9), calibPoints(2, 1), speed)];
    end
    
    for ii = 1:speed
        Screen('FillOval', scr, dotColor, [movePoint(1, ii)-dotSize(1)/2, movePoint(2, ii)-dotSize(1)/2, movePoint(1, ii)+dotSize(1)/2, movePoint(2, ii)+dotSize(1)/2]);
        Screen('Flip', scr);
    end

    
    WaitSecs(0.3);
    
    % shrink dots
    for ii = 1:75
        
        Screen('FillOval', scr, dotColor, [calibPoints(1, i)-dotSize(ii)/2, calibPoints(2, i)-dotSize(ii)/2, calibPoints(1, i)+dotSize(ii)/2, calibPoints(2, i)+dotSize(ii)/2]);
        Screen('Flip', scr);
        
    end
    tic;
    tetio_addCalibPoint(calibPoints(1, i)/dispSize(3), calibPoints(2, i)/dispSize(4));
    toc;
    pause(0.2);
    
    WaitSecs(0.5);
    
end

%% Compute, Redo calibration?
tetio_computeCalib;

calibPlotData = tetio_getCalibPlotData;

WaitSecs(0.5);
n_points = size(calibPlotData, 2)/8;
calibLeftX = [ calibPlotData([3:8:((n_points)*8)]) ];
calibLeftY = [ calibPlotData([4:8:((n_points)*8)]) ];

calibLeftX = calibLeftX( calibPlotData( 5:8:((n_points)*8) ) == 1 );
calibLeftY = calibLeftY( calibPlotData( 5:8:((n_points)*8) ) == 1 );

calibRightX = [ calibPlotData([6:8:((n_points)*8)]) ];
calibRightY = [ calibPlotData([7:8:((n_points)*8)]) ];

calibRightX = calibRightX( calibPlotData( 8:8:((n_points)*8) ) == 1 );
calibRightY = calibRightY( calibPlotData( 8:8:((n_points)*8) ) == 1 );

calibOrig = [calibPlotData([1:8:n_points*8]); calibPlotData([2:8:n_points*8])];

calibLeftLines = zeros(2, 2*size(calibLeftX, 2));
calibLeftLines(1, 1:2:2*size(calibLeftX, 2)) = dispSize(3)*calibLeftX(1, :);
calibLeftLines(2, 1:2:2*size(calibLeftY, 2)) = dispSize(4)*calibLeftY(1, :);
calibLeftLines(1, 2:2:2*size(calibLeftX, 2)) = dispSize(3)*calibOrig(1, calibPlotData( 5:8:((n_points)*8) ) == 1);
calibLeftLines(2, 2:2:2*size(calibLeftY, 2)) = dispSize(4)*calibOrig(2, calibPlotData( 5:8:((n_points)*8) ) == 1);

calibRightLines = zeros(2, 2*size(calibLeftX, 2));
calibRightLines(1, 1:2:2*size(calibRightX, 2)) = dispSize(3)*calibRightX(1, :);
calibRightLines(2, 1:2:2*size(calibRightY, 2)) = dispSize(4)*calibRightY(1, :);
calibRightLines(1, 2:2:2*size(calibRightX, 2)) = dispSize(3)*calibOrig(1, calibPlotData( 8:8:((n_points)*8) ) == 1);
calibRightLines(2, 2:2:2*size(calibRightY, 2)) = dispSize(4)*calibOrig(2, calibPlotData( 8:8:((n_points)*8) ) == 1);

Screen('DrawDots', scr, [calibLeftX*dispSize(3); calibLeftY*dispSize(4)], 4, [255 0 0], [], 2);
Screen('DrawDots', scr, [calibRightX*dispSize(3); calibRightY*dispSize(4)], 4, [0 255 0], [], 2);

Screen('DrawLines', scr, calibLeftLines, 1, [255 0 0], [], 0);
Screen('DrawLines', scr, calibRightLines, 1, [0 255 0], [], 0);

Screen('DrawDots', scr, calibPoints, 10, [0 0 255], [], 2); 

DrawFormattedText(scr, sprintf('Valid Samples: %d\nInvalid: %d\nAccept: Enter\nRedo: Space\nExit:Escape', n_points/9, sum([calibPlotData( 5:8:((n_points)*8) ) == 1, calibPlotData( 8:8:((n_points)*8) ) == 1])), 'center', 0.25*dispSize(4));

Screen('Flip', scr);

WaitSecs(2);
[~, keyCode, ~] = KbWait;
if KbName(ent_key)
    break
elseif keyCode(KbName('space'))
    tetio_clearCalib;
    continue
else
    error('Interrupted during Tobii Calibration');
end

end

tetio_stopCalib;
