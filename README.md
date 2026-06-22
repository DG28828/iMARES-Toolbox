# iMARES Toolbox

Toolbox de MATLAB para caracterizar estadísticamente bases de datos de parámetros de **oleaje** y **viento**. El toolbox permite trabajar con series temporales de parámetros, separarlas por meses y temporadas, generar gráficos estadísticos y exportar archivos de entrada para el programa **CAROL**.

## Funcionalidades principales

- Caracterización estadística total, mensual y estacional de bases de datos de **oleaje** con variables tipo altura de ola `H`, períodos `T` y dirección `Dir`.
- Caracterización estadística total, mensual y estacional de bases de datos de **viento** con variables tipo velocidad del viento `W` y dirección `Dw`.
- Filtrado por rango de fechas.
- Particionado de series por mes.
- Particionado por temporadas definidas por el usuario, por ejemplo temporada alta, baja y total.
- Generación de gráficos estadísticos mensuales y estacionales.
- Generación de boxplots mensuales, histogramas PDF, curvas CDF y rosas direccionales.
- Exportación de estructuras `.mat` con los datos procesados.
- Exportación de archivos `.dat` para uso en programa CAROL.
- Cálculo de estadísticos de validación entre datos observados y modelados.


## Scripts principales

### `waves_plot_script.m`

Script tipo plantilla para caracterizar bases de datos de oleaje. Incluye las etapas de configuración general, importación de datos, adaptación al formato estándar, configuración gráfica, particionado, exportación y generación de figuras.

Variables esperadas:

- `fechas`: fechas asociadas a las variables (Año, Mes, Día, Hora).
- `H`: variable asociada a altura de oleaje [m].
- `T`: variable asociada al periodo [s].
- `Dir`: variable asociada a la dirección del oleaje en convención náutica, desde donde viene el oleaje [°].

El script genera gráficos estadísticos para `H` y `T`, usando `Dir` como variable direccional para las rosas.

### `wind_plot_script.m`

Script tipo plantilla para caracterizar bases de datos de viento. Sigue el mismo flujo general que el script de oleaje, pero adaptado a las variables de viento.

Variables esperadas:

- `fechas`: fechas asociadas a las variables (Año, Mes, Día, Hora).
- `W`: variable asociada a la velocidad del viento [m/s].
- `Dw`: variable asociada a la dirección del viento en convención náutica, desde donde viene el viento [°].

El script genera gráficos estadísticos para `W`, usando `Dw` como variable direccional para las rosas.

### Notas de uso de los scipts

- Los scripts `waves_plot_script.m` y `wind_plot_script.m` están pensados como plantillas editables, se recomienda copiar la plantilla fuera del directorio de origen y realizar las modificaciones necesarias.
- La sección de importación debe adaptarse según el origen real de los datos.
- Los meses sin datos válidos se omiten en PDF, CDF y rosas direccionales.
- En los boxplots mensuales puede mantenerse el eje completo de enero a diciembre aunque existan meses vacíos.
- Las funciones eliminan valores `NaN` e `Inf` en las etapas donde se requiere graficar o calcular estadísticos.
- En el directorio de origen se incluyen datos de ejemplo y directorios de guardado, de forma que es posible ejecutar los script de plantilla para visualizar su funcionamiento.

## Funciones principales

| Función | Descripción |
|---|---|
| `IM_plot_statitics` | Genera gráficos estadísticos mensuales y estacionales para una variable seleccionada. Emplea las funciones `IM_plot_2D`, `IM_plot_histogram`, `IM_plot_box_mensual` e `IM_plot_rose`.|


## Funciones de graficación

| Función | Descripción |
|---|---|
| `IM_plot_2D` | Genera gráficos 2D personalizables para curvas individuales o múltiples. |
| `IM_plot_histogram` | Genera histogramas con diferentes normalizaciones, incluyendo PDF y CDF. |
| `IM_plot_box_mensual` | Genera boxplots mensuales y conserva meses vacíos cuando se requiere mostrar el eje completo de enero a diciembre. |
| `IM_plot_rose` | Genera rosas direccionales a partir de direcciones náuticas y magnitudes asociadas. |
| `IM_plot_scatter` | Genera gráficos de dispersión para validación con estadísticos de ajuste. |

## Otras funciones

| Función | Descripción |
|---|---|
| `IM_validation_coefficients` | Calcula estadísticos de validación entre datos observados y modelados. |

## Requisitos

- MATLAB 2024b o posterior.
- Statistics and Machine Learning Toolbox, requerido para funciones como `ecdf` y `boxplot`.
- Función externa `WindRose`, requerida por `IM_plot_rose` para generar rosas direccionales.

## Instalación

### Opción 1) Mediante el archivo de toolbox

Instalar el archivo .mltbx en la versión. Esta opción agrega automáticamente las dependencias y resuelve los paths.

### Opción 2) Descargando el código fuente 

Clone o descargue el repositorio y agregue sus carpetas al path de MATLAB:

```matlab
repo_dir = "C:\ruta\al\repositorio";
addpath(genpath(repo_dir));
```

