function se = calcSE(matrix, dim)
    % Calculate the standard deviation along the specified dimension
    sd = std(matrix, 0, dim);

    % Calculate the number of observations along the specified dimension
    n = size(matrix, dim);

    % Calculate the standard error
    se = sd / sqrt(n);
end
