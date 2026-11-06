# =============================================================================
# MÓDULO 3 · PERFILADO Y DIAGNÓSTICO DE CALIDAD
# Requisito: ejecutar primero por secciones R/00_preparacion.R.
# Construcción progresiva: cada bloque se comenta y se interpreta en clase.
# =============================================================================

# PASO 3.1 · Recuento total de ausencias, columna por columna.
tabla_ausencias <- tibble::tibble(
  variable = names(datos),
  n_ausentes = vapply(datos, function(x) sum(es_ausente(x)), integer(1))
) %>%
  dplyr::mutate(
    porcentaje = round(100 * n_ausentes / nrow(datos), 2)
  ) %>%
  dplyr::arrange(dplyr::desc(n_ausentes))
print(tabla_ausencias, n = 27)
# Observaciones es un campo opcional vacío; no equiparar ausencia con fallo.

# PASO 3.2 · Gráfico de barras de ausencias (se excluye el campo libre opcional).
g_ausencias <- tabla_ausencias %>%
  dplyr::filter(variable != "observaciones", n_ausentes > 0) %>%
  ggplot2::ggplot(ggplot2::aes(
    x = stats::reorder(variable, n_ausentes), y = n_ausentes
  )) +
  ggplot2::geom_col(fill = "#14679E") +
  ggplot2::coord_flip() +
  ggplot2::labs(
    title = "Ausencias declaradas por variable",
    subtitle = "CSV sintético · 1.500 registros · no implica error automático",
    x = NULL, y = "Número de ausencias"
  ) +
  ggplot2::theme_minimal()
print(g_ausencias)
# OPCIONAL DESPUÉS DE REVISAR:
# ggplot2::ggsave(here::here("resultados", "m3_ausencias.png"), g_ausencias, width=10, height=6)

# PASO 3.3 · Repetición de identificadores: primero excluir ausentes.
ids_validos <- datos$id_persona[!es_ausente(datos$id_persona)]
repeticiones_adicionales <- sum(duplicated(ids_validos))
filas_con_id_repetido <- datos %>%
  dplyr::mutate(fila_csv = dplyr::row_number() + 1L) %>%
  dplyr::filter(
    !es_ausente(id_persona),
    duplicated(id_persona) | duplicated(id_persona, fromLast = TRUE)
  ) %>%
  dplyr::arrange(id_persona, fila_csv)
print(repeticiones_adicionales) # Esperado: 20 adicionales, no 20 filas afectadas.
print(filas_con_id_repetido, n = 12)

# PASO 3.4 · Duplicados exactos: no confundir clave repetida con fila igual.
filas_duplicadas_exactas <- sum(duplicated(datos))
print(filas_duplicadas_exactas) # Esperado: 4 filas adicionales idénticas.

# PASO 3.5 · Frecuencias de categorías para detectar casos atípicos.
frecuencia_sexo <- datos %>%
  dplyr::mutate(sexo_revisado = ifelse(es_ausente(sexo), "[Ausente]", sexo)) %>%
  dplyr::count(sexo_revisado, name = "total", sort = TRUE)
print(frecuencia_sexo)

frecuencia_provincias <- datos %>%
  dplyr::mutate(provincia_revisada = ifelse(es_ausente(provincia), "[Ausente]", provincia)) %>%
  dplyr::count(provincia_revisada, name = "total", sort = TRUE)
print(frecuencia_provincias, n = 30)

# PASO 3.6 · Visualización de categorías (una frecuencia baja NO prueba error).
g_sexo <- ggplot2::ggplot(
  frecuencia_sexo, ggplot2::aes(x = stats::reorder(sexo_revisado, total), y = total)
) +
  ggplot2::geom_col(fill = "#14679E") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Categorías observadas en sexo", x = NULL, y = "Registros") +
  ggplot2::theme_minimal()
print(g_sexo)

# PASO 3.7 · Detectar FORMATOS no numéricos antes de convertirlos.
# Este patrón exige enteros o decimales con punto: no interpreta símbolos o texto.
patron_numero <- "^-?[0-9]+(\\.[0-9]+)?$"
formatos_edad <- datos %>%
  dplyr::mutate(fila_csv = dplyr::row_number() + 1L) %>%
  dplyr::filter(!es_ausente(edad), !grepl(patron_numero, trimws(edad))) %>%
  dplyr::select(fila_csv, id_persona, edad)
formatos_ingreso <- datos %>%
  dplyr::mutate(fila_csv = dplyr::row_number() + 1L) %>%
  dplyr::filter(!es_ausente(ingreso_mensual_usd),
                !grepl(patron_numero, trimws(ingreso_mensual_usd))) %>%
  dplyr::select(fila_csv, id_persona, ingreso_mensual_usd)
