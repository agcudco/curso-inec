# =============================================================================
# SESION 10 — SCRIPT 10_01: PERFILES POR SIMILITUD CON K-MEANS
# ENTRADA: resultados/10_datos_preparados.rds
# SALIDAS: tablas, graficos y resultados/10_perfiles.rds
# =============================================================================
source(here::here("R", "00_configuracion.R"))

# 1. Recuperar exactamente los datos ya preparados.
ruta_entrada <- here::here("resultados", "10_datos_preparados.rds")
if (!file.exists(ruta_entrada)) stop("Primero ejecute R/10_00_preparar_datos_perfiles.R")
preparacion <- readRDS(ruta_entrada)
datos <- preparacion$datos

# 2. Seleccionar solo edades e ingresos validos. No corregimos la fuente.
muestra <- datos %>% dplyr::filter(apto_agrupamiento)
if (nrow(muestra) < 3) stop("No hay suficientes observaciones para tres grupos")

# 3. scale() centra por media y divide por desviacion estandar cada variable.
# Sin ello, una variable con unidades mayores dominaria la distancia euclidiana.
matriz <- as.matrix(muestra[, c("edad_n", "ingreso_log")])
matriz_z <- scale(matriz)
if (anyNA(matriz_z)) stop("No es posible estandarizar: revise las variables")

# 4. Fijar semilla para reproducibilidad; nstart prueba varios centros iniciales.
set.seed(2026)
modelo <- stats::kmeans(matriz_z, centers = 3, nstart = 25, iter.max = 100)

# 5. Asignar etiqueta neutral a cada observacion.
# Los numeros de grupo son ARBITRARIOS; no son niveles de pobreza.
muestra$grupo <- factor(paste0("Grupo ", modelo$cluster),
                       levels = paste0("Grupo ", 1:3))

# 6. Construir perfiles descriptivos por grupo.
perfiles <- muestra %>%
  dplyr::group_by(grupo) %>%
  dplyr::summarise(
    personas = dplyr::n(),
    edad_media = round(mean(edad_n), 1),
    edad_mediana = round(median(edad_n), 1),
    ingreso_medio = round(mean(ingreso_n), 2),
    ingreso_mediano = round(median(ingreso_n), 2),
    .groups = "drop"
  ) %>%
  dplyr::mutate(pct_muestra = round(100 * personas / sum(personas), 1))

zonas <- muestra %>% dplyr::count(grupo, zona_norm, name = "n") %>%
  dplyr::group_by(grupo) %>%
  dplyr::mutate(pct_grupo = round(100 * n / sum(n), 1)) %>%
  dplyr::ungroup()

educacion <- muestra %>% dplyr::count(grupo, educacion_norm, name = "n") %>%
  dplyr::group_by(grupo) %>%
  dplyr::mutate(pct_grupo = round(100 * n / sum(n), 1)) %>%
  dplyr::ungroup()

print(perfiles)

# 7. Graficos: una figura de edades e ingresos y otra de educacion por grupo.
figura_perfiles <- ggplot2::ggplot(
    muestra, ggplot2::aes(x = edad_n, y = ingreso_n, color = grupo)) +
  ggplot2::geom_point(alpha = 0.5, size = 1.5) +
  ggplot2::labs(title = "Perfiles exploratorios: edad e ingreso",
                subtitle = "Grupos calculados con edad estandarizada y log(1 + ingreso)",
                x = "Edad (años)", y = "Ingreso mensual (USD)", color = "Grupo") +
  ggplot2::theme_minimal()

figura_educacion <- ggplot2::ggplot(
    educacion, ggplot2::aes(x = grupo, y = pct_grupo, fill = educacion_norm)) +
  ggplot2::geom_col() +
  ggplot2::labs(title = "Composición educativa de los grupos",
                x = "Grupo", y = "Porcentaje dentro del grupo", fill = "Nivel") +
  ggplot2::theme_minimal()

ggplot2::ggsave(here::here("resultados", "figuras", "10_perfiles.png"),
                figura_perfiles, width = 9, height = 5.5, dpi = 160)
ggplot2::ggsave(here::here("resultados", "figuras", "10_educacion_por_grupo.png"),
                figura_educacion, width = 9, height = 5.5, dpi = 160)

# 8. Guardar tablas, el modelo y los datos en formato nativo RDS.
paquete <- list(
  metadatos = list(titulo = "Identificacion de perfiles — encuesta ficticia",
                   fecha = as.character(Sys.Date()),
                   centros = 3, observaciones = nrow(muestra),
                   advertencia = "No es una clasificacion oficial ni inferencia poblacional"),
  diagnostico = preparacion$diagnostico,
  datos_preparados = datos,
  datos_agrupados = muestra,
  modelo = modelo,
  tablas = list(perfiles = perfiles, zonas = zonas, educacion = educacion),
  figuras = c("resultados/figuras/10_perfiles.png",
              "resultados/figuras/10_educacion_por_grupo.png")
)
archivo <- here::here("resultados", "10_perfiles.rds")
saveRDS(paquete, archivo, compress = "gzip")
readr::write_csv(perfiles, here::here("resultados", "tablas", "10_perfiles.csv"))
readr::write_csv(zonas, here::here("resultados", "tablas", "10_zonas_perfiles.csv"))
readr::write_csv(educacion, here::here("resultados", "tablas", "10_educacion_perfiles.csv"))
stopifnot(nrow(readRDS(archivo)$tablas$perfiles) == 3)
message("Sesion 10: reporte listo para renderizar usando ", archivo)
