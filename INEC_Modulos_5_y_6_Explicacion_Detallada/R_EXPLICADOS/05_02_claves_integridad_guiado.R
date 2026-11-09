# ============================================================================
# MÓDULO 5.2 | CLAVE, UNICIDAD E INTEGRIDAD REFERENCIAL
# Clave de persona: id_persona. Clave de hogar: id_hogar.
# Una clave de hogar REPETIDA entre personas es normal en una relación 1:N.
# ============================================================================
# EXPLICACIÓN DOCENTE | OBJETIVO: disponer de personas, hogares, variables derivadas y rutas del script base.
# EXPLICACIÓN DOCENTE | source() ejecuta el archivo indicado y puede recrear objetos existentes.
# ----------------------------------------------------------------------
source(here::here("R", "00_preparacion.R"))

# PASO 1. IDs de personas no vacíos. No usar duplicados sobre NA.
# EXPLICACIÓN DOCENTE | filter(condicion) conserva SOLO las filas que cumplen una condición.
# EXPLICACIÓN DOCENTE | OBJETIVO: excluir claves de persona NA antes de estudiar repeticiones.
# EXPLICACIÓN DOCENTE | Una clave vacía se contabiliza por completitud, no como duplicado confirmado.
# ----------------------------------------------------------------------
ids <- personas %>% filter(!is.na(id_persona))

# 'duplicated' señala cada repetición DESPUÉS de la primera aparición.
# EXPLICACIÓN DOCENTE | duplicated(id_persona) marca TRUE desde la segunda aparición de cada valor.
# EXPLICACIÓN DOCENTE | OBJETIVO: medir REPETICIONES ADICIONALES, no todas las personas involucradas.
# EXPLICACIÓN DOCENTE | Ej.: A,A,A -> 2 adicionales; hay 3 filas involucradas.
# ----------------------------------------------------------------------
repeticiones_adicionales <- ids %>%
  filter(duplicated(id_persona))

# Marcando desde ambos lados se identifican TODAS las filas implicadas.
# EXPLICACIÓN DOCENTE | duplicated(x, fromLast=TRUE) busca duplicados desde el final.
# EXPLICACIÓN DOCENTE | El operador | significa 'o'; combinando ambos sentidos marca TODAS las filas del grupo.
# EXPLICACIÓN DOCENTE | arrange(id_persona, fila_csv) ordena para revisar registros del mismo identificador.
# ----------------------------------------------------------------------
filas_con_clave_repetida <- ids %>%
  filter(duplicated(id_persona) | duplicated(id_persona, fromLast = TRUE)) %>%
  arrange(id_persona, fila_csv)
cat("Repeticiones adicionales:", nrow(repeticiones_adicionales), "\n")
cat("Filas involucradas:", nrow(filas_con_clave_repetida), "\n")
print(head(filas_con_clave_repetida, 12))

# PASO 2. Distinguir filas idénticas de claves con valores discrepantes.
# Observar: sobre campos de origen, no sobre 'fila_csv' ni columnas derivadas.
# EXPLICACIÓN DOCENTE | duplicated(personas_raw) compara FILAS COMPLETAS en las 27 variables de origen.
# EXPLICACIÓN DOCENTE | sum(TRUE/FALSE) da número de filas adicionales idénticas.
# EXPLICACIÓN DOCENTE | OBJETIVO: diferenciar duplicados exactos de una misma clave con datos distintos.
# ----------------------------------------------------------------------
filas_identicas_adicionales <- sum(duplicated(personas_raw))
cat("Filas de origen idénticas adicionales:", filas_identicas_adicionales, "\n")

# PASO 3. Verificar si el catálogo de hogares tiene su propia clave única.
# EXPLICACIÓN DOCENTE | count(id_hogar, name="apariciones") agrupa por clave y cuenta.
# EXPLICACIÓN DOCENTE | filter(apariciones > 1) muestra hogares repetidos en la tabla padre.
# EXPLICACIÓN DOCENTE | OBJETIVO: evitar que un join duplique personas por multiplicidad no esperada del catálogo.
# ----------------------------------------------------------------------
claves_catalogo_repetidas <- hogares %>%
  filter(!is.na(id_hogar)) %>%
  count(id_hogar, name = "apariciones") %>%
  filter(apariciones > 1)
print(claves_catalogo_repetidas)
# Si hay duplicados, un JOIN puede multiplicar las filas de personas.

# PASO 4. Crear tabla de CLAVES ÚNICAS PARA COMPARACIÓN, sin borrar el origen.
# EXPLICACIÓN DOCENTE | distinct(id_hogar) conserva un ejemplar de cada CLAVE para comprobar EXISTENCIA.
# EXPLICACIÓN DOCENTE | No significa eliminar duplicados reales: se crea una tabla auxiliar de comparación.
# ----------------------------------------------------------------------
ids_hogares_referencia <- hogares %>%
  filter(!is.na(id_hogar)) %>%
  distinct(id_hogar)

