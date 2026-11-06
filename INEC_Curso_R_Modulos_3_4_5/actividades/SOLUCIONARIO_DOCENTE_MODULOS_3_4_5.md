# Solucionario docente — Módulos 3, 4 y 5

**Uso reservado al instructor.** Las soluciones completas están escritas, comentadas y separadas en `R/00_preparacion.R`, `R/03_perfilado_diagnostico.R`, `R/03b_imputacion_estadistica.R`, `R/04_validacion_automatica.R` y `R/05_consistencia_integridad.R`. Este documento presenta la respuesta pedagógica y la evidencia esperada por actividad. **No se han ejecutado los scripts R de forma integral.** Los conteos indicados se contrastaron leyendo el archivo CSV sintético.

| Actividad | Archivo y paso de solución | Resultado o respuesta esperada | Advertencia metodológica |
|---|---|---|---|
| 1. Ausencias | `00` pasos 0.4–0.6; `03` paso 3.1 | `edad`: 66 / 1.500 = **4.40 %**; ingreso: 51 / 1.500 = **3.40 %**; `id_hogar`: 18 / 1.500 = **1.20 %**. | Los 928 ceros de ingreso no son ausencias. |
| 2. Tabla y gráfico | `03` pasos 3.1–3.2 | Una fila por cada una de las 27 variables y una barra por cada variable seleccionada. | `observaciones` es opcional; su ausencia no prueba incumplimiento. |
| 3. Duplicados | `03` pasos 3.3–3.4 | 20 ocurrencias adicionales de IDs válidos repetidos; 4 filas adicionales íntegramente duplicadas. | No confundir repeticiones adicionales con número total de filas afectadas. |
| 4. Categorías | `03` pasos 3.5–3.6 | `sexo`: `F` 14, `99` 10; `area`: `urban` 14; `provincia`: `PICHINCHA` 15, `Desconocida` 12. | Una frecuencia baja no demuestra error; se necesita catálogo. |
| 5. Conversiones | `03` pasos 3.7–3.8 | `edad`: 6 cadenas no numéricas aparte de las 66 ausentes; ingreso: 3 cadenas no numéricas aparte de las 51 ausentes. | Debe mantenerse la cadena original y documentarse el fallo. |
| 6. Estadística | `03` paso 3.9 | En edad elegible: media ≈ **48.30**, mediana **49**. | 12 edades numéricas se excluyen de ese cálculo por criterios demostrativos. |
| 7. Anomalías | `03` pasos 3.10–3.12 | Ingreso: 928 ceros, 2 negativos, un máximo **999999.99** y mediana **0** para todos los números interpretables. | La media inicial ≈ **1016.44** está afectada por el máximo. |
| 8. Edad imputada | `03b` pasos 3.15–3.18, 3.23–3.24 | Columnas `edad_por_media`, `edad_por_mediana`, `edad_por_grupo`; bandera `edad_fue_imputada`. | Comparar variación; la imputación no genera observaciones reales. |
| 9. Ingreso y moda | `03b` pasos 3.19–3.22 | Copias para media/mediana y mediana de ocupados; moda demostrativa de categorías válidas. | La mediana 0 puede inducir a una imputación inapropiada. |
| 10. Catálogo y reglas | `04` pasos 4.1–4.4 | Regla, variable, severidad, versión, fuente, responsable y vigencia; nuevas columnas lógicas. | Catálogos y límites son de ejercicio, no oficiales. |
| 11. Bitácora y tasas | `04` pasos 4.5–4.8 | `incidencias_m4` contiene una fila por incidencia; indicador edad usa números interpretables como denominador. | Incidencias totales ≠ personas únicas afectadas. |
| 12. IQR | `04` paso 4.3 | Q1 de ingreso no negativo **0**, Q3 ≈ **605.41**; umbral superior ≈ **1513.52**; **55** valores superiores. | Son 55 señales **exploratorias**, no 55 errores de ingreso. |
| 13. Coherencia | `05` pasos 5.1–5.2 | El CSV presenta **6** registros con `Inactivo` y horas positivas, bajo esta regla literal. | `Ocupado` y 0 horas también necesita contexto, no eliminación. |
| 14. Claves y hogares | `05` pasos 5.3–5.4 | Tablas con claves repetidas, edades/ingresos diferentes y posibles contradicciones de hogar. | Las dependencias de hogar pueden fallar por la propia generación sintética. |
| 15. Integridad y unión | `05` pasos 5.5–5.9 | `anti_join` devuelve casos sin correspondencia en el catálogo **incompleto de demostración**. `bind_rows()` integra incidencias. | No usar la referencia parcial como control real sobre las 1.500 filas. |

