function [fitresult, gof] = fitGaussian(xData, yData)
  
%     ft = fittype('a*exp(-((x-b)/c)^2) + d*x^2 + e*x + f', ...
%                  'independent', 'x', 'dependent', 'y');
    ft = fittype('a*exp(-((x-b)/c)^2) +d ', ...
             'independent', 'x', 'dependent', 'y');
    % 设置拟合选项
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.StartPoint = [max(yData)-min(yData) mean(xData) std(xData) min(yData)]; % 初始参数估计

    % 拟合模型
    [fitresult, gof] = fit(xData, yData, ft, opts);

end