% Create a master structure and make primary plots
% Lai Wei
% Jul/25/2022 

% convertIDP();
% cd G:\'Other computers'\Lab\'Maunsell Lab'\Thesis\IDPsych
% fileList = dir('**\*.mat');
cd '/Users/laiwei/Desktop/Maunsell Lab/Thesis/IDPsych/'
fileList = dir('**/*.mat');

% Pull out data from a range of dates
% Date put in as a three-element datetime: (YYYY, (M)M, (D)D)
startDate = datetime(2022, 9, 28);
endDate = datetime(2022, 12, 8);

% Use the data from certain groups of subjects
fileList(~contains({fileList(:).folder}, '20')) = [];
% Use the data files only
fileList(contains({fileList(:).name}, 'Info')) = [];
fileList(~contains({fileList(:).name}, '20')) = [];

% Remove subjects and dates not qualified
removedSubjects = ["202", "401", "407"];
for sj = 1:length(removedSubjects)
    fileList(contains({fileList(:).folder}, removedSubjects(sj))) = [];
end

% Get the indices of the files to be removed
toRemove = [];
for fi = 1:length(fileList)
    name = split(fileList(fi).name, '-');

    % Use the date of experiment instead of the date of converting ans
    % saving the file
    fileList(fi).date = string(join(name(1:3), '-'));

    if ~isbetween(datetime(str2double(name{1}), str2double(name{2}), str2double(name{3})), ...
                  startDate, endDate)
        toRemove = [toRemove, fi];
    end
end
fileList(toRemove) = [];


