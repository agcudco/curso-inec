# Solucionario docente comentado — Módulos 5 y 6

Este solucionario complementa los scripts íntegros de la carpeta `R/`. Los resultados de control se han contrastado programáticamente con los CSV sintéticos; **no se ha ejecutado el proyecto en R**. Los números dependen de usar esta versión estandarizada y las definiciones de cada regla.

## Preparación

Abra `.Rproj`. Al comienzo de cada script guiado se utiliza `source(here::here("R", "00_preparacion.R"))` para cargar paquetes, CSV y funciones auxiliares. Recomiende a los participantes entender cada instrucción antes de ejecutar un bloque. La importación como texto mantiene códigos con ceros a la izquierda.

## Actividad 1. Horas y condición de actividad

**Solución:** `R/05_01_consistencia_logica_guiado.R`, pasos 1–3. Use una conjunción entre condición declarada, horas no ausentes y regla de comparación.

**Referencia del CSV:** 0 filas ocupadas con cero horas; 6 filas no ocupadas con horas mayores a cero. La primera regla sin incidencias no valida el resto del conjunto, y la segunda requiere revisión metodológica.

## Actividad 2. Fecha/período

**Solución:** mismo script, paso 4. Convierta fechas que cumplan el formato esperado y contraste `format(fecha_d, "%Y-%m")` contra `periodo_referencia`. `NA` por parseo fallido se documenta en un control de formato separado; no interprete «ayer».

## Actividad 3. Duplicados

**Solución:** `R/05_02_claves_integridad_guiado.R`, pasos 1–2.

```r
ids <- personas %>% filter(!is.na(id_persona))
repeticiones <- ids %>% filter(duplicated(id_persona))
afectadas <- ids %>%
  filter(duplicated(id_persona) | duplicated(id_persona, fromLast = TRUE))

nrow(repeticiones) # 20 apariciones adicionales
nrow(afectadas)    # 40 filas involucradas
```

La información personal no se modifica ni se elimina. Las filas idénticas en todo el CSV son otra noción: 4 duplicaciones completas adicionales.

## Actividad 4. Integridad referencial

**Solución:** `R/05_02_claves_integridad_guiado.R`, pasos 3–7. Recomendación docente: **comprobar primero duplicados en tabla padre** antes de cualquier `left_join`.

```r
ref <- hogares %>% filter(!is.na(id_hogar)) %>% distinct(id_hogar)
orfanos <- personas %>% filter(!is.na(id_hogar)) %>%
  anti_join(ref, by = "id_hogar")
orfanos %>% distinct(id_hogar) %>% arrange(id_hogar)
```

**Referencias esperadas:** hogares huérfanos `H00027`, `H00028`, `H00029`, `H00097`, `H00098`; **14 personas** afectadas; **18 personas** no declaran `id_hogar` (incidencia diferente); hay dos IDs duplicados en el catálogo padre (`H00016` y `H00017`). Estas anomalías en catálogo se introdujeron para el taller.

## Actividad 5. Alertas

**Solución:** crear `alertas_logicas` con `crear_alerta()` y `alertas_integridad` con `bind_rows()`; conservar `fila_csv`, `id_persona`, `regla_id`, `severidad` y descripción. Recalcar que las incidencias pueden superponerse: no sumar ciegamente recuentos entre reglas.

## Actividad 6. Normalización

**Solución:** `R/06_01_normalizacion_bitacora_guiado.R`, pasos 1–2.

**Referencias:** `urban`: 14; `F`: 14; `PICHINCHA`: 15; `Guayas ` con espacio al final: 7. Una vez establecidas las equivalencias didácticas, todas pueden convertirse en propuestas sobre una copia. `99` y `Desconocida` permanecen sin corrección automática.

## Actividad 7. Bitácora

**Solución:** `registrar_cambios()` compara original y propuesta, atendiendo los `NA`; se reúnen resultados de cada columna con `bind_rows()`.

**Conteos esperados:** `area` 14 cambios; `sexo` 14 cambios; `provincia` 22 cambios (15 `PICHINCHA` y 7 `Guayas `). Total **50 eventos de normalización propuesta**. Una misma persona puede tener varios eventos. Bitácora incluye `estado = "PENDIENTE_DE_APROBACION"`.

## Actividad 8. Media y mediana

**Solución:** `R/06_02_imputacion_escenarios_guiado.R`, pasos 1–2.

| Categoría | Conteo |
|---|---:|
| Ausencia `NA` | 52 |
| Ceros legítimos | 928 |
| Ingresos negativos para revisión | 2 |
| Positivos | 518 |

**Estimadores para ingresos no negativos:** media ~USD 1.017,45; mediana USD 0,00; media considerando solo ingresos entre USD 0 y USD 3.000 (prueba de sensibilidad) ~USD 326,11. El valor extremo aumenta fuertemente la media; esto **no demuestra** que sea un error.

## Actividad 9. Imputaciones

**Solución:** en el script `R/06_02_imputacion_escenarios_guiado.R`, pasos 3–6, calcule `media_global`, `mediana_global` y `medianas_grupo`. Construya `ingreso_media_sim`, `ingreso_mediana_sim` e `ingreso_grupo_sim` únicamente en un objeto derivado; marcar `imputacion_aplicada`. **Las 52 ausencias se convierten en simulaciones, no en mediciones reales.** Los dos negativos se dejan observables para revisión.

## Actividad 10. Indicadores

**Solución:** `R/06_03_indicadores_calidad_guiado.R`. Las tasas usan denominadores distintos y explícitos.

| Indicador | Numerador antes | Denominador antes | Antes | Propuesta |
|---|---:|---:|---:|---:|
| Completitud | 8.846 | 9.000 | 98,29 % | 98,29 % |
| Validez | 4.302 | 4.349 | 98,92 % | 99,26 % |
| Unicidad de filas con ID no repetido | 1.445 | 1.485 | 97,31 % | 97,31 % |

En la propuesta de normalización, la validez pasa a **4.317/4.349**: el incremento se asocia a las 15 etiquetas `PICHINCHA` normalizadas. La validez **no** considera ausencias como pruebas fallidas: se miden en completitud. La unicidad excluye los 15 IDs ausentes del denominador y cuenta filas implicadas en duplicación.

## Preguntas de cierre

**¿Cuándo corresponde eliminar un duplicado?** Solo tras revisar unidad de análisis, fuente, versiones y autorización, dejando evidencia.

**¿Imputar media es siempre mejor que mediana?** No. La media sufre con valores extremos y la mediana puede ser cero cuando hay muchos ceros. Ambos métodos requieren justificación metodológica y evaluación de efectos.

**¿Por qué no se puede sumar «faltantes» y «huérfanos» como un indicador universal?** Porque representan fenómenos diferentes, pueden solaparse y tienen denominadores distintos.
