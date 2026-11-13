# Proyecto RStudio — sesiones 10 y 11 (versión revisada)

Este proyecto preserva la **sesión 10** sobre identificación de perfiles con K-means y **reemplaza** la antigua sesión 11 de clasificación por **Análisis estadístico de la calidad y variabilidad de perfiles**.

## Secuencia docente

- **Sesión 10 (sin cambios):** `R/10_00_preparar_datos_perfiles.R` → `R/10_01_identificar_perfiles.R` → `R/10_02_renderizar_reporte.R`.
- **Sesión 11 (nueva):** `R/11_00_evaluar_completitud_perfiles.R` → `R/11_01_estadistica_calidad_perfiles.R` → `R/11_02_renderizar_reporte.R`.

Cada sesión crea su propio archivo RDS y su informe Quarto HTML/Word. El CSV original permanece intacto.

## Comience aquí

1. Abra `encuesta_calidad.Rproj` en RStudio.
2. Lea `GUIA_ESTUDIO_DESDE_CERO_SESIONES_10_Y_11.md`.
3. Ejecute los bloques en orden desde la consola R. Los comandos `quarto render` sin `system()` van en la pestaña **Terminal**, no en **Console**.
4. Consulte `SESION_11_PROPUESTA.md` y `actividades/ACTIVIDADES_SESIONES_10_Y_11.md`.

Requisitos: R, RStudio, Quarto CLI y los paquetes `here`, `readr`, `dplyr`, `ggplot2`, `knitr` (el uso de `tibble` se efectúa desde `dplyr`). El proyecto incluye datos sintéticos y no representa estadísticas oficiales del INEC.
