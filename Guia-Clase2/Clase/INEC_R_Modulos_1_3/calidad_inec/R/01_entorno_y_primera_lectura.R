# ============================================================
# CURSO INEC | MODULO 1 | Fundamentos de calidad y entorno R
# Taller guiado: escribir y ejecutar SOLO los bloques estudiados.
# Datos sinteticos: no contienen registros institucionales reales.
# ============================================================

# PASO 1. Instale UNA SOLA VEZ los paquetes desde Console:
# install.packages(c("here", "readr", "dplyr", "ggplot2"))
# No deje install.packages() activo en un script de produccion.

# PASO 2. Cargue las librerias que utilizaremos en el taller.
library(here)     # Construye rutas relativas al proyecto .Rproj.
library(readr)    # Importa archivos CSV.
library(dplyr)    # Organiza tablas y calcula resúmenes.

# PASO 3. Examine el proyecto que tiene abierto.
here::here()      # Debe apuntar a la carpeta calidad_inec.
getwd()          # Directorio de trabajo de la sesion actual.

# PASO 4. Defina una variable que guarde la ruta del archivo fuente.
archivo_csv <- here::here("data_raw", "personas_encuesta_sintetica_2026_10.csv")
file.exists(archivo_csv)  # Debe devolver TRUE si la carpeta esta bien ubicada.

# PASO 5. Realice una primera importacion conservadora.
# Como hay edades e ingresos mal codificados adrede, primero leeremos
# TODAS las columnas como texto. Esto preserva IDs y permite auditar.
# na="NA" convierte ese marcador literal en NA de R; los campos
# vacios se mantienen como cadena vacia para analizarlos por separado.
datos <- readr::read_csv(
  file = archivo_csv,
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA",
  trim_ws = FALSE,  # Mantener espacios de origen para revisarlos.
  locale = readr::locale(encoding = "UTF-8"),
  show_col_types = FALSE
)

# PASO 6. Primera observacion (NO modifica ni corrige el CSV).
dim(datos)         # Filas y columnas.
nrow(datos)        # Numero de registros.
ncol(datos)        # Numero de variables.
names(datos)       # Nombre de todas las columnas.
head(datos, 6)     # Primeros seis registros.
tail(datos, 3)     # Ultimos tres registros.
str(datos)         # Estructura de R.
dplyr::glimpse(datos) # Vista compacta, util en tablas anchas.

# PASO 7. Ejemplo de seleccion de una columna y resumen inicial.
head(datos$provincia, 10)  # Extrae una columna usando $.
length(datos$provincia)    # Cantidad de valores en esa columna.
table(datos$area, useNA = "ifany") # Frecuencia de cada categoria.

# ACTIVIDAD PARA CLASE:
# 1. Identifique que columna contiene una clave de persona.
# 2. Distinga entre el texto "N/D", la cadena "" y un valor NA.
# 3. Explique por que id_persona NO debe convertirse a numero.
