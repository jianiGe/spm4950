% 17.06.2024
% Script for EEG preprocessing

spm('defaults', 'eeg');

proj_dir = 'C:\Users\jiani\Documents\MATLAB\spm4950\03 eeg MMN';

% Preparatory files (generated through GUI)
load('channelselection.mat');
load('avref_eog.mat')

%% Preprocessing
% Convertion
S = [];
S.dataset = fullfile(proj_dir, 'data', 'subject1.bdf');
S.mode = 'continuous';
S.channels = label;
S.eventpadding = 0;
S.blocksize = 3276800;
S.checkboundary = 1;
S.saveorigheader = 0;
S.outfile = 'spmeeg_subject1';
S.timewin = [];
S.conditionlabels = {'Undefined'};
S.inputformat = [];
D = spm_eeg_convert(S);

filename = S.outfile;
conv_D = [proj_dir '\' filename '.mat'];

% Montage
S = [];
S.D = conv_D;
S.mode = 'write';
S.blocksize = 655360;
S.prefix = 'M';
S.montage = montage;
S.keepothers = 0;
S.keepsensors = 1;
S.updatehistory = 1;
D = spm_eeg_montage(S);

filename = [S.prefix filename];
montage_D = [proj_dir '\' filename '.mat'];

% Load sensor location
S = [];
S.D = montage_D;
S.task = 'loadeegsens';
S.source = 'locfile';
S.sensfile = fullfile(proj_dir, 'data', 'sensors.pol');
S.save = 1;
D = spm_eeg_prep(S);

% High-pass filter
S = [];
S.D = montage_D;
S.type = 'butterworth';
S.band = 'high';
S.freq = 0.1;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);

filename = [S.prefix filename];
filter_D = [proj_dir '\' filename '.mat'];

% Downsampling
S = [];
S.D = filter_D;
S.fsample_new = 200;
S.method = 'fft';
S.prefix = 'd';
D = spm_eeg_downsample(S);

filename = [S.prefix filename];
downsample_D = [proj_dir '\' filename '.mat'];

% Low-pass filter
S = [];
S.D = downsample_D;
S.type = 'butterworth';
S.band = 'low';
S.freq = 30;
S.dir = 'twopass';
S.order = 5;
S.prefix = 'f';
D = spm_eeg_filter(S);

filename = [S.prefix filename];
filter_D = [proj_dir '\' filename '.mat'];

% Epoching
S = [];
S.D = filter_D;
S.trialdef(1).conditionlabel = 'standard';
S.trialdef(1).eventtype = 'STATUS';
S.trialdef(1).eventvalue = 1;
S.trialdef(1).trlshift = 0;
S.trialdef(2).conditionlabel = 'rare';
S.trialdef(2).eventtype = 'STATUS';
S.trialdef(2).eventvalue = 3;
S.trialdef(2).trlshift = 0;
S.timewin = [-100
             400];
S.bc = 1;
S.prefix = 'e';
S.eventpadding = 0;
D = spm_eeg_epochs(S);

filename = [S.prefix filename];
epoch_D = [proj_dir '\' filename '.mat'];

% Artefact
S = [];
S.D = epoch_D;
S.mode = 'reject';
S.badchanthresh = 0.2;
S.prefix = 'a';
S.append = true;
S.methods.channels = {'all'};
S.methods.fun = 'threshchan';
S.methods.settings.threshold = 80;
S.methods.settings.excwin = 1000;
D = spm_eeg_artefact(S);

filename = [S.prefix filename];
artefact_D = [proj_dir '\' filename '.mat'];

% Averaging
S = [];
S.D = artefact_D;
S.robust.ks = 3;
S.robust.bycondition = true;
S.robust.savew = false;
S.robust.removebad = false;
S.circularise = false;
S.prefix = 'm';
D = spm_eeg_average(S);

filename = [S.prefix filename];
average_D = [proj_dir '\' filename '.mat'];


