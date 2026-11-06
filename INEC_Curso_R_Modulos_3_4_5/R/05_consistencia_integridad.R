# =============================================================================
# MÓDULO 5 · CONSISTENCIA LÓGICA, CLAVES E INTEGRIDAD REFERENCIAL
# Requisito: 00_preparacion.R, 03_perfilado_diagnostico.R, 04_validacion_automatica.R
# Las relaciones del ejercicio son criterios ilustrativos y no políticas INEC.
# =============================================================================

# PASO 5.1 · Reglas entre variables (separar no evaluable de fallo).
datos_consistencia <- datos_validados %>%
  dplyr::mutate(
    alerta_ocupado_cero_horas = condicion_actividad == "Ocupado" &
      !is.na(horas_num) & horas_num == 0,
    alerta_inactivo_horas = condicion_actividad == "Inactivo" &
      !is.na(horas_num) & horas_num > 0,
    alerta_fecha_periodo = !is.na(fecha_parseada) &
      !es_ausente(periodo_referencia) &
      format(fecha_parseada, "%Y-%m") != periodo_referencia,
    alerta_escolaridad_edad = !is.na(edad_num) &
      !is.na(escolaridad_num) & escolaridad_num > edad_num
  )

# PASO 5.2 · Crear bitácora de relaciones lógicas.
reglas_m5 <- tibble::tribble(
  ~regla, ~variable, ~criterio, ~severidad, ~version,
  "alerta_ocupado_cero_horas", "condicion_actividad + horas_trabajo_semana",
    "Ocupación declarada con 0 horas", "Revisión", "demo-1.0",
  "alerta_inactivo_horas", "condicion_actividad + horas_trabajo_semana",
    "Inactividad declarada con horas positivas", "Revisión", "demo-1.0",
  "alerta_fecha_periodo", "fecha_levantamiento + periodo_referencia",
    "Mes de fecha diferente del período", "Revisión", "demo-1.0",
  "alerta_escolaridad_edad", "anios_escolaridad + edad",
    "Escolaridad mayor que edad", "Revisión", "demo-1.0"
) %>%
  dplyr::mutate(
    fuente = "Escenario didáctico M5; sujeto a revisión metodológica",
    responsable = "Equipo docente (ejercicio)",
    vigencia = "Solo capacitación 2026-11"
  )
incidencias_m5 <- datos_consistencia %>%
  dplyr::select(fila_csv, id_persona, dplyr::all_of(reglas_m5$regla)) %>%
  tidyr::pivot_longer(
    cols = dplyr::all_of(reglas_m5$regla),
    names_to = "regla", values_to = "incumple"
  ) %>%
  dplyr::filter(!is.na(incumple), incumple) %>%
  dplyr::select(-incumple) %>%
  dplyr::left_join(reglas_m5, by = "regla")
print(incidencias_m5, n = 20)

# PASO 5.3 · Claves repetidas por persona y período.
# No se concluye automáticamente que toda repetición sea un duplicado real.
conflictos_persona_periodo <- datos %>%
  dplyr::filter(!es_ausente(id_persona)) %>%
  dplyr::group_by(id_persona, periodo_referencia) %>%
  dplyr::summarise(
    filas = dplyr::n(),
    edades_diferentes = dplyr::n_distinct(edad[!es_ausente(edad)]),
    ingresos_diferentes = dplyr::n_distinct(
      ingreso_mensual_usd[!es_ausente(ingreso_mensual_usd)]
    ),
    .groups = "drop"
  ) %>%
  dplyr::filter(filas > 1) %>%
  dplyr::arrange(dplyr::desc(filas))
print(conflictos_persona_periodo, n = 20)

