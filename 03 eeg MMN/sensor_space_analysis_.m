%% Sensor space analysis
% --convert preprocessed EEG data into 4D nifti files (X - Y - time -
% trial) by condition
% --two-sample t-test and contrast estimation for differences between
% conditions

% initialize spm
spm('defaults', 'EEG');
spm_jobman('initcfg');

% set directories
proj_dir = 'C:\Users\jiani\Documents\MATLAB\spm4950\03 eeg MMN';
stats_dir = fullfile(proj_dir, 'XYTstats');

if ~isfolder(stats_dir)
    mkdir(stats_dir);
    disp('stats output folder is created');
else
    disp('stats output folder already exists');
end

%% Convert to 4D (scalpX x scalpY x time x trial) files

preproc_file = fullfile(proj_dir, 'aefdfMspmeeg_subject1.mat'); % output of preprocessing
D = spm_eeg_load(preproc_file);

S = [];
S.D = D;
S.mode = 'scalp x time';
S.conditions = {};
S.channels = 'EEG';
S.timewin = [-Inf Inf];
S.freqwin = [-Inf Inf];
S.prefix = '';
spm_eeg_convert2images(S);

%% Two-sample t-test for sensor space analysis
% Specify factorial design
% read input images
img_dir = fullfile(proj_dir, 'aefdfMspmeeg_subject1');
img_standard = fullfile(img_dir, 'condition_standard.nii');
img_rare = fullfile(img_dir, 'condition_rare.nii');

v1 = spm_vol(img_standard);
scans1 = cell(length(v1), 1);
for i = 1:length(v1)
    scans1{i} = [v1(i).fname ',' num2str(v1(i).n(1))];
end

v2 = spm_vol(img_rare);
scans2 = cell(length(v2), 1);
for i = 1:length(v2)
    scans2{i} = [v2(i).fname ',' num2str(v2(i).n(1))];
end

% specify batch
matlabbatch = {};
matlabbatch{1}.spm.stats.factorial_design.dir = {stats_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = scans1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = scans2;
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% Model estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = {fullfile(stats_dir, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% Contrast estimation
matlabbatch{3}.spm.stats.con.spmmat(1) = {fullfile(stats_dir, 'SPM.mat')};
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'standard-vs-rare';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [1 -1];
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;

spm_jobman('run', matlabbatch);

