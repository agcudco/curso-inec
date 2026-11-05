# ============================================================
# CURSO INEC | MODULO 3 | Perfilado y diagnostico exploratorio
# PRERREQUISITO: importar 'datos' en el modulo 1 y conocer
# el diccionario del modulo 2.
# ============================================================

library(dplyr)
library(ggplot2)

if (!exists("datos")) {
  stop("Primero recorra R/01_entorno_y_primera_lectura.R para crear 'datos'.")
}

# PASO 1. Definir que significa 'ausencia' PARA ESTE EJERCICIO.
# Es una convencion didactica; no equivale a politica del INEC.
es_vacio <- function(x) !is.na(x) & trimws(x) == ""
es_marcador <- function(x) {
  !is.na(x) & toupper(trimws(x)) %in% c("N/D", "SIN DATO")
}

# PASO 2. Calcular un perfil reproducible por cada variable.
perfil <- tibble::tibble(
  variable = names(datos),
  registros = nrow(datos),
  n_na = vapply(datos, function(x) sum(is.na(x)), integer(1)),
  n_vacios = vapply(datos, function(x) sum(es_vacio(x)), integer(1)),
  n_marcadores = vapply(datos, function(x) sum(es_marcador(x)), integer(1))
) %>%
  mutate(
    n_ausencias = n_na + n_vacios + n_marcadores,
    porcentaje = round(100 * n_ausencias / registros, 2)
  ) %>%
  arrange(desc(porcentaje))

print(perfil, n = nrow(perfil))
# observaciones puede tener 100 % vacios sin ser un error:
# su diccionario declara ese campo como opcional.

# PASO 3. Detectar claves repetidas sin eliminar registros.
ids_repetidos <- datos %>%
  filter(!is.na(id_persona), trimws(id_persona) != "") %>%
  count(id_persona, name = "veces") %>%
  filter(veces > 1) %>%
  arrange(desc(veces), id_persona)

n_repeticiones_adicionales <- sum(ids_repetidos$veces - 1L)
ids_repetidos
n_repeticiones_adicionales

# Tambien puede haber registros iguales en TODAS las columnas:
n_filas_identicas_adicionales <- sum(duplicated(datos))
n_filas_identicas_adicionales
# IMPORTANTE: no confunda IDs duplicados con filas totalmente iguales.

# PASO 4. Explorar categorias, sin afirmar todavia que son erroneas.
frecuencia_provincias <- datos %>%
  count(provincia, sort = TRUE, name = "registros")
frecuencia_sexo <- datos %>%
  count(sexo, sort = TRUE, name = "registros")
print(frecuencia_provincias, n = nrow(frecuencia_provincias))
print(frecuencia_sexo, n = nrow(frecuencia_sexo))

# PASO 5. Identificar edades convertibles y valores extremos.
# 0–110 es un rango ILUSTRATIVO, no una regla institucional.
edades <- datos %>%
  transmute(
    id_persona,
    edad_original = edad,
    edad_num = suppressWarnings(as.integer(edad)),
    no_convertible = !is.na(edad_original) &
      trimws(edad_original) != "" &
      !(toupper(trimws(edad_original)) %in% c("N/D", "SIN DATO")) &
      is.na(edad_num),
    extremo_ilustrativo = !is.na(edad_num) &
      (edad_num < 0 | edad_num > 110)
  )

edades %>% summarise(
  no_convertibles = sum(no_convertible),
  extremos_para_revisar = sum(extremo_ilustrativo)
)

resumen_edades <- edades %>%
  filter(!is.na(edad_num), between(edad_num, 0L, 110L)) %>%
  summarise(
    n = n(),
    media = round(mean(edad_num), 2),
    mediana = median(edad_num),
    minimo = min(edad_num),
    maximo = max(edad_num),
    desv_est = round(sd(edad_num), 2)
  )
resumen_edades

# PASO 6. Graficar variables con mayor ausencia (excluyendo el
# campo opcional observaciones para mejorar la legibilidad).
perfil_grafico <- perfil %>%
  filter(variable != "observaciones") %>%
  slice_max(order_by = porcentaje, n = 12, with_ties = FALSE)

grafico_ausencias <- ggplot(
  perfil_grafico,
  aes(x = reorder(variable, porcentaje), y = porcentaje)
) +
  geom_col(fill = "#347FA7", width = 0.72) +
  coord_flip() +
  labs(
    title = "Ausencias por variable (datos sintéticos)",
    subtitle = "NA, cadenas vacías, N/D y SIN DATO",
    x = "Variable", y = "Porcentaje (%)"
  ) +
  theme_minimal(base_size = 12)
print(grafico_ausencias)

# PASO 7. Graficar frecuencias de provincia tal como aparecen
# en el archivo, SIN normalizar ni corregir codificaciones.
provincias_top <- frecuencia_provincias %>%
  slice_head(n = 12) %>%
  mutate(provincia = if_else(is.na(provincia) | provincia == "", "(vacía/NA)", provincia))

grafico_provincias <- ggplot(
  provincias_top,
  aes(x = reorder(provincia, registros), y = registros)
) +
  geom_col(fill = "#347FA7", width = 0.75) +
  coord_flip() +
  labs(
    title = "Categorías más frecuentes de provincia",
    subtitle = "Vista exploratoria del CSV sin correcciones",
    x = "Categoría", y = "Registros"
  ) +
  theme_minimal(base_size = 12)
print(grafico_provincias)

# PASO 8. Histograma de edades, solo para DESCRIBIR valores
# convertibles en el intervalo ilustrativo de 0 a 110.
grafico_edades <- edades %>%
  filter(!is.na(edad_num), between(edad_num, 0L, 110L)) %>%
  ggplot(aes(x = edad_num)) +
  geom_histogram(binwidth = 5, boundary = 0, fill = "#347FA7", color = "white") +
  labs(
    title = "Distribución descriptiva de edad",
    subtitle = "Registros convertibles dentro de 0–110; NO es depuración",
    x = "Edad", y = "Registros"
  ) +
  theme_minimal(base_size = 12)
print(grafico_edades)

# PASO 9. Construir una tabla de hallazgos exploratorios.
# Son conteos diferentes; las categorias pueden solaparse.
incidencias_iniciales <- tibble::tibble(
  hallazgo = c(
    "Ausencias en edad",
    "Identificadores repetidos adicionales",
    "Edades no convertibles",
    "Extremos de edad (0-110 ilustrativo)"
  ),
  total = c(
    sum(perfil$n_ausencias[perfil$variable == "edad"]),
    n_repeticiones_adicionales,
    sum(edades$no_convertible),
    sum(edades$extremo_ilustrativo)
  )
)
incidencias_iniciales

# PARA PRACTICAR DESPUES: guarde resultados SOLO en resultados/.
# readr::write_csv(perfil, here::here("resultados", "perfil_ausencias.csv"))
# ggplot2::ggsave(here::here("resultados", "grafico_ausencias.png"),
#                 plot = grafico_ausencias, width = 10, height = 6, dpi = 160)

# ACTIVIDAD PARA CLASE:
# 1. Explique por que NA y "" se cuentan por separado.
# 2. Identifique una categoria atipica de provincia.
# 3. Compare claves repetidas con filas totalmente identicas.
# 4. Distinga 'hallazgo' de 'error confirmado'.
