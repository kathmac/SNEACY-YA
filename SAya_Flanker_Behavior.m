%Created by Katherine McDonald
%If you use my script, I kindly ask for co-authorship on your work as a
%significant contributor to your data processing pipeline
% 
% function Flanker_Processing
%% Naming structure
MergedFile = 'SAya_behavior_final_merged.txt';%Merge file on remote windows computer in Donovan's office (merge the sessions into target file). Export as text file as "other", unclick the unicode box. 
MergedPath = '/Volumes/SAya_USB/Data Entry'; %Move file to this folder for analysis
SaveNameMLM = 'SAya_FL_Behavior_MLM.xlsx'; %output excel file for multi-level modeling (each condition is separate line, multiple subject lines)
SaveNameRM = 'SAya_FL_Behavior_RM.xlsx'; %output excel file for repeated measures (each subject has own line, conditions are separate variables...can mixed RM model work for ANTICIPATED missing data...AKA randomizations?)
         
%% Data Organization 
% Read in table and pull out important columns
cd(MergedPath);
merged = readtable(MergedFile); % read in the original merged file 
tab = merged(:,[3 5 6 10 20 27:end]); %grab variables we want
tab.Properties.VariableNames{4} = 'Subject'; %rename Subject column from ID
tab = movevars(tab, 'Subject', 'Before', 'Session'); %move subject column to beg

% Find and replace letter variables with numerical coding (B=66=baseline, R=77=rest, E=88=exercise, T=99=trier)
 tab.Day(strcmpi(tab.Day,'B')) = {'66'}; 
 tab.Day(strcmpi(tab.Day,'R')) = {'77'}; 
 tab.Day(strcmpi(tab.Day,'E')) = {'88'}; 
 tab.Day(strcmpi(tab.Day,'T')) = {'99'};
 tab.Day=string(tab.Day); %convert to string, so it will be recognized by "unique" function line 53

%Combine RTs into one column 
tab.CongRTInconRT = sum([tab.CongRT,tab.InconRT], 2, 'omitnan');

%Remove variable "OverallRT" from active analysis because we don't know why it's funky. Use "CongRTInconRT" for overall RT
tab = removevars(tab, 'OverallRT');

%% Remove fast responses at less than 200ms from analysis
OverallFastRep = sum(tab.CongRT < 200 | tab.InconRT <200); % number of trials that are faster than 200 ms
toDelete = (tab.CongRT(:,1) < 200 & tab.InconRT(:,1) <200); % index of trials that are faster than 200 ms
tab(toDelete,:) = []; %delete the fast trials
size(tab);

%% Organizing Error Types
for d = 1:length(tab.Subject)
    if tab.Stimulus_ACC(d) == 1
        tab.ErrorType(d) = {''};  %Not an error = participant made an answer, and it was right 
        tab.ErrorNum(d) = 0;
        tab.ErrorRT(d) = NaN;
    elseif tab.Stimulus_ACC(d) == 0 && tab.Stimulus_RT(d) == 0  %Omission = participant did not make an answer fast enough
        tab.ErrorType(d) = {'O'};
        tab.ErrorNum(d) = -1;
        tab.ErrorRT(d) = NaN;
    elseif tab.Stimulus_ACC(d) == 0 && tab.Stimulus_RT(d) ~= 0  %Commission = participant made an answer, and it was wrong 
        tab.ErrorType(d) = {'C'};
        tab.ErrorNum(d) = 1;
        tab.ErrorRT(d) = tab.Stimulus_RT(d);
    end
end

%% Split by congruency
%we need to split by congruency because the InCon and Cong ACC are real time feeds 
tab_Cong = tab(tab.TrialType==string('Cong'),:); % table with data from only congruent trial types 
tab_Incon = tab(tab.TrialType==string('Incon'),:); % table with data from only incongruent trial types

%% Create summary file divided by Subject & Session
% Create structure for output variables
PID = table; PID.Subject = tab.Subject; PID.Session = tab.Session; PID.Timing = tab.Timing; PID.Day = tab.Day; %determine # sessions/subject in table PID %if errors, day is marked wrong - fix in script and file
Flanker = unique(PID, 'rows');   %create table FL with 1 row per session/subject
tab.D = findgroups(tab.Subject, tab.Session, tab.Timing); %use subject/session/timing to determine groups to calculate variables; number of unique identifying info

% Variables: Congruent Trials
tab_Cong.C = findgroups(tab_Cong.Subject,tab_Cong.Session, tab_Cong.Timing); %use subject/session to determine groups to calculate variables

