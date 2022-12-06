%Created by Katherine McDonald
%If you use my script, I kindly ask for co-authorship on your work as a
%significant contributor to your data processing pipeline

%% P3 Peak detection 
%% Flanker Pre Exercise
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Exercise/Pre/Reductions/';
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Exercise/Pre/Reductions/';
Subject_list_struct = dir('SAya_pr*_E_Flanker_avg.erp'); % grab erp files
Subject_list_EEG = {Subject_list_struct.name};

% Rename the file for better handling
b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-8);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};
Subject_list_EEG = natsort(Subject_list_EEG);

nbsubject = length(Subject_list_EEG);

% Peak detection
for s = 1:nbsubject
    subject = Subject_list_EEG{s};

    ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', m_path);
    
   CongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 13, 'Interval', [-25 25], 'Label', 'Congruent');
   IncongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 14, 'Interval', [-25 25], 'Label', 'Incongruent');   

%    writetable(struct2table(CongruentP3), [subject '_CongruentP3.xlsx']);
%    writetable(struct2table(IncongruentP3), [subject,'_IncongruentP3.xlsx']);
   
   
   mastermatrix_prFCE(s,1) = 0 + s;

   
   for ch = 1:51
       %peak amplitude
       mastermatrix_prFCE(s,1+ch) = CongruentP3(ch).amplitude;
       mastermatrix_prFCE(s,52+ch) = IncongruentP3(ch).amplitude;
       %peak latency
       mastermatrix_prFCE(s,103+ch) = CongruentP3(ch).latency;
       mastermatrix_prFCE(s,154+ch) = IncongruentP3(ch).latency;
   end

end

b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(8:10);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};

SubjectID = Subject_list_EEG;
SubjectID = natsort(SubjectID);
SubjectID = SubjectID';
% writecell(SubjectID, 'SubjectID_prFCE.xlsx');
SubjectID = cell2mat(SubjectID);
SubjectID = str2num(SubjectID);

mastermatrix_prFCE(:,1) = SubjectID;

cd([m_path]);
prFCE = mastermatrix_prFCE;
 save('prFCE_P3_sum');
%writematrix(prFCE, 'prFCE_P3_sum.xlsx');

clearvars -except   prFCE   


%% Flanker Po Exercise
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Exercise/Post/Reductions/';
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Exercise/Post/Reductions/';
Subject_list_struct = dir('SAya_po*_E_Flanker_avg.erp'); % grab erp files
Subject_list_EEG = {Subject_list_struct.name};

% Rename the file for better handling
b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-8);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};
Subject_list_EEG = natsort(Subject_list_EEG);

nbsubject = length(Subject_list_EEG);

% Peak detection
for s = 1:nbsubject
    subject = Subject_list_EEG{s};

    ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', m_path);
    
   CongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 13, 'Interval', [-25 25], 'Label', 'Congruent');
   IncongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 14, 'Interval', [-25 25], 'Label', 'Incongruent');   

%    writetable(struct2table(CongruentP3), [subject '_CongruentP3.xlsx']);
%    writetable(struct2table(IncongruentP3), [subject,'_IncongruentP3.xlsx']);
   
   mastermatrix_poFCE(s,1) = 0 + s;
   
   for ch = 1:51
       %peak amplitude
       mastermatrix_poFCE(s,1+ch) = CongruentP3(ch).amplitude;
       mastermatrix_poFCE(s,52+ch) = IncongruentP3(ch).amplitude;
       %peak latency
       mastermatrix_poFCE(s,103+ch) = CongruentP3(ch).latency;
       mastermatrix_poFCE(s,154+ch) = IncongruentP3(ch).latency;
   end

end

b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(8:10);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};

SubjectID = Subject_list_EEG;
SubjectID = natsort(SubjectID);
SubjectID = SubjectID';
% writecell(SubjectID, 'SubjectID_poFCE.xlsx');
SubjectID = cell2mat(SubjectID);
SubjectID = str2num(SubjectID);

mastermatrix_poFCE(:,1) = SubjectID;

cd ([m_path]);
poFCE = mastermatrix_poFCE;
save('poFCE_P3_sum');
% writematrix(poFCE, 'poFCE_P3_sum.xlsx');

