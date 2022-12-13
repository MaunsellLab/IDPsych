function plotHitRate()
%
%   Simulate the staircases given a threshold level, and visualize the 
%   distribution of hit rate under different performance level

    alphas = 10:10:60;     % thresholds
    hitRates = zeros(length(alphas), 10000);
    meanHitRates = zeros(length(alphas), 1);
    stdHitRates = zeros(length(alphas), 1);

    fracTop = zeros(length(alphas), 10000);
    meanFracTop = zeros(length(alphas), 1);
    stdFracTop = zeros(length(alphas), 1);

    fracBottom = zeros(length(alphas), 10000);
    meanFracBottom = zeros(length(alphas), 1);
    stdFracBottom = zeros(length(alphas), 1);

    figure(1);
    clf;
    for m = 1:length(alphas)
  
        for i = 1:10000
            [hitRates(m, i), fracTop(m, i), fracBottom(m, i)] = calcHitRate(alphas(m));
        end

        meanHitRates(m) = mean(hitRates(m, :));
        stdHitRates(m) = std(hitRates(m, :));
        

        meanFracTop(m) = mean(fracTop(m, :));
        stdFracTop(m) = std(fracTop(m, :));

        meanFracBottom(m) = mean(fracBottom(m, :));
        stdFracBottom(m) = std(fracBottom(m, :));

        subplot(length(alphas), 2, 2*m - 1);
        histogram(hitRates(m, :), 20);
        xline(meanHitRates(m), '--r');
        text(30,1000, [num2str(meanHitRates(m)), ' ', char(177), ' ', num2str(stdHitRates(m))]);
        xlim([0 100]);
        title(['Threshold = ', num2str(alphas(m))]);
        

        subplot(length(alphas), 2, 2*m);
        histogram(fracTop(m, :), 20);
        hold on
        histogram(fracBottom(m, :), 20);
        xlim([0 100]);
        t1 = ['0% - 5%:', num2str(meanFracTop(m)), ' ', char(177), ' ', num2str(stdFracTop(m))];
        t2 = ['45% - 50%:', num2str(meanFracBottom(m)), ' ', char(177), ' ', num2str(stdFracBottom(m))];
        text(50, 5000, t1)
        text(50, 4000, t2)

        title(['Threshold = ', num2str(alphas(m))]);
    end
end

function [correct100, top5, bot5] = calcHitRate(alpha)
    % Do one complete staircase for one of the test conditions, returning the
    % the hit rate
    
    threshold = randi(50);             % starting value for staircase
    step = 8;                          % initial step size
    numTrials = 0;
    seqCorrect = 0;
    seqWrong = 0;
    numRev = 0;
    limitTrials = 100;                % minimum number of trials to collect
    limitStep = 1;                    % step size limit that must be reached
    correct100 = 0;                   % hitrate of this measurement
    top5 = 0;                          % trials having 0 - 5% steps
    bot5 = 0;                         % trials having 45 - 50% steps
    
    while (step >= limitStep) && (numTrials <= limitTrials)
        prob100 = 100.0 * (1.0 - exp(-threshold / (alpha * 0.6408)));
        correct = randi(100) - 1 < prob100;
        
        if threshold >= 0 && threshold <= 5
            top5 = top5 + 1;
        elseif threshold >= 45 && threshold <= 50
            bot5 = bot5 + 1;
        end

        % First check for a reversal, and reduce step size if enough reversals
        if (correct && seqWrong > 0) || (~correct && seqCorrect > 0)  % a reversal
            numRev = numRev + 1;
            if numRev >= 6            % reduce step size after 6 reversals
                step = max(1, step * 0.5);
                numRev = 0;
            end
        end
        % Then check whether a step needs to be made
        if correct
            correct100 = correct100 + 1;
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