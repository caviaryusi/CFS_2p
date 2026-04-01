function [expect, params, R2, adR2, slope] = GaussianOriFitting_centered(x,rsp,rsp_se)
% Gaussian Ori Fitting
%  input x(in deg, -90:15:75), y(resp, with peak in center(7th element))
%  do Gaussian fitting
%  output: expect value, amplitude, peak, bandwidth, r2, adjr2

% for testing
% x = -90:15:75;
% rsp = [0.125391673000126	0.129854109423373	0.146548066774074	0.172475275492457	0.201341231405519	0.275817204092200	0.505507102695760	0.299904329681388	0.213835780139317	0.167446641503513	0.153485964150158	0.137477543551120];
% rsp_se = [0.0059722991565224 0.006	0.00687597891119498	0.00805995547315342	0.00914933518047149	0.0117486545089811	0.0120605224899988	0.0115991984239318	0.00917970578892710	0.00723417113113078	0.00654471393358824	0.00602379787462427];

step = 180/length(x);
PeakDeg= x(7);
if length(PeakDeg)>1  % if they have two peaks, choose the first one
    PeakDeg=PeakDeg(1);
end
StartAng=PeakDeg;
SP = ceil((length(x)-1)/2)*step;
AngDeg= StartAng-SP:step:StartAng-SP+(length(x)-1)*step;
Loc = AngDeg;
% Loc(find(AngDeg<0)) = Loc(find(AngDeg<0))+180;
% Loc(find(AngDeg>180-step)) = Loc(find(AngDeg>180-step))-180;

for n = 1:length(Loc) % rotate to center the peak
    data(n) = rsp(find(x == Loc(n)));
    data_se(n) = rsp_se(find(x == Loc(n)));
end
data_se = [0.005 0.005 0.005 0.005 0.005 0.005 -0.002 0.005 0.005 0.005 0.005 0.005];

params0=[data(7)-data(1) PeakDeg 20 (data(1)+data(end))/2];  % params are amp, peak, sigma,  baseline
paramsMax = [Inf PeakDeg 180 Inf];
paramsMin = [0 PeakDeg 0 0];

% least square fitting
[params,chisq,~,~,~,~,j] = lsqnonlin('OrientS4Fun1',params0, paramsMin, paramsMax,[], AngDeg, data, data_se);
j=full(j);  %something about sparse matrices
covar=inv(j'*j);  %see Numerical Recipes for meaning of covariance matrix
se=sqrt(diag(covar))';%Standard error
%        plot(AngDeg,data,'k*'); hold on
%             expect=(params(1)*2.^(-((AngDeg-params(2))/params(3)).^2)+params(2));
%             expect=(params(1)*2.^(-((AngDeg-params(2))/params(3)).^2)+min(data));
expect=(params(1)*2.^(-((AngDeg-params(2))/params(3)).^2)+params(4));
SSE = sum((data-expect).^2);
SST = sum((data-mean(data)).^2);
Rsquare = 1-SSE/SST;
adRsquare = 1-(1-Rsquare)*(size(j,1)-1)./(size(j,1)-size(j,2)-1);

% calculate the slope at the hhhw
slope = params(1) * 2.^( params(4)-1 ) * (2/params(3));

% get fitting function, seek the maxima angle and deg
AngDeg2= StartAng-90:1:StartAng+90;
negfitfun = @(Deg) -params(1)*2.^(-((Deg-params(2))/params(3)).^2)-params(4);
[Degmax, negymax] = fminbnd(negfitfun, AngDeg2(1), AngDeg2(end));
Fmax = -negymax;
if Degmax > StartAng
    DegOrtho = Degmax - 90;
else
    DegOrtho = Degmax + 90;
end
Fortho = params(1)*2.^(-((DegOrtho-params(2))/params(3)).^2)+params(4); % resp at orthogonal to optimal deg
deltaF = Fmax - Fortho; % delta between max and ortho
osi = (Fmax-Fortho)/(Fmax+Fortho-2*params(4)); % osi
expect2= params(1)*2.^(-((AngDeg2-params(2))/params(3)).^2)+params(4); % expected value
fitfun = @(Deg) params(1)*2.^(-((Deg-params(2))/params(3)).^2)+params(4);
[Degmin, Fmin] = fminbnd(fitfun, AngDeg2(1), AngDeg2(end)); % find minimal
idabove = find(expect2>0.5*abs(Fmax-Fmin)+Fmin);

Osi = osi; % orientation selective index
Se = se; % standard error
ParamList = params; % params
PeakDeg = params(2);
RangeDeg = AngDeg;
Amp = params(1);
Sigma = params(3);
data = data;
data_se = data_se;
OptOrien = Degmax; % optimal ori
adR2 = adRsquare;
Chi2 = chisq;
R2 = Rsquare;