# PASO 5. 'anti_join' identifica hijos (personas) sin padre (hogar) conocido.
# NOTA: el catálogo auxiliar omite cinco hogares A PROPÓSITO como ejercicio.
# EXPLICACIÓN DOCENTE | OBJETIVO: separar registros con clave conocida y clave ausente.
# EXPLICACIÓN DOCENTE | Los casos sin id_hogar se informan aparte; no se clasifican como huérfanos.
# ----------------------------------------------------------------------
personas_con_hogar <- personas %>% filter(!is.na(id_hogar))
# EXPLICACIÓN DOCENTE | anti_join(hijos, padres, by="id_hogar") devuelve hijos SIN correspondencia.
# EXPLICACIÓN DOCENTE | No añade columnas de padres; preserva todas las filas que no coinciden.
# EXPLICACIÓN DOCENTE | CONCEPTO: integridad referencial = toda FK no ausente debe referirse a una PK existente.
# EXPLICACIÓN DOCENTE | El catálogo es didáctico e incompleto a propósito: ausencia en el catálogo no prueba error del hogar.
# ----------------------------------------------------------------------
filas_hogar_huerfano <- personas_con_hogar %>%
  anti_join(ids_hogares_referencia, by = "id_hogar")
# EXPLICACIÓN DOCENTE | distinct(id_hogar) devuelve el conjunto de CLAVES huérfanas;
# EXPLICACIÓN DOCENTE | nrow(filas_hogar_huerfano) cuenta FILAS de personas afectadas.
# EXPLICACIÓN DOCENTE | Una clave puede afectar a varias personas, por lo que son medidas distintas.
# ----------------------------------------------------------------------
claves_huerfanas <- filas_hogar_huerfano %>%
  distinct(id_hogar) %>% arrange(id_hogar)
print(claves_huerfanas)
cat("Filas afectadas:", nrow(filas_hogar_huerfano), "\n")

# PASO 6. Probar la ausencia de claves SIN asociarla a 'huérfano'.
# EXPLICACIÓN DOCENTE | is.na(id_hogar) señala clave no informada.
# EXPLICACIÓN DOCENTE | OBJETIVO: documentar completitud sin confundirla con huérfanos.
# ----------------------------------------------------------------------
filas_hogar_ausente <- personas %>% filter(is.na(id_hogar))
cat("Personas sin ID de hogar:", nrow(filas_hogar_ausente), "\n")

# PASO 7. Comprobar catálogo de padres que no tengan hijos (no siempre es error).
# EXPLICACIÓN DOCENTE | anti_join(padres, hijos) ahora invierte la dirección: hogares sin personas registradas.
# EXPLICACIÓN DOCENTE | No equivale necesariamente a error: el universo de cada archivo puede variar.
# ----------------------------------------------------------------------
hogares_sin_personas <- ids_hogares_referencia %>%
  anti_join(personas_con_hogar %>% distinct(id_hogar), by = "id_hogar")
print(hogares_sin_personas)

# PASO 8. ALERTA CLAVE: conservar fila y mensaje sin eliminar personas.
# EXPLICACIÓN DOCENTE | transmute() selecciona y crea columnas, descartando las demás en la SALIDA.
# EXPLICACIÓN DOCENTE | bind_rows() combina alertas de huérfanos, ausencias y claves personales repetidas.
# EXPLICACIÓN DOCENTE | OBJETIVO: producir mensajes interpretables y rastreables, NO borrar datos.
# ----------------------------------------------------------------------
alertas_integridad <- dplyr::bind_rows(
  filas_hogar_huerfano %>% transmute(fila_csv, id_persona, id_hogar,
                                  regla_id = "I5-01", severidad = "REVISAR",
                                  observacion = "Hogar ausente en catálogo auxiliar"),
  filas_hogar_ausente %>% transmute(fila_csv, id_persona, id_hogar,
                                 regla_id = "I5-02", severidad = "REVISAR",
                                 observacion = "ID de hogar no declarado"),
  filas_con_clave_repetida %>% transmute(fila_csv, id_persona, id_hogar,
                                         regla_id = "I5-03", severidad = "REVISAR",
                                         observacion = "Clave personal presente más de una vez")
)
alertas_integridad %>% count(regla_id, name = "total")

# PASO 9. Gráfico de integridad: 'distinct' no sustituye la decisión de depurar.
# EXPLICACIÓN DOCENTE | count() prepara total por regla; ggplot() + geom_col() dibuja comparaciones;
# EXPLICACIÓN DOCENTE | geom_text() añade totales; labs() y theme_minimal() facilitan lectura.
# EXPLICACIÓN DOCENTE | Las barras pueden contar la misma persona más de una vez en reglas diferentes.
# ----------------------------------------------------------------------
resumen_i5 <- alertas_integridad %>% count(regla_id, name = "total")
ggplot(resumen_i5, aes(x = regla_id, y = total)) +
  geom_col(fill = "#B97747") +
  geom_text(aes(label = total), vjust = -0.35) +
  labs(title = "Alertas de claves e integridad", x = "Regla", y = "Incidencias") +
  theme_minimal()

# ACTIVIDAD: investigar el efecto de left_join contra catálogo NO deduplicado;
# nunca usar la multiplicación de filas como si fueran nuevos individuos.