clearvars -except   prFCE   poFCE  



%% Flanker Pre Rest_E
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_E/Pre/Reductions/';
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_E/Pre/Reductions/';
Subject_list_struct = dir('SAya_pr*_R_Flanker_avg.erp'); % grab erp files
Subject_list_EEG = {Subject_list_struct.name};

% Rename the file for better handling
b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-8);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};
Subject_list_EEG = natsort(Subject_list_EEG);

nbsubject = length(Subject_list_EEG);

% Peak detection
for s = 1:nbsubject
    subject = Subject_list_EEG{s};

    ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', m_path);
    
   CongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 13, 'Interval', [-25 25], 'Label', 'Congruent');
   IncongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 14, 'Interval', [-25 25], 'Label', 'Incongruent');   

%    writetable(struct2table(CongruentP3), [subject '_CongruentP3.xlsx']);
%    writetable(struct2table(IncongruentP3), [subject,'_IncongruentP3.xlsx']);
   
   
   mastermatrix_prFCRest_E(s,1) = 0 + s;
   
   for ch = 1:51
       %peak amplitude
       mastermatrix_prFCRest_E(s,1+ch) = CongruentP3(ch).amplitude;
       mastermatrix_prFCRest_E(s,52+ch) = IncongruentP3(ch).amplitude;
       %peak latency
       mastermatrix_prFCRest_E(s,103+ch) = CongruentP3(ch).latency;
       mastermatrix_prFCRest_E(s,154+ch) = IncongruentP3(ch).latency;
   end

end

b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(8:10);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};

SubjectID = Subject_list_EEG;
SubjectID = natsort(SubjectID);
SubjectID = SubjectID';
% writecell(SubjectID, 'SubjectID_prFCRest_E.xlsx');
SubjectID = cell2mat(SubjectID);
SubjectID = str2num(SubjectID);

mastermatrix_prFCRest_E(:,1) = SubjectID;

cd ([m_path]);
prFCRest_E = mastermatrix_prFCRest_E;
save('prFCRest_E_P3_sum');
% writematrix(prFCRest_E, 'prFCR_P3_sum.xlsx');

clearvars -except   prFCE   poFCE   prFCRest_E

%% Flanker Post Rest_E
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_E/Post/Reductions/';
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_E/Post/Reductions/';
Subject_list_struct = dir('SAya_po*_R_Flanker_avg.erp'); % grab erp files
Subject_list_EEG = {Subject_list_struct.name};

% Rename the file for better handling
b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-8);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};
Subject_list_EEG = natsort(Subject_list_EEG);

nbsubject = length(Subject_list_EEG);

% Peak detection
for s = 1:nbsubject
    subject = Subject_list_EEG{s};

    ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', m_path);
    
   CongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 13, 'Interval', [-25 25], 'Label', 'Congruent');
   IncongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 14, 'Interval', [-25 25], 'Label', 'Incongruent');   

%    writetable(struct2table(CongruentP3), [subject '_CongruentP3.xlsx']);
%    writetable(struct2table(IncongruentP3), [subject,'_IncongruentP3.xlsx']);
   
   
   mastermatrix_poFCRest_E(s,1) = 0 + s;
   
   for ch = 1:51
       %peak amplitude
       mastermatrix_poFCRest_E(s,1+ch) = CongruentP3(ch).amplitude;
       mastermatrix_poFCRest_E(s,52+ch) = IncongruentP3(ch).amplitude;
       %peak latency
       mastermatrix_poFCRest_E(s,103+ch) = CongruentP3(ch).latency;
       mastermatrix_poFCRest_E(s,154+ch) = IncongruentP3(ch).latency;
   end

end

b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(8:10);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};

SubjectID = Subject_list_EEG;
SubjectID = natsort(SubjectID);
SubjectID = SubjectID';
% writecell(SubjectID, 'SubjectID_poFCRest_E.xlsx');
SubjectID = cell2mat(SubjectID);
SubjectID = str2num(SubjectID);

mastermatrix_poFCRest_E(:,1) = SubjectID;

cd ([m_path]);
poFCRest_E = mastermatrix_poFCRest_E;
save('poFCRest_E_P3_sum');
% writematrix(poFCRest_E, 'poFCR_P3_sum.xlsx');

