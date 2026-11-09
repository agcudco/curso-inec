# ============================================================================
# INEC | MÓDULOS 5 Y 6 | PASO 0: PREPARAR EL AMBIENTE
# Definiciones: archivo fuente, tabla, fila, variable, NA, copia de trabajo.
# OBJETIVO: cargar archivos como texto para no perder códigos o semántica.
# ============================================================================

# EJERCICIO 0.1: instalar una única vez si hace falta (descomentar):
# install.packages(c("here", "readr", "dplyr", "tidyr", "ggplot2", "tibble"))

# EJERCICIO 0.2: cargar bibliotecas antes de utilizar %>%
library(here)     # rutas relativas al archivo .Rproj
library(readr)    # importación y exportación de CSV
library(dplyr)    # filtros, transformaciones, resúmenes y joins
library(tidyr)    # transformación de tablas
library(ggplot2)  # gráficos estadísticos

# 'Origen': bytes y contenido de entrada que NO deben sobrescribirse.
ruta_personas <- here::here("data_raw", "personas_encuesta_sintetica_2026_10.csv")
ruta_hogares <- here::here("data_raw", "hogares_catalogo_sintetico_2026_10.csv")
stopifnot(file.exists(ruta_personas), file.exists(ruta_hogares))

# Importar TODO como texto permite evaluar formatos antes de convertir columnas.
personas_raw <- readr::read_csv(
  file = ruta_personas,
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA",        # solo la cadena literal NA se traduce a ausencia inicialmente
  trim_ws = FALSE,   # retener espacios para descubrir errores de codificación
  locale = readr::locale(encoding = "UTF-8"),
  show_col_types = FALSE
)
hogares_raw <- readr::read_csv(
  ruta_hogares,
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA", trim_ws = FALSE, show_col_types = FALSE
)

# DEFINICIÓN: 'marcador de ausencia' es un texto utilizado en lugar de un dato.
# Esta función unifica ausencias SOLO en objetos de memoria; no altera el CSV.
limpiar_ausencias <- function(x) {
  y <- trimws(as.character(x))
  y[is.na(y) | toupper(y) %in% c("", "NA", "N/D", "SIN DATO")] <- NA_character_
  y
}

# Índice físico de fila: +1 porque la primera línea del CSV es la cabecera.
# Tabla de trabajo: mantiene los 27 campos originales más variables auxiliares.
personas <- personas_raw %>%
  mutate(
    fila_csv = dplyr::row_number() + 1L,
    id_persona = limpiar_ausencias(id_persona),
    id_hogar = limpiar_ausencias(id_hogar),
    provincia = limpiar_ausencias(provincia),
    area = limpiar_ausencias(area),
    sexo = limpiar_ausencias(sexo),
    condicion_actividad = limpiar_ausencias(condicion_actividad),
    edad_n = suppressWarnings(as.numeric(limpiar_ausencias(edad))),
    horas_n = suppressWarnings(as.numeric(limpiar_ausencias(horas_trabajo_semana))),
    ingreso_n = suppressWarnings(as.numeric(limpiar_ausencias(ingreso_mensual_usd)))
  )
hogares <- hogares_raw %>%
  mutate(id_hogar = limpiar_ausencias(id_hogar))

# PAUSA: el estudiante responde antes de continuar:
# ¿Por qué 'H00001' es texto y no número? ¿Qué significa 0.00 frente a NA?
cat("Personas:", nrow(personas), "registros;", ncol(personas_raw), "variables de origen\n")
cat("Hogares auxiliares:", nrow(hogares), "filas\n")
# NO usar write_csv sobre 'ruta_personas'.
