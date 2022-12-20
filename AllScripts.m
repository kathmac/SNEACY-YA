%==========Script to run all scripts!============

%% Resting EO 
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EO/'; 

%Run Exercise Pre Resting EEG EO
run('SAya_EO_EEG_Exercise_Pre.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EO/'; 

%Run Exercise Post Resting EEG EO
run('SAya_EO_EEG_Exercise_Post.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EO/'; 

%Run Rest Pre Resting_E EEG EO
run('SAya_EO_EEG_Rest_E_Pre.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EO/'; 

%Run Exercise Post Resting_E EEG EO
run('SAya_EO_EEG_Rest_E_Post.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EO/'; 

%Run Rest Pre Resting_T EEG EO
run('SAya_EO_EEG_Rest_T_Pre.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EO/'; 

%Run Exercise Post Resting_T EEG EO
run('SAya_EO_EEG_Rest_T_Post.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EO/'; 

%Run Trier Pre Resting EEG EO
run('SAya_EO_EEG_Trier_Pre.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EO/'; 

%Run Trier Post Resting EEG EO
run('SAya_EO_EEG_Trier_Post.m');

%Combine Excel outputs 
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EO_EEG/EO_EEG_Rest_E/Pre/'; 
SAya_EO_EEG_Rest_E_Pre = readtable('SAya_EO_EEG_Rest_E_Pre.xlsx');
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EO_EEG/EO_EEG_Rest_E/Post/'; 
SAya_EO_EEG_Rest_E_Post = readtable('SAya_EO_EEG_Rest_E_Post.xlsx');

cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EO_EEG/EO_EEG_Rest_T/Pre/'; 
SAya_EO_EEG_Rest_T_Pre = readtable('SAya_EO_EEG_Rest_T_Pre.xlsx');
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EO_EEG/EO_EEG_Rest_T/Post/'; 
SAya_EO_EEG_Rest_T_Post = readtable('SAya_EO_EEG_Rest_T_Post.xlsx');

cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EO_EEG/EO_EEG_Exercise/Pre/'; 
SAya_EO_EEG_Exercise_Pre = readtable('SAya_EO_EEG_Exercise_Pre.xlsx');
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EO_EEG/EO_EEG_Exercise/Post/'; 
SAya_EO_EEG_Exercise_Post = readtable('SAya_EO_EEG_Exercise_Post.xlsx');

cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EO_EEG/EO_EEG_Trier/Pre/'; 
SAya_EO_EEG_Trier_Pre = readtable('SAya_EO_EEG_Trier_Pre.xlsx');
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EO_EEG/EO_EEG_Trier/Post/'; 
SAya_EO_EEG_Trier_Post = readtable('SAya_EO_EEG_Trier_Post.xlsx');

Merge_Rest_E = join(SAya_EO_EEG_Rest_E_Pre, SAya_EO_EEG_Rest_E_Post, 'keys', 'Subject');
Merge_Rest_T = join(SAya_EO_EEG_Rest_T_Pre, SAya_EO_EEG_Rest_T_Post, 'keys', 'Subject');
Merge_Exercise = join(SAya_EO_EEG_Exercise_Pre, SAya_EO_EEG_Exercise_Post, 'keys', 'Subject');
Merge_Trier = join(SAya_EO_EEG_Trier_Pre, SAya_EO_EEG_Trier_Post, 'keys', 'Subject');

Merge_T_Master_intermediate = outerjoin(Merge_Rest_T, Merge_Trier);
Merge_T_Master_intermediate = movevars(Merge_T_Master_intermediate, 'Subject_Merge_Trier', 'Before', 'FZ_Delta_Rest_T_Pre');
Merge_T_Master_intermediate = removevars(Merge_T_Master_intermediate, 'Subject_Merge_Trier');
Merge_T_Master_intermediate.Properties.VariableNames{1} = 'Subject';

Merge_E_Master_intermediate = outerjoin(Merge_Rest_E, Merge_Exercise);
Merge_E_Master_intermediate = movevars(Merge_E_Master_intermediate, 'Subject_Merge_Exercise', 'Before', 'FZ_Delta_Rest_E_Pre');
Merge_E_Master_intermediate = removevars(Merge_E_Master_intermediate, 'Subject_Merge_Exercise');
Merge_E_Master_intermediate.Properties.VariableNames{1} = 'Subject';

Merge_Master = outerjoin(Merge_E_Master_intermediate, Merge_T_Master_intermediate);
%merge subject list by inserting a new column and copying and pasting the
%two subject columns into one column
Merge_Master.Properties.VariableNames{1} = 'Subject'; %rename the new column Subject for melting in R

%Write table to Lab_Meeting_Data, to be read by R
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/Lab_Meeting_Data';
filename = 'Resting_EO_Master.xlsx'
writetable(Merge_Master, filename);

%% Resting EC
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EC/'; 

%Run Exercise Pre Resting EEG EC
run('SAya_EC_EEG_Exercise_Pre.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EC/';

%Run Exercise Post Resting EEG EC
run('SAya_EC_EEG_Exercise_Post.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EC/';

%Run Rest Pre Resting_E EEG EC
run('SAya_EC_EEG_Rest_E_Pre.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EC/';

%Run Exercise Post Resting_E EEG EC
run('SAya_EC_EEG_Rest_E_Post.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EC/';
 
%Run Rest Pre Resting_T EEG EC
run('SAya_EC_EEG_Rest_T_Pre.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EC/';

%Run Exercise Post Resting_T EEG EC
run('SAya_EC_EEG_Rest_T_Post.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EC/';

%Run Trier Pre Resting EEG EC
run('SAya_EC_EEG_Trier_Pre.m');
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Resting_EEG_EC/';
 
%Run Trier Post Resting EEG EC
run('SAya_EC_EEG_Trier_Post.m');

%Combine Excel outputs 
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EC_EEG/EC_EEG_Rest_E/Pre/'; 
SAya_EC_EEG_Rest_E_Pre = readtable('SAya_EC_EEG_Rest_E_Pre.xlsx');
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EC_EEG/EC_EEG_Rest_E/Post/'; 
SAya_EC_EEG_Rest_E_Post = readtable('SAya_EC_EEG_Rest_E_Post.xlsx');

cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EC_EEG/EC_EEG_Rest_T/Pre/'; 
SAya_EC_EEG_Rest_T_Pre = readtable('SAya_EC_EEG_Rest_T_Pre.xlsx');
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EC_EEG/EC_EEG_Rest_T/Post/'; 
SAya_EC_EEG_Rest_T_Post = readtable('SAya_EC_EEG_Rest_T_Post.xlsx');

cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EC_EEG/EC_EEG_Exercise/Pre/'; 
SAya_EC_EEG_Exercise_Pre = readtable('SAya_EC_EEG_Exercise_Pre.xlsx');
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EC_EEG/EC_EEG_Exercise/Post/'; 
SAya_EC_EEG_Exercise_Post = readtable('SAya_EC_EEG_Exercise_Post.xlsx');

cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EC_EEG/EC_EEG_Trier/Pre/'; 
SAya_EC_EEG_Trier_Pre = readtable('SAya_EC_EEG_Trier_Pre.xlsx');
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/EC_EEG/EC_EEG_Trier/Post/'; 
SAya_EC_EEG_Trier_Post = readtable('SAya_EC_EEG_Trier_Post.xlsx');

Merge_Rest_E = join(SAya_EC_EEG_Rest_E_Pre, SAya_EC_EEG_Rest_E_Post, 'keys', 'Subject');
Merge_Rest_T = join(SAya_EC_EEG_Rest_T_Pre, SAya_EC_EEG_Rest_T_Post, 'keys', 'Subject');
Merge_Exercise = join(SAya_EC_EEG_Exercise_Pre, SAya_EC_EEG_Exercise_Post, 'keys', 'Subject');
Merge_Trier = join(SAya_EC_EEG_Trier_Pre, SAya_EC_EEG_Trier_Post, 'keys', 'Subject');

Merge_T_Master_intermediate = outerjoin(Merge_Rest_T, Merge_Trier);
Merge_T_Master_intermediate = movevars(Merge_T_Master_intermediate, 'Subject_Merge_Trier', 'Before', 'FZ_Delta_Rest_T_Pre');
Merge_T_Master_intermediate = removevars(Merge_T_Master_intermediate, 'Subject_Merge_Trier');
Merge_T_Master_intermediate.Properties.VariableNames{1} = 'Subject';

Merge_E_Master_intermediate = outerjoin(Merge_Rest_E, Merge_Exercise);
Merge_E_Master_intermediate = movevars(Merge_E_Master_intermediate, 'Subject_Merge_Exercise', 'Before', 'FZ_Delta_Rest_E_Pre');
Merge_E_Master_intermediate = removevars(Merge_E_Master_intermediate, 'Subject_Merge_Exercise');
Merge_E_Master_intermediate.Properties.VariableNames{1} = 'Subject';

Merge_Master = outerjoin(Merge_E_Master_intermediate, Merge_T_Master_intermediate);
%merge subject list by inserting a new column and copying and pasting the
%two subject columns into one column
Merge_Master.Properties.VariableNames{1} = 'Subject'; %rename the new column Subject for melting in R

%Write table to Lab_Meeting_Data, to be read by R
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/Lab_Meeting_Data';
filename = 'Resting_EC_Master.xlsx'
writetable(Merge_Master, filename);



%% Flanker EEG
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'

%Run Exercise Pre Flanker
run('SAya_Flanker_EEG_E_Pre.m');

cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'

%Run Exercise Post Flanker
run('SAya_Flanker_EEG_E_Post.m');
 
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'

%Run Rest_E Pre Flanker
run('SAya_Flanker_EEG_Rest_E_Pre.m');

cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'
 
%Run Rest_E Post Flanker
run('SAya_Flanker_EEG_Rest_E_Post.m');

cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'

%Run Rest_T Pre Flanker
run('SAya_Flanker_EEG_Rest_T_Pre.m');

cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'
 
%Run Rest_T Post Flanker
run('SAya_Flanker_EEG_Rest_T_Post.m');

cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'
 
%Run Trier Pre Flanker
run('SAya_Flanker_EEG_T_Pre.m');

cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'
 
%Run Trier Post Flanker
run('SAya_Flanker_EEG_T_Post.m');

%Create excel outputs to be read by R
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'

run('GrandAverage_PrepareforR.m');

%% Flanker EEG Peak Amplitude and Latency
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/EEG/Flanker_EEG/'

%Run Peak Detection 
run('SAya_PeakDetection_P3.m');

%% Flanker Behavior 
cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/Behavior/'

% Need to create merged E-Prime file before running
% Run Behavior Analysis 
run('SAya_Flanker_Behavior.m')
