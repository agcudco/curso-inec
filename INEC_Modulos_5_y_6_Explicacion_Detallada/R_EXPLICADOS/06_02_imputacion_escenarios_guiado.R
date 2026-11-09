# ============================================================================
# MÓDULO 6.2 | MEDIA, MEDIANA E IMPUTACIÓN EN ESCENARIOS (NO AUTORIZADOS)
# Media: suma de valores observados / número de valores observados.
# Mediana: valor central de la serie ordenada; robusta frente a extremos.
# Imputación: sustitución estimada del faltante, con supuestos y sesgos.
# ============================================================================
# EXPLICACIÓN DOCENTE | OBJETIVO: reutilizar ingreso_n y condicion_actividad para estudiar imputación.
# EXPLICACIÓN DOCENTE | No cambiar ingreso_mensual_usd del CSV fuente.
# ----------------------------------------------------------------------
source(here::here("R", "00_preparacion.R"))

# PASO 1. Confirmar que las cantidades están estandarizadas y que cero != NA.
# EXPLICACIÓN DOCENTE | sum(is.na(...)) cuenta faltantes; sum(x==0, na.rm=TRUE) cuenta ceros.
# EXPLICACIÓN DOCENTE | max(x, na.rm=TRUE) toma máximo ignorando faltantes (si todo NA, revisar advertencia).
# EXPLICACIÓN DOCENTE | CONCEPTO: NA=desconocido; 0=valor medido; negativo=caso para revisión.
# ----------------------------------------------------------------------
personas %>% summarise(
  ausencias = sum(is.na(ingreso_n)),
  ceros = sum(ingreso_n == 0, na.rm = TRUE),
  negativos = sum(ingreso_n < 0, na.rm = TRUE),
  maximo = max(ingreso_n, na.rm = TRUE)
)

# PASO 2. Conjunto numérico válido para estimadores (filtro didáctico: >= 0).
# Negativos: se separan como 'requieren revisión', no se borran del origen.
# EXPLICACIÓN DOCENTE | OBJETIVO: crear vector analítico de importes observados no negativos.
# EXPLICACIÓN DOCENTE | La expresión x[condicion] selecciona elementos por índice lógico.
# EXPLICACIÓN DOCENTE | !is.na() descarta ausencias; >=0 mantiene CEROS y positivos.
# EXPLICACIÓN DOCENTE | Esto no elimina registros del CSV ni confirma la validez contextual.
# ----------------------------------------------------------------------
ingresos_validos <- personas$ingreso_n[
  !is.na(personas$ingreso_n) & personas$ingreso_n >= 0
]
# EXPLICACIÓN DOCENTE | mean(x) = suma / n; median(x) = centro de los valores ordenados.
# EXPLICACIÓN DOCENTE | Los extremos influyen en mean() mucho más que en median().
# EXPLICACIÓN DOCENTE | mean(x[x<=3000]) es ANALISIS DE SENSIBILIDAD didáctico, no regla aprobada.
# EXPLICACIÓN DOCENTE | cat(..., "\n") presenta un resultado en consola.
# ----------------------------------------------------------------------
media_global <- mean(ingresos_validos)
mediana_global <- median(ingresos_validos)
media_sensibilidad <- mean(ingresos_validos[ingresos_validos <= 3000])
cat("Media válida:", media_global, "\n")
cat("Mediana válida:", mediana_global, "\n")
cat("Media sin extremos >3000 (SOLO sensibilidad):", media_sensibilidad, "\n")

# PASO 3. La mediana por condición de actividad puede ser distinta por grupo.
# EXPLICACIÓN DOCENTE | filter(!is.na(grupo)) define grupos conocidos; group_by() los separa;
# EXPLICACIÓN DOCENTE | summarise() calcula una fila por condición de actividad;
# EXPLICACIÓN DOCENTE | median(x, na.rm=TRUE) obtiene mediana del grupo;
# EXPLICACIÓN DOCENTE | .groups="drop" elimina agrupamiento después del cálculo.
# EXPLICACIÓN DOCENTE | Riesgo: un grupo sin valores observados genera NA y puede producir aviso.
# ----------------------------------------------------------------------
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
# EXPLICACIÓN DOCENTE | left_join(personas, medianas_grupo, by="condicion_actividad") añade estadísticas por grupo.
# EXPLICACIÓN DOCENTE | mutate() agrega columnas derivadas, conservando ingreso_n observado.
# EXPLICACIÓN DOCENTE | if_else(condicion, si_verdadero, si_falso) permite sustituir SOLO NA;
# EXPLICACIÓN DOCENTE | coalesce(mediana_grupo, mediana_global) usa respaldo cuando el grupo no tiene mediana.
# EXPLICACIÓN DOCENTE | OBJETIVO: simular tres métodos sin presentar datos imputados como observados.
# ----------------------------------------------------------------------
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
# EXPLICACIÓN DOCENTE | OBJETIVO: cuantificar efecto sobre promedios y medianas.
# EXPLICACIÓN DOCENTE | Comparar estimadores sin asumir que los valores sustituidos son verdaderos.
# EXPLICACIÓN DOCENTE | Se mantienen datos negativos en la tabla original para revisión.
# ----------------------------------------------------------------------
escenarios %>% summarise(
  n_imputados = sum(imputacion_aplicada),
  media_escenario = mean(ingreso_media_sim[ingreso_media_sim >= 0]),
  mediana_escenario = median(ingreso_mediana_sim[ingreso_mediana_sim >= 0]),
  media_grupo_escenario = mean(ingreso_grupo_sim[ingreso_grupo_sim >= 0])
)

# PASO 6. Visualizar el efecto de la distribución asimétrica.
# EXPLICACIÓN DOCENTE | tibble() crea tabla manual de tres estimadores;
# EXPLICACIÓN DOCENTE | round(x,2) presenta dos decimales, sin modificar precisión almacenada;
# EXPLICACIÓN DOCENTE | ggplot() + geom_col() + geom_text() permite observar sensibilidad de la media.
# EXPLICACIÓN DOCENTE | Cuidado: un gráfico sin unidades u origen de valores puede inducir errores.
# ----------------------------------------------------------------------
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
