# =============================================================================
# SESION 11, SCRIPT 11_02 | GENERAR HTML Y WORD DESDE EL REPORTE QUARTO
# Ejecutar con source() en la CONSOLA R. No escribir comandos de Terminal
# directamente en la consola R (provocaria 'unexpected symbol').
# =============================================================================
source(here::here("R", "00_configuracion.R"))

ruta_rds <- here::here("resultados", "11_calidad_perfiles.rds")
ruta_qmd <- here::here("reportes", "sesion_11_calidad_perfiles.qmd")
if (!file.exists(ruta_rds)) stop("Falta el RDS; ejecute antes el script 11_01")
if (!file.exists(ruta_qmd)) stop("Falta reportes/sesion_11_calidad_perfiles.qmd")

# Comprobar que las figuras esten generadas antes de intentar renderizar.
paquete <- readRDS(ruta_rds)
figuras <- vapply(paquete$figuras, here::here, character(1))
if (!all(file.exists(figuras))) stop("Faltan graficos PNG. Reejecute 11_01")

# Necesitamos Quarto CLI instalado y visible en PATH.
cli <- Sys.which("quarto")
if (!nzchar(cli)) {
  stop("No se encuentra Quarto CLI. Compruebe 'quarto --version' en Terminal.")
}

# Elegir c("html") para un solo formato o c("html", "docx") para los dos.
formatos <- c("html", "docx")
for (formato in formatos) {
  message("Renderizando informe de calidad de perfiles a ", formato)
  codigo <- system2(cli, args = c("render", shQuote(ruta_qmd),
                                  "--to", formato))
  if (!identical(as.integer(codigo), 0L)) {
    stop("Fallo el renderizado de ", formato, " (codigo ", codigo, ")")
  }
  salida <- sub("\\.qmd$", paste0(".", formato), ruta_qmd)
  if (!file.exists(salida)) stop("No se encontro la salida: ", salida)
  message("Listo: ", salida)
}
