# =============================================================================
# PUENTE DE LOS MÓDULOS 5 Y 6 A LOS MÓDULOS 7 Y 8
# OBJETIVO: crear un punto de control persistente (.rds) con las tablas ya
# generadas en clase. Este script NO recalcula, corrige ni inventa resultados.
# =============================================================================

# PASO 1: abrir el archivo .Rproj y ejecutar individualmente los scripts 5 y 6.
# Deben existir objetos de los ejercicios previos en el Environment de RStudio.
# El archivo 05_01 del paquete incluye la corrección al error de 'crear_alerta'.

# PASO 2: verificar que no falte ninguno de los objetos necesarios.
objetos_necesarios <- c(
  "personas_raw", "personas_propuesta", "alertas_logicas",
  "alertas_integridad", "bitacora_propuesta", "indicadores_antes",
  "indicadores_propuestos"
)
objetos_faltantes <- objetos_necesarios[
  !vapply(objetos_necesarios, exists, logical(1), envir = .GlobalEnv,
          inherits = FALSE)
]
if (length(objetos_faltantes) > 0L) {
  stop(paste("Faltan resultados de los módulos 5 y 6:",
             paste(objetos_faltantes, collapse = ", "),
             "Ejecute los scripts previos antes de guardar el punto de control."))
}

# PASO 3: verificar que ambas versiones tengan igual número de filas.
stopifnot(nrow(personas_raw) == nrow(personas_propuesta))
stopifnot(identical(as.character(personas_raw$id_persona),
                    as.character(personas_propuesta$id_persona)))

# PASO 4: convertir los objetos existentes en una lista con nombre.
# Una lista permite guardar múltiples data frames en un único archivo RDS.
hitos <- list(
  personas_raw = personas_raw,
  personas_propuesta = personas_propuesta,
  alertas_logicas = alertas_logicas,
  alertas_integridad = alertas_integridad,
  bitacora_propuesta = bitacora_propuesta,
  indicadores_antes = indicadores_antes,
  indicadores_propuestos = indicadores_propuestos,
  metadata = list(
    origen = "personas_encuesta_sintetica_2026_10.csv",
    fecha_punto_control = Sys.time(),
    interpretacion = "Datos sintéticos; propuesta pendiente de aprobación",
    version_modulo = "5-6/1.0"
  )
)

# PASO 5: crear carpeta de resultados y guardar el objeto.
ruta_salida <- here::here("resultados", "01_hitos_modulos_5_6.rds")
dir.create(dirname(ruta_salida), showWarnings = FALSE, recursive = TRUE)
saveRDS(hitos, ruta_salida)  # serializa los objetos conservando tipos y NA

# PASO 6: verificar que el archivo guardado se puede recuperar.
comprobacion <- readRDS(ruta_salida)
stopifnot(nrow(comprobacion$personas_raw) == nrow(personas_raw))
cat("Punto de control guardado en:", ruta_salida, "\n")
cat("Registros originales:", nrow(comprobacion$personas_raw), "\n")
cat("Alertas lógicas:", nrow(comprobacion$alertas_logicas), "\n")
cat("Alertas de integridad:", nrow(comprobacion$alertas_integridad), "\n")
# Nota: NO usar save.image() como sustituto de un punto de control explícito.
