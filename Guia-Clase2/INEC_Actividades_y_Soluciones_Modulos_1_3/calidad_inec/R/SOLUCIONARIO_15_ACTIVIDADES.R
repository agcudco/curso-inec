# ============================================================================
# INEC | SOLUCIONARIO DOCENTE - MODULOS 1, 2 Y 3
# Curso: Evaluacion de archivos de datos y reportes de calidad en R
# Caso: encuesta de personas y hogares SINTETICA (1.500 x 27)
# ============================================================================
# USO DIDACTICO:
# - Abrir calidad_inec.Rproj y construir este archivo POR BLOQUES.
# - No ejecutar todo al comenzar. Seleccionar lineas y Ctrl + Enter.
# - La base fuente queda intacta. Ninguna instruccion depura ni sobreescribe CSV.
# - Los umbrales (edad 0-110) son ilustrativos, NO normas del INEC.
# - Las cifras del caso no son estadisticas oficiales.
# ============================================================================

# MODULO 1 -------------------------------------------------------------------

# ACTIVIDAD 1 | Seis criterios operativos de calidad
# No requiere codigo: clasificar ejemplos de estructura, completitud,
# unicidad, consistencia, validez y trazabilidad en la hoja de actividades.

# ACTIVIDAD 2 | Objetos, vectores, funciones y NA en R
n_registros_esperados <- 1500
nombre_curso <- "Evaluacion de archivos de datos en R"
es_sintetico <- TRUE
edades_prueba <- c(18, 20, NA, 22)

class(n_registros_esperados)     # numeric
class(nombre_curso)            # character
class(es_sintetico)            # logical
length(edades_prueba)          # 4 elementos
is.na(edades_prueba)           # Solo el tercer elemento es TRUE
mean(edades_prueba, na.rm = TRUE) # 20 (no elimina ni corrige el NA)

# ACTIVIDAD 3 | Proyecto RStudio y rutas relativas
# Crear con File > New Project > New Directory > New Project
# y comprobar que el archivo calidad_inec.Rproj aparece en la carpeta raiz.
library(here)
library(readr)
library(dplyr)
library(ggplot2)

here::here()                   # Carpeta raiz reconocida por el proyecto
getwd()                       # Directorio de trabajo
archivo_csv <- here::here(
  "data_raw", "personas_encuesta_sintetica_2026_10.csv"
)
file.exists(archivo_csv)       # Esperado: TRUE

# ACTIVIDAD 4 | Lectura conservadora del CSV
# "NA" se reconoce como NA; los espacios y cadenas vacias se conservan.
# Todas las columnas se reciben como texto para no perder evidencia.
datos <- readr::read_csv(
  file = archivo_csv,
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA",
  trim_ws = FALSE,
  locale = readr::locale(encoding = "UTF-8"),
  show_col_types = FALSE
)

# ACTIVIDAD 5 | Exploracion inicial
nrow(datos)                     # 1500
ncol(datos)                     # 27
dim(datos)                      # c(1500, 27)
names(datos)                    # nombres de las 27 variables
head(datos, 6)                 # primeras seis filas
str(datos)                     # estructura, inicialmente character
dplyr::glimpse(datos)          # exploracion compacta
# area: Urbana 751, Rural 719, urban 14, vacio 9 y NA 7
# (las categorias se conservan literalmente en esta etapa).
table(datos$area, useNA = "ifany")

# MODULO 2 -------------------------------------------------------------------

# ACTIVIDAD 6 | Diferencia entre inferencia automatica y lectura controlada
# Esta segunda lectura NO sustituye el objeto conservador "datos".
datos_auto <- readr::read_csv(archivo_csv, show_col_types = FALSE)
dplyr::glimpse(datos_auto)
readr::problems(datos_auto)
# Una tabla vacia de problems() no significa ausencia de errores de calidad.

# ACTIVIDAD 7 | Examinar el formato del archivo CSV
readLines(archivo_csv, n = 3, encoding = "UTF-8")
# El archivo tiene separador coma y encabezado de 27 variables.
# La coma decimal en "18,5", dentro de comillas CSV, permanece en un campo.

# ACTIVIDAD 8 | Leer diccionario y cotejar los nombres
diccionario <- readr::read_csv(
  here::here("diccionario", "diccionario_variables.csv"),
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA",
  show_col_types = FALSE
)

faltan_columnas <- setdiff(diccionario$variable, names(datos))
columnas_extras <- setdiff(names(datos), diccionario$variable)
orden_coincide <- identical(names(datos), diccionario$variable)

faltan_columnas                 # character(0)
columnas_extras                 # character(0)
orden_coincide                  # TRUE

