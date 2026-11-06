# Cuaderno de actividades — Perfilado, validación e integridad en R

**Archivo:** `data_raw/personas_encuesta_sintetica_2026_10.csv`  
**Enfoque:** escribir instrucciones paso a paso en `R/PLANTILLA_TALLER_PARA_COMPLETAR.R`; no usar soluciones hasta interpretar los resultados.  
**Regla:** no sobrescribir el CSV, no eliminar filas ni imputar sin distinguir estimaciones de observaciones.

## Módulo 3 — Perfilado y estadística

### Actividad 1. Ausencias de variables seleccionadas (8 min)

**Tarea:** defina una función que detecte `NA`, espacios en blanco, `N/D` y `SIN DATO`. Calcule cantidad y porcentaje de ausencias de `edad`, `ingreso_mensual_usd` e `id_hogar`.

**Evidencia:** tabla con variable, ausencias, total de filas y porcentaje. **Pregunta:** ¿por qué `0.00` no se considera ausente?

### Actividad 2. Perfil completo y gráfico de ausencias (12 min)

**Tarea:** aplique la función anterior a todas las columnas con `vapply()`, calcule porcentajes y dibuje barras horizontales con `ggplot2`. Distinga campos opcionales.

**Evidencia:** `tabla_ausencias` y gráfico con título, ejes y valores. **Pregunta:** ¿qué implica que `observaciones` esté vacío por diseño?

### Actividad 3. Duplicados y ubicación en el CSV (10 min)

**Tarea:** compute repeticiones adicionales de `id_persona` excluyendo marcadores vacíos; liste todas las filas involucradas usando `duplicated(..., fromLast=TRUE)`. Compare con duplicación íntegra de filas.

**Evidencia:** dos conteos diferentes y tabla de IDs con `fila_csv`. **Pregunta:** ¿por qué no aplicar `distinct()` inmediatamente?

### Actividad 4. Análisis de categorías (10 min)

**Tarea:** elabore frecuencias de `sexo`, `area` y `provincia`; ubique `F`, `99`, `urban`, `PICHINCHA` y `Desconocida` si aparecen; grafique una variable.

**Evidencia:** tres tablas de frecuencia y un gráfico. **Pregunta:** ¿cómo distinguir «raro» de «inválido»?

### Actividad 5. Formatos no numéricos (10 min)

**Tarea:** proponga una expresión regular para números con punto decimal; identifique cadenas incompatibles de `edad` e `ingreso_mensual_usd`. Cree `edad_num` e `ingreso_num` en variables derivadas.

**Evidencia:** listado de filas no convertibles con su valor textual intacto.

### Actividad 6. Estadística descriptiva (12 min)

**Tarea:** seleccione edades numéricas enteras en el rango ilustrativo 0–110. Calcule mínimo, máximo, media, mediana, desviación, Q1 y Q3.

**Evidencia:** tabla descriptiva. **Pregunta:** ¿por qué las observaciones fuera del rango no deben borrarse del CSV?

### Actividad 7. Gráficos de anomalías (12 min)

**Tarea:** elabore un histograma de ingresos con zoom a USD 0–3.000, un boxplot por `condicion_actividad` y un resumen de cero, negativo y máximo.

**Evidencia:** dos gráficos y explicación de la asimetría. **Pregunta:** ¿cuál sería la consecuencia de utilizar únicamente la media?

### Actividad 8. Imputación de edad (13 min)

**Tarea:** construya copias con media, mediana global y mediana por provincia. Cree `edad_fue_imputada`; compare dispersión antes y después.

**Evidencia:** nuevas columnas, resumen estadístico y comentario de sesgo potencial.

### Actividad 9. Imputación de ingreso y moda (13 min)

**Tarea:** construya `ingreso_por_media`, `ingreso_por_mediana` y una mediana condicional para ocupados. Explique el significado de `0.00`. Calcule una moda de categorías válidas de `sexo` sin modificar valores `F` o `99`.

**Evidencia:** descripción crítica del método; no presentar el resultado imputado como dato observado.

## Módulo 4 — Reglas automáticas

### Actividad 10. Diseño y aplicación de reglas (35 min)

**Tarea:** elabore una tabla de reglas, tipo, fuente, versión, severidad y responsable; implemente obligatoriedad de ID, formato `P00001`, fecha ISO, período `AAAA-MM`, dominio de `sexo` y un rango de edad de **ejemplo**.

**Evidencia:** `reglas_m4` y columnas lógicas `error_*` o `alerta_*`.

### Actividad 11. Bitácora larga y tasas (45 min)

**Tarea:** transforme las columnas de reglas a filas usando `pivot_longer()` y añada metadatos. Calcule cantidad y porcentaje por regla. Para la validez de rango de edad defina el denominador evaluable.

**Evidencia:** `incidencias_m4`, tabla resumen, indicador de edad y gráfico por severidad.

### Actividad 12. Atípicos con IQR (40 min)

**Tarea:** calcule Q1, Q3, IQR y el límite superior de ingreso no negativo. Produzca una **advertencia** para los ingresos superiores al límite sin sustituirlos ni eliminarlos.

**Evidencia:** límite calculado, número de alertas y una explicación de por qué el IQR no prueba error.

## Módulo 5 — Consistencia e integridad

### Actividad 13. Reglas entre variables (40 min)

**Tarea:** identifique ocupados con cero horas, inactivos con horas positivas, incompatibilidades entre fecha y período y casos en que escolaridad supera edad. Clasifique como advertencias hasta recibir criterio metodológico.

**Evidencia:** tabla de `incidencias_m5` y discusión de excepciones posibles.

### Actividad 14. Repetición de claves y dependencias (30 min)

**Tarea:** agrupe por `id_persona` y `periodo_referencia`, examine repetición y variaciones de edad/ingreso. Después revise atributos de personas pertenecientes a un mismo `id_hogar`.

**Evidencia:** tabla por clave compuesta y tabla de dependencias del hogar. **Pregunta:** ¿qué inconsistencias podrían provenir de la simulación?

### Actividad 15. Integridad referencial y cierre (50 min)

**Tarea:** cree un catálogo pequeño e independiente de hogares y un subconjunto de personas; utilice `anti_join()`. Después combine las bitácoras de módulos 4 y 5 y construya un resumen de incidencias.

**Evidencia:** ejemplo de claves huérfanas **solo de demostración**, bitácora consolidada y explicación sobre la necesidad de una tabla maestra completa y aprobada.

---

## Rúbrica sugerida, sobre 20 puntos

| Criterio | Puntaje |
|---|---:|
| Comprensión de ausencias, formatos y duplicados | 4.00 |
| Construcción incremental de scripts y gráficos | 6.00 |
| Interpretación estadística e imputación crítica | 4.00 |
| Reglas, bitácora y trazabilidad | 4.00 |
| Coherencia e integridad con límites metodológicos claros | 2.00 |
| **Total** | **20.00** |

**Producto final:** una colección de scripts R comentados escritos durante el taller y un conjunto de tablas/gráficos documentados. No se exige ejecutar automáticamente todo el proyecto.
