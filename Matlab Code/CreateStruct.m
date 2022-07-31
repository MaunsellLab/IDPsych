% Create a master structure
% Lai Wei
% Jul/25/2022

% convertIDP();
cd D:\Research\IDPsych_Project\IDPsych
fileList = dir('**\*.mat');

% Pull out data from a range of dates
% Date put in as a three-element vector: [YYYY, (M)M, (D)D]
startDate = [2022, 7, 21];
endDate = [2022, 7, 27];

% Use the data files only
fileList(contains({fileList(:).name}, 'Info')) = [];

% Get the indices of the files to be removed
toRemove = [];
for fi = 1:length(fileList)
    name = split(fileList(fi).name, '-');
    if str2double(name{1}) < startDate(1) || str2double(name{1}) > endDate(1)
        toRemove = [toRemove, fi];
    elseif str2double(name{2}) < startDate(2) || str2double(name{2}) > endDate(2)
        toRemove = [toRemove, fi];
    elseif str2double(name{3}) < startDate(3) || str2double(name{3}) > endDate(3)
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

    IDPsychTrials(fi).baseCohPC = trials(1).trial.baseCohPC;
    IDPsychTrials(fi).baseDurMS = trials(1).trial.baseDurMS;
    IDPsychTrials(fi).stepDurMS = trials(1).trial.stepDurMS;
    for tr = 1:length(trials)

        % trialCertify: only trials coded as "0" should be collected
        IDPsychTrials(fi).trials(tr).trialCertify = trials(tr).trialCertify;

        % eodCode: 0 for hit, 1 for miss, 3 for
        IDPsychTrials(fi).trials(tr).eodCode = trials(tr).eotCode;

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
                  (([IDPsychTrials(fi).trials(:).eodCode] == 0) + ([IDPsychTrials(fi).trials(:).eodCode] == 1));
    % test if a trial is certified: trialCertify should be 0, and the
    % eodCode should be either 0 or 1
    allStaircase(fi,:) = [IDPsychTrials(fi).trials(testCertify == 1).trialCohPC];

    IDPsychTrials(fi).thresholdPC = abs(trials(length(trials)).trial.stepCohPC - trials(1).trial.baseCohPC);
    
end

cd D:\Research\IDPsych_Project\IDPsych\'Matlab Code'
%% Make some plots

% Bar plot with grouped scatter plots
allThresholds = [IDPsychTrials(:).thresholdPC]';
IncThresholds = [IDPsychTrials([IDPsychTrials(:).taskMode] == 1).thresholdPC]';
DecThresholds = [IDPsychTrials([IDPsychTrials(:).taskMode] == 0).thresholdPC]' ;
IncThreholdsMean = mean(IncThresholds);
IncThresholdsSEM = std(IncThresholds) / sqrt(length(IncThresholds));
DecThresholdsMean = mean(DecThresholds);
DecThresholdsSEM = std(DecThresholds) / sqrt(length(DecThresholds));
sjID = unique([IDPsychTrials(:).subjectNo]);

figure(1);
clf;
bar(1:2, [IncThreholdsMean, DecThresholdsMean]);
hold on

for sj = 1:length(sjID)
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

% % Grouped scatter plot against the diagonal line
% figure(2);
% clf;
% for sj = 1:length(sjID)
%     currsjInc = find(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
%                      ([IDPsychTrials(:).taskMode] == 1));
%     currsjDec = find(([IDPsychTrials(:).subjectNo] == sjID(sj)) .* ...
%                      ([IDPsychTrials(:).taskMode] == 0));
%     scatter(allThresholds(currsjInc),allThresholds(currsjDec), 'filled');
%     alpha(.5);
%     hold on
% end
% plot([0 50], [0 50], ':k');
% axis([0 50 0 50]);
% xlabel('Increment Thresholds');
% ylabel('Decrement Thresholds');
% legend(cellstr(categorical(sjID)));


% % Plot the average staircases
% % for subject 101 only - 072722
% IncStaircase = allStaircase([IDPsychTrials(1:20).taskMode] == 1, :);
% DecStaircase = allStaircase([IDPsychTrials(1:20).taskMode] == 0, :);
% IncStaircaseMean = mean(IncStaircase);
% IncStaircaseSEM = std(IncStaircase) / sqrt(size(IncStaircase, 1));
% DecStaircaseMean = mean(DecStaircase);
% DecStaircaseSEM = std(DecStaircase) / sqrt(size(DecStaircase, 1));
% 
% figure(3);
% clf;
% plot(1:100, IncStaircaseMean, '-', 'Color', '#77AC30');
% hold on
% patch([1:100, fliplr(1:100)], ...
%       [IncStaircaseMean + IncStaircaseSEM, fliplr(IncStaircaseMean - IncStaircaseSEM)], ...
%       [0.4660 0.6740 0.1880], ...
%       'FaceAlpha', 0.3, 'EdgeColor', 'none');
% hold on
% plot(1:100, DecStaircaseMean, '-', 'Color', '#D95319');
% hold on
% patch([1:100, fliplr(1:100)], ...
%       [DecStaircaseMean + DecStaircaseSEM, fliplr(DecStaircaseMean - DecStaircaseSEM)], ...
%       [0.8500 0.3250 0.0980], ...
%       'FaceAlpha', 0.3, 'EdgeColor', 'none');
% hold on
% plot([0 100], [50 50], ':k');
% axis([0 100 0 100]);
% text(70,85, ["Inc Threshold: ", [num2str(IncStaircaseMean(100) - 50, 3), '% ' char(177), ...
%              ' ', num2str(IncStaircaseSEM(100),2), '%'], ...
%              ['n = ', num2str(size(IncStaircase, 1))]]);
% text(70,40, ["Dec Threshold: ", [num2str(50 - DecStaircaseMean(100), 3), '% ' char(177), ...
%              ' ', num2str(DecStaircaseSEM(100),2), '%'], ...
%              ['n = ', num2str(size(DecStaircase, 1))]]);
% xlabel('Trial Number');
% ylabel('Coherence (%)');
% title('Averaged Inc/Dec Staircases (Subject 101)');


% Histograms for each subject
figure(4)
for sj = 1:length(sjID)
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
