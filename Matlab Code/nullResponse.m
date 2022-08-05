function nullResponse
%{
This function plots the effect of tuning width on responses to 0% coherent
motion.  We take the normalization model seriously, and integrate a
Gaussian direction tuning curve to get the response to 0% coherence.
Responses can run from zero to Rmax (preferred direction response), and are
plotted as a function of tuning width (sigma).  The effects of spontaneous
activity of different magnitudes are also show.   Cook & Maunsell found
sigma for direction tuning to be 60°.
%}
figure(1);
clf;

limitDeg = 180;
stepDeg = 15;

% show how the predicted response to 0% coherence varies as a function of
% direction tuning width
zeroline = [0, 0.1, 0.25];
areas = zeros(limitDeg / stepDeg, length(zeroline));
legends = cell(1, length(zeroline));
for b = 1:length(zeroline)
  legends{b} = sprintf('b = %.2f Rmax', zeroline(b));
  for s = stepDeg:stepDeg:limitDeg
    sigmaRad = deg2rad(s);
    areas(s/stepDeg, b) = sigmaRad / sqrt(2 * pi) * (normcdf(pi / sigmaRad) - normcdf(-pi / sigmaRad)) + zeroline(b);
    areas(s/stepDeg, b) = areas(s/stepDeg, b) / (1.0 + zeroline(b));
  end
end
xTickLabels = cell(1, limitDeg / stepDeg / 2);
for i = 1:limitDeg / stepDeg / 2 + 1
  xTickLabels{i} = num2str((i - 1) * 2 * stepDeg);
end
subplot(2, 1, 1);
plot(areas, 'o-');
hold on;
set(gca, 'xTick', 0:2:limitDeg / stepDeg);
set(gca, 'XTickLabel', xTickLabels);
xlabel('Direction Tuning Sigma (deg)');
set(gca, 'yTick', [0, 0.5, 1], 'yTickLabel', {'0', '0.5 Rmax', 'Rmax'});
ylabel('Zero Motion Coherence Response');
plot([0, limitDeg / stepDeg], [1, 1], 'r:');
plot([0, limitDeg / stepDeg], [0.5, 0.5], 'b:');
axis([-inf, inf, 0, 1.1]);
legend(legends, 'location', 'southeast');

% show predicted 0% coherence response given measured values

sigmaDeg = 25.5;
% sigmaDeg = 36.1;
sigmaRad = deg2rad(sigmaDeg);
R0 = sigmaRad / sqrt(2 * pi) * (normcdf(pi / sigmaRad) - normcdf(-pi / sigmaRad));
zeroline = (R0 - 0.2222) / 0.7778;
steps = 360 / stepDeg + 1;
resp = zeros(steps, 1);
xTickLabels = cell(1, steps);
for s = 1:steps
  dirDeg = -180 + (s - 1) * stepDeg;
  dirRad = deg2rad(dirDeg);
  resp(s) = exp(dirRad^2 / (-2 * sigmaRad^2));
  if mod(s, 2) ~= 0 
    xTickLabels{s} = '';
  else
    xTickLabels{s} = sprintf('%.0f', dirDeg - stepDeg);
  end
end
xTickLabels{s + 1} = '180';
subplot(2, 1, 2);
plot(resp, 'o-');
hold on;
plot([0, steps], [R0, R0], 'r:');
plot([0, steps], [zeroline, zeroline], 'k:');
set(gca, 'xTick', 0:1:steps);
set(gca, 'XTickLabel', xTickLabels);
xlabel('Dots Direction (deg)');
set(gca, 'yTick', [min(0, zeroline), max(0, zeroline), R0, 1], 'yTickLabel', ...
  {sprintf('%.2f', min(0, -zeroline)), sprintf('%.2f', max(0, -zeroline)), 'R_0', 'Rmax'});
ylabel('Neuronal Response');
plot([0, steps / 2], [1, 1], 'r:');
axis([-inf, inf,  min(0, zeroline), 1.1]);
text(0.75, 0.90, {['\sigma', ...
      sprintf(' = %.1f%c', sigmaDeg, char(176))], ...
      sprintf('R_0 = %.2f a', R0), ...
      sprintf('R_0 = 0.22 R_{max}', R0)}, ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'units', 'normalized');