clearvars -except   prFCE   poFCE   prFCRest_E poFCRest_E



%% Flanker Pre Rest_T
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_T/Pre/Reductions/';
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_T/Pre/Reductions/';
Subject_list_struct = dir('SAya_pr*_R_Flanker_avg.erp'); % grab erp files
Subject_list_EEG = {Subject_list_struct.name};

% Rename the file for better handling
b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-8);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};
Subject_list_EEG = natsort(Subject_list_EEG);

nbsubject = length(Subject_list_EEG);

% Peak detection
for s = 1:nbsubject
    subject = Subject_list_EEG{s};

    ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', m_path);
    
   CongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 13, 'Interval', [-25 25], 'Label', 'Congruent');
   IncongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 14, 'Interval', [-25 25], 'Label', 'Incongruent');   

%    writetable(struct2table(CongruentP3), [subject '_CongruentP3.xlsx']);
%    writetable(struct2table(IncongruentP3), [subject,'_IncongruentP3.xlsx']);
   
   
   mastermatrix_prFCRest_T(s,1) = 0 + s;
   
   for ch = 1:51
       %peak amplitude
       mastermatrix_prFCRest_T(s,1+ch) = CongruentP3(ch).amplitude;
       mastermatrix_prFCRest_T(s,52+ch) = IncongruentP3(ch).amplitude;
       %peak latency
       mastermatrix_prFCRest_T(s,103+ch) = CongruentP3(ch).latency;
       mastermatrix_prFCRest_T(s,154+ch) = IncongruentP3(ch).latency;
   end

end

b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(8:10);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};

SubjectID = Subject_list_EEG;
SubjectID = natsort(SubjectID);
SubjectID = SubjectID';
% writecell(SubjectID, 'SubjectID_prFCRest_T.xlsx');
SubjectID = cell2mat(SubjectID);
SubjectID = str2num(SubjectID);

mastermatrix_prFCRest_T(:,1) = SubjectID;

cd ([m_path]);
prFCRest_T = mastermatrix_prFCRest_T;
save('prFCRest_T_P3_sum');
% writematrix(prFCRest_T, 'prFCR_P3_sum.xlsx');

clearvars -except    prFCE   poFCE   prFCRest_E poFCRest_E  prFCRest_T

%% Flanker Post Rest_T
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_T/Post/Reductions/';
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_T/Post/Reductions/';
Subject_list_struct = dir('SAya_po*_R_Flanker_avg.erp'); % grab erp files
Subject_list_EEG = {Subject_list_struct.name};

% Rename the file for better handling
b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-8);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};
Subject_list_EEG = natsort(Subject_list_EEG);

nbsubject = length(Subject_list_EEG);

% Peak detection
for s = 1:nbsubject
    subject = Subject_list_EEG{s};

    ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', m_path);
    
   CongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 13, 'Interval', [-25 25], 'Label', 'Congruent');
   IncongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 14, 'Interval', [-25 25], 'Label', 'Incongruent');   

%    writetable(struct2table(CongruentP3), [subject '_CongruentP3.xlsx']);
%    writetable(struct2table(IncongruentP3), [subject,'_IncongruentP3.xlsx']);
   
   
   mastermatrix_poFCRest_T(s,1) = 0 + s;
   
   for ch = 1:51
       %peak amplitude
       mastermatrix_poFCRest_T(s,1+ch) = CongruentP3(ch).amplitude;
       mastermatrix_poFCRest_T(s,52+ch) = IncongruentP3(ch).amplitude;
       %peak latency
       mastermatrix_poFCRest_T(s,103+ch) = CongruentP3(ch).latency;
       mastermatrix_poFCRest_T(s,154+ch) = IncongruentP3(ch).latency;
   end

end

b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(8:10);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};

SubjectID = Subject_list_EEG;
SubjectID = natsort(SubjectID);
SubjectID = SubjectID';
% writecell(SubjectID, 'SubjectID_poFCRest_T.xlsx');
SubjectID = cell2mat(SubjectID);
SubjectID = str2num(SubjectID);

mastermatrix_poFCRest_T(:,1) = SubjectID;

