function verify_nc_variables(ncFile, requiredVars, opts)
%verify_nc_variables verifica la existencia de variables en archivo netCDF

%% Manejo de entradas
arguments
    ncFile 
    requiredVars 
    opts.dispFlag (1,1) logical = false
end

%% Verificaciones iniciales
if ~isfile(ncFile)
    error('El archivo NetCDF no existe: %s', ncFile);
end

%% Verificación de variables

if opts.dispFlag
    fprintf('\nVerificando variables requeridas:\n')
    fprintf('Variables requeridas: %s\n', strjoin(requiredVars, ', '))
end

%Variables disponibles
info = ncinfo(ncFile);
availableVars = {info.Variables.Name};

%Variables faltantes
missing = setdiff(requiredVars, availableVars);

if ~isempty(missing)
    warning('Faltan variables requeridas en el NetCDF: %s\n', strjoin(missing, ', '));
end

end