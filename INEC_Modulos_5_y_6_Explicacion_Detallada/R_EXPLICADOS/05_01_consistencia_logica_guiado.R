# ============================================================================
# MÓDULO 5.1 | CONSISTENCIA ENTRE CAMPOS Y REGISTROS
# DEFINICIÓN: consistencia = cumplimiento de relaciones LÓGICAS entre variables.
# No confundir un indicador de revisión con un error confirmado.
# ============================================================================
# EXPLICACIÓN DOCENTE | source(archivo.R) evalúa las instrucciones de otro script.
# EXPLICACIÓN DOCENTE | OBJETIVO: reutilizar objetos personas y hogares de 00_preparacion.R.
# EXPLICACIÓN DOCENTE | PRECAUCIÓN: vuelve a crear objetos del entorno; no debe confundirse con ejecutarlo mágicamente en segundo plano.
# ----------------------------------------------------------------------
source(here::here("R", "00_preparacion.R"))

# PASO 1. Valores categóricos y numéricos que se relacionarán.
# El ingreso estandarizado siempre es numérico o NA. Los ceros son valores.
# EXPLICACIÓN DOCENTE | count(variable) agrupa valores y devuelve frecuencias (incluye NA).
# EXPLICACIÓN DOCENTE | OBJETIVO: reconocer categorías reales antes de formular reglas.
# EXPLICACIÓN DOCENTE | La tabla responde cuántos casos hay; no clasifica automáticamente calidad.
# ----------------------------------------------------------------------
personas %>% count(condicion_actividad)
# EXPLICACIÓN DOCENTE | summarise() produce una fila de resúmenes.
# EXPLICACIÓN DOCENTE | sum(is.na(x)) suma ausencias; sum(x==0, na.rm=TRUE) cuenta ceros reales;
# EXPLICACIÓN DOCENTE | na.rm=TRUE evita que un NA convierta el recuento en NA.
# EXPLICACIÓN DOCENTE | CONCEPTO: cero y NA no son equivalentes.
# ----------------------------------------------------------------------
personas %>% summarise(
  ingresos_na = sum(is.na(ingreso_n)),
  ingresos_cero = sum(ingreso_n == 0, na.rm = TRUE),
  ingresos_negativos = sum(ingreso_n < 0, na.rm = TRUE)
)

# PASO 2. Regla L5-01 (SUPUESTO DIDÁCTICO): ocupado con cero horas.
# El '&' expresa conjunción lógica: ambas condiciones deben cumplirse.
# EXPLICACIÓN DOCENTE | OBJETIVO: crear un vector lógico, un elemento TRUE/FALSE/NA por persona.
# EXPLICACIÓN DOCENTE | & exige que TODAS las condiciones sean verdaderas.
# EXPLICACIÓN DOCENTE | !is.na(x) asegura que las variables necesarias son observables.
# EXPLICACIÓN DOCENTE | Esta es una REGLA DIDÁCTICA: cero horas puede exigir revisión metodológica, no siempre es error.
# ----------------------------------------------------------------------
alerta_ocupado_cero <- !is.na(personas$condicion_actividad) &
  personas$condicion_actividad == "Ocupado" &
  !is.na(personas$horas_n) & personas$horas_n == 0

# PASO 3. Regla L5-02: NO ocupado con horas positivas.
# EXPLICACIÓN DOCENTE | %in% c("Desocupado", "Inactivo") compara contra un CONJUNTO de categorías.
# EXPLICACIÓN DOCENTE | > 0 indica horas positivas. Usamos la conjunción & para formar la condición.
# EXPLICACIÓN DOCENTE | OBJETIVO: localizar relaciones atípicas entre estado laboral y horas.
# ----------------------------------------------------------------------
alerta_no_ocupado_horas <- !is.na(personas$condicion_actividad) &
  personas$condicion_actividad %in% c("Desocupado", "Inactivo") &
  !is.na(personas$horas_n) & personas$horas_n > 0

# PASO 4. Regla L5-03: fecha válida cuyo mes no coincide con el período.
# is.na(fecha_d) separa la fecha inválida de un desfase temporal.
# EXPLICACIÓN DOCENTE | as.Date(texto, format="%Y-%m-%d") convierte fecha ISO a clase Date.
# EXPLICACIÓN DOCENTE | suppressWarnings() oculta avisos de conversión; revisar luego los formatos fallidos.
# EXPLICACIÓN DOCENTE | format(fecha_d, "%Y-%m") extrae año y mes para compararlo con periodo_referencia.
# EXPLICACIÓN DOCENTE | OBJETIVO: encontrar diferencias temporales, no corregir la fecha.
# ----------------------------------------------------------------------
fecha_d <- suppressWarnings(as.Date(personas$fecha_levantamiento,
                                    format = "%Y-%m-%d"))
