# ============================================================================
# INEC | MÓDULOS 5 Y 6 | PASO 0: PREPARAR EL AMBIENTE
# Definiciones: archivo fuente, tabla, fila, variable, NA, copia de trabajo.
# OBJETIVO: cargar archivos como texto para no perder códigos o semántica.
# ============================================================================

# EJERCICIO 0.1: instalar una única vez si hace falta (descomentar):
# install.packages(c("here", "readr", "dplyr", "tidyr", "ggplot2", "tibble"))

# EJERCICIO 0.2: cargar bibliotecas antes de utilizar %>%
# EXPLICACIÓN DOCENTE | CONCEPTO: un paquete es un conjunto de funciones; library(paquete) lo deja disponible.
# EXPLICACIÓN DOCENTE | OBJETIVO: preparar las herramientas antes de utilizar %>% o ggplot().
# EXPLICACIÓN DOCENTE | ARGUMENTO: el nombre del paquete se escribe sin comillas dentro de library().
# EXPLICACIÓN DOCENTE | NOTA: install.packages() descarga e instala (una vez); library() carga en la sesión (cada vez).
# ----------------------------------------------------------------------
library(here)     # rutas relativas al archivo .Rproj
library(readr)    # importación y exportación de CSV
library(dplyr)    # filtros, transformaciones, resúmenes y joins
library(tidyr)    # transformación de tablas
library(ggplot2)  # gráficos estadísticos

# 'Origen': bytes y contenido de entrada que NO deben sobrescribirse.
# EXPLICACIÓN DOCENTE | CONCEPTO: ruta relativa = ubicación a partir de la carpeta raíz del .Rproj.
# EXPLICACIÓN DOCENTE | OBJETIVO: que el proyecto funcione en otros equipos sin usar C:/Usuarios/....
# EXPLICACIÓN DOCENTE | here::here('data_raw', 'archivo.csv') devuelve la ruta completa; :: permite acceder a una función sin library().
# ----------------------------------------------------------------------
ruta_personas <- here::here("data_raw", "personas_encuesta_sintetica_2026_10.csv")
ruta_hogares <- here::here("data_raw", "hogares_catalogo_sintetico_2026_10.csv")
# EXPLICACIÓN DOCENTE | OBJETIVO: detenerse antes de continuar si falta un archivo.
# EXPLICACIÓN DOCENTE | file.exists(ruta) devuelve TRUE o FALSE; stopifnot() exige todas las condiciones TRUE.
# EXPLICACIÓN DOCENTE | Si falla, revise el .Rproj, el nombre exacto y la carpeta data_raw/.
# ----------------------------------------------------------------------
stopifnot(file.exists(ruta_personas), file.exists(ruta_hogares))

# Importar TODO como texto permite evaluar formatos antes de convertir columnas.
# EXPLICACIÓN DOCENTE | CONCEPTO: importación conservadora = leer primero en texto sin suponer tipos.
# EXPLICACIÓN DOCENTE | read_csv(file=...): lee columnas separadas por comas.
# EXPLICACIÓN DOCENTE | cols(.default=col_character()): todas las columnas entran como texto.
# EXPLICACIÓN DOCENTE | na="NA": solo este literal se traduce inicialmente a ausencia.
# EXPLICACIÓN DOCENTE | trim_ws=FALSE: NO elimina espacios; interesa detectar anomalías.
# EXPLICACIÓN DOCENTE | locale(encoding="UTF-8"): interpreta tildes y otros caracteres Unicode.
# EXPLICACIÓN DOCENTE | show_col_types=FALSE: evita el mensaje automático de tipos.
# EXPLICACIÓN DOCENTE | SALIDA: tibble 'personas_raw' sin modificar el CSV físico.
# ----------------------------------------------------------------------
personas_raw <- readr::read_csv(
  file = ruta_personas,
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA",        # solo la cadena literal NA se traduce a ausencia inicialmente
  trim_ws = FALSE,   # retener espacios para descubrir errores de codificación
  locale = readr::locale(encoding = "UTF-8"),
  show_col_types = FALSE
)
# EXPLICACIÓN DOCENTE | OBJETIVO: importar la tabla padre auxiliar usando el mismo criterio de lectura.
# EXPLICACIÓN DOCENTE | CONCEPTO: catálogo de hogares ≠ tabla de personas; cada archivo tiene su propio grano.
# ----------------------------------------------------------------------
hogares_raw <- readr::read_csv(
  ruta_hogares,
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA", trim_ws = FALSE, show_col_types = FALSE
)

