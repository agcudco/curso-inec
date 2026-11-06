# =============================================================================
# MÓDULO 3 · EXTENSIÓN: IMPUTACIÓN ESTADÍSTICA DEMOSTRATIVA
# Ejecutar después de 03_perfilado_diagnostico.R.
# NO forma parte de la depuración oficial; requiere aprobación metodológica.
# =============================================================================

# PASO 3.15 · Definir qué edades son elegibles para el ejercicio.
# El valor original edad permanece intacto en datos y datos_perfilados.
datos_imputados <- datos_perfilados %>%
  dplyr::mutate(
    edad_elegible = dplyr::if_else(
      !is.na(edad_num) & edad_num >= 0 & edad_num <= 110 & edad_num == floor(edad_num),
      edad_num,
      NA_real_
    ),
    # Se conserva el indicador de ausencia: distinguir observado de estimado.
    edad_fue_imputada = is.na(edad_elegible)
  )

# PASO 3.16 · Estadísticos ANTES de completar valores.
media_edad <- mean(datos_imputados$edad_elegible, na.rm = TRUE)
mediana_edad <- median(datos_imputados$edad_elegible, na.rm = TRUE)
print(c(media = media_edad, mediana = mediana_edad))

# PASO 3.17 · Construir DOS ALTERNATIVAS, jamás sobrescribir edad_elegible.
datos_imputados <- datos_imputados %>%
  dplyr::mutate(
    edad_por_media = dplyr::coalesce(edad_elegible, media_edad),
    edad_por_mediana = dplyr::coalesce(edad_elegible, mediana_edad)
  )

# PASO 3.18 · Mediana estratificada por provincia (demostración).
# Si un grupo carece de datos, se usa la mediana global como respaldo.
datos_imputados <- datos_imputados %>%
  dplyr::group_by(provincia) %>%
  dplyr::mutate(
    mediana_grupo = if (all(is.na(edad_elegible))) mediana_edad
                    else median(edad_elegible, na.rm = TRUE),
    edad_por_grupo = dplyr::coalesce(edad_elegible, mediana_grupo)
  ) %>%
  dplyr::ungroup()

# PASO 3.19 · Ingreso: se respeta el 0; negativos se dejan en revisión.
# Un extremo alto sigue presente y afecta el promedio; es INTENCIONAL.
datos_imputados <- datos_imputados %>%
  dplyr::mutate(
    ingreso_elegible = dplyr::if_else(
      !is.na(ingreso_num) & ingreso_num >= 0, ingreso_num, NA_real_
    ),
    ingreso_fue_imputado = is.na(ingreso_elegible)
  )
media_ingreso <- mean(datos_imputados$ingreso_elegible, na.rm = TRUE)
mediana_ingreso <- median(datos_imputados$ingreso_elegible, na.rm = TRUE)

# PASO 3.20 · Comparar dos copias: media vs. mediana.
datos_imputados <- datos_imputados %>%
  dplyr::mutate(
    ingreso_por_media = dplyr::coalesce(ingreso_elegible, media_ingreso),
    ingreso_por_mediana = dplyr::coalesce(ingreso_elegible, mediana_ingreso)
  )

# PASO 3.21 · Imputación condicional con mediana de quienes declararon ocupación.
# Aplicable solo como EJERCICIO; no asumir que los faltantes son aleatorios.
mediana_ocupados <- median(
  datos_imputados$ingreso_elegible[
    datos_imputados$condicion_actividad == "Ocupado"
  ], na.rm = TRUE
)
datos_imputados <- datos_imputados %>%
  dplyr::mutate(
    ingreso_mediana_ocupados = dplyr::if_else(
      condicion_actividad == "Ocupado" & is.na(ingreso_elegible),
      mediana_ocupados,
      ingreso_elegible
    )
  )

# PASO 3.22 · La moda sólo como ejercicio con una variable categórica.
moda_no_ambigua <- function(x) {
  v <- x[!es_ausente(x)]
  if (length(v) == 0L) return(NA_character_)
  freq <- sort(table(v), decreasing = TRUE)
  if (length(freq) > 1L && freq[[1L]] == freq[[2L]]) return(NA_character_)
  names(freq)[1L]
}
moda_sexo_demo <- moda_no_ambigua(datos$sexo[datos$sexo %in% c("Hombre", "Mujer")])
# Se trata solo la ausencia: 'F' y '99' siguen siendo categorías por revisar.
datos_imputados <- datos_imputados %>%
  dplyr::mutate(
    sexo_por_moda = ifelse(es_ausente(sexo), moda_sexo_demo, sexo)
  )

# PASO 3.23 · Medir diferencias entre escenarios de imputación.
comparacion_edad <- tibble::tibble(
  escenario = c("Observado elegible", "Media global", "Mediana global", "Mediana por provincia"),
  n_observaciones = c(
    sum(!is.na(datos_imputados$edad_elegible)),
    sum(!is.na(datos_imputados$edad_por_media)),
    sum(!is.na(datos_imputados$edad_por_mediana)),
    sum(!is.na(datos_imputados$edad_por_grupo))
  ),
  media_resultante = c(
    mean(datos_imputados$edad_elegible, na.rm = TRUE),
    mean(datos_imputados$edad_por_media, na.rm = TRUE),
    mean(datos_imputados$edad_por_mediana, na.rm = TRUE),
    mean(datos_imputados$edad_por_grupo, na.rm = TRUE)
  ),
  desviacion_resultante = c(
    sd(datos_imputados$edad_elegible, na.rm = TRUE),
    sd(datos_imputados$edad_por_media, na.rm = TRUE),
    sd(datos_imputados$edad_por_mediana, na.rm = TRUE),
    sd(datos_imputados$edad_por_grupo, na.rm = TRUE)
  )
)
print(comparacion_edad)

# PASO 3.24 · Gráfico comparativo de dispersiones después de imputación.
comparacion_larga <- datos_imputados %>%
  dplyr::select(edad_elegible, edad_por_media, edad_por_mediana, edad_por_grupo) %>%
  tidyr::pivot_longer(cols = dplyr::everything(), names_to = "metodo", values_to = "edad")
g_imputacion <- ggplot2::ggplot(comparacion_larga, ggplot2::aes(x = metodo, y = edad)) +
  ggplot2::geom_boxplot(fill = "#D8E9F2", color = "#14679E") +
  ggplot2::labs(title = "Edad observada e imputada: comparación de métodos",
                subtitle = "La imputación modifica la distribución. No son valores observados.",
                x = "Método", y = "Años") +
  ggplot2::theme_minimal() +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 20, hjust = 1))
print(g_imputacion)

# PASO 3.25 · Guardado opcional SOLO de resultados derivados y con advertencia.
# readr::write_csv(comparacion_edad,
#   here::here("resultados", "m3_comparacion_imputacion_exploratoria.csv"))
# No guardar el marco completo con datos imputados como si fuese base validada.
