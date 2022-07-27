function checkFile()

load ('/Users/Shared/Data/IDPsych/103/2022-07-19-00.mat', 'file', 'trials');
% load ('2022-07-22-00.mat', 'file', 'trials');
eotCodes = [trials(:).eotCode];
trialStructs = [trials(:).trial];
side = [trialStructs(:).changeLoc];
corrLeft = find(eotCodes == 0 & side == 0);
wrongLeft = find(eotCodes == 1 & side == 0);
corrRight = find(eotCodes == 0 & side == 1);
wrongRight = find(eotCodes == 1 & side == 1);

numLChange = sum(side == 0);
numRChange = sum(side == 1);
numLResp = sum(side == 0 & eotCodes == 0) + sum(side == 1 & eotCodes == 1);
numRResp = sum(side == 1 & eotCodes == 0) + sum(side == 0 & eotCodes == 1);

fprintf('fraction right changes %.2f, fraction right resps %.2f, right bias %.2f\n',...
  numRChange / (numRChange + numLChange), numRResp / (numRChange + numLChange),...
  (numRResp - numRChange) / (numRChange + numLChange));

figure(1);
clf;
plot(corrLeft, [trialStructs(corrLeft).stepCohPC], 'bo', 'MarkerFaceColor', 'b');
hold on;
plot(wrongLeft, [trialStructs(wrongLeft).stepCohPC], 'ro', 'MarkerFaceColor', 'r');
plot(corrRight, [trialStructs(corrRight).stepCohPC], 'ko', 'MarkerFaceColor', 'k');
hold on;
plot(wrongRight, [trialStructs(wrongRight).stepCohPC], 'mo', 'MarkerFaceColor', 'm');

end