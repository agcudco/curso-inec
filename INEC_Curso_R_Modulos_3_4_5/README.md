# Paquete de capacitación INEC · R · Módulos 3, 4 y 5

La guía principal es **`GUIA_ESTUDIO_MODULOS_3_4_5.md`**. El proyecto está orientado a la **construcción progresiva en RStudio** desde el CSV `data_raw/personas_encuesta_sintetica_2026_10.csv`. No se han ejecutado los scripts de R para generar resultados finales; las imágenes descriptivas de referencia se prepararon mediante una inspección independiente del CSV.

## Para el instructor

1. Entregue el CSV, el diccionario, la guía, `.Rproj` y `R/PLANTILLA_TALLER_PARA_COMPLETAR.R` a los participantes.
2. Abra `calidad_inec_modulos_3_5.Rproj` en RStudio.
3. Reproduzca en el editor cada bloque sugerido en la guía, ejecutándolo por fragmentos seleccionados (`Ctrl+Enter`) e interpretando su salida.
4. Conserve los scripts completos `00`, `03`, `03b`, `04` y `05` como **solucionario de referencia**, no como archivos que los estudiantes deban ejecutar sin discusión.
5. No edite la fuente de `data_raw`; guarde únicamente las salidas aprobadas en `resultados/`.

## Secuencia de los scripts de referencia

`R/00_preparacion.R` → `R/03_perfilado_diagnostico.R` → `R/03b_imputacion_estadistica.R` (experiencia opcional) → `R/04_validacion_automatica.R` → `R/05_consistencia_integridad.R`.

Los scripts 04 y 05 necesitan los objetos construidos en los anteriores. **No** incluyen un `source()` automático ni un comando para ejecutar el proyecto completo: se aprende a producir los objetos paso a paso.

## Contenido

- CSV original sintético: 1.500 registros × 27 variables.
- Diccionario de 27 variables.
- Guía Markdown detallada con teoría, fórmulas, comentarios R, pasos e imágenes.
- Plantilla incompleta para participantes.
- Cinco scripts R comentados para el docente.
- Cuaderno de 15 actividades y solucionario.
- Ocho gráficos de referencia en `figuras/`.

**Advertencia:** rangos, catálogos y reglas de consistencia son didácticos. Los resultados ilustran problemas de datos y limitaciones de un generador sintético; no certifican la calidad de ninguna fuente oficial del INEC.
