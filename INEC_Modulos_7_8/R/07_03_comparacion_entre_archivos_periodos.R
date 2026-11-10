# =============================================================================
# MÓDULO 7.3 | COMPARAR DOS ARCHIVOS / PERÍODOS REALES (ACTIVIDAD OPCIONAL)
# IMPORTANTE: el CSV proporcionado se refiere al mes 2026-10. El texto
# '2026/10' NO es un mes nuevo, sino un formato atípico dentro del archivo.
# No se fabrican datos de 2026-09 ni 2026-11.
# =============================================================================
library(here)
library(readr)
library(dplyr)
source(here::here("R", "07_00_funciones_analisis.R"))

# PASO 1. Escriba una ruta REAL a un segundo CSV comparativo, o deje vacío.
segundo_csv <- ""  # EJEMPLO AL DISPONER DEL ARCHIVO: here::here("data_comparacion", "personas_2026_11.csv")

if (!nzchar(segundo_csv)) {
  message("No hay segundo archivo. Se conserva la comparación Original/Propuesta.")
} else {
  if (!file.exists(segundo_csv)) stop("No existe el segundo archivo: ", segundo_csv)
  ruta_hitos <- here::here("resultados", "01_hitos_modulos_5_6.rds")
  if (!file.exists(ruta_hitos)) stop("Guarde los hitos de módulos 5 y 6 primero")
  hitos <- readRDS(ruta_hitos)

  # PASO 2. Leer como texto, sin conversiones automáticas de IDs o códigos.
  nuevo <- readr::read_csv(
    segundo_csv,
    col_types = readr::cols(.default = readr::col_character()),
    na = "NA", trim_ws = FALSE, show_col_types = FALSE
  )
  catalogo <- readr::read_csv(
    here::here("diccionario", "catalogo_provincias_didactico.csv"),
    show_col_types = FALSE
  )$provincia

  # PASO 3. Restringir a períodos con formato ISO válido, sin fusionar formas.
  periodos <- unique(normalizar_ausencia(nuevo$periodo_referencia))
  periodos <- periodos[!is.na(periodos) &
                         grepl("^[0-9]{4}-(0[1-9]|1[0-2])$", periodos)]
  if (length(periodos) == 0L) stop("El segundo archivo no tiene períodos YYYY-MM válidos")
  if (length(periodos) != 1L) {
    stop("Este ejercicio requiere un único período válido en el segundo CSV")
  }
  periodo_nuevo <- periodos[[1]]
  periodo_base <- "2026-10"  # período de referencia del caso sintético
  if (periodo_nuevo == periodo_base) stop("El período nuevo debe ser diferente al original")
  if (any(!is.na(nuevo$periodo_referencia) &
          nuevo$periodo_referencia != periodo_nuevo)) {
    stop("Existen fechas/períodos no conformes: revisar el segundo CSV")
  }

  # PASO 4. Los resultados originales del módulo 6 son para TODO el archivo
  # e incluyen los casos mal codificados de 2026/10 (no se descartan).
  base <- hitos$indicadores_antes |>
    dplyr::mutate(periodo = periodo_base, archivo = "Archivo inicial")
  posterior <- calcular_indicadores_compatibles(nuevo, catalogo) |>
    dplyr::mutate(periodo = periodo_nuevo, archivo = "Segundo archivo")
  comparacion_periodos <- dplyr::bind_rows(base, posterior)
  print(comparacion_periodos)
  ruta <- here::here("resultados", "tablas", "07_comparacion_periodos.csv")
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(comparacion_periodos, ruta)
  message("Comparación guardada en: ", ruta)
  # ADVERTENCIA: comparar solo si universo, muestreo, variables y reglas son
  # metodológicamente compatibles. No interpretar cambio como causalidad.
}
