# ============================================================================
# MÓDULO 6.3 | MÉTRICAS AUDITABLES Y SEGUIMIENTO
# Completitud: casillas requeridas presentes / casillas requeridas evaluadas.
# Validez: pruebas de reglas satisfechas / pruebas de reglas aplicables.
# Unicidad: registros con clave personal no repetida / registros con clave.
# CADA indicador tiene su propio denominador: NO promediar porcentajes.
# ============================================================================
source(here::here("R", "00_preparacion.R"))

# PASO 1. Definir qué campos son requeridos en este escenario didáctico.
requeridas <- c("id_persona", "id_hogar", "provincia", "edad",
                "fecha_levantamiento", "personas_hogar")

# PASO 2. Crear función con criterios y denominadores explícitos.
calcular_indicadores <- function(datos) {
  # COMPLETITUD: 6 campos x número de registros.
  n_requeridas <- length(requeridas) * nrow(datos)
  n_presentes <- sum(vapply(requeridas, function(nombre) {
    sum(!is.na(limpiar_ausencias(datos[[nombre]])))
  }, integer(1)))

  # VALIDEZ: 3 pruebas con distinto conjunto de registros aplicables:
  # - provincia presente y en catálogo (módulo 4)
  # - edad presente, entera y entre 0 y 110 (rango meramente didáctico)
  # - ingreso presente, formato numérico y valor no negativo
  catalogo <- readr::read_csv(here::here("diccionario", "catalogo_provincias_didactico.csv"),
                             show_col_types = FALSE)$provincia
  prov <- limpiar_ausencias(datos$provincia)
  edad <- limpiar_ausencias(datos$edad)
  ingreso <- limpiar_ausencias(datos$ingreso_mensual_usd)
  edad_num <- suppressWarnings(as.numeric(edad))
  ingreso_num <- suppressWarnings(as.numeric(ingreso))
  den_prov <- sum(!is.na(prov))
  den_edad <- sum(!is.na(edad))
  den_ing <- sum(!is.na(ingreso))
  num_prov <- sum(!is.na(prov) & prov %in% catalogo)
  num_edad <- sum(!is.na(edad) & grepl("^[0-9]{1,3}$", edad) &
                    !is.na(edad_num) & edad_num >= 0 & edad_num <= 110)
  num_ing <- sum(!is.na(ingreso) &
                   grepl("^[0-9]+\\.[0-9]{2}$", ingreso) &
                   !is.na(ingreso_num) & ingreso_num >= 0)

  # UNICIDAD: contar filas cuya clave aparece exactamente una vez.
  ids <- limpiar_ausencias(datos$id_persona)
  ids <- ids[!is.na(ids)]
  n_ids <- length(ids)
  n_ids_sin_repeticion <- sum(!duplicated(ids) & !duplicated(ids, fromLast = TRUE))

  numeradores <- c(n_presentes, num_prov + num_edad + num_ing,
                   n_ids_sin_repeticion)
  denominadores <- c(n_requeridas, den_prov + den_edad + den_ing, n_ids)
  tibble::tibble(
    indicador = c("Completitud", "Validez", "Unicidad"),
    numerador = numeradores,
    denominador = denominadores,
    porcentaje = round(100 * ifelse(denominadores > 0,
                                    numeradores / denominadores, NA_real_), 2)
  )
}

# PASO 3. Línea base, ANTES de cualquier normalización.
indicadores_antes <- calcular_indicadores(personas_raw)
print(indicadores_antes)

# PASO 4. ESCENARIO de normalización controlada, no producto autorizado.
source(here::here("R", "06_01_normalizacion_bitacora_guiado.R"))
indicadores_propuestos <- calcular_indicadores(personas_propuesta)
print(indicadores_propuestos)

# PASO 5. Comparar sin atribuir causalidad ni aprobar datos.
comparativa <- dplyr::bind_rows(
  indicadores_antes %>% mutate(escenario = "Antes"),
  indicadores_propuestos %>% mutate(escenario = "Propuesta")
)
ggplot(comparativa, aes(x = indicador, y = porcentaje, fill = escenario)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0(porcentaje, "%")),
            position = position_dodge(width = 0.9), vjust = -0.25, size = 3) +
  coord_cartesian(ylim = c(0, 110)) +
  labs(title = "Métricas de calidad por escenario (didáctico)",
       x = "Indicador", y = "Porcentaje") +
  theme_minimal()

# PASO 6. Control final: no confundir "unicidad" con completitud de la clave;
# filas con ID ausente se excluyen del denominador de unicidad y se informan
# como problema de completitud.
# OPCIONAL: guardar en resultados, una vez aprobada la salida:
# readr::write_csv(comparativa, here::here("resultados", "comparativa_metricas.csv"))
