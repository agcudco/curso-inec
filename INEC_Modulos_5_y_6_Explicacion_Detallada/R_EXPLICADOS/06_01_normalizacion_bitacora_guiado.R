# ============================================================================
# MÓDULO 6.1 | NORMALIZACIÓN Y BITÁCORA DE CAMBIOS
# Normalizar: hacer uniforme una representación, sin suponer ni inventar datos.
# Corrección autorizada: decisión aprobada; aquí todas son SIMULACIONES.
# ============================================================================
# EXPLICACIÓN DOCENTE | OBJETIVO: cargar el CSV original y la copia de trabajo sin sobrescribir datos.
# EXPLICACIÓN DOCENTE | R debe reconocer el archivo .Rproj para resolver here::here().
# ----------------------------------------------------------------------
source(here::here("R", "00_preparacion.R"))

# PASO 1. Describir categorías ANTES de intervenir.
# EXPLICACIÓN DOCENTE | count(variable, sort=TRUE) produce tabla de frecuencias descendentes.
# EXPLICACIÓN DOCENTE | OBJETIVO: detectar etiquetas no uniformes ANTES de mapearlas.
# EXPLICACIÓN DOCENTE | 'urban', 'Urbana' y 'URBANA' pueden diferir como textos aunque compartan semántica.
# ----------------------------------------------------------------------
personas_raw %>% count(area, sort = TRUE)
personas_raw %>% count(sexo, sort = TRUE)
personas_raw %>% count(provincia, sort = TRUE)

# PASO 2. Crear COPIA derivada, nunca editar personas_raw ni CSV fuente.
# Solo 'urban', 'F' y 'PICHINCHA' se mapean bajo el diccionario didáctico.
# '99' y 'Desconocida' NO se reemplazan por una categoría inventada.
# EXPLICACIÓN DOCENTE | mutate() crea una nueva versión en memoria.
# EXPLICACIÓN DOCENTE | case_when(condicion ~ valor, TRUE ~ valor_original) aplica reglas ordenadas;
# EXPLICACIÓN DOCENTE | trimws() elimina espacios periféricos antes de comparar.
# EXPLICACIÓN DOCENTE | OBJETIVO: mapear SOLO equivalencias didácticas conocidas.
# EXPLICACIÓN DOCENTE | NO se reemplazan categorías dudosas con valores inventados; no es autorización.
# ----------------------------------------------------------------------
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
# EXPLICACIÓN DOCENTE | OBJETIVO: producir UNA FILA DE BITÁCORA POR CADA CELDA que cambia.
# EXPLICACIÓN DOCENTE | PARÁMETROS: original=tibble fuente; propuesto=tibble nuevo; columna=nombre textual;
# EXPLICACIÓN DOCENTE | codigo_regla=identificador técnico para poder reproducir la propuesta.
# EXPLICACIÓN DOCENTE | [[columna]] selecciona una columna por nombre; as.character() la convierte en texto.
# EXPLICACIÓN DOCENTE | iguales compara NA contra NA y valores contra valores, evitando confundir dos NA.
# EXPLICACIÓN DOCENTE | which(!iguales) obtiene posiciones donde hubo cambios;
# EXPLICACIÓN DOCENTE | rep() reproduce metadatos a lo largo del número de cambios.
# EXPLICACIÓN DOCENTE | Sys.Date() devuelve fecha actual al ejecutarse; no equivale a aprobación.
# EXPLICACIÓN DOCENTE | Este registro NO contiene el hash, por tanto la auditoría completa requiere versión de fuente aparte.
# ----------------------------------------------------------------------
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
# EXPLICACIÓN DOCENTE | bind_rows() reúne bitácoras de area, sexo y provincia.
# EXPLICACIÓN DOCENTE | print(head(...)) revisa muestras; count(variable, estado) resume cambios.
# EXPLICACIÓN DOCENTE | Estado PENDIENTE_DE_APROBACION distingue propuesta de corrección oficial.
# ----------------------------------------------------------------------
bitacora_propuesta <- dplyr::bind_rows(
  registrar_cambios(personas_raw, personas_propuesta, "area", "N6-01"),
  registrar_cambios(personas_raw, personas_propuesta, "sexo", "N6-02"),
  registrar_cambios(personas_raw, personas_propuesta, "provincia", "N6-03")
)
print(head(bitacora_propuesta, 15))
bitacora_propuesta %>% count(variable, estado, name = "cambios_propuestos")

# PASO 5. Verificar que las dimensiones se mantengan invariantes.
# EXPLICACIÓN DOCENTE | stopifnot() se detiene ante una condición falsa.
# EXPLICACIÓN DOCENTE | nrow() garantiza igual número de observaciones;
# EXPLICACIÓN DOCENTE | identical() exige valores y clases exactamente iguales para id_persona.
# EXPLICACIÓN DOCENTE | OBJETIVO: verificar que las transformaciones no cambien el universo ni la clave.
# ----------------------------------------------------------------------
stopifnot(nrow(personas_raw) == nrow(personas_propuesta))
stopifnot(identical(personas_raw$id_persona, personas_propuesta$id_persona))

# PAUSA: clasificar cada cambio: a) normalización representacional,
# b) corrección semántica, c) imputación. ¿Quién podría aprobar b) y c)?

# PASO 6. Comparación gráfica antes/después de la etiqueta de área.
# EXPLICACIÓN DOCENTE | count(area) produce las frecuencias; mutate(etapa=...) etiqueta cada escenario;
# EXPLICACIÓN DOCENTE | bind_rows() une ambas tablas para graficar.
# EXPLICACIÓN DOCENTE | geom_col(position="dodge") pone barras lado a lado; este gráfico NO indica mejora causal.
# ----------------------------------------------------------------------
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
