function first_level_spec_est(steps, sub_preproc_dir, sub_firstlevel_dir)

%% Set paths
func_dir = fullfile(sub_preproc_dir, 'func');
firstlevel_dir = sub_firstlevel_dir

%% 
if nargin < 2 || isempty(steps)
    steps = 'SE';
else
    steps = steps';


%% spm_jobman() variables

nrun = 1;
%jobfile = matlabbatch;
%jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end

% input variables
% preprocessed runs
input_scans = {};
filter = fullfile(func_dir, 'sw*nii');
files = dir(filter);
for i = 1:length(files)
    input_scans{end+1} = [func_dir '\' files(i).name];
end

% runs that will be included in the GLM
runs = [1];

% onset info
load('log.mat');


%% FIRST LEVEL

for i = 1:length(steps)

    matlabbatch = {};

    % =====================SPECIFICATION=====================
    if steps(i) == 'S'

        matlabbatch{1}.spm.stats.fmri_spec.dir = {firstlevel_dir};
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = log.RT;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

        for i = 1:length(runs)
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans = {input_scans{runs(i)}};

            matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).name = log.condition{1};
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).onset = log.onset{i,1} / log.RT;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).duration = log.duration{1} / log.RT;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(1).orth = 1;

            matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi_reg = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(i).hpf = 128;    
        end   

        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
        matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    end

    % ======================ESTIMATION=======================
    if steps(i) == 'E'

    %select input file
    est_spmmat_path = cellstr(strcat(firstlevel_dir,'\SPM.mat'));

    %specify batch
    matlabbatch{1}.spm.stats.fmri_est.spmmat = est_spmmat_path;
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    end

    %% Run matlabbatch
    spm('defaults', 'FMRI');
    spm_jobman('run', matlabbatch, inputs{:});

end

end