## Fragmentos explicados para la revisión en clase

### A. Valores faltantes: identificación correcta

```r
# Una ausencia se reconoce por su codificación, nunca por ser cero.
es_ausente <- function(x) {
  texto <- toupper(trimws(as.character(x)))
  is.na(texto) | texto %in% c("", "NA", "N/D", "SIN DATO")
}

# Tres porcentajes con denominador explícito de registros.
100 * sum(es_ausente(datos$edad)) / nrow(datos)
100 * sum(es_ausente(datos$ingreso_mensual_usd)) / nrow(datos)
100 * sum(es_ausente(datos$id_hogar)) / nrow(datos)
```

### B. Duplicados: clave repetida frente a fila idéntica

```r
ids_validos <- datos$id_persona[!es_ausente(datos$id_persona)]
sum(duplicated(ids_validos))  # 20 ocurrencias adicionales
sum(duplicated(datos))       # 4 filas idénticas adicionales
```

### C. Media, mediana y valores extremos

```r
# Utilizar valores numéricos CONVERTIBLES y hacer el diagnóstico primero.
ingreso_convertido <- numero_estricto(datos$ingreso_mensual_usd)
mean(ingreso_convertido, na.rm = TRUE)
median(ingreso_convertido, na.rm = TRUE)
max(ingreso_convertido, na.rm = TRUE)
```

**Pregunta de retroalimentación:** ¿cuál de los estadísticos describe mejor una distribución con 928 ceros y un ingreso extremo? La mediana es menos sensible al máximo, pero decir que «es mejor» depende del objetivo analítico. No confundir este razonamiento con decidir qué dato imputar.

### D. Imputación: separar escenarios y registrar el reemplazo

```r
# Mediana global calculada sobre valores de trabajo elegibles.
mediana_edad <- median(datos_imputados$edad_elegible, na.rm = TRUE)

# La bandera conserva información sobre qué filas fueron estimadas.
datos_imputados <- datos_imputados %>%
  mutate(
    edad_fue_imputada = is.na(edad_elegible),
    edad_por_mediana = coalesce(edad_elegible, mediana_edad)
  )
```

### E. Validaciones: no mezclar ausencia con incumplimiento de rango

```r
# La edad ausente y la edad numérica fuera de rango son señales distintas.
datos_validados <- datos_perfilados %>%
  mutate(
    error_edad_ausente = es_ausente(edad),
    error_edad_rango = !is.na(edad_num) &
      (edad_num < 0 | edad_num > 110 | edad_num != floor(edad_num))
  )
```

### F. Integridad: referencia verdaderamente independiente

```r
# El catálogo es FICTICIO y solo cubre tres hogares.
catalogo_hogares_demo <- tibble(id_hogar = c("H00001", "H00002", "H00003"))
personas_subconjunto <- datos %>%
  filter(id_hogar %in% c("H00001", "H00002", "H00003", "H00004"))
anti_join(personas_subconjunto, catalogo_hogares_demo, by = "id_hogar")
```

El ejemplo muestra cómo ejecutar la comparación, no demuestra un problema de integridad real. El paso posterior en una operación estadística consistiría en reemplazar esa referencia por un maestro de hogares con versión, fuente y cobertura aprobada.

## Criterios para valorar el desempeño

**Sobresaliente:** el participante conserva el CSV, documenta supuestos, calcula indicadores con denominadores apropiados, separa originales e imputaciones, y justifica por qué una alerta requiere revisión.  
**En proceso:** obtiene conteos y gráficos, pero no interpreta ausencias frente a errores, no documenta reglas o considera la imputación como corrección automática.  
**Por reforzar:** reemplaza el archivo original, elimina duplicados sin evidencia o presenta un catálogo parcial como prueba de integridad institucional.
