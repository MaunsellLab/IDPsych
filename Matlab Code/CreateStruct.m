% Create a master structure
% Lai Wei
% Jul/25/2022

convertIDP();
cd D:\Research\IDPsych_Project\IDPsych\Subjects\
fileList = dir('**\*.mat');

% Pull out data from a range of dates
% Date put in as a three-element datetime: (YYYY, (M)M, (D)D)
startDate = datetime(2022, 7, 21);
endDate = datetime(2022, 8, 4);

% Use the data files only
fileList(contains({fileList(:).name}, 'Info')) = [];

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

% % subFolders = unique({fileList(:).folder});
% % for fd = 1:length(subFolders)
% %     addpath(subFolders{fd});
% % end


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
    IDPsychTrials(fi).dotSettings.azimuthDeg = trials(1).randomDots.azimuthDeg;
    IDPsychTrials(fi).dotSettings.densityDPD = trials(1).randomDots.density;
    IDPsychTrials(fi).dotSettings.directionDeg = trials(1).randomDots.directionDeg;
    IDPsychTrials(fi).dotSettings.diameterDeg = trials(1).randomDots.dotDiameterDeg;
    IDPsychTrials(fi).dotSettings.speedDPS = trials(1).randomDots.speedDPS;
    IDPsychTrials(fi).dotSettings.lifeFrames = trials(1).randomDots.lifeFrames;

    for tr = 1:length(trials)
        % trialCertify: only trials coded as "0" should be collected
        IDPsychTrials(fi).trials(tr).trialCertify = trials(tr).trialCertify;

        % eodCode: 0 for hit, 1 for miss, 3 for
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
    % eodCode should be either 0 or 1
    allStaircase(fi,:) = [IDPsychTrials(fi).trials(testCertify == 1).trialCohPC];

    IDPsychTrials(fi).thresholdPC = abs(trials(end).trial.stepCohPC - trials(1).trial.baseCohPC);

    % add bias
    trialStruct = [trials(:).trial];
    IDPsychTrials(fi).rightChangesPC = sum([trialStruct(:).changeLoc]) ./ length([trialStruct(:).changeLoc]) * 100;
    IDPsychTrials(fi).rightResponsePC = (sum([trialStruct(:).changeLoc] == 1 & [trials(:).eotCode] == 0) + ...
                                        sum([trialStruct(:).changeLoc] == 0 & [trials(:).eotCode] == 1)) / ...
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


cd D:\Research\IDPsych_Project\IDPsych\'Matlab Code'
%% Make some plots

% Bar plot with grouped scatter plots
rng(1);

allThresholds = [IDPsychTrials(:).thresholdPC]';
IncThresholds = [IDPsychTrials([IDPsychTrials(:).taskMode] == 1).thresholdPC]';
DecThresholds = [IDPsychTrials([IDPsychTrials(:).taskMode] == 0).thresholdPC]' ;
IncThreholdsMean = mean(IncThresholds);
IncThresholdsSEM = std(IncThresholds) / sqrt(length(IncThresholds));
DecThresholdsMean = mean(DecThresholds);
DecThresholdsSEM = std(DecThresholds) / sqrt(length(DecThresholds));

% Calculate variances
fprintf('Inc Mean = %.2f%%\n', IncThreholdsMean);
fprintf('Dec Mean = %.2f%%\n', DecThresholdsMean);
fprintf('Total Std = %.2f%%\n', std(allThresholds));



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

% Scatter plot against the diagonal line
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
ylabel('Decrement Thresholds (%)' );



% Plot the average staircases
% Also calculated mean/std/SEM for each subject

figure(3);
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
ax = axes(figure(3), "Visible", "off");
ax.Title.Visible = "on";
ax.XLabel.Visible = "on";
ax.YLabel.Visible = "on";
xlabel(ax, 'Trial Number');
ylabel(ax, 'Coherence (%)');
sgtitle('Averaged Inc/Dec Staircases');


% Histograms for each subject
figure(4)
for sj = 1:nSubjects
    subplot(3,1,sj);
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
ax = axes(figure(4), "Visible", "off");
ax.Title.Visible = "on";
ax.XLabel.Visible = "on";
ax.YLabel.Visible = "on";
xlabel(ax, "Thresholds");
ylabel(ax, "Count");
sgtitle("Histograms for IDP Thresholds");



% Psychological learning
figure(5);

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
                10, col(50*d, :), 'filled');
        hold on
        X2 = find([IDPsychTrials(sjDecSessions).dayOfExp] == d);
        scatter(X2, [IDPsychTrials(sjDecSessions(X2)).baseCohPC] - [IDPsychTrials(sjDecSessions(X2)).thresholdPC], ...
                10, col(50*d, :), 'filled');
        hold on      
    end
    plot([1 max(max(X1), max(X2))], [50 50], ':k');
    ylim([0 100]);
    title(['Subject ', num2str(sjID(sj))]);
end
ax = axes(figure(5), "Visible", "off");
ax.Title.Visible = "on";
ax.XLabel.Visible = "on";
ax.YLabel.Visible = "on";
xlabel(ax, 'Session No.');
ylabel(ax, 'Threshold (%)');

