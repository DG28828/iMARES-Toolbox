function [datos_procesados, info] = IM_split_months_seasons(datos_usuario, tipo_datos, nodos, nodo, opts)
%IM_split_months_seasons Filtra y particiona series de reanálisis por meses y temporadas.
%
%   [datos_procesados, info] = IM_split_months_seasons(datos_usuario, tipo_datos, nodos, nodo)
%   filtra las series temporales contenidas en datos_usuario según los nodos
%   solicitados y reorganiza las variables en una estructura con datos
%   completos, mensuales y, opcionalmente, estacionales.
%
%   [datos_procesados, info] = IM_split_months_seasons(..., Name, Value)
%   permite definir opciones adicionales mediante argumentos Nombre-Valor,
%   como el rango de fechas de interés y las temporadas a procesar.
%
% -------------------------------------------------------------------------
% ENTRADAS OBLIGATORIAS
% -------------------------------------------------------------------------
%
% datos_usuario:
%   Struct con los datos originales reorganizados en un formato estándar.
%   Debe contener, como mínimo:
%
%       datos_usuario.fecha : [N x 4] o [N x 6]
%           Matriz de fechas en formato:
%               [Año Mes Día Hora]
%           o:
%               [Año Mes Día Hora Minuto Segundo]
%
%       datos_usuario.nodes : [1 x P] o [P x 1]
%           Identificadores de los nodos, puntos o ubicaciones disponibles.
%
%   Para tipo_datos = "oleaje", debe contener además:
%
%       datos_usuario.Hs : [N x P]
%       datos_usuario.Tp : [N x P]
%       datos_usuario.DD : [N x P]
%
%   Para tipo_datos = "viento", debe contener además:
%
%       datos_usuario.W  : [N x P]
%       datos_usuario.Dw : [N x P]
%
%   Donde:
%       N = número de registros temporales.
%       P = número de nodos, puntos o ubicaciones.
%
% tipo_datos:
%   Tipo de base de datos a procesar. Opciones:
%
%       "oleaje" : procesa Hs, Tp y DD.
%       "viento" : procesa W y Dw.
%
% nodos:
%   Vector con los identificadores de los nodos o puntos que se desean
%   extraer desde datos_usuario.nodes.
%
% nodo:
%   Índice dentro del vector "nodos" que se usará posteriormente para
%   exportaciones o gráficos. En esta función se utiliza únicamente para
%   validar que el índice sea consistente.
%
% -------------------------------------------------------------------------
% ARGUMENTOS OPCIONALES NOMBRE-VALOR
% -------------------------------------------------------------------------
%
% "Fecha_inicial":
%   Fecha inicial del periodo de análisis, en formato:
%
%       [AAAA MM DD HH]
%
%   Si se deja vacío [], se utiliza la primera fecha disponible.
%
% "Fecha_final":
%   Fecha final del periodo de análisis, en formato:
%
%       [AAAA MM DD HH]
%
%   Si se deja vacío [], se utiliza la última fecha disponible.
%
% "seasons":
%   String array con los subconjuntos temporales que se desea generar.
%   Opciones disponibles:
%
%       "all"  : serie completa filtrada.
%       "high" : temporada alta.
%       "low"  : temporada baja.
%
%   Ejemplos:
%
%       "seasons", "all"
%       "seasons", ["high", "low"]
%       "seasons", ["high", "low", "all"]
%
% "high_months":
%   Vector con los meses asociados a la temporada alta.
%   Por ejemplo:
%
%       "high_months", [12 1 2]
%
%   Solo es obligatorio si "seasons" contiene "high".
%
% "low_months":
%   Vector con los meses asociados a la temporada baja.
%   Por ejemplo:
%
%       "low_months", [9 10]
%
%   Solo es obligatorio si "seasons" contiene "low".
%
% -------------------------------------------------------------------------
% SALIDAS
% -------------------------------------------------------------------------
%
% datos_procesados:
%   Struct con las series filtradas y reorganizadas. Su estructura general es:
%
%       datos_procesados.fechas.vect
%       datos_procesados.fechas.datetime
%       datos_procesados.fechas.fechas_high
%       datos_procesados.fechas.fechas_low
%
%       datos_procesados.params(i).Node
%       datos_procesados.params(i).Variable.all
%       datos_procesados.params(i).Variable.enero
%       datos_procesados.params(i).Variable.febrero
%       ...
%       datos_procesados.params(i).Variable.diciembre
%       datos_procesados.params(i).Variable.high
%       datos_procesados.params(i).Variable.low
%
%   Los campos "high" y "low" solo se llenan si fueron solicitados en
%   "seasons".
%
% info:
%   Struct auxiliar con metadatos del particionado:
%
%       info.tipo_datos
%       info.variables
%       info.direccion_variable
%       info.month_names
%       info.seasons
%       info.season_label
%       info.fecha_inicial_dt
%       info.fecha_final_dt
%       info.nodos
%       info.nodo
%
% -------------------------------------------------------------------------
% EJEMPLOS
% -------------------------------------------------------------------------
%
%   [datos_procesados, info] = IM_split_months_seasons( ...
%       datos_usuario, ...
%       "oleaje", ...
%       [28 29 30], ...
%       1, ...
%       "Fecha_inicial", [1993 1 1 0], ...
%       "Fecha_final", [2023 11 30 21], ...
%       "seasons", ["high", "low", "all"], ...
%       "high_months", [12 1 2], ...
%       "low_months", [9 10]);
%
%   [datos_procesados, info] = IM_split_months_seasons( ...
%       datos_usuario, ...
%       "viento", ...
%       1, ...
%       1, ...
%       "seasons", "all");
%
% -------------------------------------------------------------------------
% NOTAS
% -------------------------------------------------------------------------
%
%   - Si Fecha_inicial y Fecha_final se dejan vacías, se utiliza todo el
%     registro disponible.
%