print(formatos_edad, n = Inf)     # Esperado: 6 representaciones no numéricas.
print(formatos_ingreso, n = Inf)  # Esperado: 3 representaciones no numéricas.

# PASO 3.8 · Crear COPIAS numéricas sin sobrescribir las columnas originales.
datos_perfilados <- datos %>%
  dplyr::mutate(
    fila_csv = dplyr::row_number() + 1L,
    edad_num = numero_estricto(edad),
    ingreso_num = numero_estricto(ingreso_mensual_usd),
    horas_num = numero_estricto(horas_trabajo_semana),
    escolaridad_num = numero_estricto(anios_escolaridad)
  )

# PASO 3.9 · Estadística descriptiva de edad (solo rango didáctico 0 a 110).
edades_elegibles <- datos_perfilados %>%
  dplyr::filter(!is.na(edad_num), edad_num >= 0, edad_num <= 110,
                edad_num == floor(edad_num))
resumen_edad <- edades_elegibles %>%
  dplyr::summarise(
    n = dplyr::n(),
    media = mean(edad_num),
    mediana = median(edad_num),
    desviacion = sd(edad_num),
    minimo = min(edad_num),
    q1 = as.numeric(quantile(edad_num, 0.25)),
    q3 = as.numeric(quantile(edad_num, 0.75)),
    maximo = max(edad_num)
  )
print(resumen_edad)
# 0–110 es un supuesto DE PRÁCTICA, no una norma INEC.

# PASO 3.10 · Diagnóstico de ingreso: cero, negativos y extremos.
resumen_ingreso <- datos_perfilados %>%
  dplyr::summarise(
    n_numericos = sum(!is.na(ingreso_num)),
    ceros = sum(ingreso_num == 0, na.rm = TRUE),
    negativos = sum(ingreso_num < 0, na.rm = TRUE),
    media = mean(ingreso_num, na.rm = TRUE),
    mediana = median(ingreso_num, na.rm = TRUE),
    percentil_99 = as.numeric(quantile(ingreso_num, 0.99, na.rm = TRUE)),
    maximo = max(ingreso_num, na.rm = TRUE)
  )
print(resumen_ingreso)
# NO reemplazar ingresos 0 por NA: puede ser un valor legítimo.
# El valor extremo puede distorsionar enormemente la media.

# PASO 3.11 · Histograma con zoom SOLO VISUAL (la base no se modifica).
g_ingresos <- datos_perfilados %>%
  dplyr::filter(!is.na(ingreso_num), ingreso_num >= 0, ingreso_num <= 3000) %>%
  ggplot2::ggplot(ggplot2::aes(x = ingreso_num)) +
  ggplot2::geom_histogram(binwidth = 100, boundary = 0, fill = "#14679E", color = "white") +
  ggplot2::labs(
    title = "Distribución de ingresos: vista USD 0–3.000",
    subtitle = "Subconjunto SOLO para el gráfico; el CSV completo permanece intacto",
    x = "Ingreso mensual (USD)", y = "Número de personas"
  ) +
  ggplot2::theme_minimal()
print(g_ingresos)

# PASO 3.12 · Boxplot con escala transformada; no eliminar los extremos.
g_box_ingreso <- datos_perfilados %>%
  dplyr::filter(!is.na(ingreso_num), ingreso_num >= 0) %>%
  ggplot2::ggplot(ggplot2::aes(x = condicion_actividad, y = log10(ingreso_num + 1))) +
  ggplot2::geom_boxplot(fill = "#DAE9F2", color = "#14679E", outlier.color = "#E67E22") +
  ggplot2::labs(
    title = "Distribución de ingresos según actividad",
    subtitle = "Eje Y: log10(ingreso + 1). Atípico no significa error.",
    x = "Condición de actividad", y = "log10(ingreso mensual + 1)"
  ) +
  ggplot2::theme_minimal()
print(g_box_ingreso)

# PASO 3.13 · Tabla descriptiva por condición de actividad.
tabla_ingreso_actividad <- datos_perfilados %>%
  dplyr::group_by(condicion_actividad) %>%
  dplyr::summarise(
    registros = dplyr::n(),
    n_ingreso_numerico = sum(!is.na(ingreso_num)),
    ingreso_media = mean(ingreso_num, na.rm = TRUE),
    ingreso_mediana = median(ingreso_num, na.rm = TRUE),
    .groups = "drop"
  )
print(tabla_ingreso_actividad)

# PASO 3.14 · Tablas que alimentarán los módulos siguientes.
# No guardar antes de revisar rutas y resultados.
# readr::write_csv(tabla_ausencias, here::here("resultados", "m3_ausencias.csv"))
# readr::write_csv(formatos_ingreso, here::here("resultados", "m3_formatos_ingreso.csv"))
