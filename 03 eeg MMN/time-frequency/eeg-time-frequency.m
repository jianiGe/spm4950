% time frequency analysis (single subject)
% assuming preprocessing has been done via eeg-preproc-tf

spm('defaults', 'eeg');

proj_dir = 'C:\Users\jiani\Documents\MATLAB\spm4950\03 eeg MMN';
preproc_output = 'aefdfMspmeeg_subject1';

%% time frequency ananlysis
% Morlet conversion
S = [];
S.D = fullfile(proj_dir, [preproc_output '.mat']);
S.channels = {'all'};
S.frequencies = [1:40]; % 1-40 Hz
S.timewin = [-Inf Inf];
S.phase = 1;
S.method = 'morlet';
S.settings.ncycles = 5;
S.settings.timeres = 0;
S.settings.subsample = 5;
S.prefix = '';
D = spm_eeg_tf(S);

filename_pw = {};
filename_ph = {};
filename_pw{end+1} = ['tf_' preproc_output]; % power
filename_ph{end+1} = ['tph_' preproc_output]; % phase

% Crop (power & phase)
S = [];
S.D = fullfile(proj_dir, [filename_pw{end} '.mat']); 
S.timewin = [-100 400];
S.freqwin = [-Inf Inf];
S.channels = {'all'};
S.prefix = 'p';
D = spm_eeg_crop(S);
filename_pw{end+1} = [S.prefix filename_pw{end}];

S = [];
S.D = fullfile(proj_dir, [filename_ph{end} '.mat']);
S.timewin = [-100 400];
S.freqwin = [-Inf Inf];
S.channels = {'all'};
S.prefix = 'p';
D = spm_eeg_crop(S);
filename_ph{end+1} = [S.prefix filename_ph{end}];

% Average (power & phase)
S = [];
S.D = fullfile(proj_dir, [filename_pw{end} '.mat']);
S.robust = false;
S.circularise = false;
S.prefix = 'm';
D = spm_eeg_average(S);
filename_pw{end+1} = [S.prefix filename_pw{end}];

S = [];
S.D = fullfile(proj_dir, [filename_ph{end} '.mat']);
S.robust = false;
S.circularise = false;
S.prefix = 'm';
D = spm_eeg_average(S);
filename_ph{end+1} = [S.prefix filename_ph{end}];

% Basline rescale (power only)
S = [];
S.D = fullfile(proj_dir, [filename_pw{end} '.mat']);
S.method = 'LogR';
S.prefix = 'r';
S.timewin = [-100 0];
S.pooledbaseline = 0;
D = spm_eeg_tf_rescale(S);
filename_pw{end+1} = [S.prefix filename_pw{end}];

% Contrast
S = [];
S.D = fullfile(proj_dir, [filename_pw{end} '.mat']);
S.c = [-1 1];
S.label = {'rare>standard'};
S.weighted = 1;
S.prefix = 'w';
D = spm_eeg_contrast(S);
filename_pw{end+1} = [S.prefix filename_pw{end}];

S = [];
S.D = fullfile(proj_dir, [filename_ph{end} '.mat']);
S.c = [-1 1];
S.label = {'rare>standard'};
S.weighted = 1;
S.prefix = 'w';
D = spm_eeg_contrast(S);
filename_ph{end+1} = [S.prefix filename_ph{end}];

%% delete intermediate outputs
userResponse = questdlg('Do you want to delete intermediate output files?', ...
                        'Continue', ...
                        'Yes', 'No', 'Yes');

switch userResponse
    case 'Yes'
        
        for i = 1:length(filename_pw)-1
            file1 = fullfile(proj_dir, [filename_pw{i} '.mat']);
            file2 = fullfile(proj_dir, [filename_pw{i} '.dat']);
            delete(file1);
            delete(file2);
        end

        for i = 1:length(filename_ph)-1
            file1 = fullfile(proj_dir, [filename_ph{i} '.mat']);
            file2 = fullfile(proj_dir, [filename_ph{i} '.dat']);
            delete(file1);
            delete(file2);
        end

        fprintf('Intermediate output files are deleted.\n');
        
    case 'No'
        % Execute the code for 'No'
        fprintf('Nothing is touched.\n');
        
end