# ACTIVIDAD 9 | Auditoria de estructura y metadatos
tabla_estructura <- tibble::tibble(
  variable = names(datos),
  clase_importada = vapply(datos, function(x) class(x)[1], character(1))
) %>%
  dplyr::left_join(
    diccionario %>%
      dplyr::select(variable, tipo_esperado, obligatoria, control_exploratorio),
    by = "variable"
  )
print(tabla_estructura, n = nrow(tabla_estructura))
# Un tipo 'character' no implica error: fue una decision de importacion.

# ACTIVIDAD 10 | Conversion de edad y localizacion de 6 formatos problematicos
comparacion_edad <- datos %>%
  dplyr::mutate(
    fila_csv = dplyr::row_number() + 1L,
    edad_convertida = suppressWarnings(as.integer(edad)),
    marcador_ausencia = !is.na(edad) &
      toupper(trimws(edad)) %in% c("N/D", "SIN DATO")
  )

edad_no_convertible <- comparacion_edad %>%
  dplyr::filter(
    !is.na(edad), trimws(edad) != "",
    !marcador_ausencia,
    is.na(edad_convertida)
  ) %>%
  dplyr::select(fila_csv, id_persona, edad)

print(edad_no_convertible, n = nrow(edad_no_convertible))
nrow(edad_no_convertible)        # 6
# Cadenas: treinta, 35 anios (con enie), ?, 18,5, sin edad, XX.
# Los marcadores N/D y SIN DATO NO se cuentan aqui como errores de conversion.

# MODULO 3 -------------------------------------------------------------------

# ACTIVIDAD 11 | Perfilado: distinguir NA, vacios y marcadores
# Funciones reutilizables de diagnostico. Ninguna cambia "datos".
es_vacio <- function(x) {
  !is.na(x) & trimws(x) == ""
}
es_marcador <- function(x) {
  !is.na(x) & toupper(trimws(x)) %in% c("N/D", "SIN DATO")
}

perfil <- tibble::tibble(
  variable = names(datos),
  registros = nrow(datos),
  n_na = vapply(datos, function(x) sum(is.na(x)), integer(1)),
  n_vacios = vapply(datos, function(x) sum(es_vacio(x)), integer(1)),
  n_marcadores = vapply(datos, function(x) sum(es_marcador(x)), integer(1))
) %>%
  dplyr::mutate(
    n_ausencias = n_na + n_vacios + n_marcadores,
    porcentaje = round(100 * n_ausencias / registros, 2)
  ) %>%
  dplyr::arrange(dplyr::desc(porcentaje))

print(perfil, n = nrow(perfil))
perfil %>% dplyr::filter(variable %in% c("edad", "sexo", "ingreso_mensual_usd"))
# Referencias:
# edad:     NA=23, vacios=19, marcadores=24, total=66 (4,40 %)
# sexo:     NA=12, vacios=22, marcadores=0, total=34 (2,27 %)
# ingresos: NA=20, vacios=17, marcadores=14, total=51 (3,40 %)

# ACTIVIDAD 12 | Identificar claves de persona duplicadas
# Se excluyen claves ausentes al contar repeticiones validas.
ids_repetidos <- datos %>%
  dplyr::filter(!is.na(id_persona), trimws(id_persona) != "") %>%
  dplyr::count(id_persona, name = "veces") %>%
  dplyr::filter(veces > 1) %>%
  dplyr::arrange(id_persona)

n_claves_repetidas <- nrow(ids_repetidos)
n_repeticiones_adicionales <- sum(ids_repetidos$veces - 1L)
n_filas_claves_repetidas <- sum(ids_repetidos$veces)

n_claves_repetidas              # 20 claves diferentes repetidas
n_repeticiones_adicionales     # 20 filas extra respecto a una por clave
n_filas_claves_repetidas       # 40 filas implicadas
sum(duplicated(datos))         # 4 filas completas duplicadas

# Registros correspondientes a las claves repetidas.
filas_repetidas <- datos %>%
  dplyr::mutate(fila_csv = dplyr::row_number() + 1L) %>%
  dplyr::semi_join(ids_repetidos, by = "id_persona") %>%
  dplyr::select(fila_csv, id_persona, id_hogar, provincia, edad) %>%
  dplyr::arrange(id_persona, fila_csv)
print(filas_repetidas, n = 40)

# ACTIVIDAD 13 | Categorias y frecuencias sin normalizar automaticamente
frecuencia_provincias <- datos %>%
  dplyr::count(provincia, sort = TRUE, name = "registros")
frecuencia_sexo <- datos %>%
  dplyr::count(sexo, sort = TRUE, name = "registros")
frecuencia_area <- datos %>%
  dplyr::count(area, sort = TRUE, name = "registros")

