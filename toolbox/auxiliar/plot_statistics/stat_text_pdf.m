function Text = stat_text_pdf(var, unidad, x_fix, y_fix, step, font_text)
% stat_text_pdf crea el texto de los estadístcos \mu, \sigma, \chi y \beta
% de la PDF.

Text = {{x_fix,y_fix,['\mu: ',num2str(mean(var),'%.2f'),' ',char(unidad)],'k',font_text}, ...
        {x_fix,y_fix-step,['\sigma: ',num2str(std(var),'%.2f'),' ',char(unidad)],'k',font_text}, ...
        {x_fix,y_fix-2*step,['\chi: ',num2str(skewness(var),'%.2f')],'k',font_text}, ...
        {x_fix,y_fix-3*step,['\beta: ',num2str(kurtosis(var),'%.2f')],'k',font_text}};

end