cd ([m_path]);
poFCRest_T = mastermatrix_poFCRest_T;
save('poFCRest_T_P3_sum');
% writematrix(poFCRest_T, 'poFCR_P3_sum.xlsx');

clearvars -except   prFCE   poFCE   prFCRest_E poFCRest_E  prFCRest_T  poFCRest_T



%% Flanker Pre Trier
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Trier/Pre/Reductions/';
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Trier/Pre/Reductions/';
Subject_list_struct = dir('SAya_pr*_T_Flanker_avg.erp'); % grab erp files
Subject_list_EEG = {Subject_list_struct.name};

% Rename the file for better handling
b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-8);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};
Subject_list_EEG = natsort(Subject_list_EEG);

nbsubject = length(Subject_list_EEG);

% Peak detection
for s = 1:nbsubject
    subject = Subject_list_EEG{s};

    ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', m_path);
    
   CongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 13, 'Interval', [-25 25], 'Label', 'Congruent');
   IncongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 14, 'Interval', [-25 25], 'Label', 'Incongruent');   

%    writetable(struct2table(CongruentP3), [subject '_CongruentP3.xlsx']);
%    writetable(struct2table(IncongruentP3), [subject,'_IncongruentP3.xlsx']);
      
   mastermatrix_prFCT(s,1) = 0 + s;
   
   for ch = 1:51
       %peak amplitude
       mastermatrix_prFCT(s,1+ch) = CongruentP3(ch).amplitude;
       mastermatrix_prFCT(s,52+ch) = IncongruentP3(ch).amplitude;
       %peak latency
       mastermatrix_prFCT(s,103+ch) = CongruentP3(ch).latency;
       mastermatrix_prFCT(s,154+ch) = IncongruentP3(ch).latency;
   end

end

b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(8:10);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};

SubjectID = Subject_list_EEG;
SubjectID = natsort(SubjectID);
SubjectID = SubjectID';
% writecell(SubjectID, 'SubjectID_prFCT.xlsx');
SubjectID = cell2mat(SubjectID);
SubjectID = str2num(SubjectID);

mastermatrix_prFCT(:,1) = SubjectID;

cd ([m_path]);
prFCT = mastermatrix_prFCT;
save('prFCT_P3_sum');
% writematrix(prFCT, 'prFCT_P3_sum.xlsx');

clearvars -except   prFCE   poFCE   prFCRest_E poFCRest_E  prFCRest_T  poFCRest_T  prFCT


%% Flanker Post Trier
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Trier/Post/Reductions/';
cd '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Trier/Post/Reductions/';
Subject_list_struct = dir('SAya_po*_T_Flanker_avg.erp'); % grab erp files
Subject_list_EEG = {Subject_list_struct.name};

% Rename the file for better handling
b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-8);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};
Subject_list_EEG = natsort(Subject_list_EEG);

nbsubject = length(Subject_list_EEG);


% Peak detection
for s = 1:nbsubject
    subject = Subject_list_EEG{s};

    ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', m_path);
    
   CongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 13, 'Interval', [-25 25], 'Label', 'Congruent');
   IncongruentP3 = erppeakinterval(ERP, 'Window', [250 800], 'Polarity', 'Positive', 'Neighborhood', 9, 'Channels', 6:56, 'Bin', 14, 'Interval', [-25 25], 'Label', 'Incongruent');   

%    writetable(struct2table(CongruentP3), [subject '_CongruentP3.xlsx']);
%    writetable(struct2table(IncongruentP3), [subject,'_IncongruentP3.xlsx']);
   
   mastermatrix_poFCT(s,1) = 0 + s;
   
   for ch = 1:51
       %peak amplitude
       mastermatrix_poFCT(s,1+ch) = CongruentP3(ch).amplitude;
       mastermatrix_poFCT(s,52+ch) = IncongruentP3(ch).amplitude;
       %peak latency
       mastermatrix_poFCT(s,103+ch) = CongruentP3(ch).latency;
       mastermatrix_poFCT(s,154+ch) = IncongruentP3(ch).latency;
   end

end

b = 1;
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(8:10);
b = b+1;

end
Subject_list_EEG = {Subject_list_struct.name};

