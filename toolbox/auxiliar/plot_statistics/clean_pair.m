function [x, d] = clean_pair(x, d)
% clean_pair limpia datos Inf o NaN de un par de vectores x y d.
    x = x(:);
    d = d(:);
    n = min(numel(x), numel(d));
    x = x(1:n);
    d = d(1:n);
    idx = isfinite(x) & isfinite(d);
    x = x(idx);
    d = d(idx);
end