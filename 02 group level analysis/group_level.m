%% Group-level analysis for SomaTI-Example dataset

% set up SPM
spm_dir = 'C:\Users\jiani\Downloads\spm12\spm12';
addpath(spm_dir);
spm('defaults', 'fmri');
spm_jobman('initcfg');

% data directory
firstlevel_dir = 'C:\Users\jiani\Downloads\SomaTI-Example\SomaTI-Example';
output_dir = 'C:\Users\jiani\Documents\MATLAB\spm4950\02 group level analysis\main-effect-interaction';


%% input data
% loop over each subject and compile paths to the first level contrast images

firstlevel_con = {};
subfolder = dir(firstlevel_dir);

for i = 1:length(subfolder)
    if subfolder(i).isdir && startsWith(subfolder(i).name, 'sub')
        filter = '^con.*\.img$';
        selected_con = spm_select('List', fullfile(firstlevel_dir, subfolder(i).name), filter);
        firstlevel_con{length(firstlevel_con)+1} = cellstr(strcat(firstlevel_dir, '\', subfolder(i).name, '\', selected_con,',1'));
    end
end

%
factor_name = {'PER-IMG', 'Position'};
conditions = [1 1; 1 2; 1 3; 1 4; 2 1; 2 2; 2 3; 2 4];
effects = {[1 2]}; %interaction


%% =====================COMPILE BATCH SCRIPT (flexible factorial)=====================
% output directory
matlabbatch = {};
matlabbatch{1}.spm.stats.factorial_design.dir = {output_dir};

% factorial design
for i = 1:length(factor_name)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).name = factor_name{1};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).dept = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).variance = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).gmsca = 0;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(i).ancova = 0;
end

% input scans
for i = 1:length(firstlevel_con)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).scans = firstlevel_con{i};
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(i).conds = conditions;
end

% main effect/interaction
for i = 1:length(effects)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{i}.inter.fnums = effects{i};
end

%
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


%% run estimation
nrun = 1;
inputs = cell(0, nrun);
spm_jobman('run', matlabbatch, inputs{:});

