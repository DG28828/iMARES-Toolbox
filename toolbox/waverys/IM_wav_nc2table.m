function [T, meta] = IM_wav_nc2table(ncFile, opts)
%IM_wav_nc2table Convierte un NetCDF WAVERYS de un nodo a tabla MATLAB.
%
%   [T, meta] = IM_wav_nc2table(ncFile) lee un archivo NetCDF
%   descargado desde WAVERYS y devuelve una tabla con los parámetros
%   de oleaje de interés.
%
%   [T, meta] = IM_wav_nc2table(ncFile, Name, Value) permite definir
%   opciones adicionales:
%
%       'ExportFile'          Ruta de archivo para exportar la tabla.
%                             Si se deja vacío, no exporta. Default: ''.
%       'IncludeTime'         Incluye columna Time tipo datetime. Default: true.
%       'IncludeDateColumns'  Incluye columnas Year, Mes, Dia, Hora.
%                             Default: true.
%       'Overwrite'           Sobrescribe el archivo de exportación si existe.
%                             Default: true.
%
%   Variables esperadas en el NetCDF:
%       latitude, longitude, time, VHM0, VTPK, VTM02, VTM10, VMDR, VPED
%
%   Salida T:
%       Time | Year | Mes | Dia | Hora | Hm0 | Tp | Tm02 | Te | Dm | Dp
%
%   Nota:
%       Esta función está pensada para archivos WAVERYS que contienen un
%       único nodo espacial. Si el archivo contiene varios nodos, se genera
%       un error para evitar mezclar puntos.
%

%% Manejo de entradas

arguments
    ncFile {mustBeTextScalar}
    opts.ExportFile {mustBeTextScalar}
    opts.IncludeTime (1,1) logical = true
    opts.IncludeDateColumns (1,1) logical = true
    opts.Overwrite (1,1) logical = true
    opts.dispFlag (1,1) logical = false
end

% Resultados
ncFile = char(ncFile);
ExportFile = opts.ExportFile;
includeTime = opts.IncludeTime;
includeDateColumns = opts.IncludeDateColumns;
overwrite = opts.Overwrite;
dispFlag = opts.dispFlag;

%% Mensaje inicial
if dispFlag
    fprintf('\n----- Extrayendo parámetros de archivo netCDF -----\n');
end

%% Verificaciones iniciales

if ~isfile(ncFile)
    error('El archivo NetCDF no existe: %s', ncFile);
end

%Verificar variables requeridas
requiredVars = {'latitude','longitude','time','VHM0','VTPK','VTM02','VTM10','VMDR','VPED'};
verify_nc_variables(ncFile, requiredVars, "dispFlag", dispFlag);

%% Leer datos

latitude = squeeze(ncread(ncFile, 'latitude'));
longitude = squeeze(ncread(ncFile, 'longitude'));
if numel(latitude) ~= 1 || numel(longitude) ~= 1
    error(['El archivo contiene más de un nodo espacial. ', ...
         'Esta función requiere un NetCDF con un único punto.']);
end

timeRaw = squeeze(ncread(ncFile, 'time'));
Time = read_cmems_time(ncFile, timeRaw);

Hm0  = read_nc_column(ncFile, 'VHM0');
Tp   = read_nc_column(ncFile, 'VTPK');
Tm02 = read_nc_column(ncFile, 'VTM02');
Te   = read_nc_column(ncFile, 'VTM10');
Dm   = read_nc_column(ncFile, 'VMDR');
Dp   = read_nc_column(ncFile, 'VPED');

nTime = numel(Time);
dataVars = {Hm0, Tp, Tm02, Te, Dm, Dp};
dataNames = {'Hm0','Tp','Tm02','Te','Dm','Dp'};
for k = 1:numel(dataVars)
    if isempty(dataVars{k})
        dataVars{k} = NaN(size(Time));
    end
    if numel(dataVars{k}) ~= nTime
        error('La variable %s tiene %d datos, pero Time tiene %d.', ...
            dataNames{k}, numel(dataVars{k}), nTime);
    end
