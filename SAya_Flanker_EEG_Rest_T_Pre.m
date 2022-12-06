%Created by Katherine McDonald
%If you use my script, I kindly ask for co-authorship on your work as a
%significant contributor to your data processing pipeline

%% grab file IDs from folder
eeglab;
m_path = '/Volumes/Data/ZShared/SNEACY/2_SNEACY_YA/SNEACY_YA_EEG/Flanker_EEG/Flanker_EEG_Rest_T/Pre/';  % This is the path to your main processing folder
refchans = {'M1' 'M2'}; %These are your references channels (i.e. M1 and M2)
unusedchans = {'F11' 'F12' 'FT11' 'FT12' 'CB1' 'CB2'};  %Unused channels

%% Extract Flanker data
cd([m_path])
Subject_list_struct = dir('*.cdt'); % grab csv files containing specified string
Subject_list_EEG = {Subject_list_struct.name};
fullSetsName_list = cellfun(@(S) S(1:end-4), Subject_list_EEG, 'Uniform', 0);
% setName_list = insertAfter(fullSetsName_list(:,1:end),8, 'Flanker');
b = 1;

for subnum = 1:length(Subject_list_EEG)
EEG = loadcurry([m_path, Subject_list_EEG{subnum}], 'CurryLocations', 'False');
winStart = double(EEG.event([EEG.event.type] == 45).latency/1000);%"45" is triggger that signals start of Flanker task
winStop = double(EEG.event([EEG.event.type] == 54).latency/1000);%"54" is triggger that signals end of Flanker task
EEG = pop_select( EEG, 'time', [winStart-2 winStop+2]);  
EEG.event = rmfield(EEG.event, 'duration');
EEG.event(1) = [];
% % % winEvents = str2double({EEG.event(i).type});
for i = 1:length(EEG.event)
    EEG.event(i).type = int32(str2double({EEG.event(i).type}));
end
EEG = pop_saveset(EEG, 'filename',[fullSetsName_list{subnum}],'filepath',[m_path 'Set/']);
end

%% Load subject file and save as '.set' file
cd([m_path 'Set/'])
Subject_list_struct = dir('*Flanker*.set'); % grab set files
Subject_list_EEG = extractfield(Subject_list_struct, 'name')';
b = 1;

% % Rename the file for better handling
for i = 1:size(Subject_list_struct)
    
Subject_list_struct([b]).name = Subject_list_struct([b]).name(1:end-4);
b = b+1;

end
Subject_list_EEG = extractfield(Subject_list_struct, 'name')';

%% Re-reference, notch-filter, bin-assignment

for subnum = 1:length(Subject_list_EEG)
    subject = Subject_list_EEG{subnum};

EEG = pop_loadset('filename',[subject '.set'],'filepath',[m_path 'Set/']);

% Arrange chanlocs
EEG = pop_chanedit(EEG, 'lookup',[m_path 'standard-10-5-cap385.elp']);

% Remove unused channels
EEG = pop_select( EEG,'nochannel',unusedchans);

% Re-reference
EEG = pop_reref( EEG, [refchans],'keepref','off');

% Save after re-reference
EEG = pop_saveset( EEG, 'filename', [subject '_Ref', '.set'],'filepath',[m_path 'Re-referenced/']); 

% Save before notch filter
EEG = pop_saveset(EEG, 'filename',[subject '_beforeNotch'],'filepath',[m_path 'NotchCheck/']);            

% Notch filter
EEG  = pop_basicfilter( EEG, 1:EEG.nbchan , 'Cutoff',  60, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 ); 

% Save after notch filter
EEG = pop_saveset(EEG, 'filename',[subject '_afterNotch'],'filepath',[m_path 'NotchCheck/']);

% Create ERP Event List
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, ...
    'BoundaryString', { 'boundary' }, 'Eventlist', [m_path 'EventLists/' subject '_EventL1.txt'] ); 
EEG = pop_saveset(EEG, 'filename',[subject '_EventL1'],'filepath',[m_path 'EventLists/']);  

