# ==============================================================
# INEC | PLANTILLA PARA CONSTRUIR EN VIVO LOS MODULOS 1, 2 Y 3
# NO ES UNA SOLUCION EJECUTADA NI UN PIPELINE AUTOMATIZADO.
# Escriba cada instruccion cuando llegue al paso correspondiente
# de la guia GUIA_ESTUDIO_MODULOS_1_3.md.
# ==============================================================

# MODULO 1 | PASO 1: cargar paquetes necesarios
# TODO: library(...)

# MODULO 1 | PASO 2: localizar el archivo .csv dentro de data_raw
# TODO: archivo_csv <- here::here(...)

# MODULO 1 | PASO 3: leer todas las columnas como texto
# TODO: datos <- readr::read_csv(...)

# MODULO 1 | PASO 4: observar dimensiones, columnas y primeras filas
# TODO: dim(datos), names(datos), head(datos)

# MODULO 2 | PASO 5: leer diccionario y comparar nombres de columnas
# TODO: diccionario <- readr::read_csv(...)
# TODO: setdiff(...)

# MODULO 2 | PASO 6: examinar conversiones de edad sin modificar la fuente
# TODO: as.integer(...)

# MODULO 3 | PASO 7: cuantificar NA, vacios y marcadores de ausencia
# TODO: is.na(...), trimws(...), %in%

# MODULO 3 | PASO 8: identificar claves repetidas
# TODO: count(...) y filter(...)

# MODULO 3 | PASO 9: construir frecuencias y graficos descriptivos
# TODO: ggplot(...), geom_col(...), geom_histogram(...)

# MODULO 3 | PASO 10: registrar hallazgos, SIN depurar
# TODO: incidencias_iniciales <- tibble::tibble(...)
