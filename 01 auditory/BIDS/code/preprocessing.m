%% Preprocessing
function preprocessing(steps, sub_preproc_dir, spm_dir)
%%
% specify the preprocessing steps to be executed; if nothing given as
% input, execute A-F
% A--realignment
% B--coregistration
% C--segmentation
% D--functional normalization
% E--structural normalization
% F--smoothing


%if nargin < 3 || isempty(steps)
%    steps = 'ABCDEF';
%else
steps = steps;
%end


%%
% paths of data/job folders
% functional data
func_dir = fullfile(sub_preproc_dir, 'func');
fileList = dir(func_dir);
data_fm_dir = {};

% functional data (assume there could be one or more functional scan(s))
for i = 1:length(fileList)
    [~, ~, ext] = fileparts(fileList(i).name);
    if strcmp(ext, '.nii') && startsWith(fileList(i).name, 'sub')
        data_fm_dir{end+1} = {fullfile(sub_preproc_dir, 'func', fileList(i).name)};
    end
end

% structural data (assume there is only one structural scan)
anat_dir = fullfile(sub_preproc_dir, 'anat');
fileList = dir(anat_dir);
data_sm_dir = '';
for i = 1:length(fileList)
    [~, ~, ext] = fileparts(fileList(i).name);
    if strcmp(ext, '.nii')
        data_sm_dir = fullfile(sub_preproc_dir, 'anat', fileList(i).name);
        break;
    end
end

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

        % select data
        input_paths = {};
        for j = 1:length(data_fm_dir)
            input_paths{j} = [data_fm_dir{j}{1}]; %using a loop here just in case you want to select certain volumes
        end

        % specify job
        job = realign(input_paths);


    % =====================COREGISTRATION=====================
    elseif steps(i) == 'B'

        % select input files
        filter_ref = '^mean.*\.nii$';
        selected_ref = spm_select('List', func_dir, filter_ref);
        input_ref = cellstr([func_dir '\' selected_ref]);
        
        input_src = cellstr([data_sm_dir]);

        % specify job
        job = coregister(input_ref, input_src);
    
    
   % =====================SEGMENTATION=====================
    elseif steps(i) == 'C'

        % select input files
        input_path = cellstr(data_sm_dir);
        spm_tpm_path = strcat(spm_dir, '\tpm\TPM.nii');

        % specify job
        job = segment(input_path, spm_tpm_path);
    

    % =====================NORMALISATION (functional)=====================

    elseif steps(i) == 'D'
        
        % select input files
        filter_def = '^y_.*\.nii$';
        selected_def = spm_select('List', anat_dir, filter_def);
        fnorm_def_path = cellstr(strcat(anat_dir, '\', selected_def));
        
        %fnorm_rsmp_path = {};
        filter = '^rsub.*\.nii$';
        selected_files = spm_select('List', func_dir, filter);
        fnorm_rsmp_path = cellstr(strcat(func_dir, '\', selected_files));
       
        % specify job
        job = normalise_functional(fnorm_def_path, fnorm_rsmp_path);
    

    % =====================NORMALISATION (structural)=====================

    elseif steps(i) == 'E'

        % select input files
        filter_def = '^y_.*\.nii$';
        selected_def = spm_select('List', anat_dir, filter_def);
        snorm_def_path = cellstr(strcat(anat_dir, '\', selected_def));

        filter_rsmp = '^m.*\.nii$';
        selected_rsmp = spm_select('List', anat_dir, filter_rsmp);
        snorm_rsmp_path = cellstr(strcat(anat_dir, '\', selected_rsmp));

        % specify job
        job = normalise_structural(snorm_def_path, snorm_rsmp_path);
    

    % =====================SMOOTHING=====================
    
    elseif steps(i) == 'F'

        % select input files
        filter = '^wrsub.*\.nii$';
        selected_files = spm_select('List', func_dir, filter);
        input_paths = cellstr(strcat(func_dir, '\', selected_files));

        % specify job
        job = smooth(input_paths);

    end

    % run current preprocessing step

    spm('defaults', 'FMRI');
    spm_jobman('run', job, inputs{:});
    
end
end