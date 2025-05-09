function [frames,rseed,start_time,end_time,response,response_time,x,y,dotInfo] = dotsX(screenInfo,dotInfo,t)
% DOTSX display dots on screen
%
% [frames,rseed,start_time,end_time,response,response_time] = dotsX(screenInfo,dotInfo)
%
% For information on minimum fields of screenInfo and dotInfo arguments, see
% also openExperiment and createDotInfo. The input argument - "targets" is not
% necessary unless showing targets with the dots. 
%
%   dotInfo.numDotField     number of dot patches that will be shown on screen
%   dotInfo.coh             vertical vectors, dots coherence (0...999) for each 
%                           dot patch
%   dotInfo.speed           vertical vectors, dots speed (10th deg/sec) for each 
%                           dot patch
%   dotInfo.dir             vertical vectors, dots direction (degrees) for each 
%                           dot patch
%   dotInfo.dotSize         size of dots in pixels, same for all patches
%   dotInfo.dotColor        color of dots in RGB, same for all patches
%   dotInfo.maxDotsPerFrame determined by testing video card
%   dotInfo.apXYD           x, y coordinates, and diameter of aperture(s) in 
%                           visual degrees          
%   dotInfo.maxDotTime      optional to set maximum duration (sec). If not provided, 
%                           dot presentation is terminated only by user response
%   dotInfo.trialtype       1 fixed duration, 2 reaction time
%   dotInfo.keys            a set of keyboard buttons that can terminate the 
%                           presentation of dots (optional)
%   dotInfo.mouse           a set of mouse buttons that can terminate the 
%                           presentation of dots (optional)
%
%   screenInfo.curWindow    window pointer on which to plot dots
%   screenInfo.center       center of the screen in pixels
%   screenInfo.ppd          pixels per visual degree
%   screenInfo.monRefresh   monitor refresh value
%   screenInfo.dontclear    If set to 1, flip will not clear the framebuffer 
%                           after Flip - this allows incremental drawing of 
%                           stimuli. Needs to be zero for dots to be erased.
%   screenInfo.rseed        random # seed, can be empty set[] 
%

%
% Algorithm:
%   All calculations take place within a square aperture in which the dots are 
% shown. The dots are constructed in 3 sets that are plotted in sequence.  For 
% each set, the probability that a dot is replotted in motion -- as opposed to 
% randomly replaced -- is given by the dotInfo.coh value. This routine generates 
% a set of dots as an (ndots,2) matrix of locations, and then plots them.  In 
% plotting the next set of dots (e.g., set 2), it prepends the preceding set 
% (e.g., set 1).
%

% created by MKMK July 2006, based on ShadlenDots by MNS, JIG and others

% Structures are not altered in this function, so should not have memory
% problems from matlab creating new structures.

% CURRENTLY THERE IS AN ALMOST ONE SECOND DELAY FROM THE TIME DOTSX IS
% CALLED UNTIL THE DOTS START ON THE SCREEN! THIS IS BECAUSE OF PRIORITY.
% NEED TO EVALUATE WHETHER PRIORITY IS REALLY NECESSARY.

curWindow = screenInfo.curWindow;
dotColor = dotInfo.dotColor;
rseed = screenInfo.rseed;

%Seed first trials in left and right visual field

if isempty(dotInfo.cohSetLeft)
    
    dotInfo.cohSet = 0.90; %start at 100% correct
    
elseif isempty(dotInfo.cohSetRight)
    
    dotInfo.cohSet = 0.90; %start at 100% correct
    
elseif dotInfo.cohSetLeft && dotInfo.DirSide(t,2) == 1 
    
    dotInfo.cohSet = dotInfo.cohSetLeft; %0.95;%
    
elseif dotInfo.cohSetRight && dotInfo.DirSide(t,2) == 2 
    
    dotInfo.cohSet = dotInfo.cohSetRight; %0.95;%
    
end

dotInfo.dirSet = [dotInfo.DirSide(t,1),dotInfo.DirSide(t,1)]; % may be able to just use one value!

dotInfo.coh = dotInfo.cohSet(ceil(rand*length(dotInfo.cohSet)))*1000;
dotInfo.dir = dotInfo.dirSet(ceil(rand*length(dotInfo.dirSet)));

