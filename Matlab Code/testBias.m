function testBias()
%
% Test the effect of a subject responding preferentially to one side. In
% the biased condition, the subject responds faithfully if the stimulus is
% above thresholds, but on 90% of the trials when the stimulus is below
% threholds, the subject always picks the 'preferred' side.  Separate plots
% are made for the biased condition to show the effect on bias on
% staircases for the preferred side, the nonpreferred side, and a
% staircases that combines both sides.  The conclusion is that bias greatly
% improves the measured thresholds on the preferred side, but only slightly
% elevates thresholds on the nonpreferred side.  The nonpreferred and joint
% staircases have very similar thresholds.

  testTypes = struct('unbiased', 1, 'jointBiased', 2, 'prefBiased', 3, 'nonprefBiased', 4, 'testTypes', 4);
  figure(1);
  clf;
  alphas = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50];     % thresholds
  for type = testTypes.unbiased:testTypes.nonprefBiased
    doOnePlot(type, alphas);
  end
end

function doOnePlot(type, alphas)
  % plot measured thresholds for one test condition (biased/unbiased,
  % joint/L-R)
  means = zeros(1, length(alphas));
  sems = zeros(1, length(alphas));
  for a = 1:length(alphas)
    numReps = 25;
    measures = zeros(1, numReps);
    for r = 1:numReps
      measures(r) = doOneStaircase(alphas(a), type);
    end
    means(a) = mean(measures);
    sems(a) = std(measures) / sqrt(numReps);
  end
  % plot the results
  subplot(2, 2, type);
  errorbar(alphas, means, sems, sems, 'bo', 'MarkerFaceColor', 'b');
  axis([0, 55, 0, 55]);
  hold on;
  plot([0, 50], [0, 50], 'k:');
  plot([0, 50, 50], [50, 50, 0], 'k:');
  xlabel('Actual Threshold');
  ylabel('Mean Measured Threshold (+/- 1 SEM)');
  plotTitles = {'Unbiased Joint Staircase', 'Biased Joint Staircase', 'Biased Preferred Staircase', ...
              'Biased Non-Preferred Staircase'};
  title(plotTitles{type});
  if (type > 1)
    text(0.05, 0.90, {'Preferred side selected', 'on 90% of trials when', 'stimulus < threshold'}, ...
      'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'units', 'normalized');
  end
end

function threshold = doOneStaircase(alpha, type)
  % Do one complete staircase for one of the test conditions, returning the
  % measured threshold
  testTypes = struct('unbiased', 1, 'jointBiased', 2, 'prefBiased', 3, 'nonprefBiased', 4, 'testTypes', 4);

  threshold = randi(50);             % starting value for staircase
  step = 8;                          % initial step size
  numTrials = 0;
  seqCorrect = 0;
  seqWrong = 0;
  numRev = 0;
  limitTrials = 100;                % minimum number of trials to collect
  limitStep = 1;                    % step size limit that must be reached
  while step >= limitStep && numTrials < limitTrials
    stimSide = randi(2);                       % 1 == Left, 2 == Right side change
    % If we are doing split L/R staircases and this isn't our side, just continue
    if (type == testTypes.prefBiased && stimSide == 1) || (type == testTypes.nonprefBiased && stimSide == 2)
      continue;
    end
    prob100 = 100.0 * (1.0 - exp(-threshold / (alpha * 0.6408)));
    % for joint biased staircase, we pick right below threshold (80) 90% of
    % the time. We'll be correct if the stimulus was on the right.
    if type == testTypes.jointBiased && prob100 < 80 && randi(100) < 90
      correct = stimSide == 2;
    elseif type == testTypes.prefBiased && prob100 < 80 && randi(100) < 90
      correct = true;
    elseif type == testTypes.nonprefBiased && prob100 < 80 && randi(100) < 90
      correct = false;
    % if we are unbiased, or above threshold, or 10% of trials where bias
    % fails, just use the probability to determine whether we are correct
    else
      correct = randi(100) - 1 < prob100;
    end

    % First check for a reversal, and reduce step size if enough reversals
    if (correct && seqWrong > 0) || (~correct && seqCorrect > 0)  % a reversal
      numRev = numRev + 1;
      if numRev >= 6            % reduce step size after 6 reversals
        step = max(limitStep, step * 0.5);
        numRev = 0;
      end
    end
    % Then check whether a step needs to be made
    if correct
      seqCorrect = seqCorrect + 1;
      seqWrong = 0;
      if mod(seqCorrect, 3) == 0      % make a step after 3 correct trials
        threshold = max(threshold - step, 0);
      end
    else
      seqWrong = seqWrong + 1;        % make a step after 1 wrong trial
      seqCorrect = 0;
      threshold = min(threshold + step, 50);
    end
    numTrials = numTrials + 1;  
  end
end