alerta_periodo <- !is.na(fecha_d) &
  !is.na(personas$periodo_referencia) &
  format(fecha_d, "%Y-%m") != personas$periodo_referencia

# PASO 5. Función: transforma una condición TRUE/FALSE en filas auditables.
# SEVERIDAD (didáctica): revisión / advertencia / error, a confirmar.
# EXPLICACIÓN DOCENTE | OBJETIVO: una función reutilizable convierte una regla lógica en evidencia auditable.
# EXPLICACIÓN DOCENTE | PARÁMETROS: tabla=tibble con campos; condicion=vector lógico del mismo largo;
# EXPLICACIÓN DOCENTE | codigo=identificador estable de regla; variable=nombre de columna;
# EXPLICACIÓN DOCENTE | descripcion=motivo de revisión; severidad=texto, predeterminado REVISAR.
# EXPLICACIÓN DOCENTE | which(!is.na(condicion) & condicion) obtiene posiciones verdaderas y observables;
# EXPLICACIÓN DOCENTE | length(idx) determina cuántas alertas crear; rep(valor, n) repite metadatos;
# EXPLICACIÓN DOCENTE | tabla[[variable]] accede a columna por NOMBRE guardado como texto;
# EXPLICACIÓN DOCENTE | tibble::tibble() construye tabla; as.character() preserva texto para registro.
# EXPLICACIÓN DOCENTE | PRECAUCIÓN: al no existir TRUE, la función devuelve una tabla de cero filas.
# ----------------------------------------------------------------------
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
# EXPLICACIÓN DOCENTE | bind_rows() concatena tablas por filas ajustando nombres de columnas.
# EXPLICACIÓN DOCENTE | OBJETIVO: unificar tres reglas bajo el mismo formato de alerta sin perder fila_csv.
# EXPLICACIÓN DOCENTE | Cada fila es una incidencia; UNA persona puede aparecer varias veces.
# ----------------------------------------------------------------------
alertas_logicas <- dplyr::bind_rows(
  crear_alerta(personas, alerta_ocupado_cero, "L5-01", "horas_trabajo_semana",
               "Ocupado con cero horas declaradas"),
  crear_alerta(personas, alerta_no_ocupado_horas, "L5-02", "horas_trabajo_semana",
               "No ocupado con horas positivas"),
  crear_alerta(personas, alerta_periodo, "L5-03", "fecha_levantamiento",
               "Mes de levantamiento diferente del período")
)

# PASO 7. Tablas de incidencias y ejemplo de identificación de fila original.
# EXPLICACIÓN DOCENTE | count(regla_id, severidad, name="incidencias") cuenta incidencias por grupo.
# EXPLICACIÓN DOCENTE | print(head(x, 15)) inspecciona las primeras 15 filas; head no altera la tabla.
# ----------------------------------------------------------------------
alertas_logicas %>% count(regla_id, severidad, name = "incidencias")
print(head(alertas_logicas, 15))
# ACTIVIDAD: agregar la regla L5-04 (provincia de una persona coherente con hogar).
# No se debe hacer sin documentar el supuesto de que el hogar tiene provincia fija.

# PASO 8. Gráfico editable en R: conteos por tipo de alerta.
# EXPLICACIÓN DOCENTE | OBJETIVO: calcular alturas del gráfico a partir de conteos observados.
# EXPLICACIÓN DOCENTE | ggplot(datos, aes(x=..., y=...)) declara el sistema de coordenadas;
# EXPLICACIÓN DOCENTE | geom_col() dibuja columnas con alturas dadas; geom_text() agrega etiquetas;
# EXPLICACIÓN DOCENTE | labs() pone títulos; theme_minimal() aplica un estilo legible.
# EXPLICACIÓN DOCENTE | El gráfico es descriptivo: no demuestra por sí mismo errores confirmados.
# ----------------------------------------------------------------------
resumen_l5 <- alertas_logicas %>% count(regla_id, name = "total")
ggplot(resumen_l5, aes(x = regla_id, y = total)) +
  geom_col(fill = "#2476A3") +
  geom_text(aes(label = total), vjust = -0.35) +
  labs(title = "Consistencia: alertas por regla",
       x = "Regla didáctica", y = "N.º de alertas") +
  theme_minimal()

# Exportación OPCIONAL. Activar SOLO al revisar visualmente:
# readr::write_csv(alertas_logicas, here::here("resultados", "alertas_logicas.csv"), na = "NA")
