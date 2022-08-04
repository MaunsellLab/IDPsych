function plotZeroResp()
% Plot the effect of tuning width on the response to zero coherence

  figure(1);
  clf;

  sigmaDeg = [1, 2, 5, 10, 20, 50, 100, 180];
  for s = 1:8
    plotOneSigma(s, sigmaDeg(s));
  end
end

function plotOneSigma(plotIndex, sigmaDeg)

  sigmaRad = deg2rad(sigmaDeg);
  r0 = sqrt(2.0 * pi) * sigmaRad / 2.0 * (erf(pi / (sqrt(2.0) * sigmaRad)) - erf(-pi / (sqrt(2.0) * sigmaRad))) / ...
    (2.0 * pi);
  r0 = 0.5 * (erf(pi / (sigmaRad)) - erf(-pi / (sigmaRad)));
  subplot(4, 2, plotIndex);
  x = deg2rad(-180:180);
  y = exp(-(x.^2)/(2 * deg2rad(sigmaDeg))^2);
  plot(x, y);
  hold on;
  plot([x(1), x(end)], [r0, r0], 'k:');
  axis([x(1), x(end), 0, 1]);
  xticks(deg2rad([-180, 0, 180]));
  xticklabels({'-180', '0', '180'});
  yticks([0, 1]);
  plotText = {strcat(sprintf('sigma = %.0f', sigmaDeg), char(176)), ...
    sprintf('R_0 = %.2f', r0)};
  if plotIndex >= 7
    text(0.05, 0.05, plotText, HorizontalAlignment='left', VerticalAlignment='bottom', units='normalized');
    xlabel('Direction (deg)');
    if plotIndex == 7
      ylabel('Normalized Response');
    end
  else
    text(0.05, 0.95, plotText, HorizontalAlignment='left', VerticalAlignment='top', units='normalized');
  end
end