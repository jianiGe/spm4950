% Date: 09.05.2024
% Description: Specification and estimation

%% Set paths

% get the path of the current (main) script;
script_fullpath = which(mfilename);
script_dir = fileparts(script_fullpath);
cd(script_dir);

% get the paths of the data folder using reletative paths
data_dir = fullfile(script_dir, 'MoAEpilot'); % (for example, would get '...spm4950\01 auditory\MoAEpilot')
data_fm_dir = fullfile(script_dir, 'MoAEpilot', 'fM00223');
data_sm_dir = fullfile(script_dir, 'MoAEpilot', 'sM00223');
data_class_dir = fullfile(script_dir, 'classical');

% spm path (replace with your own)
spm_dir = 'C:\Users\jiani\Downloads\spm12\spm12';
addpath(spm_dir);

%% spm_jobman() variables

nrun = 1;
%jobfile = matlabbatch;
%jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end

%% initialize spm_jobman()

spm_jobman('initcfg');

%% FIRST LEVEL

% =====================SPECIFICATION=====================

%select input files
filter_scans = '^sw.*\.img$';
selected_scans = spm_select('List', data_fm_dir, filter_scans);
spec_scans_path = cellstr(strcat(data_fm_dir, '\', selected_scans));

spec_dir_path = cellstr(data_class_dir);

matlabbatch = {};

%specify (hehe) batch
matlabbatch{1}.spm.stats.fmri_spec.dir = spec_dir_path;
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 7;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = spec_scans_path;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.name = 'listening';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.onset = [6
                                                      18
                                                      30
                                                      42
                                                      54
                                                      66
                                                      78];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.duration = 6;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.orth = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch, inputs{:});

% ========================(optional) REVIEW=========================

%{
load([data_class_dir, '\SPM.mat']);
design_matrix = SPM.xX.X;

% Visualize design matrix
figure;
imagesc(design_matrix);
xlabel('Conditions');
ylabel('Time Points');
title('Design Matrix');
colormap(gray);
colorbar;

% Plot time series of regressors
figure;
time_points = 1:size(design_matrix, 1);
for i = 1:size(design_matrix, 2)
    subplot(size(design_matrix, 2), 1, i);
    plot(time_points, design_matrix(:, i));
    xlabel('Time Points');
    ylabel(['Regressor ' num2str(i)]);
    title(['Time Series of Regressor ' num2str(i)]);
    grid on;
end

% Check orthogonality/cosine similarity between regressors

num_regressors = size(design_matrix, 2);
cos_theta_matrix = zeros(num_regressors);

% iterate over each pair of regressor columns
for i = 1:num_regressors
    for j = 1:num_regressors
        x1 = design_matrix(:, i);
        x2 = design_matrix(:, j);
        inner_product = dot(x1, x2);
        norm_x1 = norm(x1); % vector length
        norm_x2 = norm(x2);
        
        cos_theta_matrix(i, j) = inner_product / (norm_x1 * norm_x2);
    end
end

disp(cos_theta_matrix); % display as cosine similarity matrix

%}

% ======================ESTIMATION=======================

matlabbatch = {};

%select input file
est_spmmat_path = cellstr(strcat(data_class_dir,'\SPM.mat'));

%specify batch
matlabbatch{1}.spm.stats.fmri_est.spmmat = est_spmmat_path;
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

%% Run estimation
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch, inputs{:});

