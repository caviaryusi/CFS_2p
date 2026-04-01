%for fitting the 2photon orientation data

function [z, expect]=OrientS4Fun1(p, AngDeg, data, SD)

%expect= p(1)*exp(-((AngDeg-p(3))/p(4)).^2/2)+p(2);  %prediction of model

%expect= (p(1)*2.^(-((AngDeg-p(2))/p(3)).^2)+min(data));  %prediction of model
expect= (p(1)*2.^(-((AngDeg-p(2))/p(3)).^2)+p(4));  %prediction of model
% 
z=(data-expect)./SD; %where chisq = dif*dif';
%z=(data-expect);

%     function [se, lsqPara,adRsquare, predictY] = OrientS4Fun1(AngDeg, data, x_se, params0, paramsMin, paramsMax)
%         g = @(p) ((p(1)*2.^(-((AngDeg-p(3))/p(4)).^2)+p(2))-data)./x_se;
%         options = optimoptions('lsqnonlin','Display','none');
%         [lsqPara,~,residual,exitflag,~,~,jacobian_fit] = lsqnonlin(g, params0, paramsMin, paramsMax, options);
%         
%         chisq = residual'*residual;%chi square
%         deg_free = size(jacobian_fit, 1) - size(jacobian_fit, 2);%degree of freedom
%         jacobian_fit = full(jacobian_fit);
%         covar = inv(jacobian_fit'*jacobian_fit);
%         var = diag(covar);
%         se = sqrt(var)';%standard error
%         
%         
%         a1 = lsqPara(1); s1 = lsqPara(2); a2 = lsqPara(3); s2 = lsqPara(4);
%         myfitfun = @(x) a1.*exp(-(x./s1).^2)-a2.*exp(-(x./s2).^2);
%         
%         
%         
%         predictY = myfitfun(xdata);
%         SSE = sum((ydata-predictY).^2);
%         SST = sum((ydata-mean(ydata)).^2);
%         Rsquare = 1-SSE/SST;
%         adRsquare = 1- (1-Rsquare)*(size(jacobian_fit,1)-1)./(size(jacobian_fit,1)-size(jacobian_fit,2)-1);
%         
end