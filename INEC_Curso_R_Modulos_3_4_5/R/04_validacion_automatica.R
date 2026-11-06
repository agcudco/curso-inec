# =============================================================================
# MÓDULO 4 · VALIDACIÓN AUTOMÁTICA DE VARIABLES
# Requisito: 00_preparacion.R y 03_perfilado_diagnostico.R.
# Separamos DETECCIÓN de CORRECCIÓN. Ninguna regla cambia datos originales.
# =============================================================================

# PASO 4.1 · Elaborar y explicar un catálogo DIDÁCTICO de reglas.
# Las definiciones deben ser aprobadas por responsables del operativo real.
reglas_m4 <- tibble::tribble(
  ~regla, ~variable, ~criterio, ~severidad, ~version,
  "error_id_ausente", "id_persona", "Obligatoriedad", "Error", "demo-1.0",
  "error_id_formato", "id_persona", "Formato P + 5 dígitos", "Error", "demo-1.0",
  "error_id_duplicado", "id_persona", "Unicidad nominal", "Revisión", "demo-1.0",
  "error_edad_ausente", "edad", "Obligatoriedad", "Error", "demo-1.0",
  "error_edad_formato", "edad", "Formato numérico", "Error", "demo-1.0",
  "error_edad_rango", "edad", "Rango 0–110 y entero (ilustrativo)", "Revisión", "demo-1.0",
  "error_fecha_ausente", "fecha_levantamiento", "Obligatoriedad", "Error", "demo-1.0",
  "error_fecha_formato", "fecha_levantamiento", "Fecha ISO AAAA-MM-DD", "Error", "demo-1.0",
  "error_periodo_formato", "periodo_referencia", "AAAA-MM", "Error", "demo-1.0",
  "error_sexo_ausente", "sexo", "Obligatoriedad", "Error", "demo-1.0",
  "error_sexo_dominio", "sexo", "Hombre/Mujer (solo este ejercicio)", "Revisión", "demo-1.0",
  "error_area_dominio", "area", "Urbana/Rural (solo este ejercicio)", "Revisión", "demo-1.0",
  "error_provincia_dominio", "provincia", "Catálogo didáctico de provincias", "Revisión", "demo-1.0",
  "error_ingreso_formato", "ingreso_mensual_usd", "Número con punto decimal", "Error", "demo-1.0",
  "error_ingreso_negativo", "ingreso_mensual_usd", "Valor negativo no esperado", "Revisión", "demo-1.0",
  "alerta_ingreso_ausente", "ingreso_mensual_usd", "Ausencia no equiparada a error", "Advertencia", "demo-1.0",
  "alerta_ingreso_extremo", "ingreso_mensual_usd", "Umbral exploratorio IQR", "Advertencia", "demo-1.0"
 ) %>%
  dplyr::mutate(
    fuente = "Escenario didáctico M4; sujeto a revisión metodológica",
    responsable = "Equipo docente (ejercicio)",
    vigencia = "Solo capacitación 2026-11"
  )
print(reglas_m4, n = Inf)

# PASO 4.2 · Catálogo de provincias SOLO para la demostración.
# Reemplazar por un catálogo controlado y vigente en una operación real.
catalogo_provincias_demo <- c(
  "Azuay", "Bolívar", "Cañar", "Carchi", "Chimborazo", "Cotopaxi",
  "El Oro", "Esmeraldas", "Galápagos", "Guayas", "Imbabura", "Loja",
  "Los Ríos", "Manabí", "Morona Santiago", "Napo", "Orellana",
  "Pastaza", "Pichincha", "Santa Elena", "Santo Domingo de los Tsáchilas",
  "Sucumbíos", "Tungurahua", "Zamora Chinchipe"
)

# PASO 4.3 · Parámetros y expresiones regulares; se documentan antes del control.
patron_id <- "^P[0-9]{5}$"
patron_periodo <- "^[0-9]{4}-[0-9]{2}$"
patron_fecha <- "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
patron_num <- "^-?[0-9]+(\\.[0-9]+)?$"

# El cuartil puede señalar atípicos, NO establecer por sí mismo un error.
ingreso_no_negativo <- datos_perfilados$ingreso_num[
  !is.na(datos_perfilados$ingreso_num) & datos_perfilados$ingreso_num >= 0
]
q1_ingreso <- as.numeric(stats::quantile(ingreso_no_negativo, 0.25))
q3_ingreso <- as.numeric(stats::quantile(ingreso_no_negativo, 0.75))
limite_exploratorio <- q3_ingreso + 1.5 * (q3_ingreso - q1_ingreso)
print(limite_exploratorio)

