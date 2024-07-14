% preprocessing adapted for TF analysis
spm('defaults', 'eeg');

proj_dir = 'C:\Users\jiani\Documents\MATLAB\spm4950\03 eeg MMN';
addpath(proj_dir);

% Preparatory files (generated through GUI)
load('channelselection.mat');
load('avref_eog.mat')

%% Preprocessing
% Convertion
S = [];
S.dataset = fullfile(proj_dir, 'data', 'subject1.bdf');
S.mode = 'continuous';
S.channels = label; % from channelselection.mat
S.eventpadding = 0;
S.blocksize = 3276800;
S.checkboundary = 1;
S.saveorigheader = 0;
S.outfile = 'spmeeg_subject1';
S.timewin = [];
S.conditionlabels = {'Undefined'};
S.inputformat = [];
D = spm_eeg_convert(S);

filename = {};
filename{end+1} = S.outfile;

% Montage
S = [];
S.D = [proj_dir '\' filename{end} '.mat']; % select the output .mat file from the last step
S.mode = 'write';
S.blocksize = 655360;
S.prefix = 'M';
S.montage = montage; %from avref_eog.mat
S.keepothers = 0;
S.keepsensors = 1;
S.updatehistory = 1;
D = spm_eeg_montage(S);

filename{end+1} = [S.prefix filename{end}];

% Load sensor location
S = [];
S.D = [proj_dir '\' filename{end} '.mat'];
S.task = 'loadeegsens';
S.source = 'locfile';
S.sensfile = fullfile(proj_dir, 'data', 'sensors.pol');
S.save = 1;
D = spm_eeg_prep(S);


% High-pass filter
S = [];
S.D = [proj_dir '\' filename{end} '.mat'];
S.type = 'butterworth';
S.band = 'high';
S.freq = 0.1;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);

filename{end+1} = [S.prefix filename{end}];

%{
% Baseline correction (before downsampling as recommended in the manual)
S = [];
S.D = [proj_dir '\' filename{end} '.mat'];
S.time = [-100 0];
S.prefix = 'b';
D = spm_eeg_bc(S);

filename{end+1} = [S.prefix filename{end}];
%}

% Downsampling
S = [];
S.D = [proj_dir '\' filename{end} '.mat'];
S.fsample_new = 200;
S.method = 'fft';
S.prefix = 'd';
D = spm_eeg_downsample(S);

filename{end+1} = [S.prefix filename{end}];


% Low-pass filter
S = [];
S.D = [proj_dir '\' filename{end} '.mat'];
S.type = 'butterworth';
S.band = 'low';
S.freq = 45;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);

filename{end+1} = [S.prefix filename{end}];

% Epoching
S = [];
S.D = [proj_dir '\' filename{end} '.mat'];
S.trialdef(1).conditionlabel = 'standard';
S.trialdef(1).eventtype = 'STATUS';
S.trialdef(1).eventvalue = 1;
S.trialdef(1).trlshift = 0;
S.trialdef(2).conditionlabel = 'rare';
S.trialdef(2).eventtype = 'STATUS';
S.trialdef(2).eventvalue = 3;
S.trialdef(2).trlshift = 0;
S.timewin = [-500
             800]; % added 400ms padding
S.bc = 1;
S.prefix = 'e';
S.eventpadding = 0;
D = spm_eeg_epochs(S);

filename{end+1} = [S.prefix filename{end}];

% Artefact
% optional: mark bad channels
%{
badchannels = {'A14', 'B22'};
for i = 1:length(badchannels)
    badchannel_idx = find(strcmp(D.chanlabels, badchannels{i}));
    D = badchannels(D, channel_idx, 1);
end
save(D);
%}

S = [];
S.D = [proj_dir '\' filename{end} '.mat'];
S.mode = 'reject';
S.badchanthresh = 0.2;
S.prefix = 'a';
S.append = true;
S.methods.channels = {'all'};
S.methods.fun = 'threshchan';
S.methods.settings.threshold = 80;
S.methods.settings.excwin = 1000;
D = spm_eeg_artefact(S);

filename{end+1} = [S.prefix filename{end}];


%{
% Averaging
S = [];
S.D = [proj_dir '\' filename{end} '.mat'];
S.robust.ks = 3;
S.robust.bycondition = true;
S.robust.savew = false;
S.robust.removebad = false;
S.circularise = false;
S.prefix = 'm';
D = spm_eeg_average(S);

filename{end+1} = [S.prefix filename{end}];
%}

%% delete intermediate outputs
userResponse = questdlg('Do you want to delete intermediate output files?', ...
                        'Continue', ...
                        'Yes', 'No', 'Yes');

switch userResponse
    case 'Yes'
        
        for i = 1:length(filename)-1
            file1 = fullfile(proj_dir, [filename{i} '.mat']);
            file2 = fullfile(proj_dir, [filename{i} '.dat']);
            delete(file1);
            delete(file2);
        end

        fprintf('Intermediate output files are deleted.\n');
        
    case 'No'
        % Execute the code for 'No'
        fprintf('Nothing is touched.\n');
        
end