# DEFINICIÓN: 'marcador de ausencia' es un texto utilizado en lugar de un dato.
# Esta función unifica ausencias SOLO en objetos de memoria; no altera el CSV.
# EXPLICACIÓN DOCENTE | CONCEPTO: función propia = algoritmo reutilizable parametrizado por x.
# EXPLICACIÓN DOCENTE | OBJETIVO: reconocer NA, vacío, N/D y SIN DATO en memoria, sin corregir el origen.
# EXPLICACIÓN DOCENTE | as.character() fuerza representación textual; trimws() quita espacios externos;
# EXPLICACIÓN DOCENTE | toupper() estandariza mayúsculas para comparar; %in% comprueba pertenencia;
# EXPLICACIÓN DOCENTE | NA_character_ identifica ausencia de tipo carácter.
# EXPLICACIÓN DOCENTE | PRECAUCIÓN: las codificaciones válidas de ausencia deben derivarse del diccionario.
# ----------------------------------------------------------------------
limpiar_ausencias <- function(x) {
  y <- trimws(as.character(x))
  y[is.na(y) | toupper(y) %in% c("", "NA", "N/D", "SIN DATO")] <- NA_character_
  y
}

# Índice físico de fila: +1 porque la primera línea del CSV es la cabecera.
# Tabla de trabajo: mantiene los 27 campos originales más variables auxiliares.
# EXPLICACIÓN DOCENTE | OBJETIVO: crear datos derivados listos para controles.
# EXPLICACIÓN DOCENTE | %>% envía el resultado izquierdo a la primera entrada de la función derecha.
# EXPLICACIÓN DOCENTE | mutate() agrega o modifica columnas de un objeto nuevo.
# EXPLICACIÓN DOCENTE | row_number()+1L da la línea física (1L es un entero; línea 1=encabezado).
# EXPLICACIÓN DOCENTE | suppressWarnings(as.numeric(...)) convierte texto en número sin imprimir avisos;
# EXPLICACIÓN DOCENTE | las conversiones inválidas pasan a NA: COMPARAR con texto original antes de asumir ausencia.
# EXPLICACIÓN DOCENTE | Variables con sufijo _n son derivadas; no reemplazan columnas originales.
# ----------------------------------------------------------------------
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
# EXPLICACIÓN DOCENTE | OBJETIVO: armonizar SOLO la clave de hogar para relacionar archivos.
# EXPLICACIÓN DOCENTE | No crear personas u hogares faltantes: eso requeriría evidencia externa.
# ----------------------------------------------------------------------
hogares <- hogares_raw %>%
  mutate(id_hogar = limpiar_ausencias(id_hogar))

# PAUSA: el estudiante responde antes de continuar:
# ¿Por qué 'H00001' es texto y no número? ¿Qué significa 0.00 frente a NA?
# EXPLICACIÓN DOCENTE | OBJETIVO: inspeccionar el tamaño; cat() concatena textos y valores.
# EXPLICACIÓN DOCENTE | nrow() cuenta filas, ncol() cuenta variables y "\n" introduce un salto de línea.
# EXPLICACIÓN DOCENTE | El reporte es diagnóstico, NO garantía de calidad.
# ----------------------------------------------------------------------
cat("Personas:", nrow(personas), "registros;", ncol(personas_raw), "variables de origen\n")
cat("Hogares auxiliares:", nrow(hogares), "filas\n")
# NO usar write_csv sobre 'ruta_personas'.
