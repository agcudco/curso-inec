# =============================================================================
# SESION 10 — SCRIPT 10_00: PREPARACION CONSERVADORA PARA IDENTIFICAR PERFILES
# DEFINICION: preparar = interpretar y normalizar representaciones en OBJETOS
# derivados. Nunca modifica el CSV ni autoriza una correccion institucional.
# ENTRADA: resultados/01_datos.rds (opcional) o CSV socioeconomico (alternativa).
# SALIDA: resultados/10_datos_preparados.rds + tabla diagnostico.
# =============================================================================

source(here::here("R", "00_configuracion.R"))

# 1. Reutilizar el punto de control de los modulos originales cuando exista.
ruta_previa <- here::here("resultados", "01_datos.rds")
if (file.exists(ruta_previa)) {
  paquete_previo <- readRDS(ruta_previa)
  if (!"personas_raw" %in% names(paquete_previo)) {
    stop("El RDS previo no contiene 'personas_raw'. Revise el archivo.")
  }
  fuente <- paquete_previo$personas_raw
  procedencia <- "RDS del modulo 1"
} else {
  fuente <- leer_texto(here::here("data_raw", "encuesta_socioeconomica_2026.csv"))
  procedencia <- "CSV original leido como texto"
}

# 2. Asegurar que usamos el mismo esquema de la encuesta del taller.
columnas <- c("id_encuesta", "id_persona", "periodo_referencia", "edad",
              "ingreso_mensual_usd", "zona", "nivel_educacion", "acceso_internet")
faltan <- setdiff(columnas, names(fuente))
if (length(faltan) > 0) stop("Columnas ausentes: ", paste(faltan, collapse = ", "))

# 3. Convertir SOLO columnas auxiliares: conservar intactas las originales.
# normalizar_ausencia() y a_numero() proceden de 00_configuracion.R.
datos <- fuente %>%
  dplyr::mutate(
    fila_csv = dplyr::row_number() + 1L,
    edad_n = a_numero(edad),
    ingreso_n = a_numero(ingreso_mensual_usd),
    zona_limpia = normalizar_ausencia(zona),
    educacion_limpia = normalizar_ausencia(nivel_educacion),
    acceso_limpio = normalizar_ausencia(acceso_internet),
    zona_norm = dplyr::case_when(
      toupper(zona_limpia) == "URBANA" ~ "Urbana",
      toupper(zona_limpia) == "RURAL" ~ "Rural",
      TRUE ~ NA_character_
    ),
    educacion_norm = dplyr::case_when(
      toupper(educacion_limpia) == "SIN INSTRUCCION" ~ "Sin instruccion",
      toupper(educacion_limpia) == "PRIMARIA" ~ "Primaria",
      toupper(educacion_limpia) == "SECUNDARIA" ~ "Secundaria",
      toupper(educacion_limpia) == "SUPERIOR" ~ "Superior",
      toupper(educacion_limpia) == "POSGRADO" ~ "Posgrado",
      TRUE ~ NA_character_
    ),
    acceso_norm = dplyr::case_when(
      toupper(acceso_limpio) == "SI" ~ "Si",
      toupper(acceso_limpio) == "NO" ~ "No",
      TRUE ~ NA_character_
    )
  )

# 4. La edad y el ingreso deben ser numericOS plausibles para la practica.
# Rango de edad 18–110: criterio DIDACTICO, NO regla oficial.
# 0 USD es ingreso valido. Los ingresos negativos NO se imputan ni borran.
datos <- datos %>%
  dplyr::mutate(
    edad_valida = !is.na(edad_n) & edad_n >= 18 & edad_n <= 110,
    ingreso_valido = !is.na(ingreso_n) & ingreso_n >= 0,
    apto_agrupamiento = edad_valida & ingreso_valido
  )

# 5. log1p(x) equivale a log(1+x). Reduce la asimetria y admite ingreso cero.
# Solo calculamos logaritmo en posiciones con ingreso numerico no negativo.
datos$ingreso_log <- NA_real_
pos_validas <- which(datos$ingreso_valido)
datos$ingreso_log[pos_validas] <- log1p(datos$ingreso_n[pos_validas])

# 6. Cuantificar filas admisibles/excluidas: no esconder el denominador.
diagnostico <- tibble::tibble(
  registros_totales = nrow(datos),
  edad_invalida_o_ausente = sum(!datos$edad_valida),
  ingreso_invalido_o_ausente = sum(!datos$ingreso_valido),
  registros_aptos = sum(datos$apto_agrupamiento),
  registros_excluidos = sum(!datos$apto_agrupamiento)
)
print(diagnostico)

# 7. Guardar RDS para recuperar datos tipados sin depender del Environment.
ruta_rds <- here::here("resultados", "10_datos_preparados.rds")
saveRDS(list(datos = datos, diagnostico = diagnostico,
             procedencia = procedencia, fecha = as.character(Sys.Date())),
        ruta_rds)
readr::write_csv(diagnostico, here::here("resultados", "tablas", "10_diagnostico.csv"))
stopifnot(file.exists(ruta_rds))
message("Sesión 10, preparación lista: ", ruta_rds)
