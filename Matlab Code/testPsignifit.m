longTrials = load("longTrials.mat");
longTrials = longTrials.IDPsychTrials;
primaryTrials = load("primaryTrials.mat");
primaryTrials = primaryTrials.IDPsychTrials;
controlTrials = load("controlTrials.mat");
controlTrials = controlTrials.IDPsychTrials;

longThresh = zeros(length(longTrials) / 2, 2);
primaryThresh = zeros(length(primaryTrials) / 2, 2);
controlThresh = zeros(length(controlTrials), 1);                            % All increment trials


longConfDiff = zeros(length(longTrials) / 2, 2);

totalInc = 0;
totalDec = 0;

for se = 1:length(longTrials)
    trialCoh = round([longTrials(se).trials([longTrials(se).trials(:).trialCertify] == 0).trialCohPC]);
    eotCode = [longTrials(se).trials([longTrials(se).trials(:).trialCertify] == 0).eotCode];
    levels = unique(trialCoh);
    data = [levels', zeros(length(levels), 1), zeros(length(levels), 1)];
    
    for lv = 1:length(levels)
        data(lv, 2) = length(find((trialCoh == levels(lv)) & (eotCode == 0)));
        data(lv, 3) = length(find(trialCoh == levels(lv)));
    end
    
    data(:,1) = abs(50 - data(:,1));
    
    % cd 'G:\Other computers\Lab\Maunsell Lab\Thesis\psignifit'
    cd '/Users/laiwei/Desktop/Maunsell Lab/Thesis/psignifit'
    
    options = struct;
    options.expType='2AFC';
    options.sigmoidName = 'norm';
    options.threshPC  = .588;
    options.stimulusRange = [0 50];
    
    result = psignifit(data,options);

    if longTrials(se).taskMode == 1
        totalInc = totalInc + 1;
        longThresh(totalInc, 1) = result.Fit(1);
        longConfDiff(totalInc, 1) = (result.conf_Intervals(1, 2, 3) - result.conf_Intervals(1, 1, 3)) / result.Fit(1);
    else
        totalDec = totalDec + 1;
        longThresh(totalDec, 2) = result.Fit(1);
        longConfDiff(totalDec, 2) = (result.conf_Intervals(1, 2, 3) - result.conf_Intervals(1, 1, 3)) / result.Fit(1);
    end

end

%%
totalInc = 0;
totalDec = 0;
for se = 1:length(primaryTrials)
    trialCoh = round([primaryTrials(se).trials([primaryTrials(se).trials(:).trialCertify] == 0).trialCohPC]);
    eotCode = [primaryTrials(se).trials([primaryTrials(se).trials(:).trialCertify] == 0).eotCode];
    levels = unique(trialCoh);
    data = [levels', zeros(length(levels), 1), zeros(length(levels), 1)];
    
    for lv = 1:length(levels)
        data(lv, 2) = length(find((trialCoh == levels(lv)) & (eotCode == 0)));
        data(lv, 3) = length(find(trialCoh == levels(lv)));
    end
    
    data(:,1) = abs(50 - data(:,1));
    
    % cd 'G:\Other computers\Lab\Maunsell Lab\Thesis\psignifit'
    cd '/Users/laiwei/Desktop/Maunsell Lab/Thesis/psignifit'
    
    options = struct;
    options.expType='2AFC';
    options.sigmoidName = 'norm';
    options.threshPC  = .588;
    options.stimulusRange = [0 50];
    
    result = psignifit(data,options);

    if primaryTrials(se).taskMode == 1
        totalInc = totalInc + 1;
        primaryThresh(totalInc, 1) = result.Fit(1);
    else
        totalDec = totalDec + 1;
        primaryThresh(totalDec, 2) = result.Fit(1);
    end

end
%%

for se = 1:length(controlTrials)
    trialCoh = round([controlTrials(se).trials([controlTrials(se).trials(:).trialCertify] == 0).trialCohPC]);
    eotCode = [controlTrials(se).trials([controlTrials(se).trials(:).trialCertify] == 0).eotCode];
    levels = unique(round(trialCoh));
    data = [levels', zeros(length(levels), 1), zeros(length(levels), 1)];
    
    for lv = 1:length(levels)
        data(lv, 2) = length(find((trialCoh == levels(lv)) & (eotCode == 0)));
        data(lv, 3) = length(find(trialCoh == levels(lv)));
    end
    
    baseCoh = controlTrials(se).baseCohPC;
    data(:,1) = abs(baseCoh - data(:,1));
    
    % cd 'G:\Other computers\Lab\Maunsell Lab\Thesis\psignifit'
    % cd '/Users/laiwei/Desktop/Maunsell Lab/Thesis/psignifit'
    
    options = struct;
    options.expType='2AFC';
    options.sigmoidName = 'norm';
    options.threshPC  = .588;
    options.stimulusRange = [0 50];
    
    result = psignifit(data,options);
    controlThresh(se, 1) = result.Fit(1);
    
end

%% Test 77 (204_Dec_7) and 113 (205_Inc_13)
test = 27;

trialCoh = round([longTrials(test).trials([longTrials(test).trials(:).trialCertify] == 0).trialCohPC]);
eotCode = [longTrials(test).trials([longTrials(test).trials(:).trialCertify] == 0).eotCode];
levels = unique(round(trialCoh));
data = [levels', zeros(length(levels), 1), zeros(length(levels), 1)];
    
for lv = 1:length(levels)
    data(lv, 2) = length(find((trialCoh == levels(lv)) & (eotCode == 0)));
    data(lv, 3) = length(find(trialCoh == levels(lv)));
end
    
baseCoh = longTrials(se).baseCohPC;
data(:,1) = abs(baseCoh - data(:,1));
    
% cd 'G:\Other computers\Lab\Maunsell Lab\Thesis\psignifit'
 cd '/Users/laiwei/Desktop/Maunsell Lab/Thesis/psignifit'
    
options = struct;
options.expType='2AFC';
options.sigmoidName = 'norm';
options.threshPC  = .588;
options.stimulusRange = [0 50];
    
result = psignifit(data,options);
plotPsych(result);