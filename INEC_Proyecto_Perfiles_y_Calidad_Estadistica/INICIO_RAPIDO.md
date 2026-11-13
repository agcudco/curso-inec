# Inicio rápido en RStudio

Abra `encuesta_calidad.Rproj`. En **Console**, instale una sola vez si faltan:

```r
install.packages(c("here", "readr", "dplyr", "ggplot2", "knitr"))
```

Compruebe que Quarto está disponible con `system("quarto --version")` desde **Console**, o `quarto --version` desde **Terminal**.

## Sesión 10 (se conserva)

```r
source(here::here("R", "10_00_preparar_datos_perfiles.R"))
source(here::here("R", "10_01_identificar_perfiles.R"))
source(here::here("R", "10_02_renderizar_reporte.R"))
```

## Sesión 11 (nueva)

```r
source(here::here("R", "11_00_evaluar_completitud_perfiles.R"))
source(here::here("R", "11_01_estadistica_calidad_perfiles.R"))
source(here::here("R", "11_02_renderizar_reporte.R"))
```

Al finalizar, compruebe los RDS en `resultados/`, las tablas en `resultados/tablas/`, las figuras en `resultados/figuras/` y los HTML/DOCX en `reportes/`.

**Importante:** el archivo `resultados/10_perfiles.rds` es requisito para la sesión 11; no se necesita un árbol de decisión ni paquetes `rpart`.