end

T = table(Hm0, Tp, Tm02, Te, Dm, Dp);

if includeDateColumns
    T = addvars(T, year(Time), month(Time), day(Time), hour(Time), ...
        'Before', 'Hm0', ...
        'NewVariableNames', {'Year','Month','Day','Hour'});
    if dispFlag
        fprintf('\nIncluidas las columnas de fecha {''Year'',''Month'',''Day'',''Hour''}\n')
    end
end

if includeTime
    T = addvars(T, Time, 'Before', 1, 'NewVariableNames', 'Time');
    if dispFlag
        fprintf('\nIncluido el vector de tiempo en formato datetime\n')
    end
end

% Ordenar y eliminar tiempos duplicados, conservando el primer registro.
if includeTime
    T = sortrows(T, 'Time');
    [~, ia] = unique(T.Time, 'stable');
    T = T(ia, :);
end

meta = struct();
meta.Source = 'WAVERYS / CMEMS Global Ocean Waves Reanalysis';
meta.File = ncFile;
meta.Latitude = double(latitude);
meta.Longitude = double(longitude);
meta.TimeStart = Time(1);
meta.TimeEnd = Time(end);
meta.NRecords = height(T);
meta.Variables = dataNames;

if ~isempty(ExportFile)
    exportFolder = fileparts(ExportFile);
    if ~isempty(exportFolder) && ~isfolder(exportFolder)
        mkdir(exportFolder);
    end

    if isfile(ExportFile)
        if overwrite
            delete(ExportFile);
                if dispFlag
                    fprintf('\nLa tabla exportada existe y overwrite=true, sobreescribiendo...\n')
                end 
        else
            error('El archivo de exportación ya existe, use overwrite = true para sobrescribir: %s', ExportFile);
        end
    end

    writetable(T, ExportFile);
    meta.ExportFile = ExportFile;
    if dispFlag
        fprintf('\nTabla exportada correctamente\n')
    end
end

%% Mensaje final
if dispFlag
    fprintf('\nParámetros extraidos correctamente\n')
    fprintf('\n---------------------------------------------------\n');
end

end

%% Funciones auxiliares

function x = read_nc_column(ncFile, varName)
    try 
        x = squeeze(ncread(ncFile, varName));
        x = double(x(:));
    catch
        x = [];
    end
end

function Time = read_cmems_time(ncFile, timeRaw)
    timeRaw = double(timeRaw(:));

    try
        units = ncreadatt(ncFile, 'time', 'units');
    catch
        units = '';
    end

    unitsLower = lower(string(units));

    if contains(unitsLower, 'since')
        tokens = regexp(char(unitsLower), ...
            '(seconds|second|hours|hour|days|day)\s+since\s+([0-9]{4}-[0-9]{2}-[0-9]{2})(?:[ t]([0-9]{2}:[0-9]{2}:[0-9]{2}))?', ...
            'tokens', 'once');

        if ~isempty(tokens)
            unitName = tokens{1};
            originDate = tokens{2};
            if numel(tokens) >= 3 && ~isempty(tokens{3})
                originTime = tokens{3};
            else
                originTime = '00:00:00';
            end

            origin = datetime([originDate ' ' originTime], ...
                'InputFormat', 'yyyy-MM-dd HH:mm:ss', ...
                'TimeZone', 'UTC');

            switch unitName
                case {'seconds','second'}
                    Time = origin + seconds(timeRaw);
                case {'hours','hour'}
                    Time = origin + hours(timeRaw);
                case {'days','day'}
                    Time = origin + days(timeRaw);
                otherwise
                    error('Unidad temporal no reconocida.');
            end
            return
        end
    end

    % Respaldo para los archivos que usan POSIX time, como el script original.
    Time = datetime(timeRaw, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
end



