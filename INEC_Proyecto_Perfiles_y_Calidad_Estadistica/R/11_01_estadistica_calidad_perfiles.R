# =============================================================================
# SESION 11, SCRIPT 11_01 | ESTADISTICA Y CALIDAD POR PERFIL
# Objetivo: comparar valores centrales, dispersion y posibles atipicos.
# Los datos siguen siendo sinteticos. Una alerta NO confirma un error.
# Entrada: resultados/11_base_calidad.rds
# Salida: resultados/11_calidad_perfiles.rds + tablas CSV + graficos PNG.
# =============================================================================

source(here::here("R", "00_configuracion.R"))

# PASO 1. Leer el RDS de preparacion (NO depender del Environment).
ruta <- here::here("resultados", "11_base_calidad.rds")
if (!file.exists(ruta)) stop("Primero ejecute 11_00_evaluar_completitud_perfiles.R")
base <- readRDS(ruta)
datos <- base$datos

# PASO 2. Calcular estadisticos por grupo: media, mediana, desviacion,
# percentil 25 (Q1), percentil 75 (Q3) y rango intercuartilico (IQR).
# Se calculan para edad e ingreso. Todos los datos de estas dos columnas
# en 'datos' son validos, porque asi se seleccionaron en la sesion 10.
estadisticas <- datos %>%
  dplyr::group_by(grupo) %>%
  dplyr::summarise(
    n = dplyr::n(),
    edad_media = round(mean(edad_n), 1),
    edad_mediana = round(median(edad_n), 1),
    edad_sd = round(stats::sd(edad_n), 1),
    edad_q1 = round(as.numeric(stats::quantile(edad_n, 0.25)), 1),
    edad_q3 = round(as.numeric(stats::quantile(edad_n, 0.75)), 1),
    ingreso_media = round(mean(ingreso_n), 2),
    ingreso_mediana = round(median(ingreso_n), 2),
    ingreso_sd = round(stats::sd(ingreso_n), 2),
    ingreso_q1 = round(as.numeric(stats::quantile(ingreso_n, 0.25)), 2),
    ingreso_q3 = round(as.numeric(stats::quantile(ingreso_n, 0.75)), 2),
    .groups = "drop"
  ) %>%
  dplyr::mutate(
    edad_iqr = edad_q3 - edad_q1,
    ingreso_iqr = ingreso_q3 - ingreso_q1,
    diferencia_media_mediana = round(ingreso_media - ingreso_mediana, 2)
  )

# PASO 3. Detectar candidatos atipicos de ingreso usando cuartiles.
# Usamos cuantiles sin redondear para no distorsionar los limites.
limites <- datos %>%
  dplyr::group_by(grupo) %>%
  dplyr::summarise(
    q1 = as.numeric(stats::quantile(ingreso_n, 0.25)),
    q3 = as.numeric(stats::quantile(ingreso_n, 0.75)),
    .groups = "drop"
  ) %>%
  dplyr::mutate(
    iqr = q3 - q1,
    limite_inferior = pmax(0, q1 - 1.5 * iqr),
    limite_superior = q3 + 1.5 * iqr
  )

# Agregar los limites a cada fila, SIN sobrescribir ingreso_n.
revisados <- datos %>%
  dplyr::left_join(dplyr::select(limites, grupo, limite_inferior,
                                  limite_superior), by = "grupo") %>%
  dplyr::mutate(
    candidato_atipico = ingreso_n < limite_inferior |
                        ingreso_n > limite_superior
  )

# PASO 4. Contar observaciones que merecen revision; no eliminarlas.
resumen_atipicos <- revisados %>%
  dplyr::group_by(grupo) %>%
  dplyr::summarise(
    n = dplyr::n(),
    candidatos = sum(candidato_atipico),
    pct_candidatos = round(100 * candidatos / n, 1),
    .groups = "drop"
  )
detalle_atipicos <- revisados %>%
  dplyr::filter(candidato_atipico) %>%
  dplyr::select(id_encuesta, grupo, edad_n, ingreso_n,
                limite_inferior, limite_superior)
