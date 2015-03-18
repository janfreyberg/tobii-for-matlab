function PsychTobiiMirrorEyes(scr)

dispSize = Screen('Rect', scr);


tetio_startTracking;
KbName('UnifyKeyNames');
dotSize = 0.1*dispSize(4);

while 1
    
    [lefteye, righteye, ~, ~] = tetio_readGazeData;
    
    if isempty(lefteye)
        continue
    end
    
    lefteye = lefteye(end, :);
    righteye = righteye(end, :);
    
    leftx = lefteye(end, 4) * dispSize(3);
    lefty = lefteye(end, 5) * dispSize(4);
    
    rightx = righteye(end, 4) * dispSize(3);
    righty = righteye(end, 5) * dispSize(4);
    
    if lefteye(end, 13) == 0 && righteye(end, 13) == 0
        colour = [0 255 0];
        dotRects = [leftx - dotSize/2, rightx - dotSize/2;
                    lefty - dotSize/2, righty - dotSize/2;
                    leftx + dotSize/2, rightx + dotSize/2;
                    lefty + dotSize/2, righty + dotSize/2];
    elseif lefteye(end, 13) == 4 && righteye(end, 13) == 4
        continue
    elseif lefteye(end, 13) == 4 && righteye(end, 13) == 0
        colour = [0 255 0];
        dotRects = [rightx - dotSize/2;
                    righty - dotSize/2;
                    rightx + dotSize/2;
                    righty + dotSize/2];
    elseif lefteye(end, 13) == 0 && righteye(end, 13) == 4
        colour = [0 255 0];
        dotRects = [leftx - dotSize/2;
                    lefty - dotSize/2;
                    leftx + dotSize/2;
                    lefty + dotSize/2];
    elseif lefteye(end, 13) == 3 && righteye(end, 13) == 1
        colour = [255 255 0];
        dotRects = [rightx - dotSize/2;
                    righty - dotSize/2;
                    rightx + dotSize/2;
                    righty + dotSize/2];
    elseif lefteye(end, 13) == 1 && righteye(end, 13) == 3
        colour = [255 255 0];
        dotRects = [leftx - dotSize/2;
                    lefty - dotSize/2;
                    leftx + dotSize/2;
                    lefty + dotSize/2];
    elseif lefteye(end, 13) == 2 && righteye(end, 13) == 2
        colour = [255 0 0];
        dotRects = [leftx - dotSize/2;
                    lefty - dotSize/2;
                    leftx + dotSize/2;
                    lefty + dotSize/2];
    end
    
    Screen('FillOval', scr, colour, dotRects, dotSize);
    Screen('Flip', scr);
    
    [~, ~, keyCode] = KbCheck;
    
    if keyCode(KbName('Return'));
        tetio_stopTracking;
        break
    elseif keyCode(KbName('Escape'));
        tetio_stopTracking;
        error('Presses escape during Mirroring');
        
    end
    
end
end