%decide where to present dots
if dotInfo.DirSide(t,2) == 1 
    dotInfo.apXYD = [-120 0 80]; %left - needs to be a 8 deg aperture, which is centered on 12 deg from fixation
else
    dotInfo.apXYD = [120 0 80]; %right
end
    
keys = [dotInfo.keyN dotInfo.keyNE dotInfo.keyE dotInfo.keySE dotInfo.keyS dotInfo.keySW dotInfo.keyW dotInfo.keyNW];

% mouse
if isfield(dotInfo, 'mouse')
    mouse = dotInfo.mouse;
else
    mouse = [];
end

%clear important variables
start_time = NaN;
end_time = NaN;
response = NaN; 
response_time = NaN;
x = NaN;
y = NaN;

% Seed the random number generator. If "[]" is given, reset the seed "randomly".
% This is for VAR/NOVAR conditions.
if ~isempty(rseed) && length(rseed) == 1    
    rng(rseed,'v5uniform');
elseif ~isempty(rseed) && length(rseed) == 2
    rng(rseed(1)*rseed(2),'v5uniform');
else
    rseed = sum(100*clock);
    rng(rseed,'v5uniform');
end

% Variables have been multiplied by a factor of 10 to make sure 
% they are integers. Now convert them back so that they are correct for plotting.
coh = dotInfo.coh/1000;	% dotInfo.coh is specified in range 0..1000, but we want in range 0..1
apD = dotInfo.apXYD(:,3); % diameter of aperture
center = repmat(screenInfo.center,size(dotInfo.apXYD(:,1)));

% Change x,y coordinates to pixels (y is inverted - pos on bottom, neg. on top)
center = [center(:,1) + dotInfo.apXYD(:,1)/10*screenInfo.ppd center(:,2) - ...
    dotInfo.apXYD(:,2)/10*screenInfo.ppd]; % where you want the center of the aperture
center(:,3) = dotInfo.apXYD(:,3)/2/10*screenInfo.ppd; % add diameter
d_ppd = floor(apD/10 * screenInfo.ppd);	% size of aperture in pixels
dotSize = dotInfo.dotSize; % probably better to leave this in pixels, but not sure

% ndots is the number of dots shown per video frame. Dots will be placed in a 
% square of the size of aperture.
% - Size of aperture = Apd*Apd/100  sq deg
% - Number of dots per video frame = 16.7 dots per sq deg/sec,
% When rounding up, do not exceed the number of dots that can be plotted in a 
% video frame (dotInfo.maxDotsPerFrame).
ndots = min(dotInfo.maxDotsPerFrame, ...
    ceil(16.7 * apD .* apD * 0.01 / screenInfo.monRefresh));

% Don't worry about pre-allocating, the number of dot fields should never be 
% large enough to cause memory problems.
for df = 1 : dotInfo.numDotField
    % dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
    %   deg/sec * ap-unit/deg * sec/jump = ap-unit/jump
    dxdy{df} = repmat((dotInfo.speed(df)/10) * (10/apD(df)) * ...
        (3/screenInfo.monRefresh) * [cos(pi*dotInfo.dir(df)/180.0), ...
        -sin(pi*dotInfo.dir(df)/180.0)], ndots(df),1);    
    ss{df} = rand(ndots(df)*3, 2); % array of dot positions raw [x,y]
    % Divide dots into three sets
    Ls{df} = cumsum(ones(ndots(df),3)) + repmat([0 ndots(df) ndots(df)*2], ... 
        ndots(df), 1);
    loopi(df) = 1; % loops through the three sets of dots
end

% Continue_show loop will stop when continue_show reaches 0 - depends on maxDotTime
if isfield(dotInfo,'maxDotTime') 
    continue_show = round(dotInfo.maxDotTime*screenInfo.monRefresh); %try ceil instead of round. Round 100.02ms ; Ceil 116.9ms 
else
    continue_show = 0;
end

dontclear = screenInfo.dontclear;

% The main loop
frames = 0;
priorityLevel = MaxPriority(curWindow,'KbCheck');
Priority(priorityLevel);