nFiles = length(fileList);
IDPsychTrials = struct;
allStaircase = zeros(nFiles, 100);
% Create the master structure for all data from all subjects
for fi = 1:nFiles
    if ~strcmp(pwd, fileList(fi).folder)
        cd(fileList(fi).folder)
    end
    IDPsychTrials(fi).name = fileList(fi).name;
    
    IDPsychTrials(fi).subjectNo = str2double(extract(fileList(fi).folder, ...
                                             digitsPattern + textBoundary));
    load(fileList(fi).name);
    IDPsychTrials(fi).nTrials = length(trials);
    % taskMode: task for current session
    % 0 for Dec and 1 for Inc
    IDPsychTrials(fi).taskMode = trials(1).trial.taskMode;

    % stairType: 0 for joint staircase
    IDPsychTrials(fi).stairType = trials(1).trial.stairType;
    IDPsychTrials(fi).frameRateHz = file.frameRateHz.data;
    IDPsychTrials(fi).baseCohPC = trials(1).trial.baseCohPC;

    % behavioral settings 
    IDPsychTrials(fi).behavSettings.baseDurMS = trials(1).trial.baseDurMS;
    IDPsychTrials(fi).behavSettings.stepDurMS = trials(1).trial.stepDurMS;
    IDPsychTrials(fi).behavSettings.revBeforeChange = 6;
    IDPsychTrials(fi).behavSettings.maxStepPC = trials(1).trial.threshStepsPC;
    IDPsychTrials(fi).behavSettings.minStepPC = trials(end).trial.threshStepsPC;
    IDPsychTrials(fi).behavSettings.stepChangeFactor = .5;

    % dot settings
    IDPsychTrials(fi).dotSettings.azimuthDeg = trials(1).randomDots.azimuthDeg;
    IDPsychTrials(fi).dotSettings.elevationDeg = trials(1).randomDots.elevationDeg;
    IDPsychTrials(fi).dotSettings.radiusDeg = trials(1).randomDots.radiusDeg;
    IDPsychTrials(fi).dotSettings.densityDPD = trials(1).randomDots.density;
    IDPsychTrials(fi).dotSettings.directionDeg = trials(1).randomDots.directionDeg;
    IDPsychTrials(fi).dotSettings.diameterDeg = trials(1).randomDots.dotDiameterDeg;
    IDPsychTrials(fi).dotSettings.speedDPS = trials(1).randomDots.speedDPS;
    IDPsychTrials(fi).dotSettings.lifeFrames = trials(1).randomDots.lifeFrames;
    for tr = 1:length(trials)
        % trialCertify: only trials coded as "0" should be collected
        IDPsychTrials(fi).trials(tr).trialCertify = trials(tr).trialCertify;

        % eodCode: 0 for hit, 1 for miss
        IDPsychTrials(fi).trials(tr).eotCode = trials(tr).eotCode;

        % stepDir: task for current trial (should be the same through out
        % the session if it is not bidirectional)
        % 0 for Dec and 1 for Inc

        IDPsychTrials(fi).trials(tr).stepDir = trials(tr).trial.stepDir;

        % changeLoc: specifies on which side the change happens
        % 0 for Left and 1 for Right
        IDPsychTrials(fi).trials(tr).changeLoc = trials(tr).trial.changeLoc;
        IDPsychTrials(fi).trials(tr).stepSize = trials(tr).trial.threshStepsPC;
        IDPsychTrials(fi).trials(tr).trialCohPC = trials(tr).trial.stepCohPC;
    end    
    testCertify = ([IDPsychTrials(fi).trials(:).trialCertify] == 0) .* ...
                  (([IDPsychTrials(fi).trials(:).eotCode] == 0) + ([IDPsychTrials(fi).trials(:).eotCode] == 1));
    % test if a trial is certified: trialCertify should be 0, and the
    % eotCode should be either 0 or 1
    allStaircase(fi,:) = [IDPsychTrials(fi).trials(testCertify == 1).trialCohPC];
    IDPsychTrials(fi).thresholdPC = abs(trials(end).trial.stepCohPC - trials(1).trial.baseCohPC);
    IDPsychTrials(fi).totalHitPC = length(find([IDPsychTrials(fi).trials(testCertify == 1).eotCode] == 0));
    % add bias
    trialStruct = [trials(testCertify == 1).trial];
    IDPsychTrials(fi).rightChangesPC = sum([trialStruct(:).changeLoc]) ./ length([trialStruct(:).changeLoc]) * 100;
    IDPsychTrials(fi).rightResponsePC = (sum([trialStruct(:).changeLoc] == 1 & [trials(testCertify == 1).eotCode] == 0) + ...
                                        sum([trialStruct(:).changeLoc] == 0 & [trials(testCertify == 1).eotCode] == 1)) / ...
                                        length([trialStruct(:).changeLoc]) * 100;
    IDPsychTrials(fi).rightBiasPC = IDPsychTrials(fi).rightResponsePC - IDPsychTrials(fi).rightChangesPC;
end

% Add the day of experiment for testing learning effects
sjID = unique([IDPsychTrials(:).subjectNo]);

nSubjects = length(sjID);
for sj = 1:nSubjects
    expDays = string(unique([fileList([IDPsychTrials(:).subjectNo] == sjID(sj)).date]));
    for fi = find([IDPsychTrials(:).subjectNo] == sjID(sj))    
        IDPsychTrials(fi).dayOfExp = find(fileList(fi).date == expDays);
    end
end

% cd G:\'Other computers'\Lab\'Maunsell Lab'\Thesis\IDPsych\'Matlab Code'
cd '/Users/laiwei/Desktop/Maunsell Lab/Thesis/IDPsych/Matlab Code'
%% Make some plots
rng(1);


% Bar plot with grouped scatter plots
allThresholds = [IDPsychTrials(:).thresholdPC]';
IncThresholds = [IDPsychTrials([IDPsychTrials(:).taskMode] == 1).thresholdPC]';
DecThresholds = [IDPsychTrials([IDPsychTrials(:).taskMode] == 0).thresholdPC]' ;
IncThreholdsMean = mean(IncThresholds);
IncThresholdsSEM = std(IncThresholds) / sqrt(length(IncThresholds));
DecThresholdsMean = mean(DecThresholds);
DecThresholdsSEM = std(DecThresholds) / sqrt(length(DecThresholds));

figure(1);
clf;
bar(1:2, [IncThreholdsMean, DecThresholdsMean]);
hold on

