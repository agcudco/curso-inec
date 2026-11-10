# =============================================================================
# MÓDULO 8.1 | VERIFICAR LOS REQUISITOS ANTES DE GENERAR EL REPORTE
# Es preferible detener el proceso a publicar un informe incompleto.
# =============================================================================
library(here)

# PASO 1. R y RStudio son distintos. Quarto es un motor de publicación externo.
paquetes <- c("here", "readr", "dplyr", "tidyr", "ggplot2", "tibble", "knitr")
disponible <- vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)
print(data.frame(paquete = paquetes, instalado = disponible))
if (!all(disponible)) {
  stop("Instale paquetes faltantes: ", paste(paquetes[!disponible], collapse = ", "))
}

# PASO 2. Comprobar que Quarto CLI es visible en el sistema.
quarto <- Sys.which("quarto")
if (!nzchar(quarto)) {
  message("No se encuentra el ejecutable de Quarto en PATH. Instale Quarto CLI.")
  message("En terminal de RStudio debe poder ejecutar: quarto --version")
} else cat("Quarto disponible en:", quarto, "\n")

# PASO 3. Un reporte no usa objetos sueltos del Global Environment.
archivos <- c(
  here::here("resultados", "01_hitos_modulos_5_6.rds"),
  here::here("resultados", "02_analisis_modulo_7.rds"),
  here::here("reportes", "reporte_calidad.qmd")
)
print(data.frame(archivo = archivos, existe = file.exists(archivos)))
if (!all(file.exists(archivos))) {
  stop("Faltan archivos. Ejecute 06_99 y 07_01; revise el QMD.")
}

# PASO 4. Confirmar que el punto de control conserva las entradas esperadas.
a <- readRDS(archivos[2])
if (!all(c("indicadores_long", "indicadores_ancho", "incidencias",
           "faltantes", "resumen_numericos", "periodos") %in% names(a))) {
  stop("El análisis guardado es incompleto; regenere 07_01")
}
cat("Verificación superada. Revise manualmente los hallazgos antes de publicar.\n")
