# Solucionario docente | Módulos 7 y 8

Este documento describe las operaciones y resultados que debe comprobar el instructor. Los conteos finales no se escriben de antemano: dependen del punto de control realmente creado por cada participante.

## Actividad 7.A

```r
hitos <- readRDS(here::here("resultados", "01_hitos_modulos_5_6.rds"))
resumen_largo <- dplyr::bind_rows(
  dplyr::mutate(hitos$indicadores_antes, escenario = "Original"),
  dplyr::mutate(hitos$indicadores_propuestos, escenario = "Propuesta")
)
resumen_ancho <- tidyr::pivot_wider(
  resumen_largo,
  id_cols = indicador,
  names_from = escenario,
  values_from = c(numerador, denominador, porcentaje),
  names_glue = "{.value}_{escenario}"
) |>
  dplyr::mutate(variacion_pp = porcentaje_Propuesta - porcentaje_Original)
print(resumen_ancho)
```

**Interpretación:** la variación en pp es la resta de dos porcentajes, no un porcentaje del denominador anterior. Verificar que los indicadores tienen numeradores y denominadores válidos y que ambos escenarios usaron idénticas reglas.

## Actividad 7.B

```r
conteo_logico <- dplyr::count(hitos$alertas_logicas, regla_id)
conteo_integridad <- dplyr::count(hitos$alertas_integridad, regla_id)
filas_unicas <- union(hitos$alertas_logicas$fila_csv,
                      hitos$alertas_integridad$fila_csv)
numero_eventos <- nrow(hitos$alertas_logicas) + nrow(hitos$alertas_integridad)
numero_filas <- length(unique(filas_unicas[!is.na(filas_unicas)]))
```

**Interpretación:** si una fila incumple dos reglas genera dos eventos, pero es una sola fila afectada.

## Actividad 7.C

La solución reproducible está en `R/07_02_graficos_calidad.R` e incluye: `geom_col()` para indicadores ya calculados, `position_dodge()` para escenarios, `coord_flip()` para reglas y `ggsave()` para dejar evidencia de las figuras. Comprobar las etiquetas, los ejes y que no se presenta un semáforo sin umbrales aprobados.

## Actividad 8.A

Ver `reportes/reporte_calidad.qmd`. En su YAML hay `format: html` y `format: docx`; un bloque invisible con `readRDS()`; una tabla hecha con `knitr::kable()` y figuras que provienen de `resultados/figuras/`.

**Punto de control:** el informe no debe depender de la sesión RStudio donde el participante creó los objetos. Para construir la salida, debe cargar archivos desde disco.

## Actividad 8.B

El participante debe ejecutar, desde la raíz del `.Rproj`:

```bash
quarto render reportes/reporte_calidad.qmd --to html
quarto render reportes/reporte_calidad.qmd --to docx
```

Comprobar que las cifras de ambos informes sean idénticas. Si un render falla por falta de un RDS o figura, corregir la dependencia antes de continuar; no desactivar de forma indiscriminada las verificaciones.

## Validación final docente

La fuente CSV original debe permanecer inalterada; se debe documentar que `2026/10` es una forma no conforme del período previsto; las etiquetas `REVISAR` son alertas de ejercicio; las normalizaciones son propuestas no autorizadas. Se espera narrativa estadística proporcionada, pero no una conclusión institucional oficial.
