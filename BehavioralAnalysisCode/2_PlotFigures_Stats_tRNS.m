%% Plot and prepare data for analysis - tRNS prereg

% Grace Edwards August 2023; updated December 2024

%Input:
%   Behavior data e.g. S1_1 for hMT+, S1_2 for sham, S1_3 for forehead 
%   "Overlap_allSubs.mat" - overlap data, created in OverlapAnalysis.m
%   "Distance_mm.xlsx" - mm Distance between anatomically localized hMT+ and functionally localized hMT+

%Output;
% Figures and statistics

%% File structure

% In main folder save PlotFigures_Stats_tRNS.m (this is the master script)
% Create functions folder and save:
% 1. extractRows.m
% 2. hatchfill2.m
% 3. nansem.m
% Download data into a data folder

%% Lines to edit:

% 31:33 - put your paths here 

clear

clc

%go to working directory
%cd ('INSERT PATH WHERE SCRIPT SAVED');
%BehDir = 'INSERT PATH WHERE SCRIPT SAVED/BehData';
%addpath(genpath('INSERT PATH WHERE SCRIPT SAVED/Functions')); %path to Function folder

subs=1:42;  

nSubs=length(subs);

sessions=3; %3 sessions: 1 = hMT+ active, 2 = hMT+ sham, 3 = forehead active

%% Data used in overlap analysis:

%Load overlap data

load('Overlap_allSubs.mat');

%Read in stimulation distance metric and remove poor localizer participants

Distance_mm = readtable('Distance_mm.xlsx');

%% Plotting variables

SubsBadLoc=[10,32]; %participants with poor localizers
badLoc=zeros(1,42);
badLoc(1,SubsBadLoc)=1;

sz=60;

%% Load 

for s=1:nSubs

    for sess=1:sessions

        load([BehDir 'S' int2str(subs(s)) '_' int2str(sess)]); %load data

        %grab the motion coherence level at 70% correct at end of session
        Contralateral(s,sess)=resultMatRight(length(resultMatRight)).cohSet;
        Ipsilateral(s,sess)=resultMatLeft(length(resultMatLeft)).cohSet;

    end

end

%organize the data for plotting
data(:,1)=Ipsilateral(:,1)*100;
data(:,2)=Contralateral(:,1)*100;
data(:,3)=Ipsilateral(:,2)*100;
data(:,4)=Contralateral(:,2)*100;
data(:,5)=Ipsilateral(:,3)*100;
data(:,6)=Contralateral(:,3)*100;

ave_data=nanmean(data,1);
sem_data=nansem(data,1);

% difference between ipsi and contra
diff(:,1)=data(:,1)-data(:,2);
diff(:,2)=data(:,3)-data(:,4);
diff(:,3)=data(:,5)-data(:,6);

ave_diff=nanmean(diff);
sem_diff=nansem(diff);

%% Plot hypothetical and observed data

%hypothetical data for plotting
hypo_data=[70, 63, 70.2, 69.6, 69.7, 70.4];
hypo_diff=[(hypo_data(1)-hypo_data(2)), (hypo_data(3)-hypo_data(4)), (hypo_data(5)-hypo_data(6))];

barDist=[1 2 4 5 7 8];

%colors
hmt_ipsi=[0.5, 0.1, 0.8];
hmt_cont=[0.7, 0.5, 1];
sham_ipsi=[0.9290 0.5 0];
sham_cont=[1 0.8 0.4];
fore_ipsi=[0 0.4470 0.7410];
fore_cont=[0.7 0.9 1];

hmt_diff=[0.5 0.5 0.5];
sham_diff=[0.7 0.7 0.7];
fore_diff=[0.9 0.9 0.9];

hmt_cdiff=(hmt_ipsi+hmt_cont)/2;
sham_cdiff=(sham_ipsi+sham_cont)/2;
fore_cdiff=(fore_ipsi+fore_cont)/2;

%define the parameters of the hatch pattern
HatchColor		= [0.2,0.2,0.2];
HatchAngle		= 30;
HatchType		= 'single'; 
HatchDensity	= 50;
HatchLineWidth  = 2;

