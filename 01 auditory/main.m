% Date: 26.05.2024
% Main script for fmri data analysis (preprocessing and first-level
% specification and estimation)

%% Set paths
% path of the current (main) script;
script_dir = fileparts(which(mfilename));
cd(script_dir);

% path of data folder
data_dir = fullfile(script_dir, 'MoAEpilot');

% spm path (replace with your own)
spm_dir = 'C:\Users\jiani\Downloads\spm12\spm12';
addpath(spm_dir);


%% Preprocessing
% via function 'preprocessing'; 
% e.g., preprocessing(steps, data_dir, spm_dir)
% 'steps' argument is a string that specifies the preprocessing steps to be
% executed; if nothing is entered, the default would be to execute all of the
% following:
% A--realignment
% B--coregistration
% C--segmentation
% D--functional normalization
% E--structural normalization
% F--smoothing

preprocessing('ABCDEF', data_dir, spm_dir);


%% First-level
% via function 'first_level_sepc_est'; 
% e.g., preprocessing(steps, data_dir)
% 'steps' argument is a string that specifies the steps to be
% executed; if nothing is entered, the default would be to execute the
% following:
% S--specification
% E--estimation

first_level_spec_est('SE', data_dir);





