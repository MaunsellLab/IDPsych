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

  % Plot responses to preferred and null drift as a function of motion
  % coherence.
  sigmaRad = deg2rad(sigmaDeg);
  % the response to 0% coherence motion, assuming perfect normalization of
  % motion direction.  This is taken as the average response within from
  % -pi to pi, as a fraction of the peak response.  The first term
  % normalizes to the maximum possible area under the curve. 
  r0 = (sigmaRad / sqrt(8 * pi)) * (erf(pi / (sqrt(2) * sigmaRad)) - erf(-pi / (sqrt(2) * sigmaRad)));
  coh = (0:0.01:1);
  % response to 100% motion coherent null direction
  rN100 = exp(-pi^2 / (2 * sigmaRad^2));
  % responses to preferred and null motion as a function of coherence.
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
  % Plot direction tuning curve with width sigmaDeg and the show the predicted response to 0% coherence
  % motion. 
  sigmaRad = deg2rad(sigmaDeg);
  % the area underneath a normalized Gaussian from -pi to pi
  areaComputed = 0.5 * (erf(pi / (sqrt(2) * sigmaRad)) - erf(-pi / (sqrt(2) * sigmaRad)));
  % the response to 0% coherence motion, assuming perfect normalization of
  % motion direction.  This is taken as the average response within from
  % -pi to pi, as a fraction of the peak response.  The first term
  % normalizes to the maximum possible area under the curve. 
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
  % Plot a function showing how the ratio of Pref to Null response varies
  % as a function of tuning width (sigma).  Response are linear with motion
  % coherence, so the answer is independent of motion coherence. 
  sigmaDeg = 30:90;
  sigmaRad = deg2rad(sigmaDeg);
  % get the response to 0% coherence
  r0 = (sigmaRad / sqrt(8 * pi)) .* (erf(pi ./ (sqrt(2) * sigmaRad)) - erf(-pi ./ (sqrt(2) * sigmaRad)));
  % get the response to 100% null motion (100% preferred motion is taken to
  % be 1.0)
  rN100 = exp(-pi.^2 ./ (2 * sigmaRad.^2));
  % The ratio takes into account that rN100 is never truly zero.
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
