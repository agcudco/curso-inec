# Actividades guiadas: perfiles y calidad estadística (4 horas)

## Sesión 10 — Se conserva el taller original

1. Cree y compruebe `resultados/10_datos_preparados.rds`. Explique las razones por las que se excluyen registros con edad o ingreso inválido.
2. Obtenga tres grupos con `kmeans()` y registre cuántos casos pertenecen a cada uno.
3. Genere el gráfico de edad e ingreso y el de educación por grupo. Explique por qué las etiquetas de grupo no representan clases de pobreza.
4. Construya `resultados/10_perfiles.rds` y genere `sesion_10_perfiles.html`.

## Sesión 11 — Nueva práctica de calidad estadística de perfiles

**Actividad 11.A. Tamaños (15 min).** A partir de `10_perfiles.rds`, obtenga una tabla con las frecuencias y porcentajes por grupo. Pregunta: ¿el grupo más pequeño representa necesariamente datos de mala calidad?

**Actividad 11.B. Estadísticos (25 min).** Calcule media, mediana, desviación estándar y cuartiles de ingreso por grupo. Explique cuándo la media puede diferir de la mediana.

**Actividad 11.C. Completitud (20 min).** Revise `zona_norm`, `educacion_norm` y `acceso_norm`; calcule porcentaje de presentes por grupo. No utilice edad ni ingreso para declarar completitud general: fueron condición de inclusión.

**Actividad 11.D. Posibles valores atípicos (20 min).** Aplique la regla 1,5 × IQR a ingresos por grupo. Registre el número de candidatos y explique por qué no deben eliminarse automáticamente.

**Actividad 11.E. Informe final (40 min).** Guarde `11_calidad_perfiles.rds`, tres figuras PNG y genere Quarto HTML/Word. Redacte dos conclusiones y una limitación.

## Lista de comprobación de entregables

- [ ] `resultados/10_perfiles.rds` y reporte Quarto sesión 10.
- [ ] `resultados/11_base_calidad.rds`.
- [ ] `resultados/11_calidad_perfiles.rds`.
- [ ] Tabla de estadísticos, completitud, tamaños y candidatos a atípicos.
- [ ] Tres PNG de calidad estadística.
- [ ] `reportes/sesion_11_calidad_perfiles.html` y `.docx`.
- [ ] Interpretaciones propias que diferencien observación atípica, dato ausente y error confirmado.