SubjectID = Subject_list_EEG;
SubjectID = natsort(SubjectID);
SubjectID = SubjectID';
% writecell(SubjectID, 'SubjectID_poFCT.xlsx');
SubjectID = cell2mat(SubjectID);
SubjectID = str2num(SubjectID);

mastermatrix_poFCT(:,1) = SubjectID;


cd ([m_path]);
poFCT = mastermatrix_poFCT;
save('poFCT_P3_sum');
% writematrix(poFCT, 'poFCT_P3_sum.xlsx');

clearvars -except      prFCE   poFCE   prFCRest_E poFCRest_E  prFCRest_T  poFCRest_T  prFCT poFCT

%% Combine P3 data across different dataset

  tab_prFCE = array2table(prFCE);
  tab_poFCE = array2table(poFCE);
  tab_prFCRest_E = array2table(prFCRest_E);
  tab_poFCRest_E = array2table(poFCRest_E);
  tab_prFCRest_T = array2table(prFCRest_T);
  tab_poFCRest_T = array2table(poFCRest_T);
  tab_prFCT = array2table(prFCT);
  tab_poFCT = array2table(poFCT);
  
 
  FC_Var = {'ID', 'Con_F7_Amplitude', 'Con_F5_Amplitude' , 'Con_F3_Amplitude', 'Con_F1_Amplitude', 'Con_FZ_Amplitude', 'Con_F2_Amplitude', 'Con_F4_Amplitude', 'Con_F6_Amplitude', 'Con_F8_Amplitude', 'Con_FC5_Amplitude', 'Con_FC3_Amplitude', 'Con_FC1_Amplitude', 'Con_FCZ_Amplitude', 'Con_FC2_Amplitude', 'Con_FC4_Amplitude', 'Con_FC6_Amplitude', 'Con_T7_Amplitude', 'Con_C5_Amplitude', 'Con_C3_Amplitude', 'Con_C1_Amplitude', 'Con_CZ_Amplitude', 'Con_C2_Amplitude', 'Con_C4_Amplitude', 'Con_C6_Amplitude', 'Con_T8_Amplitude', 'Con_TP7_Amplitude', 'Con_CP5_Amplitude', 'Con_CP3_Amplitude', 'Con_CP1_Amplitude', 'Con_CPZ_Amplitude', 'Con_CP2_Amplitude', 'Con_CP4_Amplitude', 'Con_CP6_Amplitude', 'Con_TP8_Amplitude', 'Con_P7_Amplitude', 'Con_P5_Amplitude', 'Con_P3_Amplitude', 'Con_P1_Amplitude', 'Con_PZ_Amplitude', 'Con_P2_Amplitude', 'Con_P4_Amplitude', 'Con_P6_Amplitude', 'Con_P8_Amplitude', 'Con_PO7_Amplitude', 'Con_PO3_Amplitude', 'Con_POZ_Amplitude', 'Con_PO4_Amplitude', 'Con_PO8_Amplitude', 'Con_O1_Amplitude', 'Con_OZ_Amplitude', 'Con_O2_Amplitude', 'Inc_F7_Amplitude', 'Inc_F5_Amplitude', 'Inc_F3_Amplitude', 'Inc_F1_Amplitude', 'Inc_FZ_Amplitude', 'Inc_F2_Amplitude', 'Inc_F4_Amplitude', 'Inc_F6_Amplitude', 'Inc_F8_Amplitude', 'Inc_FC5_Amplitude', 'Inc_FC3_Amplitude', 'Inc_FC1_Amplitude', 'Inc_FCZ_Amplitude', 'Inc_FC2_Amplitude', 'Inc_FC4_Amplitude', 'Inc_FC6_Amplitude', 'Inc_T7_Amplitude', 'Inc_C5_Amplitude', 'Inc_C3_Amplitude', 'Inc_C1_Amplitude', 'Inc_CZ_Amplitude', 'Inc_C2_Amplitude', 'Inc_C4_Amplitude', 'Inc_C6_Amplitude', 'Inc_T8_Amplitude', 'Inc_TP7_Amplitude', 'Inc_CP5_Amplitude', 'Inc_CP3_Amplitude', 'Inc_CP1_Amplitude', 'Inc_CPZ_Amplitude', 'Inc_CP2_Amplitude', 'Inc_CP4_Amplitude', 'Inc_CP6_Amplitude', 'Inc_TP8_Amplitude', 'Inc_P7_Amplitude', 'Inc_P5_Amplitude', 'Inc_P3_Amplitude', 'Inc_P1_Amplitude', 'Inc_PZ_Amplitude', 'Inc_P2_Amplitude', 'Inc_P4_Amplitude', 'Inc_P6_Amplitude', 'Inc_P8_Amplitude', 'Inc_PO7_Amplitude', 'Inc_PO3_Amplitude', 'Inc_POZ_Amplitude', 'Inc_PO4_Amplitude', 'Inc_PO8_Amplitude', 'Inc_O1_Amplitude', 'Inc_OZ_Amplitude', 'Inc_O2_Amplitude', 'Con_F7_Latency', 'Con_F5_Latency', 'Con_F3_Latency', 'Con_F1_Latency', 'Con_FZ_Latency', 'Con_F2_Latency', 'Con_F4_Latency', 'Con_F6_Latency', 'Con_F8_Latency', 'Con_FC5_Latency', 'Con_FC3_Latency', 'Con_FC1_Latency', 'Con_FCZ_Latency', 'Con_FC2_Latency', 'Con_FC4_Latency', 'Con_FC6_Latency', 'Con_T7_Latency', 'Con_C5_Latency', 'Con_C3_Latency', 'Con_C1_Latency', 'Con_CZ_Latency', 'Con_C2_Latency', 'Con_C4_Latency', 'Con_C6_Latency', 'Con_T8_Latency', 'Con_TP7_Latency', 'Con_CP5_Latency', 'Con_CP3_Latency', 'Con_CP1_Latency', 'Con_CPZ_Latency', 'Con_CP2_Latency', 'Con_CP4_Latency', 'Con_CP6_Latency', 'Con_TP8_Latency', 'Con_P7_Latency', 'Con_P5_Latency', 'Con_P3_Latency', 'Con_P1_Latency', 'Con_PZ_Latency', 'Con_P2_Latency', 'Con_P4_Latency', 'Con_P6_Latency', 'Con_P8_Latency', 'Con_PO7_Latency', 'Con_PO3_Latency', 'Con_POZ_Latency', 'Con_PO4_Latency', 'Con_PO8_Latency', 'Con_O1_Latency', 'Con_OZ_Latency', 'Con_O2_Latency', 'Inc_F7_Latency', 'Inc_F5_Latency', 'Inc_F3_Latency', 'Inc_F1_Latency', 'Inc_FZ_Latency', 'Inc_F2_Latency', 'Inc_F4_Latency', 'Inc_F6_Latency', 'Inc_F8_Latency', 'Inc_FC5_Latency', 'Inc_FC3_Latency', 'Inc_FC1_Latency', 'Inc_FCZ_Latency', 'Inc_FC2_Latency', 'Inc_FC4_Latency', 'Inc_FC6_Latency', 'Inc_T7_Latency', 'Inc_C5_Latency', 'Inc_C3_Latency', 'Inc_C1_Latency', 'Inc_CZ_Latency', 'Inc_C2_Latency', 'Inc_C4_Latency', 'Inc_C6_Latency', 'Inc_T8_Latency', 'Inc_TP7_Latency', 'Inc_CP5_Latency', 'Inc_CP3_Latency', 'Inc_CP1_Latency', 'Inc_CPZ_Latency', 'Inc_CP2_Latency', 'Inc_CP4_Latency', 'Inc_CP6_Latency', 'Inc_TP8_Latency', 'Inc_P7_Latency', 'Inc_P5_Latency', 'Inc_P3_Latency', 'Inc_P1_Latency', 'Inc_PZ_Latency', 'Inc_P2_Latency', 'Inc_P4_Latency', 'Inc_P6_Latency', 'Inc_P8_Latency', 'Inc_PO7_Latency', 'Inc_PO3_Latency', 'Inc_POZ_Latency', 'Inc_PO4_Latency', 'Inc_PO8_Latency', 'Inc_O1_Latency', 'Inc_OZ_Latency' , 'Inc_O2_Latency'};

  tab_prFCE.Properties.VariableNames = FC_Var;
