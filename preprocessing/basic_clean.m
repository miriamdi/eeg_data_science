function EEG = basic_clean(params, EEG)

raw_EEG = EEG;

%downsample data
if EEG.srate>300
    EEG = pop_resample(EEG, params.eeg.down_srate);
end
EEG = eeg_checkset(EEG);

% reject the start of the recording
EEG = eeg_eegrej(EEG, [1 params.eeg.rej_time*EEG.srate]);
EEG = eeg_checkset(EEG);

% Clean the electricity line frequency
EEG = pop_cleanline(EEG, ...
    'linefreqs', params.eeg.linefreqs, ...
    'computepower', 0, ...
    'VerboseOutput',0);
EEG = eeg_checkset(EEG);

% Filter the data
EEG = pop_eegfiltnew(EEG, params.eeg.highpass, params.eeg.lowpass);
EEG = eeg_checkset(EEG);

% Rereference the data to average reference:
EEG = pop_reref(EEG, []);
EEG = eeg_checkset(EEG);

% add locaion
EEG = pop_chanedit(EEG, 'lookup', fullfile(params.paths.eeglab , params.eeg.chanlocs ));
EEG = eeg_checkset( EEG );

% remove bad channels & interpulate [ASR]
EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
EEG = eeg_checkset( EEG );

EEG = pop_interp(EEG, raw_EEG.chanlocs, 'spherical');
EEG = eeg_checkset( EEG );

pop_saveset(EEG, ...
    'filename', fname, ...
    'filepath', params.paths.pre_dir);

end