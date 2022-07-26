



cd D:\Research\IDPsych_Project\IDPsych\101
fileList = dir("*.mat");
startDate = '2022-07-21';
endDate = '2022-07-22';
fileList(1:find(contains({fileList(:).name},startDate) == 1, 1)-1) = [];
fileList(find(contains({fileList(:).name},endDate) == 1, 1, 'last')+1:length(fileList)) = [];
fileList(contains({fileList(:).name}, 'Info')) = [];

IDPsychTrials = struct;
nFiles = length(fileList);

for fi = 1:nFiles
    IDPsychTrials(fi).name = fileList(fi).name;
    load(fileList(fi).name);
    IDPsychTrials(fi).nTrials = length(trials);
    IDPsychTrials(fi).taskMode = trials(1).trial.taskMode;
    % 1 for Inc and 0 for Dec
    IDPsychTrials(fi).stairType = trials(1).trial.stairType;
    IDPsychTrials(fi).baseCohPC = trials(1).trial.baseCohPC;
    IDPsychTrials(fi).baseDurMS = trials(1).trial.baseDurMS;
    IDPsychTrials(fi).stepDurMS = trials(1).trial.stepDurMS;
    for tr = 1:length(trials)
        IDPsychTrials(fi).trials(tr).trialCertify = trials(tr).trialCertify;
        IDPsychTrials(fi).trials(tr).eodCode = trials(tr).eotCode;
        IDPsychTrials(fi).trials(tr).stepDir = trials(tr).trial.stepDir;
        IDPsychTrials(fi).trials(tr).changeLoc = trials(tr).trial.changeLoc;
        IDPsychTrials(fi).trials(tr).stepSize = trials(tr).trial.threshStepsPC;
        IDPsychTrials(fi).trials(tr).trialCohPC = trials(tr).trial.stepCohPC;
    end
    IDPsychTrials(fi).thresholdPC = abs(trials(length(trials)).trial.stepCohPC - trials(1).trial.baseCohPC);
end

cd D:\Research\IDPsych_Project\IDPsych\'Matlab Code'
%%

IncThresholds = [IDPsychTrials([IDPsychTrials(:).taskMode] == 1).thresholdPC]';
DecThresholds = [IDPsychTrials([IDPsychTrials(:).taskMode] == 0).thresholdPC]' ;
IncMean = mean(IncThresholds);
IncSEM = std(IncThresholds) / sqrt(length(IncThresholds));
DecMean = mean(DecThresholds);
DecSEM = std(DecThresholds) / sqrt(length(DecThresholds));


figure(1);
clf;
bar(1:2, [IncMean, DecMean]);
hold on
er = errorbar(1:2, [IncMean, DecMean], ...
              [IncSEM, DecSEM], ...
              'LineStyle','none','Color','k');
er.Annotation.LegendInformation.IconDisplayStyle = 'off';
hold on
X = [ones(size(IncThresholds)); 2*ones(size(DecThresholds))];
X = X + 0.08*randn(size(X));
scatter(X, [IncThresholds; DecThresholds], 'filled');
xticklabels({'Inc','Dec'});
ylabel('Average Threshold');
title('Subject 101');