for varName = 2:length(tab_prFCE.Properties.VariableNames)
    tab_prFCE.Properties.VariableNames{varName} = ['FC_E_pre_P3_' tab_prFCE.Properties.VariableNames{varName}];
end

  tab_poFCE.Properties.VariableNames = FC_Var;
for varName = 2:length(tab_poFCE.Properties.VariableNames)
    tab_poFCE.Properties.VariableNames{varName} = ['FC_E_po_P3_' tab_poFCE.Properties.VariableNames{varName}];
end

  tab_prFCRest_E.Properties.VariableNames = FC_Var;
for varName = 2:length(tab_prFCRest_E.Properties.VariableNames)
    tab_prFCRest_E.Properties.VariableNames{varName} = ['FC_Rest_E_pre_P3_' tab_prFCRest_E.Properties.VariableNames{varName}];
end

  tab_poFCRest_E.Properties.VariableNames = FC_Var;
for varName = 2:length(tab_poFCRest_E.Properties.VariableNames)
    tab_poFCRest_E.Properties.VariableNames{varName} = ['FC_Rest_E_po_P3_' tab_poFCRest_E.Properties.VariableNames{varName}];
end

  tab_prFCRest_T.Properties.VariableNames = FC_Var;
for varName = 2:length(tab_prFCRest_T.Properties.VariableNames)
    tab_prFCRest_T.Properties.VariableNames{varName} = ['FC_Rest_T_pre_P3_' tab_prFCRest_T.Properties.VariableNames{varName}];
