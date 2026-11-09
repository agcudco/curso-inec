# Paquete de capacitación en R — INEC | Módulos 5 y 6

**Tema 5:** consistencia lógica, claves e integridad referencial.  
**Tema 6:** normalización, propuestas de depuración, bitácoras, estadística de ingresos e indicadores de calidad.  
**Duración sugerida:** dos sesiones de 2 horas.  
**Material:** sintético, sin información personal real.

## Inicio

1. Descomprimir el ZIP completo.
2. Abrir `calidad_inec_modulos_5_6.Rproj` con RStudio.
3. Leer `GUIA_ESTUDIO_MODULOS_5_Y_6.md` en orden.
4. Crear un script `.R` de trabajo a partir de `R/TALLER_PARA_CONSTRUIR_EN_CLASE.R`.
5. Instalar bibliotecas si fuera necesario: `here`, `readr`, `dplyr`, `tidyr`, `ggplot2`, `tibble`.
6. Construir manualmente cada bloque antes de consultar los scripts guiados resueltos.

## Archivos importantes

- **CSV estándar:** `data_raw/personas_encuesta_sintetica_2026_10.csv` (1.500 filas; 27 variables; `ingreso_mensual_usd` con punto decimal y dos cifras, `NA` para ausencia).
- **Copia del CSV previo:** `datos_originales/personas_encuesta_sintetica_2026_10_original.csv`.
- **Bitácora de estandarización:** `bitacoras/bitacora_normalizacion_ingresos.csv` (35 transformaciones sobre la copia de capacitación).
- **Tabla auxiliar de hogares:** `data_raw/hogares_catalogo_sintetico_2026_10.csv` (introduce incidencias didácticas de referencia).
- **Diccionario:** `diccionario/diccionario_variables.csv` y `diccionario/ESTANDAR_INGRESOS.md`.
- **Guía:** `GUIA_ESTUDIO_MODULOS_5_Y_6.md`.
- **Actividades:** `actividades/ACTIVIDADES_PARTICIPANTE.md`.
- **Soluciones:** `actividades/SOLUCIONARIO_DOCENTE.md`.
- **Scripts R:** `R/00_preparacion.R`, `R/05_01_...`, `R/05_02_...`, `R/06_01_...`, `R/06_02_...`, `R/06_03_...`.
- **Gráficos:** carpeta `figuras/` (PNG usados para explicar las distribuciones antes de reproducirlos en R).

**Importante:** el proyecto **no se ha ejecutado en R**; es un material de enseñanza diseñado para ser construido progresivamente, no una salida institucional validada.


## Nueva guía ampliada

El archivo `GUIA_ESTUDIO_MODULOS_5_Y_6.md` es la **versión ampliada** del material. Incluye definiciones, contexto de las diapositivas 12–16, instrucciones de inicio del proyecto RStudio, 16 actividades, controles del CSV, código comentado por pasos, estadística aplicada, imputación simulada, métricas de calidad, interpretación, glosario y preguntas de aprendizaje.

La edición anterior se conserva como `GUIA_ESTUDIO_MODULOS_5_Y_6_VERSION_ANTERIOR.md`. Se añadieron los gráficos `figuras/07_ingresos_boxplot_log.png`, `figuras/08_modelo_personas_hogares.png` y `figuras/09_flujo_depuracion.png`. El CSV **no ha sido modificado**.

El orden recomendado de trabajo es: abrir `.Rproj` → construir la importación → escribir reglas del módulo 5 → construir la propuesta y bitácora del módulo 6 → explorar estadísticos e imputación sin sobrescribir → calcular indicadores → interpretar. Los scripts incluidos se conservan como referencias docentes.