print(frecuencia_provincias, n = nrow(frecuencia_provincias))
print(frecuencia_sexo, n = nrow(frecuencia_sexo))
print(frecuencia_area, n = nrow(frecuencia_area))
# Pichincha=336; PICHINCHA=15; Guayas=247; "Guayas "=7.
# 'F' y '99' en sexo necesitan revisar catalogo, no cambiar directamente.

# ACTIVIDAD 14 | Medidas descriptivas de edad con criterios explicitos
edades <- datos %>%
  dplyr::transmute(
    id_persona,
    edad_original = edad,
    edad_num = suppressWarnings(as.integer(edad)),
    no_convertible = !is.na(edad_original) &
      trimws(edad_original) != "" &
      !(toupper(trimws(edad_original)) %in% c("N/D", "SIN DATO")) &
      is.na(edad_num),
    extremo_ilustrativo = !is.na(edad_num) &
      (edad_num < 0L | edad_num > 110L)
  )

edades %>% dplyr::summarise(
  no_convertibles = sum(no_convertible),
  extremos_para_revisar = sum(extremo_ilustrativo)
)
# 6 no convertibles; 12 fuera de 0-110 (rango exclusivamente didactico).

resumen_edades <- edades %>%
  dplyr::filter(!is.na(edad_num), dplyr::between(edad_num, 0L, 110L)) %>%
  dplyr::summarise(
    n = dplyr::n(),
    media = round(mean(edad_num), 2),
    mediana = median(edad_num),
    minimo = min(edad_num),
    maximo = max(edad_num),
    desviacion_estandar = round(sd(edad_num), 2)
  )
print(resumen_edades)
# n=1416, media=48.30, mediana=49, min=0, max=95, sd=27.62.
# Reportar siempre el filtro usado al comunicar estadisticas.

# ACTIVIDAD 15 | Graficos descriptivos y primera sintesis
# 15.A Porcentaje de ausencias: excluir 'observaciones' por ser opcional.
perfil_grafico <- perfil %>%
  dplyr::filter(variable != "observaciones") %>%
  dplyr::slice_max(order_by = porcentaje, n = 12, with_ties = FALSE)

g_ausencias <- ggplot2::ggplot(
  perfil_grafico,
  ggplot2::aes(x = reorder(variable, porcentaje), y = porcentaje)
) +
  ggplot2::geom_col() +
  ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Ausencias por variable (base sintetica)",
    x = "Variable", y = "Porcentaje de registros (%)"
  ) +
  ggplot2::theme_minimal()
print(g_ausencias)

# 15.B Frecuencia de categorias de provincia.
provincias_top <- frecuencia_provincias %>%
  dplyr::slice_head(n = 12) %>%
  dplyr::mutate(
    provincia = dplyr::if_else(
      is.na(provincia) | provincia == "", "(vacia/NA)", provincia
    )
  )
g_provincias <- ggplot2::ggplot(
  provincias_top,
  ggplot2::aes(x = reorder(provincia, registros), y = registros)
) +
  ggplot2::geom_col() +
  ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Frecuencias de provincia (base sintetica)",
    x = "Categoria literal", y = "Registros"
  ) +
  ggplot2::theme_minimal()
print(g_provincias)

# 15.C Histograma de edad bajo un filtro didactico explicitado.
g_edades <- edades %>%
  dplyr::filter(!is.na(edad_num), dplyr::between(edad_num, 0L, 110L)) %>%
  ggplot2::ggplot(ggplot2::aes(x = edad_num)) +
  ggplot2::geom_histogram(binwidth = 5, boundary = 0) +
  ggplot2::labs(
    title = "Distribucion de edades (base sintetica)",
    subtitle = "Solo valores enteros 0-110; umbral demostrativo",
    x = "Edad (anios)", y = "Registros"
  ) +
  ggplot2::theme_minimal()
print(g_edades)

# TABLA FINAL DE HALLAZGOS - No sumar como personas distintas afectadas.
incidencias_iniciales <- tibble::tibble(
  hallazgo = c(
    "Ausencias de edad (NA, vacio, marcador)",
    "Ausencias de ingreso mensual",
    "Claves de persona repetidas adicionales",
    "Edad no convertible (sin marcadores)",
    "Edad fuera del rango ilustrativo 0-110"
  ),
  total = c(
    perfil$n_ausencias[perfil$variable == "edad"],
    perfil$n_ausencias[perfil$variable == "ingreso_mensual_usd"],
    n_repeticiones_adicionales,
    sum(edades$no_convertible),
    sum(edades$extremo_ilustrativo)
  )
)
print(incidencias_iniciales)
# FIN: Por ahora NO se elimina, imputa, normaliza ni corrige ningun registro.
# El siguiente modulo formaliza reglas y decisiones autorizadas.