Flanker.SAya_FL_Congruent_TotalTrials = splitapply(@nansum,tab_Cong.TrialList_Cycle,tab_Cong.C);  %Congruent Number of total trials 
Flanker.SAya_FL_Congruent_MeanRT = splitapply(@nanmean,tab_Cong.CongRT,tab_Cong.C);   %Congruent Mean RT
Flanker.SAya_FL_Congruent_MedianRT = splitapply(@nanmedian,tab_Cong.CongRT,tab_Cong.C);  %Congruent Median RT
Flanker.SAya_FL_Congruent_SD_RT = splitapply(@nanstd,tab_Cong.CongRT,tab_Cong.C);  %Congruent standard deviation of RT
Flanker.SAya_FL_Congruent_CV_RT = Flanker.SAya_FL_Congruent_SD_RT./Flanker.SAya_FL_Congruent_MeanRT;  %Congruent Coefficient of variance of RT
Flanker.SAya_FL_Congruent_ResponseAccuracy = (splitapply(@nanmean,tab_Cong.Stimulus_ACC,tab_Cong.C))*100;  %Congruent Total accuracy
Flanker.SAya_FL_Congruent_TotalCorrect = splitapply(@nansum,tab_Cong.Stimulus_ACC,tab_Cong.C); %Overall Total number of correct responses
Flanker.SAya_FL_Congruent_TotalErrors = Flanker.SAya_FL_Congruent_TotalTrials - Flanker.SAya_FL_Congruent_TotalCorrect;   %Congruent Total number of error responses
Flanker.SAya_FL_Congruent_InverseEfficiency = Flanker.SAya_FL_Congruent_MeanRT./(1-(Flanker.SAya_FL_Congruent_TotalErrors./Flanker.SAya_FL_Congruent_TotalTrials));   %Congruent Total RT accounting for speed/accuracy
Flanker.SAya_FL_Congruent_TotalCommissionErrors =  splitapply(@nansum,(strcmp(tab_Cong.ErrorType, {'C'})),tab_Cong.C);  %Congruent Total number of incorrect responses
Flanker.SAya_FL_Congruent_TotalOmissionErrors = splitapply(@nansum,(strcmp(tab_Cong.ErrorType, {'O'})),tab_Cong.C);  %Congruent Total number of no responses
Flanker.SAya_FL_Congruent_ER_Latency = splitapply(@nanmean,tab_Cong.ErrorRT,tab_Cong.C); %RT for congruent error trials

% Variables: Incongruent Trials
tab_Incon.I = findgroups(tab_Incon.Subject,tab_Incon.Session, tab_Incon.Timing); %use subject/session to determine groups to calculate variables

Flanker.SAya_FL_Incongruent_TotalTrials = splitapply(@nansum,tab_Incon.TrialList_Cycle,tab_Incon.I);  %Incongruent Number of total trials 
Flanker.SAya_FL_Incongruent_MeanRT = splitapply(@nanmean,tab_Incon.InconRT,tab_Incon.I);   %Incongruent Mean RT
Flanker.SAya_FL_Incongruent_MedianRT = splitapply(@nanmedian,tab_Incon.InconRT,tab_Incon.I);  %Incongruent Median RT
Flanker.SAya_FL_Incongruent_SD_RT = splitapply(@nanstd,tab_Incon.InconRT,tab_Incon.I);  %Incongruent standard deviation of RT
Flanker.SAya_FL_Incongruent_CV_RT = Flanker.SAya_FL_Incongruent_SD_RT./Flanker.SAya_FL_Incongruent_MeanRT;  %Incongruent Coefficient of variance of RT
Flanker.SAya_FL_Incongruent_ResponseAccuracy = (splitapply(@nanmean,tab_Incon.Stimulus_ACC,tab_Incon.I))*100;  %Incongruent Total accuracy
Flanker.SAya_FL_Incongruent_TotalCorrect = splitapply(@nansum,tab_Incon.Stimulus_ACC,tab_Incon.I); %Overall Total number of incongruent correct responses
Flanker.SAya_FL_Incongruent_TotalErrors = Flanker.SAya_FL_Incongruent_TotalTrials - Flanker.SAya_FL_Incongruent_TotalCorrect;   %Incongruent Total number of error responses
Flanker.SAya_FL_Incongruent_InverseEfficiency = Flanker.SAya_FL_Incongruent_MeanRT./(1-(Flanker.SAya_FL_Incongruent_TotalErrors./Flanker.SAya_FL_Incongruent_TotalTrials));   %Incongruent Total RT accounting for speed/accuracy
Flanker.SAya_FL_Incongruent_TotalCommissionErrors =  splitapply(@nansum,(strcmp(tab_Incon.ErrorType, {'C'})),tab_Incon.I);  %Incongruent Total number of incorrect responses
Flanker.SAya_FL_Incongruent_TotalOmissionErrors = splitapply(@nansum,(strcmp(tab_Incon.ErrorType, {'O'})),tab_Incon.I);  %Incongruent Total number of no responses
Flanker.SAya_FL_Incongruent_ER_Latency = splitapply(@nanmean,tab_Incon.ErrorRT,tab_Incon.I); %RT for incongruent error trials


