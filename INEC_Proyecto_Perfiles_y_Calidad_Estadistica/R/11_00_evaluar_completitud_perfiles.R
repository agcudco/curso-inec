# =============================================================================
# SESION 11, SCRIPT 11_00 | CALIDAD DE LA INFORMACION DE CADA PERFIL
# Objetivo: recuperar los grupos de la sesion 10 y describir su cobertura.
# No modifica la encuesta de origen ni recalcula los grupos K-means.
# Entradas: resultados/10_perfiles.rds
# Salidas: resultados/11_base_calidad.rds y dos tablas CSV.
# =============================================================================

source(here::here("R", "00_configuracion.R"))

# PASO 1. Verificar que el grupo ya fue creado en la sesion 10.
ruta_10 <- here::here("resultados", "10_perfiles.rds")
if (!file.exists(ruta_10)) {
  stop("Falta resultados/10_perfiles.rds. Termine primero la sesion 10.")
}
paquete_10 <- readRDS(ruta_10)
if (!all(c("datos_agrupados", "diagnostico") %in% names(paquete_10))) {
  stop("El RDS 10 no tiene los componentes esperados")
}

# PASO 2. Recuperar las personas con grupo asignado y revisar columnas.
datos <- paquete_10$datos_agrupados
requeridas <- c("grupo", "edad_n", "ingreso_n", "zona_norm",
               "educacion_norm", "acceso_norm", "id_encuesta")
faltantes <- setdiff(requeridas, names(datos))
if (length(faltantes) > 0L) {
  stop("Faltan columnas: ", paste(faltantes, collapse = ", "))
}
if (nrow(datos) == 0L) stop("No existen observaciones agrupadas")

# PASO 3. Cuantificar la representacion de cada grupo.
# El porcentaje se calcula sobre las observaciones agrupadas, NO sobre
# las 2400 filas originales. Ver el cuadro de cobertura mas abajo.
tamanos <- datos %>%
  dplyr::count(grupo, name = "registros") %>%
  dplyr::mutate(pct_de_agrupados = round(100 * registros / sum(registros), 1))

# PASO 4. Calcular calidad de tres variables complementarias por grupo.
# NOTA: edad e ingreso fueron obligatorios para construir K-means.
# Medir su completitud solo entre agrupados daria 100% por seleccion.
variables_calidad <- c("zona_norm", "educacion_norm", "acceso_norm")
completitud <- dplyr::bind_rows(lapply(variables_calidad, function(campo) {
  datos %>%
    dplyr::group_by(grupo) %>%
    dplyr::summarise(
      registros = dplyr::n(),
      faltantes = sum(is.na(.data[[campo]])),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      variable = campo,
      presentes = registros - faltantes,
      pct_completitud = round(100 * presentes / registros, 1)
    ) %>%
    dplyr::select(grupo, variable, registros, presentes, faltantes,
                  pct_completitud)
}))

# PASO 5. Mostrar cuantas observaciones del CSV no entraron en los grupos.
# No se les puede asignar un grupo sin aplicar otro procedimiento.
cobertura <- tibble::tibble(
  filas_del_archivo = paquete_10$diagnostico$registros_totales,
  filas_agrupadas = nrow(datos),
  filas_excluidas = paquete_10$diagnostico$registros_excluidos,
  pct_agrupadas = round(100 * nrow(datos) /
                        paquete_10$diagnostico$registros_totales, 1)
)
stopifnot(cobertura$filas_agrupadas + cobertura$filas_excluidas ==
          cobertura$filas_del_archivo)

print(tamanos)
print(completitud)
print(cobertura)

# PASO 6. Guardar un punto de control para la siguiente etapa.
paquete_11_base <- list(
  datos = datos,
  cobertura = cobertura,
  tamanos = tamanos,
  completitud = completitud,
  fecha_creacion = as.character(Sys.Date())
)
ruta_guardado <- here::here("resultados", "11_base_calidad.rds")
saveRDS(paquete_11_base, ruta_guardado, compress = "gzip")
readr::write_csv(tamanos,
                 here::here("resultados", "tablas", "11_tamanos_perfiles.csv"))
readr::write_csv(completitud,
                 here::here("resultados", "tablas", "11_completitud_perfiles.csv"))
message("Etapa 11_00 terminada: ", ruta_guardado)
