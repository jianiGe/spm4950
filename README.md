# spm4950
Repository for Neurocognitive Methods & Data Analysis (SoSe24) at FU Berlin. Contains neuroimaging data and analysis scripts using SPM12.

### 01 auditory
- Single-subject fMRI preprocessing and GLM based on the [Auditory](https://www.fil.ion.ucl.ac.uk/spm/docs/manual/auditory/auditory/) dataset from the SPM manual<br>
- IMG: Analysis script based on the original data in .img format; for single-subject and single-run only
- BIDS: Analysis script adapted for BIDS, multiple-subject and multiple-run

### 02 group level analysis
- Second-level GLM and contrasts (flexible factorial design) based on the first-level tactile imagery-perception data provided by Timo

### 03 eeg MMN
- Single-subject EEG preprocessing, ERP, and time-frequency analysis based on the [Mismatch Negativity](https://www.fil.ion.ucl.ac.uk/spm/data/eeg_mmn/) dataset from the SPM manual

### references
- SPM manual: https://www.fil.ion.ucl.ac.uk/spm/doc/spm12_manual.pdf<br>
- Flexible factorical design: https://www.nemotos.net/resources/conweights.pdf
- BIDS specification: https://bids-specification.readthedocs.io/en/stable/
