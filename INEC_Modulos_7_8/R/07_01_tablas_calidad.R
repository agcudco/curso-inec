# =============================================================================
# MÓDULO 7.1 | TABLAS DE CALIDAD A PARTIR DE RESULTADOS PREVIOS
# PRERREQUISITO: resultados/01_hitos_modulos_5_6.rds
# OBJETIVO: tablas auditables con denominadores y comparación en puntos porcentuales.
# =============================================================================

# PASO 1. Cargar paquetes y funciones (las funciones se definen, NO se ejecutan).
library(here)
library(dplyr)
library(tidyr)
library(readr)
source(here::here("R", "07_00_funciones_analisis.R"))

# PASO 2. Recuperar las tablas guardadas al terminar los módulos 5 y 6.
ruta_hitos <- here::here("resultados", "01_hitos_modulos_5_6.rds")
if (!file.exists(ruta_hitos)) {
  stop("Primero ejecute R/06_99_guardar_hitos_para_reporte.R")
}
hitos <- readRDS(ruta_hitos)  # RDS conserva valores NA y tipos de datos.

# PASO 3. Construir análisis, sin volver a ejecutar los módulos 5 y 6.
analisis <- construir_analisis(hitos)

# PASO 4. Revisar indicadores, incidencia y ausencias antes de exportar.
print(analisis$indicadores_ancho)
print(analisis$incidencias)
print(analisis$cobertura_alertas)
print(analisis$faltantes)
print(analisis$resumen_numericos)
print(analisis$periodos)
# ATENCIÓN: '2026/10' es un error de formato, no otro mes estadístico.

# PASO 5. Crear carpeta y exportar tablas derivadas (nunca 'data_raw').
ruta_tablas <- here::here("resultados", "tablas")
dir.create(ruta_tablas, showWarnings = FALSE, recursive = TRUE)
readr::write_csv(analisis$indicadores_ancho,
                 file.path(ruta_tablas, "07_indicadores_escenarios.csv"), na = "NA")
readr::write_csv(analisis$incidencias,
                 file.path(ruta_tablas, "07_alertas_por_regla.csv"), na = "NA")
readr::write_csv(analisis$faltantes,
                 file.path(ruta_tablas, "07_ausencias_campos.csv"), na = "NA")
readr::write_csv(analisis$resumen_numericos,
                 file.path(ruta_tablas, "07_estadisticos_descriptivos.csv"), na = "NA")
readr::write_csv(analisis$bitacora_resumen,
                 file.path(ruta_tablas, "07_resumen_bitacora.csv"), na = "NA")
readr::write_csv(analisis$periodos,
                 file.path(ruta_tablas, "07_calidad_formato_periodo.csv"), na = "NA")

# PASO 6. Guardar además un RDS para que Quarto use tipos originales.
saveRDS(analisis, here::here("resultados", "02_analisis_modulo_7.rds"))
cat("Tablas guardadas en:", ruta_tablas, "\n")
# Pregunta: ¿por qué una variación de 2 puntos porcentuales no equivale a 2%?
