function print_skip(disp_info, tipo_grafico, variable, etiqueta)
% print_skip imprime mensaje sobre gráfico no impreso debido a ausencia de
% datos.

if disp_info
    fprintf('[IM_plot_statitics] Se omite %s de %s (%s): sin datos válidos.\n', ...
        char(tipo_grafico), char(variable), char(etiqueta));
end

end