%% Main Results Figure

F4=figure;
subplot(2,2,1)
a=bar(barDist,hypo_data);
hold on
a.FaceColor = 'flat';
a.CData(1,:) = hmt_ipsi;
a.CData(2,:) = hmt_cont;
a.CData(3,:) = sham_ipsi;
a.CData(4,:) = sham_cont;
a.CData(5,:) = fore_ipsi;
a.CData(6,:) = fore_cont;
set(a, 'LineWidth', 3)

title({'A)';'               Hypothetical Data'});
ax1 = gca;
ax1.LineWidth = 3;
ax1.FontSize = 20;
ylabel('Motion Coherence %');
set(ax1,'XTickLabel',{'L', 'R', 'L', 'R', 'L', 'R'});
xlabel('    hMT+            Sham         Forehead');
ylim([60, 80]);
ax1.TitleHorizontalAlignment = 'left';
box off;

subplot(2,2,2)
b=bar(barDist,ave_data);
hold on
b.FaceColor = 'flat';
b.CData(1,:) = hmt_ipsi;
b.CData(2,:) = hmt_cont;
b.CData(3,:) = sham_ipsi;
b.CData(4,:) = sham_cont;
b.CData(5,:) = fore_ipsi;
b.CData(6,:) = fore_cont;
errorbar(barDist,ave_data,sem_data,'.k', 'LineWidth', 3);
set(b, 'LineWidth', 3)

title({'  ';'                   Actual Data'});
ax2 = gca;
ax2.LineWidth = 3;
ax2.FontSize = 20;
ax2.TitleHorizontalAlignment = 'left';
ylabel('Motion Coherence %');
set(ax2,'XTickLabel',{'L', 'R', 'L', 'R', 'L', 'R'});
xlabel('    hMT+            Sham         Forehead');
ylim([60, 80]);
box off;

subplot(2,2,3)
c=bar(hypo_diff);
hold on
c.FaceColor = 'flat';
c.CData(1,:) = hmt_diff; 
c.CData(2,:) = sham_diff; 
c.CData(3,:) = fore_diff; 
set(c, 'LineWidth', 3)

title({'B)';'                   '});
ax3 = gca;
ax3.LineWidth = 3;
ax3.FontSize = 20;
ylabel('Difference in Motion Coherence %');
set(ax3,'XTick',[]);
xlabel('     hMT+    Sham   Forehead');
ylim([-4, 8]);
ax3.TitleHorizontalAlignment = 'left';
box off;
hatchfill2(c(1),'single','HatchAngle',HatchAngle,'HatchColor',HatchColor, 'HatchDensity',HatchDensity, 'HatchLineWidth', HatchLineWidth);

subplot(2,2,4)
disdiffer=bar(ave_diff);
hold on
disdiffer.FaceColor = 'flat';
disdiffer.CData(1,:) = hmt_diff; 
disdiffer.CData(2,:) = sham_diff; 
disdiffer.CData(3,:) = fore_diff; 
errorbar(ave_diff,sem_diff,'.k', 'LineWidth', 3);
set(disdiffer, 'LineWidth', 3)

ax4 = gca;
ax4.LineWidth = 3;
ax4.FontSize = 20;  
ylabel('Difference in Motion Coherence %');
set(ax4,'XTick',[]);
xlabel('     hMT+    Sham   Forehead');
ylim([-4, 8]);
box off;
hatchfill2(disdiffer(1),'single','HatchAngle',HatchAngle,'HatchColor',HatchColor, 'HatchDensity',HatchDensity, 'HatchLineWidth', HatchLineWidth);

%% Run after resizing images:

