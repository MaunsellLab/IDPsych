function dirIntegration

% This equation is set up for a Gaussian with a baseline of 0 and an
% amplitude of 1, with the area between -pi and pi normalized to 1. This
% way the maximum integral is 1 over this range. 

  sigmaDeg = 37.5;                % SD of direction tuning Gaussian
  sigmaRad = deg2rad(sigmaDeg);
  % Integral giving the response to 0% coherence
  r0 = (sigmaRad / sqrt(8 * pi)) * (erf(pi / (sqrt(2) * sigmaRad)) - erf(-pi / (sqrt(2) * sigmaRad)));
  fprintf('sigma %.1f deg, r0 = %.2f\n', sigmaDeg, r0);
  for intDeg = [35:40, 40:0.1:41, 42:49, 50:0.1:51, 52:55]
    intRad = deg2rad(intDeg);
    % integrated R0% response over range
    intR0 = 2 * intRad / (2 * pi) * r0; 
    % integrated Preferred response over range (minus R0%)
    intP = sigmaRad / sqrt(8 * pi) * (erf(intRad/(sqrt(2) * sigmaRad)) - erf(-intRad / (sqrt(2) * sigmaRad))) - intR0;
    % integrated Null response over range (minus R0%)
    intN = 2 * sigmaRad / sqrt(8 * pi) * (erf(pi/(sqrt(2) * sigmaRad)) - erf((pi - intRad)/(sqrt(2) * sigmaRad))) - intR0;
    fprintf('limits ±%.02d deg, integrals: R0 %6.3f, Pref %6.3f, Null %7.3f: ratio %.2f\n', intDeg, intR0, intP, intN, abs(intP / intN));
  end
  
  x = sqrt(-log(r0) * 2.0 * sigmaRad^2);
  fprintf('y == r0 at %.2f SD, or %.2f degrees\n', x, x * sigmaDeg);

%   subjectRatios = [2.10, 21.9, 1.75, 1.78, 1.91];
%   [h, p, ci, stats] = ttest(subjectRatios, 2.21)
end