print(estadisticas)
print(resumen_atipicos)

# PASO 5. Crear tres visualizaciones. Las PNG sirven para Quarto.
fig_tamanos <- ggplot2::ggplot(base$tamanos,
    ggplot2::aes(x = grupo, y = registros, fill = grupo)) +
  ggplot2::geom_col() +
  ggplot2::geom_text(ggplot2::aes(label = registros), vjust = -0.3) +
  ggplot2::labs(title = "Cantidad de registros por perfil",
                x = "Perfil", y = "Registros agrupados") +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "none")

fig_caja <- ggplot2::ggplot(revisados,
    ggplot2::aes(x = grupo, y = ingreso_n, fill = grupo)) +
  ggplot2::geom_boxplot(outlier.alpha = 0.45) +
  ggplot2::labs(title = "Distribucion del ingreso por perfil",
                subtitle = "Diagrama de caja: linea central = mediana; caja = Q1 a Q3",
                x = "Perfil", y = "Ingreso mensual (USD)") +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "none")

fig_completitud <- ggplot2::ggplot(base$completitud,
    ggplot2::aes(x = variable, y = grupo, fill = pct_completitud)) +
  ggplot2::geom_tile(color = "white") +
  ggplot2::geom_text(ggplot2::aes(label = paste0(pct_completitud, "%")),
                     size = 4) +
  ggplot2::scale_fill_gradient(low = "#e7edf3", high = "#568cad",
                               limits = c(0, 100)) +
  ggplot2::labs(title = "Completitud de variables complementarias por perfil",
                subtitle = "Solo entre los registros agrupados",
                x = "Variable revisada", y = "Perfil", fill = "% presente") +
  ggplot2::theme_minimal() +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 18,
                                                     hjust = 1))

rutas_figuras <- c(
  "resultados/figuras/11_cantidad_por_perfil.png",
  "resultados/figuras/11_caja_ingreso_por_perfil.png",
  "resultados/figuras/11_completitud_por_perfil.png"
)
ggplot2::ggsave(here::here(rutas_figuras[1]), fig_tamanos,
                width = 8, height = 5, dpi = 150)
ggplot2::ggsave(here::here(rutas_figuras[2]), fig_caja,
                width = 8, height = 5, dpi = 150)
ggplot2::ggsave(here::here(rutas_figuras[3]), fig_completitud,
                width = 9, height = 5, dpi = 150)

# PASO 6. Guardar resultados para el reporte Quarto (RDS de salida).
paquete <- list(
  metadatos = list(
    titulo = "Calidad y variabilidad estadistica de perfiles",
    fecha = as.character(Sys.Date()),
    observaciones = nrow(datos),
    nota = "Datos ficticios; indicadores por grupo son descriptivos"
  ),
  cobertura = base$cobertura,
  tablas = list(
    tamanos = base$tamanos,
    completitud = base$completitud,
    estadisticas = estadisticas,
    limites_iqr = limites,
    atipicos = resumen_atipicos,
    detalle_atipicos = detalle_atipicos
  ),
  figuras = rutas_figuras
)
ruta_salida <- here::here("resultados", "11_calidad_perfiles.rds")
saveRDS(paquete, ruta_salida, compress = "gzip")

readr::write_csv(estadisticas, here::here("resultados", "tablas",
                                         "11_estadisticas_perfiles.csv"))
readr::write_csv(limites, here::here("resultados", "tablas",
                                    "11_limites_iqr.csv"))
readr::write_csv(resumen_atipicos, here::here("resultados", "tablas",
                                             "11_atipicos_por_perfil.csv"))
readr::write_csv(detalle_atipicos, here::here("resultados", "tablas",
                                             "11_detalle_atipicos.csv"))
stopifnot(file.exists(ruta_salida),
          nrow(readRDS(ruta_salida)$tablas$estadisticas) == 3L)
message("Sesion 11: RDS y graficos guardados en resultados/")
