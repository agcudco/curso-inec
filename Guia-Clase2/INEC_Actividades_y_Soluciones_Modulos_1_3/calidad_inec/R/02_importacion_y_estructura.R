# ============================================================
# CURSO INEC | MODULO 2 | Importacion y diagnostico estructural
# PRERREQUISITO: haber recorrido 01_entorno_y_primera_lectura.R
# y mantener el objeto 'datos' en la sesion de RStudio.
# ============================================================

library(here)
library(readr)
library(dplyr)

if (!exists("datos")) {
  stop("Primero recorra R/01_entorno_y_primera_lectura.R para importar 'datos'.")
}

# PASO 1. Comparar lectura automatica frente a lectura conservadora.
# Esta lectura es diagnostica; readr infiere clases por su contenido.
datos_auto <- readr::read_csv(
  here::here("data_raw", "personas_encuesta_sintetica_2026_10.csv"),
  show_col_types = FALSE
)
readr::problems(datos_auto) # Puede haber 0 o varias incidencias de lectura.
dplyr::glimpse(datos_auto)
# Las 0 incidencias NO garantizan que la base sea correcta.

# PASO 2. Revisar la cabecera, los nombres y la estructura de datos.
names(datos)
dim(datos)
str(datos)
anyDuplicated(names(datos))   # 0 indica nombres de columna no repetidos.

# PASO 3. Importar el diccionario didactico del ejercicio.
diccionario <- readr::read_csv(
  here::here("diccionario", "diccionario_variables.csv"),
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA",
  show_col_types = FALSE
)
head(diccionario, 8)

# PASO 4. Comparar columnas presentes frente a columnas declaradas.
columnas_observadas <- names(datos)
columnas_esperadas <- diccionario$variable

faltan_columnas <- setdiff(columnas_esperadas, columnas_observadas)
columnas_extras <- setdiff(columnas_observadas, columnas_esperadas)
orden_coincide <- identical(columnas_observadas, columnas_esperadas)

faltan_columnas     # Debe ser character(0) en este archivo inicial.
columnas_extras     # Debe ser character(0) en este archivo inicial.
orden_coincide      # TRUE si los nombres y su orden son iguales.

# PASO 5. Crear una tabla descriptiva de tipos presentes y esperados.
# Todos los tipos importados seran character, intencionalmente.
# El tipo esperado expresa como interpretar la variable mas adelante.
tabla_estructura <- tibble::tibble(
  variable = names(datos),
  clase_importada = vapply(datos, function(x) class(x)[1], character(1))
) %>%
  left_join(
    diccionario %>% select(variable, tipo_esperado, obligatoria, control_exploratorio),
    by = "variable"
  )

print(tabla_estructura, n = nrow(tabla_estructura))

# PASO 6. Explorar si una variable que deberia ser numerica se
# convierte sin perdida. NO reemplazamos la variable original.
edad_num <- suppressWarnings(as.integer(datos$edad))

problemas_edad <- datos %>%
  mutate(
    fila_csv = row_number() + 1L, # +1 porque la primera linea es cabecera.
    edad_num = suppressWarnings(as.integer(edad)),
    es_marcador_ausencia = !is.na(edad) &
      toupper(trimws(edad)) %in% c("N/D", "SIN DATO")
  ) %>%
  filter(
    !is.na(edad),
    trimws(edad) != "",
    !es_marcador_ausencia,
    is.na(edad_num)
  ) %>%
  select(fila_csv, id_persona, edad, edad_num)

print(problemas_edad, n = 20)
# Interpretacion: se identifican cadenas no convertibles, pero todavia
# no se autorizan modificaciones de la base fuente.

# ACTIVIDAD PARA CLASE:
# 1. Busque una variable con tipo esperado 'decimal'.
# 2. Identifique los marcadores especiales del archivo.
# 3. Explique por que problems(datos_auto) y problemas_edad
#    responden a preguntas diferentes.
