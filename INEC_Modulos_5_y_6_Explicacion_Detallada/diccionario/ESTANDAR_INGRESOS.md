# Especificación de la variable ingreso_mensual_usd

**Archivo de trabajo:** `data_raw/personas_encuesta_sintetica_2026_10.csv`. Se conserva el original sin modificar en `datos_originales/`.

## Reglas de formato

- Moneda: USD; unidad: dólares estadounidenses mensuales.
- Formato textual en CSV: número decimal con punto (`1234.56`) y dos posiciones obligatorias. Sin signo de dólar, separadores de millares ni espacios.
- Ausencia declarada: `NA` literal. **Cero (`0.00`) es un valor observado y no se convierte en ausencia**.
- Valores negativos (por ejemplo, `-80.00`) siguen siendo numéricos bien formados, pero son **incidencias de validez** a revisar.
- El extremo `999999.99` se conserva como anomalía estadística; **no se corrige sin evidencia**.
- Textos no interpretables (como `mil`) se recodifican a `NA` y su valor original queda documentado en la bitácora.
- Interpretaciones inequívocas `1.250,50` → `1250.50` y `120 USD` → `120.00` se documentan fila por fila.

## Reglas estadísticas y de publicación

- No estimar ingresos faltantes automáticamente durante la carga del CSV.
- La imputación con media, mediana o mediana de grupo se trabaja **solo en columnas de simulación**.
- Los valores extremos no son errores demostrados; calcular sensibilidad de la media sin eliminarlos.
- La corrección de una medición requiere documento metodológico y aprobación responsable.

**Filas:** 1500. **Columnas:** 27. **Registros de transformación representacional:** 35.