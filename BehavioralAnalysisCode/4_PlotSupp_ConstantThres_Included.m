% Constant thresholding - Supplemental Figure for Included participants Stage 2

% Grace Edwards August 2023; updated December 2024

%Input:
%   Constant Thresholding Behavior data x 8 runs e.g. S1_1.mat ... S1_8.mat

%Output:
% Figures

%% File structure

% In main folder save PlotSupp_ConstantThres_Included.m (this is the master script)
% Create functions folder and save:
% 1. fitPsycheCurveLogit.m
% Download data into a data folder "Included_ConstThres" from OSF

%% Lines to edit:

% 28:30 - put your paths here 

%% Script Start

clear

clc

cd ('INSERT PATH WHERE SCRIPT SAVED'); 
addpath(genpath('INSERT PATH WHERE SCRIPT SAVED/Included_ConstThres')); %path to data folder
addpath(genpath('INSERT PATH WHERE SCRIPT SAVED/Functions')); %path to Function folder

nSubs=42;

Cruns=8;

%% Constant

for s=1:nSubs
    cl25=0; cr25=0;
    cl30=0; cr30=0;
    cl35=0; cr35=0;
    cl40=0; cr40=0;
    cl45=0; cr45=0;
    cl50=0; cr50=0;
    cl55=0; cr55=0;
    cl60=0; cr60=0;
    cl65=0; cr65=0;
    cl70=0; cr70=0;
    cl75=0; cr75=0;
    cl80=0; cr80=0;
    cl85=0; cr85=0;
    cl90=0; cr90=0;
    cl95=0; cr95=0;
    cl100=0; cr100=0;    

    for r=1:Cruns
        filename=['S',int2str(s), '_', int2str(r), '.mat']; %
        load(filename);

            for t=1:size(resultMat,2)
                if resultMat(t).Side==1 && resultMat(t).cohSet==0.25 %left VF; coh 24
                    cl25=cl25+1;
                    LeftData(s).sub25(cl25,1)=resultMat(t).Side;
                    LeftData(s).sub25(cl25,2)=resultMat(t).cohSet;
                    LeftData(s).sub25(cl25,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.30
                    cl30=cl30+1;
                    LeftData(s).sub30(cl30,1)=resultMat(t).Side;
                    LeftData(s).sub30(cl30,2)=resultMat(t).cohSet;
                    LeftData(s).sub30(cl30,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.35
                    cl35=cl35+1;
                    LeftData(s).sub35(cl35,1)=resultMat(t).Side;
                    LeftData(s).sub35(cl35,2)=resultMat(t).cohSet;
                    LeftData(s).sub35(cl35,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.40
                    cl40=cl40+1;
                    LeftData(s).sub40(cl40,1)=resultMat(t).Side;
                    LeftData(s).sub40(cl40,2)=resultMat(t).cohSet;
                    LeftData(s).sub40(cl40,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.45
                    cl45=cl45+1;
                    LeftData(s).sub45(cl45,1)=resultMat(t).Side;
                    LeftData(s).sub45(cl45,2)=resultMat(t).cohSet;
                    LeftData(s).sub45(cl45,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.50
                    cl50=cl50+1;
                    LeftData(s).sub50(cl50,1)=resultMat(t).Side;
                    LeftData(s).sub50(cl50,2)=resultMat(t).cohSet;
                    LeftData(s).sub50(cl50,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.55
                    cl55=cl55+1;
                    LeftData(s).sub55(cl55,1)=resultMat(t).Side;
                    LeftData(s).sub55(cl55,2)=resultMat(t).cohSet;
                    LeftData(s).sub55(cl55,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.60
                    cl60=cl60+1;
                    LeftData(s).sub60(cl60,1)=resultMat(t).Side;
                    LeftData(s).sub60(cl60,2)=resultMat(t).cohSet;
                    LeftData(s).sub60(cl60,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.65
                    cl65=cl65+1;
                    LeftData(s).sub65(cl65,1)=resultMat(t).Side;
                    LeftData(s).sub65(cl65,2)=resultMat(t).cohSet;
                    LeftData(s).sub65(cl65,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.70
                    cl70=cl70+1;
                    LeftData(s).sub70(cl70,1)=resultMat(t).Side;
                    LeftData(s).sub70(cl70,2)=resultMat(t).cohSet;
                    LeftData(s).sub70(cl70,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.75
                    cl75=cl75+1;
                    LeftData(s).sub75(cl75,1)=resultMat(t).Side;
                    LeftData(s).sub75(cl75,2)=resultMat(t).cohSet;
                    LeftData(s).sub75(cl75,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.80
                    cl80=cl80+1;
                    LeftData(s).sub80(cl80,1)=resultMat(t).Side;
                    LeftData(s).sub80(cl80,2)=resultMat(t).cohSet;
                    LeftData(s).sub80(cl80,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.85
                    cl85=cl85+1;
                    LeftData(s).sub85(cl85,1)=resultMat(t).Side;
                    LeftData(s).sub85(cl85,2)=resultMat(t).cohSet;
                    LeftData(s).sub85(cl85,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.90
                    cl90=cl90+1;
                    LeftData(s).sub90(cl90,1)=resultMat(t).Side;
                    LeftData(s).sub90(cl90,2)=resultMat(t).cohSet;
                    LeftData(s).sub90(cl90,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==0.95
                    cl95=cl95+1;
                    LeftData(s).sub95(cl95,1)=resultMat(t).Side;
                    LeftData(s).sub95(cl95,2)=resultMat(t).cohSet;
                    LeftData(s).sub95(cl95,3)=resultMat(t).resp;

                elseif resultMat(t).Side==1 && resultMat(t).cohSet==1
                    cl100=cl100+1;
                    LeftData(s).sub100(cl100,1)=resultMat(t).Side;
                    LeftData(s).sub100(cl100,2)=resultMat(t).cohSet;
                    LeftData(s).sub100(cl100,3)=resultMat(t).resp;    

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.25 
                    cr25=cr25+1;
                    RightData(s).sub25(cr25,1)=resultMat(t).Side;
                    RightData(s).sub25(cr25,2)=resultMat(t).cohSet;
                    RightData(s).sub25(cr25,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.30
                    cr30=cr30+1;
                    RightData(s).sub30(cr30,1)=resultMat(t).Side;
                    RightData(s).sub30(cr30,2)=resultMat(t).cohSet;
                    RightData(s).sub30(cr30,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.35
                    cr35=cr35+1;
                    RightData(s).sub35(cr35,1)=resultMat(t).Side;
                    RightData(s).sub35(cr35,2)=resultMat(t).cohSet;
                    RightData(s).sub35(cr35,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.40
                    cr40=cr40+1;
                    RightData(s).sub40(cr40,1)=resultMat(t).Side;
                    RightData(s).sub40(cr40,2)=resultMat(t).cohSet;
                    RightData(s).sub40(cr40,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.45
                    cr45=cr45+1;
                    RightData(s).sub45(cr45,1)=resultMat(t).Side;
                    RightData(s).sub45(cr45,2)=resultMat(t).cohSet;
                    RightData(s).sub45(cr45,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.50
                    cr50=cr50+1;
                    RightData(s).sub50(cr50,1)=resultMat(t).Side;
                    RightData(s).sub50(cr50,2)=resultMat(t).cohSet;
                    RightData(s).sub50(cr50,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.55
                    cr55=cr55+1;
                    RightData(s).sub55(cr55,1)=resultMat(t).Side;
                    RightData(s).sub55(cr55,2)=resultMat(t).cohSet;
                    RightData(s).sub55(cr55,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.60
                    cr60=cr60+1;
                    RightData(s).sub60(cr60,1)=resultMat(t).Side;
                    RightData(s).sub60(cr60,2)=resultMat(t).cohSet;
                    RightData(s).sub60(cr60,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.65
                    cr65=cr65+1;
                    RightData(s).sub65(cr65,1)=resultMat(t).Side;
                    RightData(s).sub65(cr65,2)=resultMat(t).cohSet;
                    RightData(s).sub65(cr65,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.70
                    cr70=cr70+1;
                    RightData(s).sub70(cr70,1)=resultMat(t).Side;
                    RightData(s).sub70(cr70,2)=resultMat(t).cohSet;
                    RightData(s).sub70(cr70,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.75
                    cr75=cr75+1;
                    RightData(s).sub75(cr75,1)=resultMat(t).Side;
                    RightData(s).sub75(cr75,2)=resultMat(t).cohSet;
                    RightData(s).sub75(cr75,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.80
                    cr80=cr80+1;
                    RightData(s).sub80(cr80,1)=resultMat(t).Side;
                    RightData(s).sub80(cr80,2)=resultMat(t).cohSet;
                    RightData(s).sub80(cr80,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.85
                    cr85=cr85+1;
                    RightData(s).sub85(cr85,1)=resultMat(t).Side;
                    RightData(s).sub85(cr85,2)=resultMat(t).cohSet;
                    RightData(s).sub85(cr85,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.90
                    cr90=cr90+1;
                    RightData(s).sub90(cr90,1)=resultMat(t).Side;
                    RightData(s).sub90(cr90,2)=resultMat(t).cohSet;
                    RightData(s).sub90(cr90,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==0.95
                    cr95=cr95+1;
                    RightData(s).sub95(cr95,1)=resultMat(t).Side;
                    RightData(s).sub95(cr95,2)=resultMat(t).cohSet;
                    RightData(s).sub95(cr95,3)=resultMat(t).resp;

                elseif resultMat(t).Side==2 && resultMat(t).cohSet==1
                    cr100=cr100+1;
                    RightData(s).sub100(cr100,1)=resultMat(t).Side;
                    RightData(s).sub100(cr100,2)=resultMat(t).cohSet;
                    RightData(s).sub100(cr100,3)=resultMat(t).resp; 

                end
            end

    end

end

%average score for each step for each subject

for count=1:nSubs
    Left(count,1)=(nanmean(LeftData(count).sub25(:,3))*100);
    Left(count,2)=(nanmean(LeftData(count).sub30(:,3))*100);
    Left(count,3)=(nanmean(LeftData(count).sub35(:,3))*100);
    Left(count,4)=(nanmean(LeftData(count).sub40(:,3))*100);
    Left(count,5)=(nanmean(LeftData(count).sub45(:,3))*100);
    Left(count,6)=(nanmean(LeftData(count).sub50(:,3))*100);
    Left(count,7)=(nanmean(LeftData(count).sub55(:,3))*100);
    Left(count,8)=(nanmean(LeftData(count).sub60(:,3))*100);
    Left(count,9)=(nanmean(LeftData(count).sub65(:,3))*100);
    Left(count,10)=(nanmean(LeftData(count).sub70(:,3))*100);
    Left(count,11)=(nanmean(LeftData(count).sub75(:,3))*100);
    Left(count,12)=(nanmean(LeftData(count).sub80(:,3))*100);
    Left(count,13)=(nanmean(LeftData(count).sub85(:,3))*100);
    Left(count,14)=(nanmean(LeftData(count).sub90(:,3))*100);
    Left(count,15)=(nanmean(LeftData(count).sub95(:,3))*100);
    Left(count,16)=(nanmean(LeftData(count).sub100(:,3))*100);

    Right(count,1)=(nanmean(RightData(count).sub25(:,3))*100);
    Right(count,2)=(nanmean(RightData(count).sub30(:,3))*100);
    Right(count,3)=(nanmean(RightData(count).sub35(:,3))*100);
    Right(count,4)=(nanmean(RightData(count).sub40(:,3))*100);
    Right(count,5)=(nanmean(RightData(count).sub45(:,3))*100);
    Right(count,6)=(nanmean(RightData(count).sub50(:,3))*100);
    Right(count,7)=(nanmean(RightData(count).sub55(:,3))*100);
    Right(count,8)=(nanmean(RightData(count).sub60(:,3))*100);
    Right(count,9)=(nanmean(RightData(count).sub65(:,3))*100);
    Right(count,10)=(nanmean(RightData(count).sub70(:,3))*100);
    Right(count,11)=(nanmean(RightData(count).sub75(:,3))*100);
    Right(count,12)=(nanmean(RightData(count).sub80(:,3))*100);
    Right(count,13)=(nanmean(RightData(count).sub85(:,3))*100);
    Right(count,14)=(nanmean(RightData(count).sub90(:,3))*100);
    Right(count,15)=(nanmean(RightData(count).sub95(:,3))*100);
    Right(count,16)=(nanmean(RightData(count).sub100(:,3))*100);

end

%% Plot data and psychometric function - if able

steps=[25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100];
targets = [0.25, 0.54, 0.70]; % 25%, 54% and 70% performance

Left=Left/100;
Right=Right/100;

sz=100;

%% All in two figures

x_label_names = {'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','Motion Coherence(%)','Motion Coherence(%)','Motion Coherence(%)','Motion Coherence(%)','Motion Coherence(%)','Motion Coherence(%)'};
y_label_names = {'Accuracy','','','','','','Accuracy','','','','','','Accuracy','','','','','','Accuracy','','','','','','Accuracy','','','','','','Accuracy','','','','','','Accuracy','','','','',''};

    AppC2Left_inc=figure;


for f=1:nSubs

    subplot(7,6,f)
    scatter(steps, Left(f,:),sz, 'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    axis([20 100 0 1]);
    
    hold on
    
    ax = gca;
    ax.LineWidth = 3; %change to the desired value
    ax.FontSize = 15;  % Font Size of 15

    weights = ones(1,length(steps)); % No weighting
    % Fit for psychometric function
    [coeffsLeft, curveLeft, thresholdLeft] = ...
        fitPsycheCurveLogit(steps, Left(f,:), weights, targets);
    
    p = plot(curveLeft(:,1), curveLeft(:,2), 'LineStyle', '--');
    p.LineWidth = 3;
    p.Color = [0 .7 .7];


    roundthresh = round(thresholdLeft(3), 1);
    thresh = num2str(roundthresh);
    txt = [thresh];
    text(25, 0.9, txt);

    title(['Left S', int2str(f)])


    xlabel(x_label_names{f}, 'FontSize', 13);
    ylabel(y_label_names{f}, 'FontSize', 13);

end

    AppC2Right_inc=figure;


for f=1:nSubs
    subplot(7,6,f)
    scatter(steps, Right(f,:),sz,  'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    axis([20 100 0 1]);
    
    hold on
    
    ax = gca;
    ax.LineWidth = 3; %change to the desired value
    ax.FontSize = 15;  % Font Size of 15

    weights = ones(1,length(steps)); % No weighting
    % Fit for psychometric function
    [coeffsRight, curveRight, thresholdRight] = ...
        fitPsycheCurveLogit(steps, Right(f,:), weights, targets);
    
    p2 = plot(curveRight(:,1), curveRight(:,2), 'LineStyle', '--');
    p2.LineWidth = 3;
    p2.Color = [0 .7 .7];
    
    roundthresh = round(thresholdRight(3), 1);
    thresh = num2str(roundthresh);
    txt = [thresh];
    text(25, 0.9, txt);

    title(['Right S', int2str(f)])

    xlabel(x_label_names{f}, 'FontSize', 13);
    ylabel(y_label_names{f}, 'FontSize', 13);

end

%% Run after resizing images

% f_name=AppC2Right_inc;
% 
% set(f_name,'Units','Inches');
% pos = round(get(f_name,'Position'));
% set(f_name,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(f_name,'AppC2Right_inc','-dpdf','-r0')
% print(f_name,'AppC2Right_inc','-dsvg','-r0')
