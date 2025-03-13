%% Motion Coherence Master script with MLP thresholding

% Developed using: 1. Dots demo from Shadlen Lab, 2014
%                  2. Grassi MLP functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Code written by Grace Edwards
% Experiment run on Matlab 2016b with PTB-3 
% Have not confirmed experiment will run on other versions of Matlab

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% File structure

% In main folder save tRNS_MC_thres_MLP.m (this is the master script)
% Create functions folder and save:
% 1. openExperiment.m
% 2. closeExperiment.m
% 3. createDotInfo.m
% 4. dotsX.m
% 5. all arrow images (8 total).

% download MLP functions from: https://dpg.unipd.it/en/mlp/mlp-toolbox
% add MLP folder (called psychoacoustic) to path - we saved the folder 
% in a shared location for multiuse. 
% Alternatively add MLP functions to function folder.

%% Lines to edit:

%Paths - lines 36 & 39
%Screens - lines 62:68

%%
clear

%cd to path where script is saved
cd ('INSERT PATH WHERE SCRIPT SAVED');

%add path to functions folder
addpath('INSERT PATH WHERE SCRIPT SAVED/Functions');

%% Output directory created

if ~exist('Output','dir')
    mkdir('Output/')
end

%% Enter participant number and the starting block type Motion or Static
prompt = {'Enter participant ID:','Laptop(1), testRoom1(2), or VPixx(3)'}; %select which screen presented 
dlgtitle = 'Input';
dims = [1 40];
answer = inputdlg(prompt,dlgtitle,dims);
subid = answer{1};
Setup = answer{2};

%% Set-up

nTrials=64;
nBlocks=5;

% Initialize the screen - SHOULD BE EDITED
if Setup=='1'
    screenInfo = openExperiment(32,50,0); % monWidth, viewDist, curScreen
elseif Setup=='2'
    screenInfo = openExperiment(65,70,1);
elseif Setup=='3'
    screenInfo = openExperiment(54,57,1); %VPixx - screen used for experiment     
end

% Initialize stimuli
dotInfo = createDotInfo(screenInfo);

% Put cursor in command window
commandwindow;

left_t=1; %initialize left VF trial counter
right_t=1; %initialize right VF trial counter

for b=1:nBlocks
    
    if b==1
        starter=GetSecs;
    end
   
    Screen('DrawText',screenInfo.curWindow,['Block ' int2str(b) ' of 5'],(screenInfo.center(1)-100),screenInfo.center(2),screenInfo.white);
    Screen('Flip',screenInfo.curWindow);
    
    if b==1
       WaitSecs(0.5) 
    else
       WaitSecs(28); %give subjects a 30 second break between blocks 
    end
    
    Screen('DrawText',screenInfo.curWindow,'Ready...',(screenInfo.center(1)-100),screenInfo.center(2),screenInfo.white);
    Screen('Flip',screenInfo.curWindow);
    WaitSecs(2);
    
    for t=1:nTrials
        
        %fixation point
        Screen('FillOval',screenInfo.curWindow,dotInfo.fixColor,screenInfo.CentFix);
        Screen('Flip',screenInfo.curWindow);
        WaitSecs(1);
        
        % Present dots
        [frames,rseed,start_time,end_time,response,response_time,x,y,dotInfo] = ...
            dotsX(screenInfo,dotInfo,t);
        
        %Record response and Stimulus level depending on visual field
        if dotInfo.DirSide(t,2)==1 %if left visual field
            
            if x >= dotInfo.corrResp(t,1) && x <= dotInfo.corrResp(t,3) && y >= dotInfo.corrResp(t,2) && y <= dotInfo.corrResp(t,4)
                LeftAcc(left_t)=1;
                LeftStimLevel(left_t)=dotInfo.cohSet; 
            else
                LeftAcc(left_t)=0;
                LeftStimLevel(left_t)=dotInfo.cohSet;
                
            end
            
            %output file
            resultMatLeft(left_t).trial = t;
            resultMatLeft(left_t).Block = b;
            resultMatLeft(left_t).Side = dotInfo.DirSide(t,2);
            resultMatLeft(left_t).cohSet = dotInfo.cohSet;
            resultMatLeft(left_t).dirSet = dotInfo.dirSet(1);
            resultMatLeft(left_t).resp = LeftAcc(left_t);
            resultMatLeft(left_t).RT = response_time;
            resultMatLeft(left_t).xClick = x;
            resultMatLeft(left_t).yClick = y;
            
            %find threshold for next left
            [dotInfo.cohSetLeft, FA]=FindThreshold(dotInfo.ptarget, LeftStimLevel(1:left_t), LeftAcc(1:left_t),...
                dotInfo.cohs, dotInfo.beta, dotInfo.gamma, dotInfo.lamba);

            leftshow=dotInfo.cohSetLeft;
            
            left_t=left_t+1;
            
        else
            
            if x >= dotInfo.corrResp(t,1) && x <= dotInfo.corrResp(t,3) && y >= dotInfo.corrResp(t,2) && y <= dotInfo.corrResp(t,4)
                RightAcc(right_t)=1;
                RightStimLevel(right_t)=dotInfo.cohSet; 
            else
                RightAcc(right_t)=0;
                RightStimLevel(right_t)=dotInfo.cohSet;
            end
            
            %output file
            resultMatRight(right_t).trial = t;
            resultMatRight(right_t).Block = b;
            resultMatRight(right_t).Side = dotInfo.DirSide(t,2);
            resultMatRight(right_t).cohSet = dotInfo.cohSet;
            resultMatRight(right_t).dirSet = dotInfo.dirSet(1);
            resultMatRight(right_t).resp = RightAcc(right_t);
            resultMatRight(right_t).RT = response_time;
            resultMatRight(right_t).xClick = x;
            resultMatRight(right_t).yClick = y;
            
            %find threshold for next left
            [dotInfo.cohSetRight, FA]=FindThreshold(dotInfo.ptarget, RightStimLevel(1:right_t), RightAcc(1:right_t),...
                dotInfo.cohs, dotInfo.beta, dotInfo.gamma, dotInfo.lamba);

            rightshow=dotInfo.cohSetRight;
            
            right_t=right_t+1;
            
        end
        
        
    end
    
    %outputname
    tmp=clock;
    outputName = sprintf('MC_MLPthres_sub%s_block%d_%d%02d%02d%02d%02d',...
        subid,b,tmp(1),tmp(2),tmp(3),tmp(4),tmp(5));
    
    save(['Output/' outputName],'resultMatRight','resultMatLeft','dotInfo'); %dotInfo has the last cohSetRight and cohSetLeft
    
end


ender=GetSecs-starter;

closeExperiment; % clear the screen and exit

