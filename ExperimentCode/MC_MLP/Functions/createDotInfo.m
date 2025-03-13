 function dotInfo = createDotInfo(screenInfo) %side
% Creates the default dotInfo structure

% created June 2006 MKMK
% updated Dec 2021 Grace Edwards

ntrials=32;
dotInfo.cohSet = 0.99; %this will be edited in dotsX

%p-target:
dotInfo.ptarget = 0.7; % 0.7 70% - performance threshold
%midpoints:
dotInfo.cohs = -120:1:-30; %list of all coherences 0-100% 
dotInfo.cohs = dotInfo.cohs/100; %made into a 0-1 coherence in the master script 
%beta:
dotInfo.beta = 1/2; %slope of psychometric function (for every 1 step on x axis, go up by 0.5 on y axis)
%gamma:
dotInfo.gamma = 0.125; %chance level %0.125
%lamba:
dotInfo.lamba = 0; %subject's attention lapse rate 

%initialize left and right coherences

dotInfo.cohSetRight=[];
dotInfo.cohSetLeft=[];

%Which side to present to:
Lside=ones(1,ntrials); Rside=ones(1,ntrials)+1; Side=cat(2,Lside,Rside);

% Eight different directions: E, NE, N, NW, W, SW, S, SE
dotInfo.dirSet = [135, 135]; %%this will be edited in dotsX
dotInfo.dirs = [0; 45; 90; 135; 180; 225; 270; 315]; %list of all directions [E, NE, N, NW, W, SW, S, SE]

% %arrow locations - around fixation
distCent=100;
arrowX2=screenInfo.center(1); %x2
arrowX1=screenInfo.center(1)-distCent; %x1
arrowX3=screenInfo.center(1)+distCent; %x3
arrowY2=screenInfo.center(2); %Y2
arrowY1=screenInfo.center(2)-distCent; %Y1
arrowY3=screenInfo.center(2)+distCent; %Y3

%read in arrow images
Nimage = 'N_image.png';
dotInfo.Nim = imread(Nimage);

NWimage = 'NW_image.png';
dotInfo.NWim = imread(NWimage);

Wimage = 'W_image.png';
dotInfo.Wim = imread(Wimage);

SWimage = 'SW_image.png';
dotInfo.SWim = imread(SWimage);

Simage = 'S_image.png';
dotInfo.Sim = imread(Simage);

SEimage = 'SE_image.png';
dotInfo.SEim = imread(SEimage);

Eimage = 'E_image.png';
dotInfo.Eim = imread(Eimage);

NEimage = 'NE_image.png';
dotInfo.NEim = imread(NEimage);

%LOCATIONS
arrowSize=30; %in pixels
dotInfo.Nxy=[arrowX2-arrowSize arrowY1-arrowSize arrowX2+arrowSize arrowY1+arrowSize];
dotInfo.NExy=[arrowX3-arrowSize arrowY1-arrowSize arrowX3+arrowSize arrowY1+arrowSize];
dotInfo.Exy=[arrowX3-arrowSize arrowY2-arrowSize arrowX3+arrowSize arrowY2+arrowSize];
dotInfo.SExy=[arrowX3-arrowSize arrowY3-arrowSize arrowX3+arrowSize arrowY3+arrowSize];
dotInfo.Sxy=[arrowX2-arrowSize arrowY3-arrowSize arrowX2+arrowSize arrowY3+arrowSize];
dotInfo.SWxy=[arrowX1-arrowSize arrowY3-arrowSize arrowX1+arrowSize arrowY3+arrowSize];
dotInfo.Wxy=[arrowX1-arrowSize arrowY2-arrowSize arrowX1+arrowSize arrowY2+arrowSize];
dotInfo.NWxy=[arrowX1-arrowSize arrowY1-arrowSize arrowX1+arrowSize arrowY1+arrowSize];

%make 32 dot directions, randomize
%for left and right 
dirs=zeros(1,4);
dirs45=dirs+45; dirs90=dirs+90; dirs135=dirs+135; dirs180=dirs+180; dirs225=dirs+225; dirs270=dirs+270; dirs315=dirs+315;

direct=cat(2,dirs,dirs45,dirs90,dirs135,dirs180,dirs225,dirs270,dirs315)';
directions=cat(1,direct,direct);
directions(:,2)=Side;

dotInfo.DirSide=directions(randperm(size(directions,1)),:);

%number of dot fields
dotInfo.numDotField = 1; 

%correct response
for counts=1:length(dotInfo.DirSide)
    if dotInfo.DirSide(counts,1)==0
        dotInfo.corrResp(counts,:)=dotInfo.Exy; %East
    elseif dotInfo.DirSide(counts,1)==45
        dotInfo.corrResp(counts,:)=dotInfo.NExy; %NE 
    elseif dotInfo.DirSide(counts,1)==90
        dotInfo.corrResp(counts,:)=dotInfo.Nxy; %North
    elseif dotInfo.DirSide(counts,1)==135
        dotInfo.corrResp(counts,:)=dotInfo.NWxy; %NW
    elseif dotInfo.DirSide(counts,1)==180
        dotInfo.corrResp(counts,:)=dotInfo.Wxy; %West
    elseif dotInfo.DirSide(counts,1)==225
        dotInfo.corrResp(counts,:)=dotInfo.SWxy; %SW
    elseif dotInfo.DirSide(counts,1)==270
        dotInfo.corrResp(counts,:)=dotInfo.Sxy; %South
    elseif dotInfo.DirSide(counts,1)==315
        dotInfo.corrResp(counts,:)=dotInfo.SExy; %SE    
        
    end
    
end

dotInfo.speed = 50; %dots speed (10th deg/sec) for each patch
dotInfo.coh = dotInfo.cohSet(ceil(rand*length(dotInfo.cohSet)))*1000;
dotInfo.dir = dotInfo.dirSet(ceil(rand*length(dotInfo.dirSet)));
dotInfo.maxDotTime = 0.106; % needs to be 0.106 Ghin et al. 
dotInfo.maxRespTime = 36; %to fit everything into 18 minutes

dotInfo.dotColor = [255 255 255]; % white dots default

% dot size in pixels
if screenInfo.Type==1 %laptop
    dotInfo.dotSize = 5; % 5/ppd 
elseif screenInfo.Type==2 %testRoom1
    dotInfo.dotSize = 6; % 6/ppd 
elseif screenInfo.Type==3 %VPixx
    dotInfo.dotSize = 5; % 5/ppd     
end

% fixation x,y coordinates
dotInfo.fixXY = [0 -20];
% fixation diameter
dotInfo.fixDiam = 20;
% fixation color
dotInfo.fixColor = [0 0 0];

dotInfo.maxDotsPerFrame = 150;   % by trial and error.  Depends on graphics card

% possible keys active during trial
KbName('UnifyKeyNames');
dotInfo.keyEscape = KbName('ESCAPE'); %escape
dotInfo.keyReturn = KbName('return');

dotInfo.keyLeft = KbName('leftarrow');
dotInfo.keyRight = KbName('rightarrow');

dotInfo.keyN = KbName('z');
dotInfo.keyNE = KbName('x');
dotInfo.keyE = KbName('c');
dotInfo.keySE = KbName('v');
dotInfo.keyS = KbName('b');
dotInfo.keySW = KbName('n');
dotInfo.keyW = KbName('m');
dotInfo.keyNW = KbName(',<');

mouse_left = 1;
mouse_right = 2;
dotInfo.mouse = [mouse_left, mouse_right];