% set(F4,'Units','Inches');
% pos = round(get(F4,'Position'));
% set(F4,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(F4,'Figure4','-dpdf','-r0')
% print(F4,'F4','-dsvg','-r0')


%% Stats

[h_hMT_ic,p_hMT_ic,ci_hMT_ic,stats_hMT_ic]=ttest(data(:,1),data(:,2),"Tail","right","Alpha",0.02)
[h_hMT_sham,p_hMT_sham,ci_hMT_sham,stats_hMT_sham]=ttest(diff(:,1),diff(:,2),"Tail","right","Alpha",0.02)
[h_hMT_fore,p_hMT_fore,ci_hMT_fore,stats_hMT_fore]=ttest(diff(:,1),diff(:,3),"Tail","right","Alpha",0.02)

%% Exploratory

%% Exploratory hf-tRNS versus sham - whole visual field

hmt_whole=(data(:,1)+data(:,2))/2;
sham_whole=(data(:,3)+data(:,4))/2;
fore_whole=(data(:,5)+data(:,6))/2;

[h_whole_ic,p_whole_ic,ci_whole_ic,stats_whole_ic]=ttest(hmt_whole,sham_whole,"Alpha",0.02)

all=cat(2,hmt_whole,sham_whole,fore_whole);

t = table(hmt_whole,sham_whole,fore_whole,'VariableNames',{'Stim1','Stim2','Stim3'});
withinDesign = table([1 2 3]', 'VariableNames', {'Stimulation'});
rmModel = fitrm(t, 'Stim1-Stim3~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);


%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%               Overlap Analysis              %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disdif=diff(:,1);
disdif(:,2)=Distance_mm.Var2;

%just take subjects with strong localizers
disdif(:,3)=badLoc;
dd_good=extractRows(disdif,3,0);
disdif_goodloc=dd_good(:,[1:2]);

%% Only use behavioral data for participants with simulations (all except S41)

%remove S41 behavior for plotting with simulation - S41 corrupted
%simulation
no41=diff([1:40 42],1);

%% Graph masked MI efield and behavior

F5=figure;
scatter(MI_baselined(:,2),no41,1000,".","k")

ax1 = gca;
ax1.LineWidth = 3;
ax1.FontSize = 20;  
ylabel('Ipsi>Contra MC (%)');
xlabel('MI between hMT+ activity and anat hMT+ efield sim');
box off;
h1=lsline(ax1);
h1.Color='k';
h1.LineWidth = 2;
h1.LineStyle = ":";
title('MI vox activity vs vox efield')

%% Run after resizing images:

% set(F5,'Units','Inches');
% pos = round(get(F5,'Position'));
% set(F5,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(F5,'Figure5','-dpdf','-r0')
% print(F5,'F5','-dsvg','-r0')

%% Correlation between MI of localizer and simulation and behavior

[r_MI,p_MI]=corrcoef(MI_baselined(:,2),no41);

%% Graph masked MI efield and behavior
%Supplemental Figure
F_Supp=figure;

subplot(1,2,1)
scatter(corrs(:,2),no41,1000,".","k")

ax1 = gca;
ax1.LineWidth = 3;
ax1.FontSize = 20;  
ylabel('Ipsi>Contra MC (%)');
xlabel('Corr between hMT+ activity and anat hMT+ efield sim');
box off;
h1=lsline(ax1);
h1.Color='k';
h1.LineWidth = 2;
h1.LineStyle = ":";

subplot(1,2,2)
scatter(disdif_goodloc(:,2),disdif_goodloc(:,1),1000,".","k")

hold on
ax1 = gca;
ax1.LineWidth = 3;
ax1.FontSize = 20;  
ylabel('Ipsi>Contra MC (%)');
xlabel('Dist between anat and loc hMT+ (mm)');
box off;
set ( gca, 'xdir', 'reverse' )
h1=lsline(ax1);
h1.Color='k';
h1.LineWidth = 2;
h1.LineStyle = ":";

%% Run after resizing images:

% set(F_Supp,'Units','Inches');
% pos = round(get(F_Supp,'Position'));
% set(F_Supp,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(F_Supp,'Figure_Supp','-dpdf','-r0')
% print(F_Supp,'F_Supp','-dsvg','-r0')

%% Correlation between MI of localizer and simulation and behavior

[r_mm,p_mm]=corrcoef(disdif_goodloc(:,2),disdif_goodloc(:,1))
[r_c,p_c]=corrcoef(corrs(:,2),no41)

