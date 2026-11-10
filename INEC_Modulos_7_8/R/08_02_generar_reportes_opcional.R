# =============================================================================
# MÓDULO 8.2 | PUBLICAR HTML Y WORD USANDO LA INTERFAZ R DE QUARTO (OPCIONAL)
# No confunda preparar el .qmd con su renderizado: la ejecución es manual.
# Requiere instalar paquete 'quarto' y el programa independiente Quarto CLI.
# =============================================================================

# PASO 1. Compruebe que ya hizo el paso 08_01_verificar_precondiciones.R.
library(here)
if (!requireNamespace("quarto", quietly = TRUE)) {
  stop("Instale el paquete: install.packages('quarto')")
}
ruta_qmd <- here::here("reportes", "reporte_calidad.qmd")
if (!file.exists(ruta_qmd)) stop("No se encuentra el reporte .qmd")

# PASO 2. Render HTML. execute_params modifica el período del título/contexto;
# NO sustituye el CSV original ni inventa información de otro mes.
quarto::quarto_render(
  input = ruta_qmd,
  output_format = "html",
  execute_params = list(periodo = "2026-10")
)

# PASO 3. Render Word. El formato 'docx' conserva tablas y figuras compatibles.
quarto::quarto_render(
  input = ruta_qmd,
  output_format = "docx",
  execute_params = list(periodo = "2026-10")
)

# PASO 4. Verificar los archivos EN LA CARPETA reportes/. No enviar sin revisar.
print(list.files(here::here("reportes"), pattern = "reporte_calidad\\.(html|docx)$"))