% Variables: All trials
Flanker.SAya_FL_All_TotalTrials = (Flanker.SAya_FL_Congruent_TotalTrials + Flanker.SAya_FL_Incongruent_TotalTrials);  %Overall Number of total trials 
Flanker.SAya_FL_All_ResponseAccuracy = (splitapply(@nanmean,tab.Stimulus_ACC,tab.D))*100;  %Overall Total accuracy
Flanker.SAya_FL_All_TotalCorrect = splitapply(@nansum,tab.Stimulus_ACC,tab.D); %Overall Total number of correct responses
Flanker.SAya_FL_All_MeanRT = ((Flanker.SAya_FL_Congruent_MeanRT.* Flanker.SAya_FL_Congruent_TotalCorrect)+(Flanker.SAya_FL_Incongruent_MeanRT.* Flanker.SAya_FL_Incongruent_TotalCorrect))./(Flanker.SAya_FL_All_TotalCorrect);   %Overall Mean RT
Flanker.SAya_FL_All_MedianRT = splitapply(@nanmedian,tab.CongRTInconRT,tab.D);  %Overall Median RT
Flanker.SAya_FL_All_SD_RT = splitapply(@nanstd,tab.CongRTInconRT,tab.D);  %Overall standard deviation of RT
Flanker.SAya_FL_All_CV_RT = Flanker.SAya_FL_All_SD_RT./Flanker.SAya_FL_All_MeanRT;  %Overall Coefficient of variance of RT
Flanker.SAya_FL_All_TotalErrors = Flanker.SAya_FL_All_TotalTrials - Flanker.SAya_FL_All_TotalCorrect;   %Overall Total number of error responses
Flanker.SAya_FL_All_InverseEfficiency = Flanker.SAya_FL_All_MeanRT./(1-(Flanker.SAya_FL_All_TotalErrors./Flanker.SAya_FL_All_TotalTrials));   %Overall Total RT accounting for speed/accuracy
Flanker.SAya_FL_All_TotalCommissionErrors =  splitapply(@nansum,(strcmp(tab.ErrorType, {'C'})),tab.D);  %Overall Total number of incorrect responses
Flanker.SAya_FL_All_TotalOmissionErrors = splitapply(@nansum,(strcmp(tab.ErrorType, {'O'})),tab.D);  %Overall Total number of no responses
Flanker.SAya_FL_All_ER_Latency = splitapply(@nanmean,tab.ErrorRT,tab.D); %RT for overall error trials

%% Split by Timing - pre and Post
Flanker_pre = Flanker(Flanker.Timing==string('pr'),:); % table with data from only pre timing
Flanker_post = Flanker(Flanker.Timing==string('po'),:); % table with data from only post timing
            
%% RM Pre
Variables = Flanker_pre.Properties.VariableNames(:,5:end)'; % get a list of variables (without Subject, Session, Day)
Flanker_pre_RM = table; %create table to put data into
Flanker_pre_RM.Subject = unique(Flanker_pre.Subject); %add subject column into Flanker_RM

% create Names structure with all variable names x condition
for n=1:length(Variables)
        Names.B_pre(n) = strcat(Variables(n), {'_B_pre'});
        Names.R_pre(n) = strcat(Variables(n), {'_R_pre'});
        Names.E_pre(n) = strcat(Variables(n), {'_E_pre'});
        Names.T_pre(n) = strcat(Variables(n), {'_T_pre'});
end
    
% create Flanker_RM by looping through each variable
for n=1:length(Variables)
    x = [Names.B_pre(n) Names.R_pre(n) Names.E_pre(n) Names.T_pre(n)]; 
    temp = unstack(Flanker_pre, Variables(n), 'Day', 'GroupingVariables', 'Subject', 'NewDataVariableNames', x);
    Flanker_pre_RM = outerjoin(Flanker_pre_RM, temp);
    Flanker_pre_RM.Properties.VariableNames{1} = 'Subject';