% Make sure the fixation still on
Screen('FillOval',screenInfo.curWindow,dotInfo.fixColor,screenInfo.CentFix); 

Screen('DrawingFinished',curWindow,dontclear);

% How dots are presented: 1st group of dots are shown in the first frame, a 2nd 
% group are shown in the second frame, a 3rd group shown in the third frame.
% Then in the next (4th) frame, some percentage of the dots from the 1st frame 
% are replotted according to the speed/direction and coherence. Similarly, the 
% same is done for the 2nd group, etc.

while continue_show
    for df = 1 : dotInfo.numDotField
        
        % Lthis has the dot positions from 3 frames ago, which is what is then
        Lthis{df}  = Ls{df}(:,loopi(df));
        
        % Moved in the current loop. This is a matrix of random numbers - starting 
        % positions of dots not moving coherently.
        this_s{df} = ss{df}(Lthis{df},:);
        
        % Update the loop pointer
        loopi(df) = loopi(df)+1;
        
        if loopi(df) == 4
            loopi(df) = 1;
        end
        
        % Compute new locations, how many dots move coherently
        L = rand(ndots(df),1) < coh(df);
        % Offset the selected dots
        this_s{df}(L,:) = bsxfun(@plus,this_s{df}(L,:),dxdy{df}(L,:));
        
        if sum(~L) > 0
            this_s{df}(~L,:) = rand(sum(~L),2);	% get new random locations for the rest
        end
        
        % Check to see if any positions are greater than 1 or less than 0 which 
        % is out of the square aperture, and replace with a dot along one of the
        % edges opposite from the direction of motion.
        N = sum((this_s{df} > 1 | this_s{df} < 0)')' ~= 0;
        
        if sum(N) > 0
            xdir = sin(pi*dotInfo.dir(df)/180.0);
            ydir = cos(pi*dotInfo.dir(df)/180.0);
            % Flip a weighted coin to see which edge to put the replaced dots
            if rand < abs(xdir)/(abs(xdir) + abs(ydir))
                this_s{df}(find(N==1),:) = [rand(sum(N),1),(xdir > 0)*ones(sum(N),1)];
            else
                this_s{df}(find(N==1),:) = [(ydir < 0)*ones(sum(N),1),rand(sum(N),1)];
            end
        end
        
        % Convert for plot
        this_x{df} = floor(d_ppd(df) * this_s{df});	% pix/ApUnit
        
        % It assumes that 0 is at the top left, but we want it to be in the 
        % center, so shift the dots up and left, which means adding half of the 
        % aperture size to both the x and y directions.
        dot_show{df} = (this_x{df} - d_ppd(df)/2)';
    end
    
    % After all computations, flip to draws dots from the previous loop. For the
    % first time, this doesn't draw anything.
    Screen('Flip', curWindow,0,dontclear);
    
    % Now do the actual drawing commands, although nothing is drawn until next        
    for df = 1:dotInfo.numDotField
        % NaN out-of-circle dots                
        xyDis = dot_show{df};
        outCircle = sqrt(xyDis(1,:).^2 + xyDis(2,:).^2) + dotInfo.dotSize/2 > center(df,3);        
        dots2Display = dot_show{df};
        dots2Display(:,outCircle) = NaN;
        
        Screen('DrawDots',curWindow,dots2Display,dotSize,dotColor,center(df,1:2),1); %add ,1 ro draw dots rather than squares?
    end
    

    Screen('FillOval',screenInfo.curWindow,dotInfo.fixColor,screenInfo.CentFix);
 
    % Tell PTB to get ready while doing computations for next dots presentation
    Screen('DrawingFinished',curWindow,dontclear);
    
    frames = frames + 1;
    
    if frames == 1     
        start_time = GetSecs;       
    end
       
    for df = 1 : dotInfo.numDotField
        % Update the dot position array for the next loop
        ss{df}(Lthis{df}, :) = this_s{df};
    end
    
    % Check for the end of loop
    continue_show = continue_show - 1;

    % Enable to exit script during dot presentation (and for very quick
    % responses)
    if ~isempty(keys)
        [keyDown,keyTime,keyCodes] = KbCheck(-1);
        if keyDown
            % Exit out of experiment
            if keyCodes(dotInfo.keyEscape)
                sca; ShowCursor; return;
            end
 
        end
    end

end

% Present the last frame of dots
Screen('Flip',curWindow,0,dontclear);

% Erase the last frame of dots, but leave up fixation 
Screen('FillOval',screenInfo.curWindow,dotInfo.fixColor,screenInfo.CentFix);
Screen('Flip',curWindow);
WaitSecs(0.3);

%place mouse of screen
ShowCursor;
SetMouse(screenInfo.center(1),screenInfo.center(2),screenInfo.curWindow);

Screen('FillOval',screenInfo.curWindow,dotInfo.fixColor,screenInfo.CentFix);
imageN=Screen(screenInfo.curWindow,'MakeTexture',dotInfo.Nim); 
imageNE=Screen(screenInfo.curWindow,'MakeTexture',dotInfo.NEim); 
imageE=Screen(screenInfo.curWindow,'MakeTexture',dotInfo.Eim); 
imageSE=Screen(screenInfo.curWindow,'MakeTexture',dotInfo.SEim); 
imageS=Screen(screenInfo.curWindow,'MakeTexture',dotInfo.Sim);
imageSW=Screen(screenInfo.curWindow,'MakeTexture',dotInfo.SWim); 
imageW=Screen(screenInfo.curWindow,'MakeTexture',dotInfo.Wim); 
imageNW=Screen(screenInfo.curWindow,'MakeTexture',dotInfo.NWim);

Screen('DrawTexture',screenInfo.curWindow,imageN,[],dotInfo.Nxy);
Screen('DrawTexture',screenInfo.curWindow,imageNE,[],dotInfo.NExy);
Screen('DrawTexture',screenInfo.curWindow,imageE,[],dotInfo.Exy);
Screen('DrawTexture',screenInfo.curWindow,imageSE,[],dotInfo.SExy);
Screen('DrawTexture',screenInfo.curWindow,imageS,[],dotInfo.Sxy);
Screen('DrawTexture',screenInfo.curWindow,imageSW,[],dotInfo.SWxy);
Screen('DrawTexture',screenInfo.curWindow,imageW,[],dotInfo.Wxy);
Screen('DrawTexture',screenInfo.curWindow,imageNW,[],dotInfo.NWxy);

Screen('Flip',curWindow);

if isfield(dotInfo,'maxRespTime')
    RespWait = round(dotInfo.maxRespTime*screenInfo.monRefresh);
else
    RespWait = 0;
end

% while RespWait
for i=1:RespWait
    
    if i==1
        RespStart=GetSecs;
    end
    
    if ~isempty(keys)
        [keyDown,keyTime,keyCodes] = KbCheck(-1);
        if keyDown
            % Exit out of experiment
            if keyCodes(dotInfo.keyEscape)
                sca; ShowCursor; return;
            end
        end
    end
    
    %check for mouse click
    if ~isempty(mouse)
        [x,y,buttons] = GetMouse(curWindow);
        
        press_right=buttons(1);
        press_left=buttons(3);
        if press_right==1
            response_time = GetSecs-start_time;
            HideCursor;
            SetMouse(0,0,screenInfo.curWindow); %move away from arrows
            % Erase arrows, but leave up fixation
            Screen('FillOval',screenInfo.curWindow,dotInfo.fixColor,screenInfo.CentFix);
            Screen('Flip',curWindow);
            RespUsed=GetSecs-RespStart;
            RespToGo=1.5-RespUsed;
            WaitSecs(RespToGo);
            mouse=[];
            break
            
        elseif press_left==1
            response_time = GetSecs-start_time;
            HideCursor;
            SetMouse(0,0,screenInfo.curWindow); %move away from arrows
            % Erase arrows, but leave up fixation
            Screen('FillOval',screenInfo.curWindow,dotInfo.fixColor,screenInfo.CentFix);
            Screen('Flip',curWindow);
            RespUsed=GetSecs-RespStart;
            RespToGo=1.5-RespUsed;
            WaitSecs(RespToGo);
            mouse=[];
            break
            
        end
       
        
    end
    
end


end_time = GetSecs;
Priority(0);