%% Manejo de entradas

arguments
    datos_usuario struct
    tipo_datos (1,1) string {mustBeMember(tipo_datos, ["oleaje", "viento"])}
    nodos (1,:) double
    nodo (1,1) double {mustBeInteger, mustBePositive}

    opts.Fecha_inicial double = []
    opts.Fecha_final double = []
    opts.seasons (1,:) string = "all"
    opts.high_months (1,:) double = []
    opts.low_months (1,:) double = []
end

%Resultados
Fecha_inicial = opts.Fecha_inicial;
Fecha_final = opts.Fecha_final;
seasons = opts.seasons;
high_months = opts.high_months;
low_months = opts.low_months;

%% Verificaciones iniciales

seasons = string(opts.seasons);
seasons = unique(seasons, 'stable');

seasons_validas = ["all", "high", "low"];

if any(~ismember(seasons, seasons_validas))
    error('Las temporadas en "seasons" deben ser: "all", "high" o "low".');
end

if any(seasons == "high") && isempty(high_months)
    error('Debe especificar "high_months" si "seasons" contiene "high".');
end

if any(seasons == "low") && isempty(low_months)
    error('Debe especificar "low_months" si "seasons" contiene "low".');
end

if any(high_months < 1 | high_months > 12)
    error('"high_months" debe contener valores enteros entre 1 y 12.');
end

if any(low_months < 1 | low_months > 12)
    error('"low_months" debe contener valores enteros entre 1 y 12.');
end


%% Validación y creación de fechas estándar

if ~isfield(datos_usuario, "fecha")
    error('Falta el campo datos_usuario.fecha.');
end

if ~isfield(datos_usuario, "nodes")
    error('Falta el campo datos_usuario.nodes.');
end

% Asegurar que fecha tenga 6 columnas: [Año Mes Día Hora Min Seg]
if size(datos_usuario.fecha, 2) == 4
    datos_usuario.fecha = [ ...
        datos_usuario.fecha, ...
        zeros(size(datos_usuario.fecha, 1), 2)];
elseif size(datos_usuario.fecha, 2) ~= 6
    error(['datos_usuario.fecha debe tener tamaño [N x 4] o [N x 6]. ', ...
           'Formato esperado: [Año Mes Día Hora] o [Año Mes Día Hora Min Seg].']);
end

% Crear vector datetime
datos_usuario.datetime = datetime( ...
    datos_usuario.fecha(:, 1), ...
    datos_usuario.fecha(:, 2), ...
    datos_usuario.fecha(:, 3), ...
    datos_usuario.fecha(:, 4), ...
    datos_usuario.fecha(:, 5), ...
    datos_usuario.fecha(:, 6));



%% Filtrado por fechas y nodos

% -------------------------------------------------------------------------
% Filtrado por fechas
% -------------------------------------------------------------------------
% Si Fecha_inicial y Fecha_final están vacías, se utiliza todo el registro.
% Si solo una de las dos está vacía, se usa el extremo disponible de la
% serie temporal.

if isempty(Fecha_inicial)
    fecha_inicial_dt = min(datos_usuario.datetime);
else
    fecha_inicial_dt = datetime( ...
        Fecha_inicial(1), Fecha_inicial(2), Fecha_inicial(3), Fecha_inicial(4), 0, 0);
end

if isempty(Fecha_final)
    fecha_final_dt = max(datos_usuario.datetime);
else
    fecha_final_dt = datetime( ...
        Fecha_final(1), Fecha_final(2), Fecha_final(3), Fecha_final(4), 0, 0);
end

idx_fechas = datos_usuario.datetime >= fecha_inicial_dt & ...
             datos_usuario.datetime <= fecha_final_dt;

% -------------------------------------------------------------------------
% Filtrado por nodos o puntos
% -------------------------------------------------------------------------

[tf_nodos, idx_nodos] = ismember(nodos, datos_usuario.nodes);

if any(~tf_nodos)
    error('Uno o más nodos solicitados no existen en datos_usuario.nodes.');
end

%% Definición de variables a procesar

