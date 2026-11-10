# ============================================================================
# MÓDULO 6.2 | MEDIA, MEDIANA E IMPUTACIÓN EN ESCENARIOS (NO AUTORIZADOS)
# Media: suma de valores observados / número de valores observados.
# Mediana: valor central de la serie ordenada; robusta frente a extremos.
# Imputación: sustitución estimada del faltante, con supuestos y sesgos.
# ============================================================================
source(here::here("R", "00_preparacion.R"))

# PASO 1. Confirmar que las cantidades están estandarizadas y que cero != NA.
personas %>% summarise(
  ausencias = sum(is.na(ingreso_n)),
  ceros = sum(ingreso_n == 0, na.rm = TRUE),
  negativos = sum(ingreso_n < 0, na.rm = TRUE),
  maximo = max(ingreso_n, na.rm = TRUE)
)

# PASO 2. Conjunto numérico válido para estimadores (filtro didáctico: >= 0).
# Negativos: se separan como 'requieren revisión', no se borran del origen.
ingresos_validos <- personas$ingreso_n[
  !is.na(personas$ingreso_n) & personas$ingreso_n >= 0
]
media_global <- mean(ingresos_validos)
mediana_global <- median(ingresos_validos)
media_sensibilidad <- mean(ingresos_validos[ingresos_validos <= 3000])
cat("Media válida:", media_global, "\n")
cat("Mediana válida:", mediana_global, "\n")
cat("Media sin extremos >3000 (SOLO sensibilidad):", media_sensibilidad, "\n")

# PASO 3. La mediana por condición de actividad puede ser distinta por grupo.
medianas_grupo <- personas %>%
  filter(!is.na(condicion_actividad)) %>%
  group_by(condicion_actividad) %>%
  summarise(
    mediana_grupo = median(ingreso_n[!is.na(ingreso_n) & ingreso_n >= 0],
                           na.rm = TRUE),
    observados_validos = sum(!is.na(ingreso_n) & ingreso_n >= 0),
    .groups = "drop"
  )
print(medianas_grupo)

# PASO 4. Crear variables de ESCENARIO. Preservar negativos existentes para
# revisión; solo sustituir los NA. La variable ingreso_n NO se modifica.
escenarios <- personas %>%
  left_join(medianas_grupo, by = "condicion_actividad") %>%
  mutate(
    imputacion_aplicada = is.na(ingreso_n),
    ingreso_media_sim = if_else(is.na(ingreso_n), media_global, ingreso_n),
    ingreso_mediana_sim = if_else(is.na(ingreso_n), mediana_global, ingreso_n),
    ingreso_grupo_sim = if_else(is.na(ingreso_n),
                               coalesce(mediana_grupo, mediana_global), ingreso_n)
  )

# PASO 5. Analizar el efecto SIN presentar los escenarios como datos medidos.
escenarios %>% summarise(
  n_imputados = sum(imputacion_aplicada),
  media_escenario = mean(ingreso_media_sim[ingreso_media_sim >= 0]),
  mediana_escenario = median(ingreso_mediana_sim[ingreso_mediana_sim >= 0]),
  media_grupo_escenario = mean(ingreso_grupo_sim[ingreso_grupo_sim >= 0])
)

# PASO 6. Visualizar el efecto de la distribución asimétrica.
resumen_estimadores <- tibble::tibble(
  estimador = c("Media global", "Mediana global", "Media (<= 3000)"),
  usd = c(media_global, mediana_global, media_sensibilidad)
)
ggplot(resumen_estimadores, aes(x = estimador, y = usd)) +
  geom_col(fill = "#397E9C") +
  geom_text(aes(label = round(usd, 2)), vjust = -0.3) +
  labs(title = "Media y mediana: sensibilidad a extremos",
       x = "Estimador", y = "USD") +
  theme_minimal()

# PAUSA: ¿por qué mediana=0 puede ser correcta y, aun así, poco informativa
# para determinados subgrupos? ¿En qué casos NO debe imputarse un ingreso?
# Nunca sobrescribir 'ingreso_mensual_usd' en el CSV original.