for sj = 1:nSubjects
    currsjInc = find(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
                     ([IDPsychTrials(:).taskMode] == 1));
    currsjDec = find(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
                     ([IDPsychTrials(:).taskMode] == 0));
    X = [ones(size(allThresholds(currsjInc))); 2*ones(size(allThresholds(currsjDec)))];  
    X = X + 0.08*randn(size(X));
    scatter(X, [allThresholds(currsjInc); allThresholds(currsjDec)], 'filled');
    hold on
end
er = errorbar(1:2, [IncThreholdsMean, DecThresholdsMean], ...
              [IncThresholdsSEM, DecThresholdsSEM], ...
              'LineStyle','none','Color','k');
er.Annotation.LegendInformation.IconDisplayStyle = 'off';
ylim([0 50]);
xticklabels({'Inc','Dec'});
ylabel('Average Threshold');
legend(["Mean", cellstr(categorical(sjID))]);
title('IDPsych');

% Calculate variances
fprintf('Inc Mean = %.2f%%\n', IncThreholdsMean);
fprintf('Dec Mean = %.2f%%\n', DecThresholdsMean);
fprintf('Total Std = %.2f%%\n', std(allThresholds));

% Get the mean and variance for each subject, and create a scatter plot 
% against the diagonal line

SumTable = table(sjID', zeros(length(sjID), 2), zeros(length(sjID), 1), ...
                 zeros(length(sjID), 2), zeros(length(sjID), 1), zeros(length(sjID), 1));
SumTable.Properties.VariableNames = ["Subject No.", "Inc Mean and SEM (%)", "Inc N", ... 
                      "Dec Mean and SEM (%)", "Dec N", "p-value"];
figure(2);
clf;
for sj = 1:length(sjID)
    currsjInc = find(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
                     ([IDPsychTrials(:).taskMode] == 1));
    currsjDec = find(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
                     ([IDPsychTrials(:).taskMode] == 0));
    currIncMean = mean(allThresholds(currsjInc));
    currIncSEM = std(allThresholds(currsjInc)) / sqrt(length(currsjInc));
    currDecMean = mean(allThresholds(currsjDec));
    currDecSEM = std(allThresholds(currsjDec)) / sqrt(length(currsjDec));
    [~, pOnetail] = ttest2(allThresholds(currsjInc), allThresholds(currsjDec), "Tail", "left");
    SumTable(sj,:) = {sjID(sj), [currIncMean, currIncSEM], length(currsjInc), ...
                      [currDecMean, currDecSEM], length(currsjDec), pOnetail};   
    scatter(currIncMean, currDecMean, 100, 'filled');
    hold on
    % 2*SEM for ~95% confidence interval
    er = errorbar(currIncMean, currDecMean, 2*currDecSEM, 2*currDecSEM, 2*currIncSEM, ...
                  2*currIncSEM);
    er.LineStyle = ':';
    er.Color = 'k';
    er.Annotation.LegendInformation.IconDisplayStyle = 'off';
end
plot([0 50], [0 50], ':k');
axis([0 50 0 50]);
legend(cellstr(categorical(sjID)));
xlabel('Increment Thresholds (%)');
ylabel('Decrement Thresholds (%)');

disp(SumTable);

% Plot the histogram of hit rates
figure(3);
clf;
for sj = 1:nSubjects
    subplot(nSubjects, 1, sj);
    histogram([IDPsychTrials(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
             ([IDPsychTrials(:).taskMode] == 1) == 1).totalHitPC], 5); % Inc
    hold on
    histogram([IDPsychTrials(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
             ([IDPsychTrials(:).taskMode] == 0) == 1).totalHitPC], 5); % Dec
    title(['Subject ', num2str(sjID(sj))]);
end
ax = axes(figure(3), "Visible", "off");
ax.Title.Visible = "on";
ax.XLabel.Visible = "on";
ax.YLabel.Visible = "on";
xlabel(ax, "Thresholds");
ylabel(ax, "Count");
sgtitle("Histograms for Hit Rates");

% Plot the average staircases
% Also calculated mean/std/SEM for each subject