switch tipo_datos
    case "oleaje"
        variables = ["Hs", "Tp", "DD"];
        direccion_variable = "DD";
        %nombre_salida = "Parametros_Oleaje_Reanalisis_Mensuales_Temporadas.mat";

    case "viento"
        variables = ["W", "Dw"];
        direccion_variable = "Dw";
        %nombre_salida = "Parametros_Viento_Reanalisis_Mensuales_Temporadas.mat";

    otherwise
        error('tipo_datos debe ser "oleaje" o "viento".');
end

%% Validación de configuración del usuario y datos de entrada


seasons = unique(seasons, 'stable');

% Validar índice del nodo usado para gráficos/exportaciones
if nodo < 1 || nodo > numel(nodos)
    error('"nodo" debe ser un índice válido dentro del vector "nodos".');
end

% Validar rango de fechas
if fecha_inicial_dt > fecha_final_dt
    error('Fecha_inicial debe ser menor o igual que Fecha_final.');
end

% Validar que existan datos después del filtrado
if ~any(idx_fechas)
    error('No hay datos dentro del rango de fechas seleccionado.');
end


% Validación de datos de entrada
campos_requeridos = ["fecha", variables, "nodes"];

for c = 1:numel(campos_requeridos)

    campo = campos_requeridos(c);

    if ~isfield(datos_usuario, campo)
        error('Falta el campo datos_usuario.%s.', campo);
    end
end

N = size(datos_usuario.fecha, 1);
P = numel(datos_usuario.nodes);

for v = 1:numel(variables)

    var_name = variables(v);

    if size(datos_usuario.(var_name), 1) ~= N
        error('datos_usuario.%s debe tener el mismo número de filas que datos_usuario.fecha.', var_name);
    end

    if size(datos_usuario.(var_name), 2) ~= P
        error('datos_usuario.%s debe tener una columna por cada nodo/punto en datos_usuario.nodes.', var_name);
    end
end

%% Reorganización y procesamiento de datos

month_names = {'enero','febrero','marzo','abril','mayo','junio', ...
               'julio','agosto','setiembre','octubre','noviembre','diciembre'};

sub_struct = struct( ...
    'all', [], ...
    'low', [], ...
    'high', [], ...
    'enero', [], ...
    'febrero', [], ...
    'marzo', [], ...
    'abril', [], ...
    'mayo', [], ...
    'junio', [], ...
    'julio', [], ...
    'agosto', [], ...
    'setiembre', [], ...
    'octubre', [], ...
    'noviembre', [], ...
    'diciembre', [] ...
    );

datos_procesados = struct();

datos_procesados.fechas = struct( ...
    'vect', datos_usuario.fecha(idx_fechas, :), ...
    'datetime', datos_usuario.datetime(idx_fechas));

datos_procesados.params = struct();

for i = 1:numel(nodos)

    datos_procesados.params(i).Node = nodos(i);

    for v = 1:numel(variables)

        var_name = variables(v);

        datos_procesados.params(i).(var_name) = sub_struct;

        % Serie completa filtrada
        datos_procesados.params(i).(var_name).all = ...
            datos_usuario.(var_name)(idx_fechas, idx_nodos(i));

        % Separación mensual
        for m = 1:12
            idx_mes = datos_procesados.fechas.vect(:, 2) == m;

            datos_procesados.params(i).(var_name).(month_names{m}) = ...
                datos_procesados.params(i).(var_name).all(idx_mes);
        end
    end
end

%% Separación por temporadas

% -------------------------------------------------------------------------
% Esta sección calcula únicamente las temporadas solicitadas en "seasons".
% El campo "all" ya fue generado durante la reorganización mensual.
% -------------------------------------------------------------------------

% Etiquetas para nombres de figuras y archivos
season_label = struct();
season_label.high = "temporada_alta";
season_label.low  = "temporada_baja";
season_label.all  = "total";

% Fechas de temporada alta
if any(seasons == "high")

    idx_high = ismember(datos_procesados.fechas.vect(:, 2), high_months);
    datos_procesados.fechas.fechas_high = datos_procesados.fechas.vect(idx_high, :);

    for i = 1:numel(nodos)
        for v = 1:numel(variables)

            var_name = variables(v);

            datos_procesados.params(i).(var_name).high = ...
                datos_procesados.params(i).(var_name).all(idx_high);

        end
    end
end

% Fechas de temporada baja
if any(seasons == "low")

    idx_low = ismember(datos_procesados.fechas.vect(:, 2), low_months);
    datos_procesados.fechas.fechas_low = datos_procesados.fechas.vect(idx_low, :);

    for i = 1:numel(nodos)
        for v = 1:numel(variables)

            var_name = variables(v);

            datos_procesados.params(i).(var_name).low = ...
                datos_procesados.params(i).(var_name).all(idx_low);

        end
    end
end

%% Guardado de variables utiles
info = struct();

info.tipo_datos = tipo_datos;
info.variables = variables;
info.direccion_variable = direccion_variable;
info.month_names = month_names;
info.seasons = seasons;
info.season_label = season_label;
info.fecha_inicial_dt = fecha_inicial_dt;
info.fecha_final_dt = fecha_final_dt;
info.nodos = nodos;
info.nodo = nodo;

end