# ============================================================================
# TALLER INEC: CONSTRUCCIÓN MANUAL DEL PROYECTO · MÓDULOS 3, 4 y 5
# Archivo para el participante: completar cada TODO a partir de la guía.
# No requiere ejecutar el proyecto completo ni modificar el archivo CSV.
# ============================================================================

# SESIÓN DE PREPARACIÓN
# TODO 00.1: cargar here, readr, dplyr, tidyr, ggplot2 y tibble.
# TODO 00.2: crear archivo_csv con here::here("data_raw", "...").
# TODO 00.3: importar todas las columnas como texto con read_csv().
# TODO 00.4: inspeccionar nrow(), ncol(), names(), head() y problems().
# TODO 00.5: construir es_ausente(x) para NA, vacío, N/D y SIN DATO.
# TODO 00.6: construir numero_estricto(x) sin perder el texto original.

# MÓDULO 3 · PERFILADO
# TODO 03.1: calcular la cantidad de ausencias en edad e ingreso.
# TODO 03.2: construir tabla_ausencias para todas las columnas.
# TODO 03.3: realizar un gráfico de barras de tabla_ausencias.
# TODO 03.4: contar id_persona repetidos, EXCLUYENDO los ausentes.
# TODO 03.5: crear filas_ids_repetidos y añadir fila_csv.
# TODO 03.6: contar duplicados de filas completas.
# TODO 03.7: hacer tablas de frecuencias de sexo, provincia y area.
# TODO 03.8: detectar ingreso y edad con formato no numérico.
# TODO 03.9: crear datos_perfilados con edad_num e ingreso_num.
# TODO 03.10: calcular media, mediana, desviación, Q1 y Q3 de edad elegible.
# TODO 03.11: comparar media, mediana y máximo de ingresos.
# TODO 03.12: construir histogramas y boxplots explicados.

# MÓDULO 3 · IMPUTACIÓN EXPLORATORIA
# TODO 03.13: construir datos_imputados como COPIA derivada.
# TODO 03.14: crear edad_elegible e indicador edad_fue_imputada.
# TODO 03.15: crear edad_por_media y edad_por_mediana.
# TODO 03.16: crear edad_por_grupo usando mediana de provincia.
# TODO 03.17: crear ingreso_por_media e ingreso_por_mediana.
# TODO 03.18: comparar estadísticos antes y después, sin sobrescribir.
# TODO 03.19: explicar por qué la moda NO debe rellenar automáticamente todo.

# MÓDULO 4 · VALIDACIÓN
# TODO 04.1: crear una tabla de reglas, severidad, versión y fuente.
# TODO 04.2: codificar grepl() para ID P + cinco dígitos.
# TODO 04.3: verificar fecha ISO y período AAAA-MM.
# TODO 04.4: codificar obligatoriedad, dominio y rango de edad.
# TODO 04.5: marcar ingreso negativo y formatos monetarios irregulares.
# TODO 04.6: calcular IQR; marcar valores superiores como ADVERTENCIA.
# TODO 04.7: crear incidencias_m4 usando pivot_longer().
# TODO 04.8: resumir por regla y graficar frecuencias.

# MÓDULO 5 · CONSISTENCIA E INTEGRIDAD
# TODO 05.1: cruzar condición de actividad y horas de trabajo.
# TODO 05.2: comparar fecha de levantamiento y período de referencia.
# TODO 05.3: agrupar por id_persona y periodo_referencia.
# TODO 05.4: revisar dependencias simuladas dentro de id_hogar.
# TODO 05.5: crear un microcatálogo INDEPENDIENTE de hogares.
# TODO 05.6: usar anti_join() en un subconjunto para ilustrar huérfanos.
# TODO 05.7: crear incidencias_m5 y combinar con incidencias_m4.
# TODO 05.8: proponer un reporte de reglas, denominadores y trazabilidad.

# PREGUNTA DE CIERRE:
# ¿Qué correcciones requerirían autorización del responsable metodológico?
