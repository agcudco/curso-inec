# =====================================================================
# INEC | CUADERNO DE PROGRAMACION PASO A PASO
# MODULOS 1-3 | 15 ACTIVIDADES
# Archivo de trabajo del PARTICIPANTE. No es una solucion ejecutada.
# Instruccion: completar cada TODO despues de estudiar su enunciado.
# Leer: actividades/ACTIVIDADES_PROPUESTAS_PARTICIPANTE.md
# =====================================================================

# ------------- MODULO 1: ENTORNO Y FUNDAMENTOS -----------------------

# ACTIVIDAD 1. Identificar las dimensiones de calidad de seis casos.
# TODO: comentar 6 ejemplos y asociarlos a una dimension.

# ACTIVIDAD 2. Objetos basicos, clases, vectores y NA.
# TODO: crear un objeto numerico, uno de texto y uno logico.
# TODO: crear el vector c(18, 20, NA, 22).
# TODO: utilizar class(), length(), is.na() y mean(..., na.rm=TRUE).

# ACTIVIDAD 3. Proyecto RStudio y ruta relativa.
# TODO: crear/abrir calidad_inec.Rproj.
# TODO: cargar here, readr, dplyr, ggplot2.
# TODO: definir archivo_csv con here::here("data_raw", "...").
# TODO: verificar file.exists(archivo_csv).

# ACTIVIDAD 4. Importacion conservadora del CSV.
# TODO: usar readr::read_csv() con columnas character,
#       na="NA", trim_ws=FALSE y encoding="UTF-8".

# ACTIVIDAD 5. Exploracion preliminar.
# TODO: nrow(), ncol(), dim(), names(), head(), str(), glimpse().
# TODO: tabla de frecuencias de area, incluyendo NA.

# ------------- MODULO 2: IMPORTACION Y ESTRUCTURA --------------------

# ACTIVIDAD 6. Comparacion con inferencia automatica.
# TODO: importar CSV como datos_auto SIN forzar tipo character.
# TODO: inspeccionar glimpse() y readr::problems().

# ACTIVIDAD 7. Inspeccion del archivo de texto.
# TODO: leer las primeras 3 lineas del CSV con readLines().

# ACTIVIDAD 8. Diccionario y cotejo de columnas.
# TODO: importar diccionario_variables.csv como texto.
# TODO: comparar setdiff() en ambos sentidos e identical().

# ACTIVIDAD 9. Tabla de auditoria estructural.
# TODO: vapply() para obtener la clase de cada columna.
# TODO: left_join() con informacion del diccionario.

# ACTIVIDAD 10. Conversiones numericas problematicas.
# TODO: crear edad_convertida sin modificar datos$edad.
# TODO: excluir ausencias y encontrar valores informados no convertibles.
# TODO: indicar fila_csv, id_persona y edad.

# ------------- MODULO 3: PERFILADO Y GRAFICOS ------------------------

# ACTIVIDAD 11. Ausencias.
# TODO: definir es_vacio() y es_marcador().
# TODO: calcular perfil por variable con NA / vacios / marcadores.
# TODO: expresar el porcentaje con dos decimales.

# ACTIVIDAD 12. Duplicados.
# TODO: contar id_persona validos repetidos con count().
# TODO: calcular claves, filas implicadas y repeticiones adicionales.
# TODO: comparar con duplicated(datos).

# ACTIVIDAD 13. Frecuencias.
# TODO: contar categorias de provincia, sexo y area.
# TODO: identificar etiquetas alternativas sin modificarlas.

# ACTIVIDAD 14. Estadistica descriptiva de edad.
# TODO: contar no convertibles y edades fuera del rango didactico.
# TODO: describir edad_num entre 0 y 110 con n, mean, median,
#       min, max y sd. Explicar el filtro usado.

# ACTIVIDAD 15. Visualizaciones y tabla de hallazgos.
# TODO: barras horizontales para 12 variables con mayor ausencia.
# TODO: barras horizontales para 12 categorias de provincia.
# TODO: histograma de edades con binwidth = 5.
# TODO: crear una tabla de 5 hallazgos iniciales.

# FIN: Diagnosticar no es depurar. Conservar el archivo original.