# PASO 5.4 · Posibles dependencias dentro del hogar.
# Advertencia: este CSV es sintético y puede no haber sido generado con
# atributos de hogar coherentes. No usar este hallazgo para borrar registros.
conflictos_hogar <- datos %>%
  dplyr::filter(!es_ausente(id_hogar)) %>%
  dplyr::group_by(id_hogar) %>%
  dplyr::summarise(
    personas_registradas = dplyr::n(),
    provincias_distintas = dplyr::n_distinct(
      provincia[!es_ausente(provincia)]
    ),
    areas_distintas = dplyr::n_distinct(area[!es_ausente(area)]),
    tamanios_declarados_distintos = dplyr::n_distinct(personas_hogar),
    .groups = "drop"
  ) %>%
  dplyr::filter(provincias_distintas > 1 | areas_distintas > 1 |
                tamanios_declarados_distintos > 1)
print(conflictos_hogar, n = 15)

# PASO 5.5 · Integridad referencial: microcatálogo construido PARA ENSEÑAR.
# IMPORTANTE: un catálogo derivado de personas NO demostraría integridad real.
# Esta referencia independiente y limitada solo sirve para un subconjunto.
catalogo_hogares_demo <- tibble::tibble(
  id_hogar = c("H00001", "H00002", "H00003")
)
personas_subconjunto <- datos %>%
  dplyr::filter(id_hogar %in% c("H00001", "H00002", "H00003", "H00004"))
personas_huerfanas_demo <- personas_subconjunto %>%
  dplyr::anti_join(catalogo_hogares_demo, by = "id_hogar")
print(personas_huerfanas_demo %>% dplyr::select(id_persona, id_hogar), n = 20)
# Se espera que H00004 no tenga correspondencia en este catálogo INCOMPLETO.
# Para evaluar todo el CSV se necesita un archivo de hogares independiente.

# PASO 5.6 · Comparación de provincia/cantón con catálogo SOLO PARCIAL.
# No marcar otros cantones como errores cuando la referencia es parcial.
catalogo_geo_demo <- tibble::tribble(
  ~provincia, ~canton,
  "Pichincha", "Quito",
  "Pichincha", "Rumiñahui",
  "Guayas", "Guayaquil",
  "Azuay", "Cuenca"
)
# Limitar el análisis a cantones explícitamente presentes en la referencia.
territorio_evaluable <- datos %>%
  dplyr::filter(canton %in% catalogo_geo_demo$canton)
pares_no_coincidentes_demo <- territorio_evaluable %>%
  dplyr::anti_join(catalogo_geo_demo, by = c("provincia", "canton"))
print(pares_no_coincidentes_demo %>%
        dplyr::select(id_persona, provincia, canton), n = 20)

# PASO 5.7 · Agregar las incidencias de M4 y M5 con trazabilidad.
bitacora_consolidada <- dplyr::bind_rows(incidencias_m4, incidencias_m5) %>%
  dplyr::arrange(fila_csv, regla)
print(bitacora_consolidada, n = 25)

# PASO 5.8 · Producir una tabla de seguimiento.
resumen_severidad <- bitacora_consolidada %>%
  dplyr::count(severidad, regla, name = "incidencias") %>%
  dplyr::arrange(dplyr::desc(incidencias))
print(resumen_severidad, n = Inf)

g_logica <- incidencias_m5 %>%
  dplyr::count(regla, name = "incidencias") %>%
  ggplot2::ggplot(ggplot2::aes(
    x = stats::reorder(regla, incidencias), y = incidencias
  )) +
  ggplot2::geom_col(fill = "#E77F23") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Alertas de consistencia lógica",
                subtitle = "Revisiones, no errores concluyentes",
                x = NULL, y = "Incidencias") +
  ggplot2::theme_minimal()
print(g_logica)

# PASO 5.9 · Preparar exportación después de revisión.
# readr::write_csv(incidencias_m5, here::here("resultados", "m5_incidencias.csv"))
# readr::write_csv(bitacora_consolidada, here::here("resultados", "m5_bitacora.csv"))
# readr::write_csv(conflictos_hogar, here::here("resultados", "m5_conflictos_hogar.csv"))
