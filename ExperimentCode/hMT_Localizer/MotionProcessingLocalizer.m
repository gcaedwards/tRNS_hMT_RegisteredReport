function MotionProcessingLocalizer

% Original author of DotDemo: Keith Schneider, 12/13/04

% 12/16/21 Grace Edwards    Used DotDemo and made into motion processing localizer

%% Check PTB is working properly

AssertOpenGL;

%% Check sync between screens

Screen('Preference', 'SkipSyncTests', 1); %

%% Output directory created

if ~exist('Output','dir')
    mkdir('Output/')
end

%% Parameters

% activate keys
KbName('UnifyKeyNames');
triggerkey=KbName('t');
responsekey=KbName('r');
quitkey=KbName('ESCAPE');

% Enter participant number and the starting block type Motion or Static
prompt = {'Enter participant ID:','Run 1 or 2?','4C216(1), or MRI 100 Hz(2) or MRI 120 Hz(3)'}; %Hz of screen impacts number of frames presented
dlgtitle = 'Input';
dims = [1 45];
answer = inputdlg(prompt,dlgtitle,dims);
subid = answer{1};
startBlock = answer{2};
comp = answer{3};

%outputname
tmp=clock;          
outputName = sprintf('LatMotLoc_sub%s_run%s_%d%02d%02d%02d%02d',...
            subid,startBlock,tmp(1),tmp(2),tmp(3),tmp(4),tmp(5));

% Least squares counterbalancing
% Run1: F,1,2,4,3,F,2,3,1,4,F,4,1,3,2,F,3,4,2,1,F
% Run2: F,3,4,2,1,F,4,1,3,2,F,2,3,1,4,F,1,2,4,3,F
% F = fixation
% 1 = Motion, Right
% 2 = Static, Right
% 3 = Motion, Left
% 4 = Static, Left

% Define block type list
if contains(startBlock,'1')
    BlockOrder = {'F','M','S','S','M','F','S','M','M','S','F','S','M','M','S','F','M','S','S','M','F'};
    SideOrder = {'F','R','R','L','L','F','R','L','R','L','F','L','R','L','R','F','L','L','R','R','F'};
elseif contains(startBlock,'2')
    BlockOrder = {'F','M','S','S','M','F','S','M','M','S','F','S','M','M','S','F','M','S','S','M','F'};
    SideOrder = {'F','L','L','R','R','F','L','R','L','R','F','R','L','R','L','F','R','R','L','L','F'};
else
    error('Start block type not recognized!')
end

    % ------------------------
    % set dot field parameters
    % ------------------------

    % number of animation frames in loop 
    if comp == '1'
       nframes     = 898; % 898 = 15 seconds in lab at 60 Hz
    elseif comp == '2'
       nframes     = 1500; % 1500 = 15 seconds in scanner at 100 Hz
    elseif comp == '3'
       nframes     = 1796; % 1796 = 15 seconds in scanner at 120 Hz   
    end
    
    mon_width   = 64;   % horizontal dimension of viewable screen (cm)
    v_dist      = 72;   % viewing distance (cm)
    dot_speed   = 7;    % dot speed (deg/sec)
    f_kill      = 0.05; % fraction of dots to kill each frame (limited lifetime)
    ndots       = 300; % number of dots
    max_d       = 7.5;   % maximum radius of  annulus (degrees)
    min_d       = 0.3;    % minumum
    dot_w       = 0.2;  % width of dot (deg)
    fix_r       = 0.15; % radius of fixation point (deg)
    fix_tar       = 0.5; % radius of target dot (deg)
    differentcolors =0; % Use a different color for each point if == 1. Use common color white if == 0. UNUSED FOR NOW
    differentsizes = 0; % Use different sizes for each point if >= 1. Use one common size if == 0. UNUSED FOR NOW
    waitframes = 1;     % Show new dot-images at each waitframes'th monitor refresh.
    dummyTime=12; %make into 12 for running with scanner
    IBI=1; %inter block interval 0.5 sec
    
    if differentsizes>0  % drawing large dots is a bit slower
        ndots=round(ndots/5);
    end


