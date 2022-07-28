function convertIDP(forceConversion)
  % convert IDPsych dat files to mat format
  % Requires readLLFile
  if nargin < 1
    forceConversion = false;
  end
  dataFolder = '/Users/Shared/Data/IDPsych/';
  if ~isfolder(dataFolder)
    return;
  end
  fileList = dir(dataFolder);
  fileList = fileList([fileList.isdir]);                    % only examine folders
  for f = 1:length(fileList)
    digitIndex = regexp(fileList(f).name, '[0-9]+');        % only folders with names that are all numerals
    if length(digitIndex) == 1 && digitIndex == 1
      doOneFolder(strcat(dataFolder, fileList(f).name, '/'), forceConversion);
    end
  end
  fprintf('All ''.dat'' files have been converted to ''.mat''\n');
end

function doOneFolder(subjectFolder, forceConversion)
  fileList = dir(subjectFolder);
  fileList = fileList(~[fileList.isdir]);                    % only examine files
  for f = 1:length(fileList)
    [~, fileName, fileExt] = fileparts(fileList(f).name);
    if strcmp(fileExt, '.dat') && (~exist(strcat(subjectFolder, fileName, '.mat'), 'file') || forceConversion)
      doOneFile(strcat(subjectFolder, fileName))
    end
  end
end

function doOneFile(filePath)
  datPath = strcat(filePath, '.dat');
  file = readLLFile('i', datPath);
  file.subjectNumber = file.subjectNumber(1).data;
  numTrials = file.numberOfTrials;
  for dataTypes = {'trialStart', 'trialEnd', 'trialCertify', 'eotCode', 'fixOn', 'fixate', ...
            'subjectNumber', 'trial'}
    dataT = dataTypes{:};
    trials.(dataT) = nan(numTrials, 1);
  end
  hWait = waitbar(0, '', 'name', sprintf('Converting %s', filePath((find(filePath == '/', 1, 'last') + 1):end)));
  for tIndex = numTrials:-1:1
    waitbar((numTrials - tIndex) / numTrials, hWait, sprintf('Loading trial %d of %d', numTrials - tIndex, numTrials));
    trial = readLLFile('t', tIndex);
    trials(tIndex).trialStart = trial.trialStart.timeMS;            % trial start timeStamp
    trials(tIndex).fixOn = trial.fixOn.timeMS;                      % fixation point on timeStamp
    if isfield(trial, 'fixate')
      trials(tIndex).fixate = trial.fixate.timeMS;                  % fixate start
    end
    if isfield(trial, 'saccade')
      trials(tIndex).saccade = trial.saccade.timeMS;                % saccade time stamp
    end
    trials(tIndex).trialEnd = trial.trialEnd.timeMS;                 % trial end timeStamp
    trials(tIndex).eotCode = trial.trialEnd.data;
    if isfield(trial, 'trial')
      trials(tIndex).trial = trial.trial.data;
    end
    if isfield(trial, 'trialCertify')
      trials(tIndex).trialCertify = trial.trialCertify.data;
    end    
  end
  delete(hWait)
  save(strcat(filePath, '.mat'), 'file', 'trials');
end