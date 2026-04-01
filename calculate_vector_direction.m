function primary_direction = calculate_vector_direction(gabor_directions)

      [Gx, Gy] = imgradientxy(gabor_directions);

    gradient_vectors = [Gx(:), Gy(:)];
    
    [coeff, ~, latent] = pca(gradient_vectors);
    
    if abs(latent(1) - latent(2)) / latent(1) < 0.1 || gabor_directions(1,1) < 0.25
        primary_direction = 720;
    else
        primary_direction = atan2(coeff(2, 1), coeff(1, 1));
        primary_direction = rad2deg(primary_direction);
        primary_direction = mod(180 - primary_direction, 180);
    end
end
