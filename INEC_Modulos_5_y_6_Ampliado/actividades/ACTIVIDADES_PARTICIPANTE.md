# Actividades para participantes — Módulos 5 y 6

**Curso INEC | Evaluación de archivos de datos y automatización de reportes de calidad en R**  
**Archivo:** `data_raw/personas_encuesta_sintetica_2026_10.csv`  
**Regla:** desarrollar cada bloque manualmente en `R/TALLER_PARA_CONSTRUIR_EN_CLASE.R` y conservar intacto el archivo original.

## Antes de iniciar

1. Abrir `calidad_inec_modulos_5_6.Rproj`.
2. Cargar bibliotecas `here`, `readr`, `dplyr`, `tidyr`, `ggplot2`.
3. Importar el CSV como texto, sin eliminar espacios ni inferir tipos.
4. Crear variables numéricas auxiliares para ingresos, edad y horas; mantener el CSV original.
5. Comentar cada bloque con su interpretación estadística.

## Módulo 5 — Consistencia lógica e integridad

### Actividad 1. Condición de actividad y horas (15 min)
**Problema:** identifique personas con `condicion_actividad == "Ocupado"` y `horas_trabajo_semana == 0`, y personas no ocupadas que declaran horas positivas. ¿Los hallazgos confirman errores por sí solos?

**Entregable:** dos tablas, sus conteos y una explicación del alcance de la regla.

### Actividad 2. Fecha y período de referencia (15 min)
**Problema:** contraste `fecha_levantamiento` con `periodo_referencia` cuando la fecha sea interpretable; reporte por separado las fechas ilegibles o fuera de formato.

**Entregable:** incidencia por fecha y un comentario sobre el riesgo de convertir `ayer` a la fecha actual.

### Actividad 3. Duplicación personal (15 min)
**Problema:** calcule (a) repeticiones adicionales de `id_persona` y (b) número total de filas con `id_persona` repetido. Excluya claves ausentes del análisis de duplicación.

**Entregable:** dos cantidades, tabla de todas las filas afectadas y explicación.

### Actividad 4. Integridad entre archivos (20 min)
**Problema:** cargue `hogares_catalogo_sintetico_2026_10.csv`. Comience detectando duplicados en clave de hogares, luego use `anti_join()` para encontrar las personas que refieren un hogar ausente. Mantenga separadas las personas sin ID de hogar.

**Entregable:** tabla de hogares duplicados; cinco IDs huérfanos; número de filas afectadas.

### Actividad 5. Alertas trazables (15 min)
**Problema:** construya una tabla unificada de alertas con `fila_csv`, `id_persona`, `id_hogar`, `regla_id`, `severidad` y `descripcion`.

**Entregable:** gráfico con total por regla y tabla de 10 ejemplos; no elimine filas.

## Módulo 6 — Depuración y métricas de calidad

### Actividad 6. Diagnóstico y normalización (15 min)
**Problema:** identifique las formas de `area`, `sexo` y `provincia`. En una nueva tabla, proponga unificar `urban`, `F`, `PICHINCHA` y quitar el espacio final en `Guayas `; conserve otras etiquetas sin inferir valores.

**Entregable:** distribución antes y propuesta. Explique la diferencia entre «normalizar» y «corregir el significado».

### Actividad 7. Bitácora de propuestas (15 min)
**Problema:** identifique únicamente las filas en las que cambió una etiqueta; registre archivo, fila, ID, campo, original, propuesto, regla, versión, responsable, fecha y estado. El estado inicial debe ser `PENDIENTE_DE_APROBACION`.

**Entregable:** bitácora y conteos por variable.

### Actividad 8. Ingresos y estadística robusta (15 min)
**Problema:** cuente ingresos `NA`, ceros, negativos y positivos. Calcule media y mediana de los ingresos no negativos y compare la media frente a una prueba de sensibilidad que considere solo valores no mayores a USD 3.000.

**Entregable:** tabla y gráfico; explique por qué retirar un extremo para análisis no permite borrarlo del registro.

### Actividad 9. Escenarios de imputación (15 min)
**Problema:** cree tres nuevas columnas: ingresos faltantes sustituidos (a) por media global, (b) por mediana global y (c) por mediana por condición de actividad. **Solo como simulaciones**, sin sobrescribir la variable original.

**Entregable:** conteo de imputaciones y comentario sobre sesgo potencial.

### Actividad 10. Indicadores verificables (25 min)
**Problema:** calcule completitud de seis columnas obligatorias, validez con tres reglas y unicidad de identificadores presentes. Construya indicadores para base estandarizada antes de normalizaciones y propuesta normalizada.

**Entregable:** tabla con indicador, numerador, denominador, porcentaje, escenario y gráfico comparativo.

## Cierre (10 min)

Entregue su script R comentado, las tablas y dos gráficos producidos por los participantes, además de un párrafo que explique por qué una incidencia no es automáticamente un error y una imputación no es automáticamente una corrección autorizada.

## Rúbrica sugerida (20 puntos)

| Criterio | Peso |
|---|---:|
| Reglas de consistencia lógica | 4.00 |
| Identificadores e integridad entre archivos | 4.00 |
| Normalización controlada y bitácora | 4.00 |
| Estadística, visualizaciones e imputación simulada | 4.00 |
| Indicadores de calidad y justificación | 4.00 |
| **Total** | **20.00** |
