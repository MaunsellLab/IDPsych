function plotStaircase(filePath)

  load(filePath, 'file', 'trials');                 % load data file
  trialCertify = [trials(:).trialCertify];          % extract trial certificates
  eotCodes = [trials(:).eotCode];                   % extract EOT codes
  validIndices = trialCertify == 0 & eotCodes <= 1; % get indices for valid trials
  trials = trials(validIndices);                    % remove invalid trials from trial
  eotCodes = eotCodes(validIndices);                % remove invalid trials from eotCodes
  trialStructs = [trials(:).trial];                 % extract trial descriptors 
  stepCohPC = [trialStructs(:).stepCohPC];          % extract coherence steps
  correctIndices = find(eotCodes == 0);             % get indices for correct trials
  wrongIndices = find(eotCodes == 1);               % get indices for wrong trialsw

  figure(1);
  clf;
  plot(correctIndices, stepCohPC(correctIndices), 'ko', 'MarkerFaceColor', 'c');
  hold on;
  plot(wrongIndices, stepCohPC(wrongIndices), 'ko', 'MarkerFaceColor', 'r');
  axis([0, file.numberOfTrials, 0, 100]);
  plot([0, file.numberOfTrials], trials(1).trial.baseCohPC * [1, 1], 'k');
  ylabel('step coherence (%)');
  xlabel('trial number');
  title(filePath);
end