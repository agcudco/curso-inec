# Material docente explicado — R / INEC / Módulos 5 y 6

Esta versión **agrega explicaciones sin sustituir los archivos originales** del paquete anterior.

## Archivo principal

`GUIA_DOCENTE_EXPLICACION_DE_CADA_SCRIPT.md` (guía en Markdown, 7 scripts, 11 secciones, glosario de funciones, explicación de parámetros, objetivos, riesgos, ejemplos, actividades y visualizaciones).

## Secuencia para construir en RStudio

| Orden | Archivo a estudiar | Objetivo |
|---|---|---|
| 0 | `R_EXPLICADOS/00_preparacion.R` | Preparar proyecto, importar CSV sin cambiar el origen y crear columnas derivadas. |
| 1 | `R_EXPLICADOS/05_01_consistencia_logica_guiado.R` | Formular condiciones entre variables, producir alertas y graficarlas. |
| 2 | `R_EXPLICADOS/05_02_claves_integridad_guiado.R` | Distinguir duplicados y verificar claves con `anti_join()`. |
| 3 | `R_EXPLICADOS/06_01_normalizacion_bitacora_guiado.R` | Crear propuestas de normalización y bitácora auditable. |
| 4 | `R_EXPLICADOS/06_02_imputacion_escenarios_guiado.R` | Comparar estimadores y simular imputaciones sin tocar observaciones. |
| 5 | `R_EXPLICADOS/06_03_indicadores_calidad_guiado.R` | Calcular métricas auditables y comparar escenarios. |
| Actividades | `R_EXPLICADOS/TALLER_PARA_CONSTRUIR_EN_CLASE.R` | Desarrollar manualmente tareas TODO antes de consultar las soluciones. |

## Qué se modificó

Se añadieron únicamente **comentarios explicativos** a los archivos de `R_EXPLICADOS/`. Los archivos `R/` se conservan tal como aparecen en el paquete previo. Se comprobó programáticamente que las líneas originales de instrucciones y comentarios son idénticas una vez retiradas las nuevas líneas docentes.

La guía anterior de módulos 5 y 6 también está en `GUIA_ESTUDIO_MODULOS_5_Y_6.md` para continuidad. El CSV normalizado, su copia previa, catálogo auxiliar, diccionario, actividades y figuras se incluyen sin modificaciones.

## Recomendación pedagógica

No ejecutar todo el paquete de una sola vez. Abrir el archivo `.Rproj` y trabajar **un bloque por vez**. Identificar entradas, parámetros, objetos creados, salida en consola/gráfico, interpretación, faltantes y posibles riesgos. Usar el material explicado para resolver dudas al final de cada actividad.

## Limitación

Los archivos se han revisado como material y contrastado estructuralmente; **no se ejecutó R ni se validó aquí el comportamiento de los scripts en un intérprete R**. El estudio utiliza reglas sintéticas, no controles institucionales del INEC.