figure(4);
clf;
for sj = 1:nSubjects
    IncStaircase = allStaircase((([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ([IDPsychTrials(:).taskMode] == 1)) == 1, :);
    DecStaircase = allStaircase((([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ([IDPsychTrials(:).taskMode] == 0)) == 1, :);
    IncStaircaseMean = mean(IncStaircase);
    IncStaircaseStd = std(IncStaircase);
    IncStaircaseSEM = IncStaircaseStd / sqrt(size(IncStaircase, 1));
    DecStaircaseMean = mean(DecStaircase);
    DecStaircaseStd = std(DecStaircase);
    DecStaircaseSEM = DecStaircaseStd / sqrt(size(DecStaircase, 1));
    
    subplot(nSubjects, 1, sj);
    plot(1:100, IncStaircaseMean, '-', 'Color', '#77AC30');
    hold on
    patch([1:100, fliplr(1:100)], ...
          [IncStaircaseMean + IncStaircaseSEM, fliplr(IncStaircaseMean - IncStaircaseSEM)], ...
          [0.4660 0.6740 0.1880], ...
          'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on
    plot(1:100, DecStaircaseMean, '-', 'Color', '#D95319');
    hold on
    patch([1:100, fliplr(1:100)], ...
          [DecStaircaseMean + DecStaircaseSEM, fliplr(DecStaircaseMean - DecStaircaseSEM)], ...
          [0.8500 0.3250 0.0980], ...
          'FaceAlpha', 0.3, 'EdgeColor', 'none');
    hold on
    plot([0 100], [50 50], ':k');
    axis([0 100 0 100]);

    % Write the average thresholds (mean pm std)
    text(70,85, {['Inc (mean ', char(177), ' std):'], ...
                 [num2str(IncStaircaseMean(100) - 50, 3), '% ' char(177), ...
                 ' ', num2str(IncStaircaseStd(100),2), '%'], ...
                 ['n = ', num2str(size(IncStaircase, 1))]});
    text(70,40, {['Dec (mean ', char(177), ' std):'], ...
                 [num2str(50 - DecStaircaseMean(100), 3), '% ' char(177), ...
                 ' ', num2str(DecStaircaseStd(100),2), '%'], ...
                 ['n = ', num2str(size(DecStaircase, 1))]});
    title(['Subject ', num2str(sjID(sj))]);
end
ax = axes(figure(4), "Visible", "off");
ax.Title.Visible = "on";
ax.XLabel.Visible = "on";
ax.YLabel.Visible = "on";
xlabel(ax, 'Trial Number');
ylabel(ax, 'Coherence (%)');
sgtitle('Averaged Inc/Dec Staircases');


% Histograms for each subject
figure(5)
for sj = 1:nSubjects
    subplot(nSubjects,1,sj);
%     btstrap = zeros(1000,2);
%     currsjInc = allThresholds(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
%         ([IDPsychTrials(:).taskMode] == 1) == 1);
%     currsjDec = allThresholds(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
%         ([IDPsychTrials(:).taskMode] == 0) == 1);
%     btstrap(:, 1) = currsjInc(randi(length(currsjInc), 1000, 1));
%     btstrap(:, 2) = currsjDec(randi(length(currsjDec), 1000, 1));
%     histogram(btstrap(:, 1), 10);
%     hold on
%     histogram(btstrap(:, 2), 10);
    histogram(allThresholds(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
        ([IDPsychTrials(:).taskMode] == 1) == 1)); % Inc
    hold on
    histogram(allThresholds(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
        ([IDPsychTrials(:).taskMode] == 0) == 1)); % Dec
    title(['Subject ', num2str(sjID(sj))]);
end
ax = axes(figure(5), "Visible", "off");
ax.Title.Visible = "on";
ax.XLabel.Visible = "on";
ax.YLabel.Visible = "on";
xlabel(ax, "Thresholds");
ylabel(ax, "Count");
sgtitle("Histograms for IDP Thresholds");



% Psychological learning
figure(6);
for sj = 1:nSubjects
    subplot(nSubjects, 1, sj);
    sjAllSessions = find([IDPsychTrials(:).subjectNo] == sjID(sj));
    sjIncSessions = sjAllSessions([IDPsychTrials(sjAllSessions).taskMode] == 1);
    sjDecSessions = sjAllSessions([IDPsychTrials(sjAllSessions).taskMode] == 0);
    days = unique([IDPsychTrials(sjAllSessions).dayOfExp]);
    col = hsv(50*length(days));
    for d = days
        X1 = find([IDPsychTrials(sjIncSessions).dayOfExp] == d);
        scatter(X1, [IDPsychTrials(sjIncSessions(X1)).thresholdPC] + [IDPsychTrials(sjIncSessions(X1)).baseCohPC], ...
                10, col(50*d-25, :), 'filled');
        hold on
        X2 = find([IDPsychTrials(sjDecSessions).dayOfExp] == d);
        scatter(X2, [IDPsychTrials(sjDecSessions(X2)).baseCohPC] - [IDPsychTrials(sjDecSessions(X2)).thresholdPC], ...
                10, col(50*d-25, :), 'filled');
        hold on      
    end
    plot([1 max(max(X1), max(X2))], [50 50], ':k');
    ylim([0 100]);
    title(['Subject ', num2str(sjID(sj))]);
end
ax = axes(figure(6), "Visible", "off");
ax.Title.Visible = "on";
ax.XLabel.Visible = "on";
ax.YLabel.Visible = "on";
xlabel(ax, 'Session No.');
ylabel(ax, 'Threshold (%)');


% Psychological learning (per day)
figure(7);
for sj = 1:length(sjID(1:5))
    subplot(5, 1, sj);
    sjAllSessions = find([IDPsychTrials(:).subjectNo] == sjID(sj));
    sjIncSessions = sjAllSessions([IDPsychTrials(sjAllSessions).taskMode] == 1);
    sjDecSessions = sjAllSessions([IDPsychTrials(sjAllSessions).taskMode] == 0);
    days = unique([IDPsychTrials(sjAllSessions).dayOfExp]);
    nDays = length(days) / 2;
    sjPsyLearnMean = zeros(2, nDays);
    sjPsyLearnSEM = zeros(2, nDays);
    for d = 1:nDays
        currDayInc = [IDPsychTrials(sjIncSessions((5*d-4):(5*d))).thresholdPC];
        currDayDec = [IDPsychTrials(sjDecSessions((5*d-4):(5*d))).thresholdPC];
        sjPsyLearnMean(1, d) = mean(currDayInc);
        sjPsyLearnMean(2, d) = mean(currDayDec);
        sjPsyLearnSEM(1, d) = std(currDayInc) / sqrt(length(currDayInc));
        sjPsyLearnSEM(2, d) = std(currDayDec) / sqrt(length(currDayDec));
    end
    plot(1:nDays, sjPsyLearnMean(1,:));
    hold on
    plot(1:nDays, sjPsyLearnMean(2,:));
    hold on
    er1 = errorbar(1:nDays, sjPsyLearnMean(1,:), sjPsyLearnSEM(1,:), sjPsyLearnSEM(1,:));
    er1.LineStyle = ':';
    er1.Color = 'k';
    er1.Annotation.LegendInformation.IconDisplayStyle = 'off';
    hold on 
    er2 = errorbar(1:nDays, sjPsyLearnMean(2,:), sjPsyLearnSEM(2,:), sjPsyLearnSEM(2,:));
    er2.LineStyle = ':';
    er2.Color = 'k';
    er2.Annotation.LegendInformation.IconDisplayStyle = 'off';
    xlim([0,4]);
    ylim([0 50]);
    xticks([1:3]);
    xticklabels([1:3]);
    title(['Subject ', num2str(sjID(sj))]);
end
ax = axes(figure(7), "Visible", "off");
ax.Title.Visible = "on";
ax.XLabel.Visible = "on";
ax.YLabel.Visible = "on";
xlabel(ax, 'Day No.');
ylabel(ax, 'Threshold (%)');