# PASO 4.4 · Registrar incidencias lógicas en columnas nuevas.
datos_validados <- datos_perfilados %>%
  dplyr::mutate(
    fecha_parseada = as.Date(fecha_levantamiento, format = "%Y-%m-%d"),
    error_id_ausente = es_ausente(id_persona),
    error_id_formato = !es_ausente(id_persona) & !grepl(patron_id, id_persona),
    error_id_duplicado = !es_ausente(id_persona) &
      (duplicated(id_persona) | duplicated(id_persona, fromLast = TRUE)),
    error_edad_ausente = es_ausente(edad),
    error_edad_formato = !es_ausente(edad) & !grepl(patron_num, trimws(edad)),
    error_edad_rango = !is.na(edad_num) &
      (edad_num < 0 | edad_num > 110 | edad_num != floor(edad_num)),
    error_fecha_ausente = es_ausente(fecha_levantamiento),
    error_fecha_formato = !es_ausente(fecha_levantamiento) &
      (!grepl(patron_fecha, fecha_levantamiento) | is.na(fecha_parseada)),
    error_periodo_formato = !grepl(patron_periodo, periodo_referencia),
    error_sexo_ausente = es_ausente(sexo),
    error_sexo_dominio = !es_ausente(sexo) & !sexo %in% c("Hombre", "Mujer"),
    error_area_dominio = !es_ausente(area) & !area %in% c("Urbana", "Rural"),
    error_provincia_dominio = !es_ausente(provincia) &
      !provincia %in% catalogo_provincias_demo,
    error_ingreso_formato = !es_ausente(ingreso_mensual_usd) &
      !grepl(patron_num, trimws(ingreso_mensual_usd)),
    error_ingreso_negativo = !is.na(ingreso_num) & ingreso_num < 0,
    alerta_ingreso_ausente = es_ausente(ingreso_mensual_usd),
    alerta_ingreso_extremo = !is.na(ingreso_num) &
      ingreso_num > limite_exploratorio
  )

# PASO 4.5 · Filas con cualquier señal, sin deduplicar ni corregir.
columnas_reglas <- reglas_m4$regla
datos_validados <- datos_validados %>%
  dplyr::mutate(total_alertas_registro = rowSums(dplyr::across(
    dplyr::all_of(columnas_reglas)
  ), na.rm = TRUE))

filas_con_incidencias <- datos_validados %>%
  dplyr::filter(total_alertas_registro > 0) %>%
  dplyr::select(fila_csv, id_persona, total_alertas_registro)
print(filas_con_incidencias, n = 20)

# PASO 4.6 · Transformar columnas de errores en bitácora larga.
incidencias_m4 <- datos_validados %>%
  dplyr::select(fila_csv, id_persona, dplyr::all_of(columnas_reglas)) %>%
  tidyr::pivot_longer(
    cols = dplyr::all_of(columnas_reglas),
    names_to = "regla", values_to = "incumple"
  ) %>%
  dplyr::filter(!is.na(incumple), incumple) %>%
  dplyr::select(-incumple) %>%
  dplyr::left_join(reglas_m4, by = "regla")
print(incidencias_m4, n = 20)
# Un registro puede fallar más de una regla: contar alertas ≠ contar personas.

# PASO 4.7 · Indicadores y denominadores explícitos.
resumen_reglas_m4 <- incidencias_m4 %>%
  dplyr::count(regla, variable, criterio, severidad, name = "incidencias") %>%
  dplyr::mutate(
    registros_evaluados = nrow(datos),
    porcentaje_sobre_filas = round(100 * incidencias / registros_evaluados, 2)
  ) %>%
  dplyr::arrange(dplyr::desc(incidencias))
print(resumen_reglas_m4, n = Inf)

# El denominador de VALIDEZ solo incluye entradas numéricas interpretables.
indicador_edad_rango <- datos_validados %>%
  dplyr::summarise(
    numericas_interpretables = sum(!is.na(edad_num)),
    cumplen_rango = sum(!is.na(edad_num) & !error_edad_rango),
    validez_evaluable = ifelse(numericas_interpretables > 0,
      100 * cumplen_rango / numericas_interpretables, NA_real_)
  )
print(indicador_edad_rango)

# PASO 4.8 · Gráfico de tipos de incidencia.
g_reglas <- resumen_reglas_m4 %>%
  ggplot2::ggplot(ggplot2::aes(
    x = stats::reorder(regla, incidencias), y = incidencias, fill = severidad
  )) +
  ggplot2::geom_col() +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Incidencias por regla y severidad",
                x = NULL, y = "Incidencias registradas") +
  ggplot2::theme_minimal()
print(g_reglas)

# PASO 4.9 · Exportación solo tras inspección humana.
# readr::write_csv(reglas_m4, here::here("resultados", "m4_reglas_demo.csv"))
# readr::write_csv(incidencias_m4, here::here("resultados", "m4_incidencias.csv"))
# readr::write_csv(resumen_reglas_m4, here::here("resultados", "m4_resumen.csv"))