end

% Remove temp subject columns
Flanker_pre_RM = removevars(Flanker_pre_RM, {'Subject_temp','Subject_temp_1','Subject_temp_2','Subject_temp_3','Subject_temp_4','Subject_temp_5',...
    'Subject_temp_6','Subject_temp_7','Subject_temp_8','Subject_temp_9','Subject_temp_10','Subject_temp_11','Subject_temp_12','Subject_temp_13',...
    'Subject_temp_14','Subject_temp_15','Subject_temp_16','Subject_temp_17','Subject_temp_18','Subject_temp_19','Subject_temp_20','Subject_temp_21',...
    'Subject_temp_22','Subject_temp_23','Subject_temp_24','Subject_temp_25','Subject_temp_26','Subject_temp_27','Subject_temp_28','Subject_temp_29',...
    'Subject_temp_30','Subject_temp_31','Subject_temp_32','Subject_temp_33','Subject_temp_34','Subject_temp_35'});

%remove the contents from the Names table to make space for post
clearvars Names temp x Variables n

%% RM Post
Variables = Flanker_post.Properties.VariableNames(:,5:end)'; % get a list of variables (without Subject, Session, Day)
Flanker_post_RM = table; %create table to put data into
Flanker_post_RM.Subject = unique(Flanker_pre.Subject); %add subject column into Flanker_RM

% create Names structure with all variable names x condition
for n=1:length(Variables)
        Names.B_post(n) = strcat(Variables(n), {'_B_post'});
        Names.R_post(n) = strcat(Variables(n), {'_R_post'});
        Names.E_post(n) = strcat(Variables(n), {'_E_post'});
        Names.T_post(n) = strcat(Variables(n), {'_T_post'});
end

% create Flanker_RM by looping through each variable
for n=1:length(Variables)
    x = [Names.R_post(n) Names.E_post(n) Names.T_post(n)]; 
    temp = unstack(Flanker_post, Variables(n), 'Day', 'GroupingVariables', 'Subject', 'NewDataVariableNames', x);
    Flanker_post_RM = outerjoin(Flanker_post_RM, temp);
    Flanker_post_RM.Properties.VariableNames{1} = 'Subject';
end

% Remove temp subject columns
Flanker_post_RM = removevars(Flanker_post_RM, {'Subject_temp','Subject_temp_1','Subject_temp_2','Subject_temp_3','Subject_temp_4','Subject_temp_5',...
    'Subject_temp_6','Subject_temp_7','Subject_temp_8','Subject_temp_9','Subject_temp_10','Subject_temp_11','Subject_temp_12','Subject_temp_13',...
    'Subject_temp_14','Subject_temp_15','Subject_temp_16','Subject_temp_17','Subject_temp_18','Subject_temp_19','Subject_temp_20','Subject_temp_21',...
    'Subject_temp_22','Subject_temp_23','Subject_temp_24','Subject_temp_25','Subject_temp_26','Subject_temp_27','Subject_temp_28','Subject_temp_29',...
    'Subject_temp_30','Subject_temp_31','Subject_temp_32','Subject_temp_33','Subject_temp_34','Subject_temp_35'});

%% Combine RM tables so pre and post are together for one output  
clearvars -except Flanker Flanker_pre_RM Flanker_post_RM tab SaveNameRM SaveNameMLM MergedPath
Flanker_RM = join(Flanker_pre_RM, Flanker_post_RM);

%% Save 
clearvars -except Flanker Flanker_RM tab SaveNameRM SaveNameMLM MergedPath

%Change intervention codes back to letters, (B=66=baseline, R=77=rest, E=88=exercise, T=99=trier)
 Flanker.Day(strcmpi(Flanker.Day,'66')) = {'B'}; 
 Flanker.Day(strcmpi(Flanker.Day,'77')) = {'R'}; 
 Flanker.Day(strcmpi(Flanker.Day,'88')) = {'E'}; 
 Flanker.Day(strcmpi(Flanker.Day,'99')) = {'T'};
 Flanker.Day=string(Flanker.Day); %convert to string
 
cd(MergedPath);
save SAya_FL_behavior %save output as Matlab variable
writetable(Flanker_RM,SaveNameRM,'Sheet',1,'Range','A1') %save output as .xlsx
writetable(Flanker, SaveNameMLM,'Sheet',1,'Range','A1') %save output as .xlsx
