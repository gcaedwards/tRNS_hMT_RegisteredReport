% Overlap analysis - using mutual information analysis and correlations

% Grace Edwards August 2023; updated December 2024

%Input:
%   EMAG_hMT=importdata('*_EMAG_mask.txt');
%   FMRI_Rmot=importdata('*_RmotVstat.txt');

%Output;
% Overlap_allSubs.m

%% File structure

% In main folder save OverlapAnalysis.m (this is the master script)
% Create functions folder and save:
% 1. MI_GG.m written by Giangregorio, 2022
% Download data into a data folder

%% Lines to edit:

% 29:31 - put your paths here 

%% Script Start

clear

clc

cd ('INSERT PATH WHERE SCRIPT SAVED'); 
addpath(genpath('INSERT PATH WHERE SCRIPT SAVED/data')); %path to data folder
addpath(genpath('INSERT PATH WHERE SCRIPT SAVED/Functions')); %path to Function folder

%sub variables
name=[1:40 42]; % corrupt files: sub 41
nSubs=length(name);

for s = 1:nSubs

     %read in the data

     %electric field magnitude for stimulated hMT simulation within cortex mask only
     EMAG_hMTstim_file=['S',int2str(name(s)),'_EMAG_hMTstim_MASK.txt'];
     EMAG_hMTstim=importdata(EMAG_hMTstim_file);

     %tvals for right visual field motion perception within cortex mask only
     FMRI_Rmot_file=['S',int2str(name(s)),'_RmotVstat_mask.txt'];
     FMRI_Rmot=importdata(FMRI_Rmot_file);

    %Take the emag and tvals from each of the file types, respectively and
    %rank the voxels according to magnitude of response (lowest to highest)

    %check for below zero in EMAGs
    count_hMTstim=1;
 
    for check=1:length(EMAG_hMTstim)

        if EMAG_hMTstim(check,7)<0
            EMAG_hMTstim_incorrect(s)=count_hMTstim;
            count_hMTstim=count_hMTstim+1;
            EMAG_hMTstim(check,7)=0.0001; %replace with lowest emag 
        end

    end

    rankEMAG_hMTstim=EMAG_hMTstim(:,7);
    rankEMAG_hMTstim(:,2)=1:length(EMAG_hMTstim);
    sortEMAG_hMTstim=sortrows(rankEMAG_hMTstim);

    rankFMRI_Rmot=FMRI_Rmot(:,7);
    rankFMRI_Rmot(:,2)=1:length(FMRI_Rmot);
    sortFMRI_Rmot=sortrows(rankFMRI_Rmot);

    %rescale the voxels between 0-1 and make the vectors into 2D then plot
    reEMAG_hMTs=rescale(sortEMAG_hMTstim(:,2));
    reFMRI_Rmot=rescale(sortFMRI_Rmot(:,2));

    %make non-reshaped into integers
    reEMAG_hMTs_int=fix(reEMAG_hMTs*100);
    reFMRI_Rmot_int=fix(reFMRI_Rmot*100);

    %% masked overlap analysis
    %calculate the MI between the voxel ranking with masked data
    MI(s,1) = name(s);
    MI(s,2) = MI_GG(reFMRI_Rmot_int,reEMAG_hMTs_int); %overlap of interest: right hemifield (left hemisphere) motion selective vs left hMT stimulation
    MI(s,3) = MI_GG(reEMAG_hMTs_int,reEMAG_hMTs_int); %highest possible overlap using masked data

    corrs(s,1) = name(s);
    corrs_mask_act=corrcoef(reFMRI_Rmot_int,reEMAG_hMTs_int);
    corrs(s,2)=corrs_mask_act(1,2);

end

%baseline the overlap to the max overlap

MI_baselined(:,1)=MI(:,1);

for a=1:length(MI)

    MI_baselined(a,2)=MI(a,2)/MI(a,3); %gives percentage of possible MI: voxel rank

end

save('Overlap_allSubs','MI','MI_baselined','corrs');
