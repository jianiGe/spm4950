% Kasey, Nur, Valerie, Jiani
% Date: 06.05.2024
% Description: Combined proprocessing steps into one script, including
% the option to selectively running the steps

%% Preprocessing steps

% specify the preprocessing steps to be executed
steps = 'ABCDEF';

%% Set paths

% get the path of the current (main) script;
% (should be '...Users\YOUR_NAME\...\spm4950\01 auditory')
script_fullpath = which(mfilename);
script_dir = fileparts(script_fullpath);

% get the paths of the data folder using reletative paths
data_dir = fullfile(script_dir, 'MoAEpilot'); % (for example, would get '...spm4950\01 auditory\MoAEpilot')
data_fm_dir = fullfile(script_dir, 'MoAEpilot', 'fM00223');
data_sm_dir = fullfile(script_dir, 'MoAEpilot', 'sM00223');

% spm path (replace with your own)
spm_dir = 'C:\Users\jiani\Downloads\spm12\spm12';

%% spm_jobman() variables

nrun = 1;
%jobfile = matlabbatch;
%jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end

%% initialize spm_jobman()

spm_jobman('initcfg');


%% PREPROCESSING

for i = 1:length(steps)

    matlabbatch = {};
    
    % =====================REALIGNMENT=====================

    if steps(i) == 'A'

        % select input files
        filter = '^fM.*\.img$';
        selected_files = spm_select('List', data_fm_dir, filter);
        input_paths = cellstr(strcat(data_fm_dir, '\', selected_files));

        % specify batch struct
        matlabbatch{1}.spm.spatial.realign.estwrite.data = {input_paths}';
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

        % run realignment
        spm('defaults', 'FMRI');
        spm_jobman('run', matlabbatch, inputs{:});

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

        % specify batch struct
        matlabbatch{1}.spm.spatial.coreg.estimate.ref = input_ref;
        matlabbatch{1}.spm.spatial.coreg.estimate.source = input_src;
        matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

        % run coregistration
        spm('defaults', 'FMRI');
        spm_jobman('run', matlabbatch, inputs{:});

    end

    
   % =====================SEGMENTATION=====================
    if steps(i) == 'C'

        % select input files
        filter = '^sM.*\.img$';
        selected_seg = spm_select('List', data_sm_dir, filter);
        input_path = cellstr(strcat(data_sm_dir, '\', selected_seg));

        spm_tpm_path = strcat(spm_dir, '\tpm\TPM.nii');

        % specify batch struct
        matlabbatch{1}.spm.spatial.preproc.channel.vols = input_path;
        matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.preproc.channel.write = [0 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm_tpm_path ',1']};
        matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm_tpm_path ',2']};
        matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm_tpm_path ',3']};
        matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm_tpm_path ',4']};
        matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm_tpm_path ',5']};
        matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm_tpm_path ',6']};
        matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
        matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
        matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
        % run segmentation
        spm('defaults', 'FMRI');
        spm_jobman('run', matlabbatch, inputs{:});

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

        % specify batch
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = fnorm_def_path;
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = fnorm_rsmp_path;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

        % run functional normalisation
        spm('defaults', 'FMRI');
        spm_jobman('run', matlabbatch, inputs{:});
    
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

        % specify batch struct
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = snorm_def_path;
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = snorm_rsmp_path;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 3];
        matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
        matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
        
        % run structural normalisation
        spm('defaults', 'FMRI');
        spm_jobman('run', matlabbatch, inputs{:});

    end

    % =====================SMOOTHING=====================
    
    if steps(i) == 'F'

        % select input files
        filter = '^wfM.*\.img$';
        selected_files = spm_select('List', data_fm_dir, filter);
        input_paths = cellstr(strcat(data_fm_dir, '\', selected_files));

        % batch
        matlabbatch{1}.spm.spatial.smooth.data = input_paths;
        matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';

        % run smoothing
        spm('defaults', 'FMRI');
        spm_jobman('run', matlabbatch, inputs{:});

    end
    
end
