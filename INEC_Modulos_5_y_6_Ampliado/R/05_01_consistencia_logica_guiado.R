# ============================================================================
# MÓDULO 5.1 | CONSISTENCIA ENTRE CAMPOS Y REGISTROS
# DEFINICIÓN: consistencia = cumplimiento de relaciones LÓGICAS entre variables.
# No confundir un indicador de revisión con un error confirmado.
# ============================================================================
source(here::here("R", "00_preparacion.R"))

# PASO 1. Valores categóricos y numéricos que se relacionarán.
# El ingreso estandarizado siempre es numérico o NA. Los ceros son valores.
personas %>% count(condicion_actividad)
personas %>% summarise(
  ingresos_na = sum(is.na(ingreso_n)),
  ingresos_cero = sum(ingreso_n == 0, na.rm = TRUE),
  ingresos_negativos = sum(ingreso_n < 0, na.rm = TRUE)
)

# PASO 2. Regla L5-01 (SUPUESTO DIDÁCTICO): ocupado con cero horas.
# El '&' expresa conjunción lógica: ambas condiciones deben cumplirse.
alerta_ocupado_cero <- !is.na(personas$condicion_actividad) &
  personas$condicion_actividad == "Ocupado" &
  !is.na(personas$horas_n) & personas$horas_n == 0

# PASO 3. Regla L5-02: NO ocupado con horas positivas.
alerta_no_ocupado_horas <- !is.na(personas$condicion_actividad) &
  personas$condicion_actividad %in% c("Desocupado", "Inactivo") &
  !is.na(personas$horas_n) & personas$horas_n > 0

# PASO 4. Regla L5-03: fecha válida cuyo mes no coincide con el período.
# is.na(fecha_d) separa la fecha inválida de un desfase temporal.
fecha_d <- suppressWarnings(as.Date(personas$fecha_levantamiento,
                                    format = "%Y-%m-%d"))
alerta_periodo <- !is.na(fecha_d) &
  !is.na(personas$periodo_referencia) &
  format(fecha_d, "%Y-%m") != personas$periodo_referencia

# PASO 5. Función: transforma una condición TRUE/FALSE en filas auditables.
# SEVERIDAD (didáctica): revisión / advertencia / error, a confirmar.
crear_alerta <- function(tabla, condicion, codigo, variable, descripcion,
                        severidad = "REVISAR") {
  idx <- which(!is.na(condicion) & condicion)
  tibble::tibble(
    fila_csv = tabla$fila_csv[idx],
    id_persona = tabla$id_persona[idx],
    id_hogar = tabla$id_hogar[idx],
    regla_id = rep(codigo, length(idx)),
    variable = rep(variable, length(idx)),
    valor = as.character(tabla[[variable]][idx]),
    severidad = rep(severidad, length(idx)),
    descripcion = rep(descripcion, length(idx))
  )
}

# PASO 6. Registrar todas las alertas con una estructura común.
alertas_logicas <- dplyr::bind_rows(
  crear_alerta(personas, alerta_ocupado_cero, "L5-01", "horas_trabajo_semana",
               "Ocupado con cero horas declaradas"),
  crear_alerta(personas, alerta_no_ocupado_horas, "L5-02", "horas_trabajo_semana",
               "No ocupado con horas positivas"),
  crear_alerta(personas, alerta_periodo, "L5-03", "fecha_levantamiento",
               "Mes de levantamiento diferente del período")
)

# PASO 7. Tablas de incidencias y ejemplo de identificación de fila original.
alertas_logicas %>% count(regla_id, severidad, name = "incidencias")
print(head(alertas_logicas, 15))
# ACTIVIDAD: agregar la regla L5-04 (provincia de una persona coherente con hogar).
# No se debe hacer sin documentar el supuesto de que el hogar tiene provincia fija.

# PASO 8. Gráfico editable en R: conteos por tipo de alerta.
resumen_l5 <- alertas_logicas %>% count(regla_id, name = "total")
ggplot(resumen_l5, aes(x = regla_id, y = total)) +
  geom_col(fill = "#2476A3") +
  geom_text(aes(label = total), vjust = -0.35) +
  labs(title = "Consistencia: alertas por regla",
       x = "Regla didáctica", y = "N.º de alertas") +
  theme_minimal()

# Exportación OPCIONAL. Activar SOLO al revisar visualmente:
# readr::write_csv(alertas_logicas, here::here("resultados", "alertas_logicas.csv"), na = "NA")
