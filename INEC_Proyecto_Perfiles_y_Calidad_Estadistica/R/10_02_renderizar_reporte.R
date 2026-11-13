# =============================================================================
# SESION 10 — SCRIPT 10_02: RENDERIZAR EL REPORTE EN HTML Y WORD
# Ejecutar desde la consola R, NO escribir 'quarto render' sin system2().
# =============================================================================
source(here::here("R", "00_configuracion.R"))
rds <- here::here("resultados", "10_perfiles.rds")
qmd <- here::here("reportes", "sesion_10_perfiles.qmd")
if (!file.exists(rds)) stop("Primero ejecute R/10_01_identificar_perfiles.R")
if (!file.exists(qmd)) stop("No se encuentra reportes/sesion_10_perfiles.qmd")
cli <- Sys.which("quarto")
if (!nzchar(cli)) stop("Quarto CLI no disponible. Instale Quarto y compruebe 'quarto --version' en Terminal.")

# Por defecto genera ambos formatos. Cambie a c('html') para solo HTML.
formatos <- c("html", "docx")
for (formato in formatos) {
  message("Generando reporte de sesion 10 en: ", formato)
  estado <- system2(cli, args = c("render", shQuote(qmd), "--to", formato))
  if (!identical(as.integer(estado), 0L)) stop("Quarto devolvio un error: ", formato)
  salida <- sub("\\.qmd$", paste0(".", formato), qmd)
  if (!file.exists(salida)) stop("No se genero el archivo esperado: ", salida)
  message("Generado: ", salida)
}
