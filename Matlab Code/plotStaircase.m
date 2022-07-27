function plotStaircase(filePath)

  load(filePath, 'file', 'trials');
  trialCertify = [trials(:).trialCertify];
  trials = trials(trialCertify == 0);
  trialStructs = [trials(:).trial];
  eotCodes = [trials(:).eotCode];
  stepCohPC = [trialStructs(:).stepCohPC];
  correctIndices = find(eotCodes == 0);
  wrongIndices = find(eotCodes == 1);

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
