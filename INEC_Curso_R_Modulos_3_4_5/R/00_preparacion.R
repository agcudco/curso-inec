# =============================================================================
# INEC · Curso de calidad de datos en R · BASE DE PARTIDA
# Este archivo se construye durante la clase. No modifica el CSV de origen.
# Se ejecuta por secciones en RStudio con Ctrl+Enter.
# =============================================================================

# PASO 0.1 · Instalar UNA SOLA VEZ desde la consola (descomentar si hace falta):
# install.packages(c("here", "readr", "dplyr", "tidyr", "ggplot2", "tibble"))

# PASO 0.2 · Cargar librerías antes de utilizar %>%.
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tibble)

# PASO 0.3 · Crear la ruta relativa del archivo proporcionado.
archivo_csv <- here::here("data_raw", "personas_encuesta_sintetica_2026_10.csv")
if (!file.exists(archivo_csv)) stop("No se encuentra el CSV en data_raw/")

# PASO 0.4 · Importar TODAS las variables como texto para preservar su forma.
# El marcador NA se reconoce; celdas vacías, N/D y SIN DATO se examinarán después.
datos <- readr::read_csv(
  file = archivo_csv,
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA",
  trim_ws = FALSE,
  locale = readr::locale(encoding = "UTF-8"),
  show_col_types = FALSE
)

# PASO 0.5 · Verificación inicial (no es aún un certificado de calidad).
dim(datos)             # Esperado: 1500 filas y 27 columnas
names(datos)           # Revisar encabezados
head(datos, 5)         # Primeros cinco registros
readr::problems(datos) # Puede dar 0 problemas aunque haya datos incorrectos.

# PASO 0.6 · Funciones reutilizables para ausencias y números.
# La ausencia es un concepto distinto de un valor numérico 0.
es_ausente <- function(x) {
  texto <- toupper(trimws(as.character(x)))
  is.na(texto) | texto %in% c("", "NA", "N/D", "SIN DATO")
}

# Conversión conservadora: no convierte silenciosamente textos como '1.250,50'.
# Las advertencias de conversión se investigarán en el módulo 3.
numero_estricto <- function(x) {
  suppressWarnings(readr::parse_double(
    x,
    na = c("", "NA", "N/D", "SIN DATO"),
    locale = readr::locale(decimal_mark = ".")
  ))
}

# TODO de clase: ¿Por qué '0.00' no aparece en la lista de ausencias?