% Assign Bins
EEG  = pop_binlister( EEG , 'BDF', [m_path 'FC_BinLister.txt'], 'ExportEL', ...
    [m_path 'EventLists/' subject '_EventL2.txt'], 'ImportEL', [m_path 'EventLists/' subject...
    '_EventL1.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );

% Save file
EEG = pop_saveset(EEG, 'filename',[subject '_Binned'],'filepath',[m_path 'Binned/']);

end

%% Bad channel identification and removal

for subnum = 1:length(Subject_list_EEG)
    subject = Subject_list_EEG{subnum};

%load file
EEG = pop_loadset('filename',[subject '_Binned.set'],'filepath',[m_path 'Binned/']);
    
%Low Pass Filter
EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  4 );

%Extract bin-based epochs
EEG = pop_epochbin( EEG , [-200 1000],  'pre'); 

% Compute Averaged ERPs
ERP = pop_averager( EEG , 'Criterion', 'all', 'ExcludeBoundary', 'on', 'SEM', 'on' );

%Creating and Adding Additional Bins
ERP = pop_binoperator( ERP, {'b13 = (b1+b2+b3+b4+b5+b6)/6 label Congruent Correct',...
    'b14 = (b7+b8+b9+b10+b11+b12)/6 label Incongruent Correct'}); 

% Save ERP set for bad channel check
ERP = pop_savemyerp(ERP, 'erpname', [subject '_BadChannel'], 'filename', [subject '_BadChannel.erp'], ...
    'filepath', [m_path 'Reductions/BadchannelInspect'], 'Warning', 'off');

%Plot ERP Waveforms for Inspection
ERP = pop_loaderp( 'filename', [subject '_BadChannel.erp'], 'filepath', [m_path 'Reductions/BadchannelInspect'] );    
ERP = pop_ploterps( ERP, [13 14],1:EEG.nbchan , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'no', 'Box', ...
    [ 8 8], 'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', ...
    'bottom', 'Linespec', {'k-' , 'r-' }, 'LineWidth',1, 'Maximize', 'on', 'Position', ...
    [ 103.714 29.6429 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, ...
    'xscale', [ -200.0 999.0 -200:200:800 ], 'YDir', 'reverse', 'yscale', ...
    [ -75.0 75.0 -75 -56.3 -37.5 -18.8:18.8:18.8 37.5 56.3 75 ] );

%Save plot and close
cd([m_path 'ArtifactRejectionInfo/'])
 pop_exporterplabfigure(ERP, 'Format', 'pdf', 'tag', 'ERP_figure','SaveMode','auto');
% ERP = pop_exporterplabfigure( ERP , 'Filepath', [m_path 'ArtifactRejection_Info/'], 'Format', 'jpg', 'Resolution',  300, 'SaveMode', 'auto' );
% saveas([subject '_BadChannel.jpg']);

close all;

% Remove bad channels

%Reload the 'Binned' file
EEG = pop_loadset('filename',[subject '_Binned.set'],'filepath',[m_path 'Binned/']);

% Identify bad channels before computing ICA
    % Find bad channels automatically using the "catchbadchannels" function
    badchannels = catchbadchannels( EEG, 'Smoothed', 20, 'PointByPoint', 20, 'Trim', 2, 'Skip', {'VEO', 'HEO'});

    bc = table(badchannels);
    bcPath = strcat([m_path 'BadChannelLists/']);
    cd (bcPath)
    writetable(bc,[subject '_auto']);
    cd .. 

%     % For Manual removal of channels
%     if exist([m_path 'BadChannelLists/' subject '_man.txt'], 'file')
%         filename = [m_path 'BadChannelLists/manual/' subject '_man.txt'];
%         formatSpec = '%s%s%[^/n/r]';
%         fileID = fopen(filename,'r');
%         dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '',  'ReturnOnError', false);
%         fclose(fileID);
%         badchannels_man = dataArray{1,1};
%         clearvars filename formatSpec fileID dataArray ans;
%         badchannels_backup = badchannels;
%         badchannels_man = badchannels_man';
%         badchannels = [badchannels_man badchannels];
%         badchannels = unique(badchannels);
%     end
% 
%     bc = table(badchannels);
%     bcPath = strcat([m_path 'BadChannelLists/']);
%     cd (bcPath)
%     writetable(bc,subject);
%     cd .. 

% Remove bad channels
EEG = pop_select( EEG, 'nochannel', badchannels);

% Save file with bad channels removed
EEG = pop_saveset( EEG, 'filename', [subject '_bc'],'filepath', [m_path 'BadChannelLists/']);

close all;

end

%% ICA

for subnum = 1:length(Subject_list_EEG)
    subject = Subject_list_EEG{subnum};

EEG = pop_loadset('filename', [subject '_bc.set'],'filepath',[m_path 'BadChannelLists/']);

% High-pass filter befor ICA
EEG  = pop_basicfilter( EEG, 1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  0.05, 'Design', ...
    'butter', 'Filter', 'highpass', 'Order',  2 ); 

% Run ICA
tic;
EEG = pop_runica(EEG,'icatype','runica','options',{'extended',1,'block',floor(sqrt(EEG.pnts/3)),'anneal',0.98});
toc;
min = toc/60;

time = table(min);
icaTimep = strcat([m_path 'ICA/Time/']);
cd (icaTimep)
writetable(time,subject);
cd ..

%Save file after ICA
EEG = pop_saveset( EEG, 'filename', [subject '_ICA'],'filepath', [m_path 'ICA/Sets/']);

end

%% Remove eye blink components and interpolate bad channels

for subnum = 1:length(Subject_list_EEG)
    subject = Subject_list_EEG{subnum};

EEG = pop_loadset('filename',[subject '_ICA.set'],'filepath',[m_path 'ICA/Sets/']);

%----These are the temp ICA weights that are saved  
TMP.icawinv = EEG.icawinv;
TMP.icasphere = EEG.icasphere;
TMP.icaweights = EEG.icaweights;
TMP.icachansind = EEG.icachansind;
clear EEG;

% Reload the "bc" file
EEG = pop_loadset('filename',[subject '_bc.set'],'filepath',[m_path 'BadChannelLists/']);
% pop_eegplot( EEG, 1, 1, 1); % Plot eeg before ICA 

%----These weights for ICA are then assigned to a file that has not been filtered    
EEG.icawinv = TMP.icawinv;
EEG.icasphere = TMP.icasphere;
EEG.icaweights = TMP.icaweights;
EEG.icachansind = TMP.icachansind;
clear TMP;

% Save before removing eye blinks
EEG = pop_saveset( EEG, 'filename', [subject '_BeforeICA'],'filepath', [m_path 'ICA/Sets/']);

% Find Eye Blink Component(s)    
EEG.icaquant = icablinkmetrics(EEG, 'ArtifactChannel', EEG.data(find(strcmp({EEG.chanlocs.labels},'VEO')),:), ...
    'Alpha', 0.001, 'VisualizeData', 'False');

d = 1;
for i=1:(length(EEG.icaquant.identifiedcomponents))
    number = num2str(d);
    FIGICA = figure;pop_topoplot(EEG,0,[EEG.icaquant.identifiedcomponents(d)],subject,0,'electrodes','on')
    saveas(FIGICA,[m_path 'ICA/Components/' subject '_' number '.jpg']);
    d = d+1;
end

% Plot ICA components identified as blinks
ica_tab = table(EEG.icaquant.identifiedcomponents);
cd ([m_path 'ICA/Output/'])
writetable(ica_tab,subject);
cd ..; cd ..;

% Remove ICA components identified as blinks
EEG = pop_subcomp( EEG, EEG.icaquant.identifiedcomponents, 0);

% Save file after blinks are removed
EEG = pop_saveset( EEG, 'filename', [subject '_AfterICA.set'],'filepath', [m_path 'ICA/Sets/']);  

% % Plot EEG after ICA
% pop_eegplot( EEG, 1, 1, 1); %allow you to compare the data before and after removing ICA/eye blink

end

for subnum = 1:length(Subject_list_EEG)
    subject = Subject_list_EEG{subnum};

EEG = pop_loadset('filename',[subject '_AfterICA.set'],'filepath',[m_path 'ICA/Sets/']);

% Interpolate Bad Channels (i.e., to recapture bad channels)    
EEGref = pop_loadset('filename', [subject '_Ref.set'],'filepath', [m_path 'Re-referenced/']);
EEG = pop_interp(EEG, EEGref.chanlocs, 'spherical');

% Save after ICA & Interpolation (before filter and epoch)
EEG = pop_saveset(EEG, 'filename',[subject '_AfterICA_Interpolated'],'filepath',[m_path 'ICA/Sets/']);

%Low Pass Filter
EEG = pop_basicfilter( EEG,  1:EEG.nbchan , 'Cutoff',  30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  4 );
    
%High-pass Filter (optional)
%EEG  = pop_basicfilter( EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );

% Create ERP Event List
EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, ...
'BoundaryString', { 'boundary' }, 'Eventlist', [m_path 'EventLists/' subject '_EventL1.txt'] );  