end

  tab_poFCRest_T.Properties.VariableNames = FC_Var;
for varName = 2:length(tab_poFCRest_T.Properties.VariableNames)
    tab_poFCRest_T.Properties.VariableNames{varName} = ['FC_Rest_T_po_P3_' tab_poFCRest_T.Properties.VariableNames{varName}];
end

  tab_prFCT.Properties.VariableNames = FC_Var;
for varName = 2:length(tab_prFCT.Properties.VariableNames)
    tab_prFCT.Properties.VariableNames{varName} = ['FC_T_pre_P3_' tab_prFCT.Properties.VariableNames{varName}];
end

  tab_poFCT.Properties.VariableNames = FC_Var;
for varName = 2:length(tab_poFCT.Properties.VariableNames)
    tab_poFCT.Properties.VariableNames{varName} = ['FC_T_po_P3_' tab_poFCT.Properties.VariableNames{varName}];
end

  Flanker_Exercise_P3_mastertab = outerjoin(tab_prFCE, tab_poFCE, 'Type', 'full', 'MergeKeys', true);
  Flanker_Rest_E_P3_mastertab = outerjoin(tab_prFCRest_E, tab_poFCRest_E, 'Type', 'full', 'MergeKeys', true);
  Flanker_Rest_T_P3_mastertab = outerjoin(tab_prFCRest_T, tab_poFCRest_T, 'Type', 'full', 'MergeKeys', true);
  Flanker_Trier_P3_mastertab = outerjoin(tab_prFCT, tab_poFCT, 'Type', 'full', 'MergeKeys', true);
   
  %% Create master table for P3
  Flanker_Rest_E_T_P3_mastertab = outerjoin(Flanker_Rest_E_P3_mastertab, Flanker_Rest_T_P3_mastertab, 'Type', 'full', 'MergeKeys', true);
  Flanker_Rest_E_T_Exercise_P3_mastertab = outerjoin(Flanker_Rest_E_T_P3_mastertab, Flanker_Exercise_P3_mastertab,'Type', 'full', 'MergeKeys', true);
  Flanker_P3_mastertab = outerjoin(Flanker_Rest_E_T_Exercise_P3_mastertab, Flanker_Trier_P3_mastertab,'Type', 'full', 'MergeKeys', true);
  
 m_path = '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/Lab_Meeting_Data/';
 cd '/Volumes/Data/KatherineM/SNEACY/SNEACY_YA/Lab_Meeting_Data/'; 
 writetable(Flanker_P3_mastertab, 'Flanker_P3_amplitude_latency.xlsx');



