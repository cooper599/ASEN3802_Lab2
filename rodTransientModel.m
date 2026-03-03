function T = rodTransientModel(x, t, L, alpha, Huse, T0use, N, bnScale)
% bnScale = coefficient multiplier for bn term

    Tsteady = T0use + Huse.*x;

    T = Tsteady; 

    % Force shapes: x = 1xNx, t = Nt x1
    x = x(:).';      % row
    t = t(:);        % col
    Tsteady = T0use + Huse.*x;  % row

    sumTerm = zeros(length(t), length(x));

    for n = 1:N
        lambda = pi*(2*n-1)/(2*L);
        bn = (8*L*bnScale*(-1)^n) / (pi^2*(2*n-1)^2); 
        sumTerm = sumTerm + bn .* sin(lambda*x) .* exp(-(lambda^2)*alpha*t);
    end

    T = Tsteady + sumTerm;
end