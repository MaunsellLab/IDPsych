function convertIDP(forceConversion)
  % convert IDPsych dat files to mat format
  % Requires readLLFile
  if nargin < 1
    forceConversion = false;
  end
  % For now, assume that the only PC user is Lai.  We can expand this as
  % needed if others are using PCs
  if ismac
    dataFolder = '/Users/Shared/Data/IDPsych/';
  else
    dataFolder = 'D:\Research\IDPsych_Project\IDPsych\';       % for Lai's Desktop only
  end
  if ~isfolder(dataFolder)
    fprintf('Cannot find %s\n', dataFolder);
    return;
  end
  fileList = dir(dataFolder);
  fileList = fileList([fileList.isdir]);                    % only examine folders
  hWait = waitbar(0, '', 'Name', 'convertIDP');
  for f = 1:length(fileList)
    digitIndex = regexp(fileList(f).name, '[0-9]+');        % only folders with names that are all numerals
    if length(digitIndex) == 1 && digitIndex == 1
      folderPath = strcat(dataFolder, fileList(f).name, filesep);
      if forceConversion
        delete(strcat(folderPath, '*.mat'));
      end
      doOneFolder(folderPath, hWait);
    end
  end
  delete(hWait)
  fprintf('All ''.dat'' files have been converted to ''.mat''\n');
end

function doOneFolder(subjectFolder, hWait)
  fileList = dir(subjectFolder);
  fileList = fileList(~[fileList.isdir]);                    % only examine files
  for f = 1:length(fileList)
    [~, fileName, fileExt] = fileparts(fileList(f).name);
    if strcmp(fileExt, '.dat') && (~exist(strcat(subjectFolder, fileName, '.mat'), 'file'))
      doOneFile(strcat(subjectFolder, fileName), hWait)
    end
  end
end

function doOneFile(filePath, hWait)
  dataPath = strcat(filePath, '.dat');
  file = readLLFile('i', dataPath);
  file.subjectNumber = file.subjectNumber(1).data;
  numTrials = file.numberOfTrials;
  for dataTypes = {'trialStart', 'trialEnd', 'trialCertify', 'eotCode', 'fixOn', 'fixate', ...
            'subjectNumber', 'randomDots', 'trial'}
    dataT = dataTypes{:};
    trials.(dataT) = nan(numTrials, 1);
  end
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
    if isfield(trial, 'randomDots')
      trials(tIndex).randomDots = trial.randomDots.data;
    end    
  end
  save(strcat(filePath, '.mat'), 'file', 'trials');
end