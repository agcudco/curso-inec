# INEC | MÓDULOS 5 y 6 — TALLER SIN RESPUESTAS
# Instrucción: trabaje desde el archivo .Rproj. No pegue todo a la vez.
# Instalación previa (solo una vez):
# install.packages(c("here", "readr", "dplyr", "tidyr", "ggplot2", "tibble"))

# ACTIVIDAD 1 | ¿Qué significa una clave única y una relación 1:N?
# TODO: cargar dplyr, here y readr y leer el CSV como texto.

# ACTIVIDAD 2 | ¿Hay personas ocupadas que declaran cero horas?
# TODO: crear una columna numérica a partir de horas_trabajo_semana.
# TODO: contar los registros que cumplen AMBAS condiciones.

# ACTIVIDAD 3 | ¿Cuántos registros tienen id_persona repetido?
# TODO: distinguir filas involucradas de repeticiones adicionales.

# ACTIVIDAD 4 | ¿Cuáles son los hogares huérfanos?
# TODO: leer hogares_catalogo_sintetico_2026_10.csv.
# TODO: utilizar anti_join() sin eliminar registros del origen.

# ACTIVIDAD 5 | ¿Cómo crear una alerta útil para auditoría?
# TODO: incluir fila_csv, id_persona, regla, valor y severidad.

# ACTIVIDAD 6 | ¿Cómo normalizar 'urban' y 'F' sin perder evidencia?
# TODO: crear una COPIA de la base y bitácora antes / propuesta.

# ACTIVIDAD 7 | ¿Qué diferencia hay entre NA, 0.00 y -80.00?
# TODO: contar cada caso de ingreso_mensual_usd.

# ACTIVIDAD 8 | ¿Por qué media y mediana son distintas?
# TODO: excluir negativos de los estadísticos válidos,
#       conservar los valores no válidos para revisión y comparar estimadores.

# ACTIVIDAD 9 | ¿Cómo se define tasa de completitud?
# TODO: seleccionar los 6 campos requeridos; calcular numerador/denominador.

# ACTIVIDAD 10 | ¿Qué es validez y qué reglas se aplican?
# TODO: documentar dominio de provincia, rango didáctico de edad,
#       formato y condición de ingreso no negativo.

# ACTIVIDAD 11 | ¿Cómo contar unicidad sin mezclar NA con duplicados?
# TODO: excluir ID ausente del denominador; identificar TODAS las filas
#       cuya clave id_persona aparece una sola vez.

# ACTIVIDAD 12 | ¿Qué evidencia queda para auditoría?
# TODO: comparar indicadores antes y después SOLO EN ESCENARIOS,
#       adjuntar bitácora de propuesta y emitir un breve comentario técnico.
