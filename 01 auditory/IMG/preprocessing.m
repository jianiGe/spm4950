%% Preprocessing
function preprocessing(steps, data_dir, spm_dir)
%%
% specify the preprocessing steps to be executed; if nothing given as
% input, execute A-F
% A--realignment
% B--coregistration
% C--segmentation
% D--functional normalization
% E--structural normalization
% F--smoothing
if nargin < 3 || isempty(steps)
    steps = 'ABCDEF';
else
    steps = steps;
end


%%
% paths of data/job folders
data_fm_dir = fullfile(data_dir, 'fM00223');
data_sm_dir = fullfile(data_dir, 'sM00223');
data_job_dir = fullfile(fileparts(data_dir), 'job');
addpath(data_job_dir);
% spm path
spm_dir = spm_dir;


%% spm_jobman() variables

nrun = 1;
%jobfile = matlabbatch;
%jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end


%%
for i = 1:length(steps)

    job = {};
    
    % =====================REALIGNMENT=====================
    if steps(i) == 'A'

        % select input files
        filter = '^fM.*\.img$';
        selected_files = spm_select('List', data_fm_dir, filter);
        input_paths = cellstr(strcat(data_fm_dir, '\', selected_files));

        % specify job
        job = realign(input_paths);

    end

    % =====================COREGISTRATION=====================
    if steps(i) == 'B'

        % select input files
        filter_ref = '^meanfM.*\.img$';
        selected_ref = spm_select('List', data_fm_dir, filter_ref);
        input_ref = cellstr(strcat(data_fm_dir, '\', selected_ref));
        
        filter_src = '^sM.*\.img$';
        selected_src = spm_select('List', data_sm_dir, filter_src);
        input_src = cellstr(strcat(data_sm_dir, '\', selected_src));

        % specify job
        job = coregister(input_ref, input_src);

    end
    
   % =====================SEGMENTATION=====================
    if steps(i) == 'C'

        % select input files
        filter = '^sM.*\.img$';
        selected_seg = spm_select('List', data_sm_dir, filter);
        input_path = cellstr(strcat(data_sm_dir, '\', selected_seg));

        spm_tpm_path = strcat(spm_dir, '\tpm\TPM.nii');

        % specify job
        job = segment(input_path, spm_tpm_path);

    end

    % =====================NORMALISATION (functional)=====================

    if steps(i) == 'D'
        
        % select input files
        filter_def = '^y_sM.*\.nii$';
        selected_def = spm_select('List', data_sm_dir, filter_def);
        fnorm_def_path = cellstr(strcat(data_sm_dir, '\', selected_def));
        
        filter_rsmp = '^fM.*\.img$';
        selected_rsmp = spm_select('List', data_fm_dir, filter_rsmp);
        fnorm_rsmp_path = cellstr(strcat(data_fm_dir, '\', selected_rsmp));

        % specify job
        job = normalise_functional(fnorm_def_path, fnorm_rsmp_path);
    
    end

    % =====================NORMALISATION (structural)=====================

    if steps(i) == 'E'

        % select input files
        filter_def = '^y_.*\.nii$';
        selected_def = spm_select('List', data_sm_dir, filter_def);
        snorm_def_path = cellstr(strcat(data_sm_dir, '\', selected_def));

        filter_rsmp = '^msM.*\.nii$';
        selected_rsmp = spm_select('List', data_sm_dir, filter_rsmp);
        snorm_rsmp_path = cellstr(strcat(data_sm_dir, '\', selected_rsmp));

        % specify job
        job = normalise_structural(snorm_def_path, snorm_rsmp_path);

    end

    % =====================SMOOTHING=====================
    
    if steps(i) == 'F'

        % select input files
        filter = '^wfM.*\.img$';
        selected_files = spm_select('List', data_fm_dir, filter);
        input_paths = cellstr(strcat(data_fm_dir, '\', selected_files));

        % specify job
        job = smooth(input_paths);

    end

    % run current preprocessing step

    spm('defaults', 'FMRI');
    spm_jobman('run', job, inputs{:});
    
end
end