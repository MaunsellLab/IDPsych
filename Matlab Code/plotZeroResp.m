function plotZeroResp()
% Plot the effect of tuning width on the response to zero coherence

  figure(1);
  clf;
  sigmaDeg = [5, 10, 15, 30, 45, 60, 90, 180];
  for s = 1:length(sigmaDeg)
    plotOneSigma(s, sigmaDeg(s));
  end

  figure(2);
  clf;
  sigmaDeg = [30, 45, 60, 90];
  for s = 1:length(sigmaDeg)
    plotOneResp(s, sigmaDeg(s));
  end

  plotSigmaFunction()

end

function plotOneResp(plotIndex, sigmaDeg)

  sigmaRad = deg2rad(sigmaDeg);
  r0 = (sigmaRad / sqrt(8 * pi)) * (erf(pi / (sqrt(2) * sigmaRad)) - erf(-pi / (sqrt(2) * sigmaRad)));
  coh = (0:0.01:1);
  rN100 = (1 / sqrt(2 * pi) / sigmaRad) * exp(-(pi / sigmaRad)^2 / (2 * sigmaRad^2));
  rPref = coh + (1 - coh) * r0;
  rNull = r0 - coh * (r0 - rN100);
  subplot(4, 2, plotIndex);
  plot(coh, rPref, 'b');
  hold on;
  plot(coh, rNull, 'b-');
  plot([0, 1], [r0, r0], 'k:');
  xticks([0, 1]);
  yticks([0, 1]);
  if plotIndex == 1
    title('plotZeroResp.m');
  end
  if plotIndex > 2
    xlabel('Motion Coherence');
    if plotIndex == 3
      ylabel('Normalized Response');
    end
  end
  plotText = {strcat(sprintf('sigma = %.0f', sigmaDeg), char(176))};
  text(0.02, 0.98, plotText, HorizontalAlignment='left', VerticalAlignment='top', units='normalized');
  plotText = {sprintf('R_0_%% = %.2f', r0), sprintf('R_N_1_0_0_%% = %.2f', rN100)};
  text(0.98, r0 + 0.01, plotText, HorizontalAlignment='right', VerticalAlignment='middle', units='normalized');
  plotText = {sprintf('Inc/Dec Ratio = %.1f', (1 - r0) / (r0 - rN100))};
  text(0.02, 0.02, plotText, HorizontalAlignment='left', VerticalAlignment='bottom', units='normalized');
end

function plotOneSigma(plotIndex, sigmaDeg)

  sigmaRad = deg2rad(sigmaDeg);
  areaComputed = 0.5 * (erf(pi / (sqrt(2) * sigmaRad)) - erf(-pi / (sqrt(2) * sigmaRad)));
  r0 = (sigmaRad / sqrt(8 * pi)) * (erf(pi / (sqrt(2) * sigmaRad)) - erf(-pi / (sqrt(2) * sigmaRad)));
  subplot(4, 2, plotIndex);
  x = deg2rad(-180:180);
  y = exp(-(x.^2)/(2 * sigmaRad^2));
  plot(x, y);
  hold on;
  plot([x(1), x(end)], [r0, r0], 'k:');
  axis([x(1), x(end), 0, 1]);
  xticks(deg2rad([-180, 0, 180]));
  xticklabels({'-180', '0', '180'});
  yticks([0, 1]);
  plotText = {strcat(sprintf('sigma = %.0f', sigmaDeg), char(176)), ...
    sprintf('peak = %.2f', 1.0 / (sigmaRad * sqrt(2 * pi))), ...
    sprintf('area = %.2f', areaComputed), ...
    sprintf('R_0_%% = %.2f', r0)};
  if plotIndex >= 7
    text(0.50, 0.05, plotText, HorizontalAlignment='center', VerticalAlignment='bottom', units='normalized');
    xlabel('Direction (deg)');
    if plotIndex == 7
      ylabel('Normalized Response');
    end
  else
    text(0.05, 0.95, plotText, HorizontalAlignment='left', VerticalAlignment='top', units='normalized');
    if plotIndex == 1
      title('plotZeroResp.m');
    end
  end
end

function plotSigmaFunction()

  sigmaDeg = 30:90;
  sigmaRad = deg2rad(sigmaDeg);
  r0 = (sigmaRad / sqrt(8 * pi)) .* (erf(pi ./ (sqrt(2) * sigmaRad)) - erf(-pi ./ (sqrt(2) * sigmaRad)));
  rN100 = (1 / sqrt(2 * pi) ./ sigmaRad) .* exp(-(pi ./ sigmaRad).^2 ./ (2 * sigmaRad.^2));
  ratio = (1 - r0) ./ (r0 - rN100);
  ax = subplot(2, 1, 2);
  plot(sigmaDeg, ratio, 'b');
  hold on;
  plot([sigmaDeg(1), sigmaDeg(end)], [1, 1]);
  xlabel('Sigma (degrees)');
  ylabel('Ratio Pref/Null Response');
  ax.XGrid = 'on';
  ax.YGrid = 'on';
end
