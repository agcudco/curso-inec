# Propuesta: Sesión 11 — Análisis estadístico de la calidad y variabilidad de perfiles

**Duración:** 2 horas. **Público:** predominantemente básico, con extensión opcional intermedia. **Relación:** continúa de forma directa la sesión 10 sin modificar sus agrupaciones K-means.

## Objetivo

Evaluar la calidad y diversidad de la información en los perfiles identificados, mediante frecuencias, medidas descriptivas, dispersión, completitud y detección orientativa de valores atípicos, utilizando RStudio y Quarto.

## Contenido y actividad

| Tiempo | Tema | Conceptos | Producto |
|---|---|---|---|
| 0–20 min | Lectura de perfiles | Frecuencia, porcentaje, denominador, grupos grandes y pequeños | Tabla de composición |
| 20–55 min | Resúmenes estadísticos | Media, mediana, desviación estándar, Q1, Q3, IQR | Tabla de ingresos y edades por grupo |
| 55–75 min | Calidad de los perfiles | Registros excluidos, campos ausentes, completitud condicional | Tabla y mapa de calor |
| 75–95 min | Revisión de extremos | Boxplot y regla de 1,5 × IQR, sin eliminación automática | Tabla de posibles atípicos |
| 95–120 min | Informe reproducible | RDS, Quarto, HTML y Word | Reporte `sesion_11_calidad_perfiles` |

## Entregables

1. Scripts `11_00_evaluar_completitud_perfiles.R`, `11_01_estadistica_calidad_perfiles.R` y `11_02_renderizar_reporte.R`.
2. `resultados/11_calidad_perfiles.rds` con tablas de estadísticos, completitud y candidatos a atípicos.
3. Tablas CSV y tres PNG.
4. `reportes/sesion_11_calidad_perfiles.html` y `.docx` generados por Quarto.
5. Dos conclusiones propias y una limitación metodológica.

**Alcance:** perfiles = grupos exploratorios; calidad = información disponible y coherencia descriptiva. No se trata de certificar el algoritmo ni de asignar clasificaciones oficiales.
