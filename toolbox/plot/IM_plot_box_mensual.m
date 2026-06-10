function IM_plot_box_mensual(var, meses, varargin)
%IM_plot_box_mensual Genera un boxplot mensual.
%
% INPUTS
% var   : vector de datos
% meses : vector de meses (1-12) mismo tamaño que var
%
% PARAMETROS OPCIONALES (Name-Value)
%
% 'name'           : nombre de la figura
% 'ext'            : extensión de la figura
% 'save_dir'       : direccion para guardar figura
% 'Labels'         : etiquetas meses
% 'ColorCaja'      : color de cajas
% 'MedianColor'    : color mediana
% 'Whisker'        : factor whisker
% 'Symbol'         : símbolo outliers
% 'Widths'         : ancho cajas
% 'BoxStyle'       : estilo cajas
% 'Notch'          : notch on/off
% 'FigurePosition' : posición figura
% 'ShowMedianLine' : true/false
% 'Ylabel'         : etiqueta eje Y
% 'Xlabel'         : etiqueta eje X
%
%----------------------------------------------------------

p = inputParser;

addParameter(p,'name', ' ');
addParameter(p,'ext', 'png')
addParameter(p,'save_dir', []);
addParameter(p,'Labels',{'Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'});
addParameter(p,'ColorCaja',[0.4 0.6 0.4]);
addParameter(p,'MedianColor',[0.4 0.6 0.4]);
addParameter(p,'Whisker',1.5);
addParameter(p,'Symbol','*');
addParameter(p,'Widths',0.6);
addParameter(p,'BoxStyle','outline');
addParameter(p,'Notch','on');
addParameter(p,'FigurePosition',[327 415 913 463]);
addParameter(p,'ShowMedianLine',true);
addParameter(p,'Ylabel','');
addParameter(p,'Xlabel','Mes');

parse(p,varargin{:})
opt = p.Results;

%% Figura

f = figure('Color','w','Position',opt.FigurePosition);

boxplot(var, meses,...
    'Labels',opt.Labels,...
    'Whisker',opt.Whisker,...
    'Symbol',opt.Symbol,...
    'Colors',opt.ColorCaja,...
    'Widths',opt.Widths,...
    'BoxStyle',opt.BoxStyle,...
    'Notch',opt.Notch)

%% Colorear cajas

cajas = findobj(gca,'Tag','Box');

for i = 1:length(cajas)
    patch(get(cajas(i),'XData'), ...
          get(cajas(i),'YData'), ...
          opt.ColorCaja,...
          'FaceAlpha',0.5,...
          'EdgeColor','k');
end

set(findobj(gca,'Tag','Upper Whisker'),'Color','k')
set(findobj(gca,'Tag','Lower Whisker'),'Color','k')
set(findobj(gca,'Tag','Box'),'Color','k')

%% Mediana

medianas = findobj(gca,'Tag','Median');
set(medianas,'Color',opt.MedianColor,'LineWidth',2)

%% Línea conectando medianas

if opt.ShowMedianLine

    x_mediana = zeros(1,length(medianas));
    y_mediana = zeros(1,length(medianas));

    for i = 1:length(medianas)
        x_mediana(i) = mean(get(medianas(i),'XData'));
        y_mediana(i) = mean(get(medianas(i),'YData'));
    end

    hold on
    plot(x_mediana,y_mediana,'--*','Color','k','LineWidth',2,'MarkerFaceColor','k')
    hold off

end

%% Formato ejes

xlabel(opt.Xlabel,'FontSize',14,'FontWeight','bold','FontName','Calibri')
ylabel(opt.Ylabel,'FontSize',14,'FontWeight','bold','FontName','Calibri')

grid on
set(gca,'FontSize',12,'FontName','Calibri','Box','off')

%% Guardar la figura
dpi = 300;
if ~isempty(opt.save_dir) % Guardar figura si existe la dirección
    cd(opt.save_dir)
    if strcmp(opt.ext, 'fig')
        saveas(f, opt.name, opt.ext)
    else
        print(f, opt.name, strcat('-d',opt.ext), strcat('-r',num2str(dpi)))
    end
    %cd(path)
end

end


%% Basado en el siguiente código:

% figure('Color', 'w','Position',[327,415,913,463]);
% box_handle = boxplot(var, meses, 'Labels', {'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'}, ...
%     'Whisker', 1.5, 'Symbol', '*','Colors',[0.4 0.6 0.4], 'Widths', 0.6,'BoxStyle','outline','Notch','on');
% 
% % **Cambiar color de las cajas a verde**
% color_verde = [0.4 0.6 0.4]; % Verde en RGB
% cajas = findobj(gca, 'Tag', 'Box'); % Encontrar las cajas en el gráfico
% for i = 1:length(cajas)
%     patch(get(cajas(i), 'XData'), get(cajas(i), 'YData'), color_verde, 'FaceAlpha', 0.5, 'EdgeColor', 'k'); 
% end
% set(findobj(gca, 'Tag', 'Upper Whisker'), 'Color', 'k'); % Extremo superior en negro
% set(findobj(gca, 'Tag', 'Lower Whisker'), 'Color', 'k'); % Extremo inferior en negro
% set(findobj(gca, 'Tag', 'Box'), 'Color', 'k');  % Bordes de la caja en negro
% 
% % **Cambiar color de la línea de la mediana a rojo**
% medianas = findobj(gca, 'Tag', 'Median'); % Buscar líneas de la mediana
% set(medianas, 'Color', [0.4 0.6 0.4], 'LineWidth', 2); % Cambiar a rojo y hacerla más gruesa
% 
% x_mediana = zeros(1, length(medianas)); % Inicializar vector de posiciones en x
% y_mediana = zeros(1, length(medianas)); % Inicializar vector de posiciones en y
% 
% for i = 1:length(medianas)
%     x_mediana(i) = mean(get(medianas(i), 'XData')); % Posición en X de la mediana
%     y_mediana(i) = mean(get(medianas(i), 'YData')); % Posición en Y de la mediana
% end
% 
% hold on;
% plot(x_mediana, y_mediana, '--*', 'Color', 'k', 'LineWidth', 2, 'MarkerFaceColor', 'k'); % Línea negra con marcadores
% hold off;
% 
% % Mejorar etiquetas
% xlabel('Mes', 'FontSize', 14, 'FontWeight', 'bold','FontName','calibri');
% ylabel('Hs (m)', 'FontSize', 14, 'FontWeight', 'bold','FontName','calibri');
% % title('Distribución Mensual de Velocidad del Viento', 'FontSize', 16, 'FontWeight', 'bold');
% grid on;
% set(gca, 'FontSize', 12, 'FontName', 'Calibri', 'Box', 'off');