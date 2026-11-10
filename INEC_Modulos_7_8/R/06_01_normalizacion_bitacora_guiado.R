# ============================================================================
# MÓDULO 6.1 | NORMALIZACIÓN Y BITÁCORA DE CAMBIOS
# Normalizar: hacer uniforme una representación, sin suponer ni inventar datos.
# Corrección autorizada: decisión aprobada; aquí todas son SIMULACIONES.
# ============================================================================
source(here::here("R", "00_preparacion.R"))

# PASO 1. Describir categorías ANTES de intervenir.
personas_raw %>% count(area, sort = TRUE)
personas_raw %>% count(sexo, sort = TRUE)
personas_raw %>% count(provincia, sort = TRUE)

# PASO 2. Crear COPIA derivada, nunca editar personas_raw ni CSV fuente.
# Solo 'urban', 'F' y 'PICHINCHA' se mapean bajo el diccionario didáctico.
# '99' y 'Desconocida' NO se reemplazan por una categoría inventada.
personas_propuesta <- personas_raw %>%
  mutate(
    area = dplyr::case_when(
      trimws(area) == "urban" ~ "Urbana",
      TRUE ~ area
    ),
    sexo = dplyr::case_when(
      trimws(sexo) == "F" ~ "Mujer",
      TRUE ~ sexo
    ),
    provincia = dplyr::case_when(
      trimws(provincia) == "PICHINCHA" ~ "Pichincha",
      trimws(provincia) == "Guayas" ~ "Guayas",  # quitar espacios
      TRUE ~ provincia
    )
  )

# PASO 3. Función de auditoría de cambios (no registrar filas sin cambio).
# El número de fila coincide con el CSV físico (encabezado = línea 1).
registrar_cambios <- function(original, propuesto, columna, codigo_regla) {
  a <- as.character(original[[columna]])
  b <- as.character(propuesto[[columna]])
  iguales <- (is.na(a) & is.na(b)) |
    (!is.na(a) & !is.na(b) & a == b)
  indices <- which(!iguales)
  tibble::tibble(
    archivo_origen = rep("personas_encuesta_sintetica_2026_10.csv", length(indices)),
    fila_csv = indices + 1L,
    id_persona = original$id_persona[indices],
    variable = rep(columna, length(indices)),
    valor_original = a[indices],
    valor_propuesto = b[indices],
    regla_id = rep(codigo_regla, length(indices)),
    version_regla = rep("1.0", length(indices)),
    justificacion = rep("Equivalencia definida en diccionario didáctico", length(indices)),
    tipo_accion = rep("NORMALIZACION_PROPUESTA", length(indices)),
    responsable = rep("Participante (simulación)", length(indices)),
    fecha_propuesta = rep(as.character(Sys.Date()), length(indices)),
    estado = rep("PENDIENTE_DE_APROBACION", length(indices))
  )
}

# PASO 4. Bitácora para tres variables. Recuerde: aún no hay aprobación.
bitacora_propuesta <- dplyr::bind_rows(
  registrar_cambios(personas_raw, personas_propuesta, "area", "N6-01"),
  registrar_cambios(personas_raw, personas_propuesta, "sexo", "N6-02"),
  registrar_cambios(personas_raw, personas_propuesta, "provincia", "N6-03")
)
print(head(bitacora_propuesta, 15))
bitacora_propuesta %>% count(variable, estado, name = "cambios_propuestos")

# PASO 5. Verificar que las dimensiones se mantengan invariantes.
stopifnot(nrow(personas_raw) == nrow(personas_propuesta))
stopifnot(identical(personas_raw$id_persona, personas_propuesta$id_persona))

# PAUSA: clasificar cada cambio: a) normalización representacional,
# b) corrección semántica, c) imputación. ¿Quién podría aprobar b) y c)?

# PASO 6. Comparación gráfica antes/después de la etiqueta de área.
comp_area <- dplyr::bind_rows(
  personas_raw %>% count(area, name = "total") %>% mutate(etapa = "Antes"),
  personas_propuesta %>% count(area, name = "total") %>% mutate(etapa = "Propuesta")
)
ggplot(comp_area, aes(x = area, y = total, fill = etapa)) +
  geom_col(position = "dodge") +
  labs(title = "Normalización de etiquetas de área",
       x = "Área registrada", y = "Registros") +
  theme_minimal()

# SOLO si el instructor revisa, guardar en ruta distinta:
# readr::write_csv(bitacora_propuesta, here::here("bitacoras", "bitacora_propuesta.csv"), na = "NA")