% Assign Bins
EEG  = pop_binlister( EEG , 'BDF', [m_path 'FC_BinLister.txt'], 'ExportEL', ...
    [m_path 'EventLists/' subject '_EventL2.txt'], 'ImportEL', [m_path 'EventLists/' subject...
    '_EventL1.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' );

%Bin-based epochs
EEG = pop_epochbin( EEG , [-200.0  1000.0], 'pre' );

% Save after epoch and baseline correction
EEG = pop_saveset(EEG, 'filename',[subject '_AfterICA_Binned'],'filepath',[m_path 'ICA/Sets/']);

% Artifact Rejection & reporting
EEG = pop_artmwppth( EEG , 'Channel', [10 18 26 35 44], 'Flag',  1, 'Threshold',  100, 'Twindow', [ 0 998], 'Windowsize', 100, 'Windowstep',50 );% AR on midline sites
EEG = pop_jointprob(EEG,1,[10 18 26 35 44],3,3,1,0); %Probability reject at 3SD
pop_summary_AR_eeg_detection(EEG, [m_path 'ArtifactRejectionInfo/' subject '_ar.txt']);
EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);

% Save after artifact rejection
EEG = pop_saveset( EEG, 'filename', [subject '_Beforeavg'],'filepath', [m_path 'BeforeAVG/']);

