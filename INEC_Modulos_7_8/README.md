# INEC — módulos 7 y 8, continuación práctica

## Qué contiene

Esta carpeta trae los **mismos CSV, catálogos y scripts de los módulos 5 y 6**, incluyendo una corrección puntual de la función `crear_alerta()` que previamente daba un error de selección de columna. Además añade una **guía Markdown**, un **cuaderno de ejercicios**, scripts de los módulos 7 y 8 y una plantilla `.qmd` para un reporte HTML/Word.

## Preparación imprescindible

1. Descomprima el paquete en una carpeta de trabajo y abra `calidad_inec_modulos_7_8.Rproj` en RStudio.
2. Confirme que R y RStudio están instalados. Instale paquetes (`here`, `readr`, `dplyr`, `tidyr`, `ggplot2`, `tibble`, `knitr` y, si desea renderizar desde R, `quarto`). Instale Quarto CLI como programa separado.
3. **Construya en la sesión** los resultados del módulo 5 y 6 usando sus scripts previos: `personas_raw`, `personas_propuesta`, `alertas_logicas`, `alertas_integridad`, `bitacora_propuesta`, `indicadores_antes`, `indicadores_propuestos`.
4. Luego ejecute en ese orden: `R/06_99_guardar_hitos_para_reporte.R`, `R/07_01_tablas_calidad.R`, `R/07_02_graficos_calidad.R`, `R/08_01_verificar_precondiciones.R`.
5. Finalmente abra `reportes/reporte_calidad.qmd` y renderice HTML/Word. Puede usar `R/08_02_generar_reportes_opcional.R` una vez instalados sus requisitos.

**No ejecute todo de una vez:** lea y explique cada bloque antes de correrlo, revise salidas y conserve intactos los datos fuentes. El archivo `R/07_03_comparacion_entre_archivos_periodos.R` es opcional y requiere un verdadero segundo archivo CSV; el valor `2026/10` presente en el CSV actual es una irregularidad de formato, no otro período.

## Archivos de salida: se construyen durante el taller

- `resultados/01_hitos_modulos_5_6.rds`
- `resultados/02_analisis_modulo_7.rds`
- `resultados/tablas/07_*.csv`
- `resultados/figuras/07_*.png`
- `reportes/reporte_calidad.html`
- `reportes/reporte_calidad.docx`

No se incluyen archivos RDS, HTML ni DOCX ya calculados. Deben generarse con las decisiones y resultados de la práctica; se evita así sugerir que el proyecto fue ejecutado o aprobado.

## Materiales

- [Guía de estudio paso a paso](GUIA_ESTUDIO_MODULOS_7_Y_8.md)
- [Actividades de participantes](actividades/ACTIVIDADES_PARTICIPANTE_MODULOS_7_8.md)
- [Solucionario docente](actividades/SOLUCIONARIO_DOCENTE_MODULOS_7_8.md)
- [Plantilla Quarto](reportes/reporte_calidad.qmd)
- [Plantilla de ejercicios en R](R/TALLER_MODULOS_7_8_PARA_COMPLETAR.R)
- [Material anterior de módulos 5 y 6](material_previo/GUIA_ESTUDIO_MODULOS_5_6.md)

## Comandos de Quarto desde la terminal

```bash
quarto --version
quarto check
quarto render reportes/reporte_calidad.qmd --to html
quarto render reportes/reporte_calidad.qmd --to docx
```

**Nota:** no hay ejecutable R o Quarto disponible en el entorno de creación del paquete, de modo que la sintaxis de los scripts se revisó de forma estática pero su ejecución completa queda pendiente de comprobación en RStudio.
