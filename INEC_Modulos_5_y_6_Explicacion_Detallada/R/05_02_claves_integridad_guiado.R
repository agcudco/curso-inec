# ============================================================================
# MÓDULO 5.2 | CLAVE, UNICIDAD E INTEGRIDAD REFERENCIAL
# Clave de persona: id_persona. Clave de hogar: id_hogar.
# Una clave de hogar REPETIDA entre personas es normal en una relación 1:N.
# ============================================================================
source(here::here("R", "00_preparacion.R"))

# PASO 1. IDs de personas no vacíos. No usar duplicados sobre NA.
ids <- personas %>% filter(!is.na(id_persona))

# 'duplicated' señala cada repetición DESPUÉS de la primera aparición.
repeticiones_adicionales <- ids %>%
  filter(duplicated(id_persona))

# Marcando desde ambos lados se identifican TODAS las filas implicadas.
filas_con_clave_repetida <- ids %>%
  filter(duplicated(id_persona) | duplicated(id_persona, fromLast = TRUE)) %>%
  arrange(id_persona, fila_csv)
cat("Repeticiones adicionales:", nrow(repeticiones_adicionales), "\n")
cat("Filas involucradas:", nrow(filas_con_clave_repetida), "\n")
print(head(filas_con_clave_repetida, 12))

# PASO 2. Distinguir filas idénticas de claves con valores discrepantes.
# Observar: sobre campos de origen, no sobre 'fila_csv' ni columnas derivadas.
filas_identicas_adicionales <- sum(duplicated(personas_raw))
cat("Filas de origen idénticas adicionales:", filas_identicas_adicionales, "\n")

# PASO 3. Verificar si el catálogo de hogares tiene su propia clave única.
claves_catalogo_repetidas <- hogares %>%
  filter(!is.na(id_hogar)) %>%
  count(id_hogar, name = "apariciones") %>%
  filter(apariciones > 1)
print(claves_catalogo_repetidas)
# Si hay duplicados, un JOIN puede multiplicar las filas de personas.

# PASO 4. Crear tabla de CLAVES ÚNICAS PARA COMPARACIÓN, sin borrar el origen.
ids_hogares_referencia <- hogares %>%
  filter(!is.na(id_hogar)) %>%
  distinct(id_hogar)

# PASO 5. 'anti_join' identifica hijos (personas) sin padre (hogar) conocido.
# NOTA: el catálogo auxiliar omite cinco hogares A PROPÓSITO como ejercicio.
personas_con_hogar <- personas %>% filter(!is.na(id_hogar))
filas_hogar_huerfano <- personas_con_hogar %>%
  anti_join(ids_hogares_referencia, by = "id_hogar")
claves_huerfanas <- filas_hogar_huerfano %>%
  distinct(id_hogar) %>% arrange(id_hogar)
print(claves_huerfanas)
cat("Filas afectadas:", nrow(filas_hogar_huerfano), "\n")

# PASO 6. Probar la ausencia de claves SIN asociarla a 'huérfano'.
filas_hogar_ausente <- personas %>% filter(is.na(id_hogar))
cat("Personas sin ID de hogar:", nrow(filas_hogar_ausente), "\n")

# PASO 7. Comprobar catálogo de padres que no tengan hijos (no siempre es error).
hogares_sin_personas <- ids_hogares_referencia %>%
  anti_join(personas_con_hogar %>% distinct(id_hogar), by = "id_hogar")
print(hogares_sin_personas)

# PASO 8. ALERTA CLAVE: conservar fila y mensaje sin eliminar personas.
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
resumen_i5 <- alertas_integridad %>% count(regla_id, name = "total")
ggplot(resumen_i5, aes(x = regla_id, y = total)) +
  geom_col(fill = "#B97747") +
  geom_text(aes(label = total), vjust = -0.35) +
  labs(title = "Alertas de claves e integridad", x = "Regla", y = "Incidencias") +
  theme_minimal()

# ACTIVIDAD: investigar el efecto de left_join contra catálogo NO deduplicado;
# nunca usar la multiplicación de filas como si fueran nuevos individuos.