try
    
    % ---------------
    % open the screen
    % ---------------
    
    screens=Screen('Screens');
    screenNumber=max(screens); 
    [w, rect] = Screen('OpenWindow', screenNumber, 0); 
    
    % Enable alpha blending with proper blend-function. We need it
    % for drawing of smoothed points:
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [center(1), center(2)] = RectCenter(rect);
    [left(1), left(2)]=RectCenter(rect); left(1)=left(1)/2;
    [right(1), right(2)]=RectCenter(rect); right(1)=right(1)+left(1);
    
    fps=Screen('FrameRate',w);     % frames per second
    ifi=Screen('GetFlipInterval', w);
    if fps==0
       fps=1/ifi;
    end

    white = WhiteIndex(w);
    HideCursor; % Hide the mouse cursor
    commandwindow;
    Priority(MaxPriority(w));

    % Do initial flip...
    vbl=Screen('Flip', w);
    
    Screen(w,'DrawText','Welcome to the experiment!',(center(1)-100),center(2),white);
    Screen('Flip',w);

    while 1
        % first check trigger from button relay
        [keyDown, keyTime, keyCodes] = KbCheck(-1); 
        if keyDown
            if keyCodes(triggerkey)
                break;
            elseif keyCodes(quitkey)
                sca; ShowCursor; return;
            end
        end
    end
    
    scanStart = keyTime;
    
    % ---------------------------------------
    % initialize dot positions and velocities
    % ---------------------------------------

    ppd = pi * (rect(3)-rect(1)) / atan(mon_width/v_dist/2) / 360;    % pixels per degree
    pfs = dot_speed * ppd / fps;                            % dot speed (pixels/frame)
    s = dot_w * ppd;                                        % dot size (pixels)
    fix_cord = [center-fix_r*ppd center+fix_r*ppd];
    left_cord = [left-fix_tar*ppd left+fix_tar*ppd];
    right_cord = [right-fix_tar*ppd right+fix_tar*ppd];
    
    rmax = max_d * ppd;	% maximum radius of annulus (pixels from center)
    rmin = min_d * ppd; % minimum
    
    while GetSecs-scanStart <= dummyTime 
            Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot (flip erases it)
            Screen('Flip',w);
    end
    
    %loop for each block
    
    for blk=1:length(BlockOrder)
        
        %randomize when central point will change color
        coldot=randi([10, nframes-10],1,1); %choose a frame to present colored dot
        
        %randomize starting position for each block
        r = rmax * sqrt(rand(ndots,1));	% r
        r(r<rmin) = rmin;
        t = 2*pi*rand(ndots,1);                     % theta polar coordinate
        cs = [cos(t), sin(t)];
        xy = [r r] .* cs;   % dot positions in Cartesian coordinates (pixels from center)
        
        mdir = 2 * floor(rand(ndots,1)+0.5) - 1;    % motion direction (in or out) for each dot
        dr = pfs * mdir;                            % change in radius per frame (pixels)
        dxdy = [dr dr] .* cs;                       % change in x and y per frame (pixels)
        
        % Create a vector with different colors for each single dot, if
        % requested:
        if (differentcolors==1)
            colvect = uint8(round(rand(3,ndots)*255));
        else
            colvect=white;
        end
        
        % Create a vector with different point sizes for each single dot, if
        % requested:
        if (differentsizes>0)
            s = (1+rand(1, ndots)*(differentsizes-1))*s;
        end
        
        % Clamp point sizes to range supported by graphics hardware:
        [minsmooth,maxsmooth] = Screen('DrawDots', w);
        s = min(max(s, minsmooth), maxsmooth);
        
        if strcmp(BlockOrder{blk},'M')
            
            resp = -100;
            RT = -100;
            
            Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
            blockStart=Screen('Flip',w);
            
            
            % --------------
            % animation loop
            % --------------
            for i = 1:nframes
                if (i>1)
                    
                    Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
                    
                    if i>=coldot && i<coldot+9
                        Screen('FillOval', w, [203 66 245], fix_cord);  % draw fixation dot
                    end                    
                    
                    if strcmp(SideOrder{blk},'R')
                       
                        Screen('DrawDots', w, xymatrix, s, colvect, right, 1);  % draw dots
                        
                    elseif strcmp(SideOrder{blk},'L')
                        
                        Screen('DrawDots', w, xymatrix, s, colvect, left, 1);  % draw dots
                        
                    end
                    
                    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                end
                
                % detect keypress
                [keyDown, keyTime, keyCodes] = KbCheck(-1);
                if keyDown
                    if keyCodes(responsekey)
                        RT=keyTime-blockStart;
                        resp=responsekey;
                    elseif keyCodes(quitkey)
                        sca; ShowCursor; return;
                    end
                end
                
                xy = xy + dxdy; % move dots
                r = r + dr; % update polar coordinates too
                
                % check to see which dots have gone beyond the borders of the annuli
                
                r_out = find(r > rmax | r < rmin | rand(ndots,1) < f_kill);	% dots to reposition
                nout = length(r_out);
                
                if nout
                    
                    % choose new coordinates
                    
                    r(r_out) = rmax * sqrt(rand(nout,1));
                    r(r<rmin) = rmin;
                    t(r_out) = 2*pi*(rand(nout,1));
                    
                    % now convert the polar coordinates to Cartesian
                    
                    cs(r_out,:) = [cos(t(r_out)), sin(t(r_out))];
                    xy(r_out,:) = [r(r_out) r(r_out)] .* cs(r_out,:);
                    
                    % compute the new cartesian velocities
                    
                    dxdy(r_out,:) = [dr(r_out) dr(r_out)] .* cs(r_out,:);
                end
                
                xymatrix = transpose(xy);
                
                vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
                
            end
            
            %Between each block
            Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
            BlockEnd=Screen('Flip', w);
            WaitSecs(IBI);
            
        elseif strcmp(BlockOrder{blk},'S')
            
            resp = -100;
            RT = -100;
            
            Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
            blockStart=Screen('Flip',w);
            
            for i = 1:nframes
                if (i>1)
                    Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
                    
                    if i>=coldot && i<coldot+9
                            Screen('FillOval', w, [203 66 245], fix_cord);  % draw fixation dot
                    end
                    
                    if strcmp(SideOrder{blk},'R')

                        Screen('DrawDots', w, xymatrix, s, colvect, right, 1);  % draw dots
                        
                    elseif strcmp(SideOrder{blk},'L')

                        Screen('DrawDots', w, xymatrix, s, colvect, left, 1);  % draw dots
                        
                    end
                    
                    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                end
                
                % detect keypress
                [keyDown, keyTime, keyCodes] = KbCheck(-1);
                if keyDown
                    if keyCodes(responsekey)
                        RT=keyTime-blockStart;
                        resp=responsekey;
                    elseif keyCodes(quitkey)
                        sca; ShowCursor; return;
                    end
                end
                
                xymatrix = transpose(xy);
                vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
                
            end
            
            %Between each block
            Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
            blockEnd=Screen('Flip', w);
            WaitSecs(IBI);
            
            
        elseif strcmp(BlockOrder{blk},'F')
            
            resp = -100;
            RT = -100;
            
            Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
            blockStart=Screen('Flip',w);
            
            for i = 1:nframes
                if (i>1)
                    
                    Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
                    
                    if i>=coldot && i<coldot+9
                        Screen('FillOval', w, [203 66 245], fix_cord);  % draw pink target
                    end
                    
                    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                end
                
                % detect keypress
                [keyDown, keyTime, keyCodes] = KbCheck(-1);
                if keyDown
                    if keyCodes(responsekey)
                        RT=keyTime-blockStart;
                        resp=responsekey;
                    elseif keyCodes(quitkey)
                        sca; ShowCursor; return;
                    end
                end
                
                vbl=Screen('Flip', w, vbl + (waitframes-0.5)*ifi);
                
            end
            
            %Between each block
            Screen('FillOval', w, uint8(white), fix_cord);  % draw fixation dot
            blockEnd=Screen('Flip', w);
            WaitSecs(IBI);
             
        end
                
        resultMat(blk).BlockType = BlockOrder{blk};
        resultMat(blk).Side = SideOrder{blk};
        resultMat(blk).BlockOnset = blockStart-scanStart;
        resultMat(blk).Resp = resp;
        resultMat(blk).RT = RT-(coldot*ifi);
        resultMat(blk).TargetFrame = coldot;
        resultMat(blk).RTfromBlockStart = RT;
        resultMat(blk).scanStart = scanStart;
        
    end
    
    resultMat(blk).runDur = GetSecs-scanStart;
    save(['Output/' outputName],'resultMat');
    
    Priority(0);
    ShowCursor;
    sca;
catch
    Priority(0);
    ShowCursor;
    sca;
end
