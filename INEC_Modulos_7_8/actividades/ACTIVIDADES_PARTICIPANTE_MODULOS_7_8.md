# Cuaderno del participante | Módulos 7 y 8

**Fuente única:** `personas_encuesta_sintetica_2026_10.csv` y resultados reales construidos en los módulos 5 y 6. **No editar `data_raw/`.**

## Módulo 7 — 120 minutos

| Actividad | Tiempo sugerido | Desafío | Evidencia solicitada |
|---|---:|---|---|
| 7.1 | 15 min | Explicar la diferencia entre evento de alerta y fila afectada. | Definición y ejemplo con la tabla `alertas_*`. |
| 7.2 | 20 min | Guardar el punto de control `.rds` sin volver a calcular. | `01_hitos_modulos_5_6.rds` e inspección de `names()`. |
| 7.3 | 25 min | Preparar indicadores largos y anchos; comparar en pp. | Tabla con numerador y denominador. |
| 7.4 | 30 min | Construir gráficos de indicadores e incidencias. | Dos archivos PNG y análisis de barras. |
| 7.5 | 20 min | Visualizar ausencias en campos obligatorios. | PNG, tabla y párrafo explicativo. |
| 7.6 | 10 min | Identificar si existe un segundo período verdadero. | Texto que argumente por qué `2026/10` no es otro mes. |

### Ejercicio guiado 7.A — Pasar una tabla de formato largo a ancho

1. Recupere `hitos <- readRDS(...)` desde el punto de control.
2. Combine `indicadores_antes` e `indicadores_propuestos`, agregando la columna `escenario`.
3. Use `pivot_wider()` para crear columnas `porcentaje_Original` y `porcentaje_Propuesta`.
4. Cree `variacion_pp` y explique por qué su resultado se expresa en puntos porcentuales.

### Ejercicio guiado 7.B — Recuento de incidencias

1. Obtenga el número de eventos por `regla_id` de `alertas_logicas` y `alertas_integridad`.
2. Cuente las `fila_csv` diferentes que aparecen en ambos resultados.
3. Construya dos representaciones y explique por qué pueden diferir.

### Ejercicio guiado 7.C — Interpretación de gráficos

1. Construya el gráfico de barras agrupadas de indicadores.
2. Construya un gráfico horizontal de reglas de alerta.
3. Construya un gráfico de ausencias por variable.
4. Explique qué anomalías se observan y cuáles requieren validación posterior.

## Módulo 8 — 120 minutos

| Actividad | Tiempo sugerido | Desafío | Evidencia solicitada |
|---|---:|---|---|
| 8.1 | 15 min | Comprobar R, paquetes, Quarto y archivos. | Salida de verificación. |
| 8.2 | 20 min | Explicar YAML de `.qmd` y definir HTML/Word. | Plantilla fuente con título, formatos y período. |
| 8.3 | 20 min | Agregar el bloque inicial que lee `02_analisis_modulo_7.rds`. | Bloque con `#| include: false`. |
| 8.4 | 25 min | Insertar tablas, gráficos y cifras en línea. | `.qmd` con `knitr::kable()` e `include_graphics()`. |
| 8.5 | 25 min | Generar HTML y Word y contrastar salidas. | Dos archivos renderizados y captura/nota de revisión. |
| 8.6 | 15 min | Redactar conclusiones con límites metodológicos. | Conclusiones que distingan propuesta de corrección aprobada. |

### Ejercicio guiado 8.A — Reporte mínimo

Cree `reportes/reporte_calidad.qmd`. Debe incluir un YAML válido, al menos tres secciones, la tabla comparativa y el gráfico de indicadores. No escriba cifras fijas; incorpórelas desde el RDS.

### Ejercicio guiado 8.B — Reproducibilidad

1. Cierre RStudio o limpie los objetos de memoria.
2. Abra el proyecto `.Rproj` y compruebe que el RDS y las imágenes siguen disponibles.
3. Renderice HTML y DOCX desde Quarto.
4. Anote la fuente de los indicadores y el estado de la propuesta.

### Preguntas para discusión

- ¿Se puede comparar calidad entre dos archivos si cambian las reglas de validación?
- ¿Qué diferencia existe entre 5 % y un cambio de 5 pp?
- ¿Qué debe ocurrir si Quarto no encuentra un gráfico esperado?
- ¿Por qué no es válido presentar `2026/10` como un segundo período?
- ¿Qué metadatos necesita un tercero para reconstruir el reporte?

**Criterio final de logro:** el participante demuestra que las tablas, las figuras y el reporte proceden del mismo punto de control de datos, sin cambios ocultos ni cifras inventadas.
