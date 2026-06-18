function x = clean_vector(x)
% clean_vector convierte el vector a columna y extrae solo los datos que
% son finitos o cero. Excluye los datos infinitos o NaN.

x = x(:);
x = x(isfinite(x));

end