close all;

end

%% Compute grand-averaged waveforms

for subnum = 1:length(Subject_list_EEG)
    subject = Subject_list_EEG{subnum};

EEG = pop_loadset('filename',[subject '_Beforeavg.set'],'filepath',[m_path 'BeforeAVG/']);

% Compute Averaged ERPs
ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on' );

% Creating and Adding Additional Bins
ERP = pop_binoperator( ERP, {'b13 = (b1+b2+b3+b4+b5+b6)/6 label Congruent Correct',...
    'b14 = (b7+b8+b9+b10+b11+b12)/6 label Incongruent Correct'});   
    
% Save ERP
ERP = pop_savemyerp(ERP, 'erpname', [subject '_avg'],'filename', [subject '_avg.erp'], 'filepath', ...
    [m_path 'Reductions/']);                                                                                                                                                                                                                                                       

% Plot ERP Waveforms for Inspection
ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', [m_path 'Reductions/'] );                                                                                                                                                                                                                                                                                                                                                                                 
ERP = pop_ploterps( ERP, [13 14],1:EEG.nbchan , 'Axsize', [ 0.05 0.08], 'BinNum', 'on', 'Blc', 'no', 'Box', ...
    [ 8 8], 'ChLabel', 'on', 'FontSizeChan',10, 'FontSizeLeg',12, 'FontSizeTicks',10, 'LegPos', ...
    'bottom', 'Linespec', {'k-' , 'r-' }, 'LineWidth',1, 'Maximize', 'on', 'Position', ...
    [ 103.714 29.6429 106.857 31.9286], 'Style', 'Classic', 'Tag', 'ERP_figure', 'Transparency',0, ...
    'xscale', [ -200.0 999.0 -200:200:800 ], 'YDir', 'reverse', 'yscale', ...
    [ -30.0 30.0   -30:7.5:-15 -7.6:7.6:7.6 15:7.5:30 ] ); %...ERP, [13 14]... = the bins you want to display

% Save plot and close    
cd([m_path 'Reductions/FinalReview/'])
% % %     saveas(ERP,[subject '_FinalERPreview.jpg']);
    pop_exporterplabfigure(ERP, 'Format', 'pdf', 'tag', 'ERP_figure','SaveMode','auto');    
    close all; 
    
end

%% GrandAverages (GA) & Plotting

for subnum = 1:length(Subject_list_EEG)
    subject = Subject_list_EEG{subnum};

% Export Data for Graphing
ERP = pop_loaderp( 'filename', [subject '_avg.erp'], 'filepath', [m_path 'Reductions/'] );                                                            
pop_export2text( ERP, [m_path 'Export_Excel/' subject '_erp_export.txt'], [13 14], 'electrodes', 'on', 'precision',4, 'time', 'on', 'timeunit',0.001 );

end

%% Group-level Grand-averaged Data 

cd([m_path 'Reductions/']);
filelist = dir('SAya_*_R_Flanker_avg.erp')
filenames = {filelist.name};

[ERP ALLERP] = pop_loaderp('filename', filenames, 'filepath', [m_path 'Reductions/']);
ERP = pop_gaverager( ALLERP, 'Erpsets', 1:length(filenames), 'ExcludeNullBin', 'on', 'SEM', 'on' );
ERP = pop_savemyerp(ERP, 'erpname', 'SAya_pr_Flanker_Rest_T_', 'filename', 'SAya_pr_Flanker_Rest_T_.erp', 'filepath', [m_path 'ERPsets/'], 'Warning', 'off');   
pop_export2text( ERP, [m_path 'Export_Excel/GrandAVG/','SAya_pr_Flanker_Rest_T_','_erp_export.txt'], [13 14], 'electrodes', 'on', 'precision',4, 'time', 'on', 'timeunit',0.001 );
% % 
% disp(',');
% disp('--------------------------------');
% disp(['Grand-averaged ' num2str(length(filenames)) ' Participants Flanker Post Exercise']); 
% disp('--------------------------------');
% disp(',');
% clear('filenames');
% % 