install.packages("tidyverse")

library(here)

#library(readr)
#library(dplyr)
#library(ggplot2)
#library(tibble)
library(tidyverse)   # ya incluye readr, dplyr, ggplot2, tibble

# Obtener la ruta a partir de la carpeta raíz del proyecto.
archivo_csv <- here::here(
  "data_raw", "personas_encuesta_sintetica_2026_10.csv"
)

# Verificar la existencia antes de intentar la lectura.
file.exists(archivo_csv)

# Importar las 27 columnas como texto para conservar el contenido original.
datos <- readr::read_csv(
  file = archivo_csv,
  col_types = readr::cols(.default = readr::col_character()),
  na = "NA",          # Reconoce exactamente este marcador como ausente.
  trim_ws = FALSE,    # Permite diagnosticar espacios que haya en el origen.
  locale = readr::locale(encoding = "UTF-8"),
  show_col_types = FALSE
)

# Examinar estructura y muestras de filas.
dim(datos)               # Debe indicar 1500 × 27.
names(datos)             # Encabezados originales.
head(datos, 5)           # Cinco registros iniciales.
readr::problems(datos)   # Problemas de lectura, NO todos los de calidad.

# Una ausencia puede estar representada de varias formas.
es_ausente <- function(x) {
  texto <- toupper(trimws(as.character(x)))
  is.na(texto) | texto %in% c("", "NA", "N/D", "SIN DATO")
}

# Prueba didáctica: cero es un dato, no una ausencia.
es_ausente(c(NA, "", "NA", "N/D", "SIN DATO", "0", "0.00"))
es_ausente(c("0", "", "NA", "N/D", "SIN DATO", "0", "0.00"))


# Comparar tres maneras de buscar ausencias de edad.
sum(is.na(datos$edad))
sum(trimws(datos$edad) == "", na.rm = TRUE)
sum(es_ausente(datos$edad))

# Porcentaje respecto del número total de registros.
porcentaje_edad <- round(
  100 * sum(es_ausente(datos$edad)) / nrow(datos),
  2
)
print(porcentaje_edad)  # 4.40 % para esta base.


# vapply recorre cada columna y devuelve su número de ausencias.
tabla_ausencias <- tibble::tibble(
  variable = names(datos),
  n_ausentes = vapply(
    datos,
    function(x) sum(es_ausente(x)),
    integer(1)
  )
) %>%
  mutate(
    porcentaje = round(100 * n_ausentes / nrow(datos), 2)
  ) %>%
  arrange(desc(n_ausentes))

print(tabla_ausencias, n = 27)


# Se omite el campo opcional observaciones, no se elimina de la base.
g_ausencias <- tabla_ausencias %>%
  filter(variable != "observaciones", n_ausentes > 0) %>%
  ggplot(aes(x = reorder(variable, n_ausentes), y = n_ausentes)) +
  geom_col(fill = "#14679E") +
  coord_flip() +
  labs(
    title = "Ausencias por variable",
    x = NULL,
    y = "Número de registros"
  ) +
  theme_minimal()

print(g_ausencias)


# 1. No considerar marcadores ausentes como claves válidas.
ids_validos <- datos$id_persona[!es_ausente(datos$id_persona)]

# 2. Repeticiones adicionales de claves no vacías.
sum(duplicated(ids_validos))
# Esperado: 20.

# 3. Mostrar TODAS las filas relacionadas con claves repetidas.
filas_ids_repetidos <- datos %>%
  mutate(fila_csv = row_number() + 1L) %>%
  filter(
    !es_ausente(id_persona),
    duplicated(id_persona) | duplicated(id_persona, fromLast = TRUE)
  ) %>%
  arrange(id_persona, fila_csv) %>%
  select(fila_csv, id_persona, id_hogar, provincia, edad)

print(filas_ids_repetidos, n = 30)

# 4. Contar filas totalmente idénticas adicionales.
sum(duplicated(datos))
# Esperado: 4.


# Frecuencias de sexo conservando las etiquetas originales.
frecuencia_sexo <- datos %>%
  mutate(sexo_revisado = ifelse(es_ausente(sexo), "[Ausente]", sexo)) %>%
  count(sexo_revisado, name = "total", sort = TRUE)

print(frecuencia_sexo)

ggplot(frecuencia_sexo, aes(x = reorder(sexo_revisado, -total), y = total)) +
  geom_col(fill = "steelblue", width = 0.7) +
  geom_text(aes(label = total), vjust = -0.4, size = 4) +
  labs(
    title    = "Frecuencia por sexo",
    subtitle = "Incluye registros con sexo ausente",
    x        = "Sexo",
    y        = "Número de registros",
    caption  = paste("Total de registros:", sum(frecuencia_sexo$total))
  ) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.10))) +
  theme_minimal(base_size = 13) +
  theme(panel.grid.major.x = element_blank())


# Una segunda comparación, por provincia.
datos %>% count(provincia, sort = TRUE)


# Esta función interpreta punto decimal, no elimina letras o símbolos.
numero_estricto <- function(x) {
  suppressWarnings(readr::parse_double(
    x,
    na = c("", "NA", "N/D", "SIN DATO"),
    locale = readr::locale(decimal_mark = ".")
  ))
}

# Crear variables derivadas (sufijo _num).
datos_perfilados <- datos %>%
  mutate(
    fila_csv = row_number() + 1L,
    edad_num = numero_estricto(edad),
    ingreso_num = numero_estricto(ingreso_mensual_usd),
    horas_num = numero_estricto(horas_trabajo_semana),
    escolaridad_num = numero_estricto(anios_escolaridad)
  )

# Contrastar, fila a fila, texto original y número convertido.
datos_perfilados %>%
  select(fila_csv, id_persona, ingreso_mensual_usd, ingreso_num) %>%
  head(15)

# Expresión regular: signo opcional, enteros y decimales con punto.
patron_numero <- "^-?[0-9]+(\\.[0-9]+)?$"

formatos_ingreso <- datos %>%
  mutate(fila_csv = row_number() + 1L) %>%
  filter(
    !es_ausente(ingreso_mensual_usd),
    !grepl(patron_numero, trimws(ingreso_mensual_usd))
  ) %>%
  select(fila_csv, id_persona, ingreso_mensual_usd)

print(formatos_ingreso, n = Inf)
# Esperado: 3 entradas, no confundir con las 51 ausencias declaradas.


edades_elegibles <- datos_perfilados %>%
  filter(!is.na(edad_num), edad_num >= 0, edad_num <= 110,
         edad_num == floor(edad_num))

resumen_edad <- edades_elegibles %>%
  summarise(
    n = n(),
    media = mean(edad_num),
    mediana = median(edad_num),
    desviacion = sd(edad_num),
    q1 = as.numeric(quantile(edad_num, 0.25)),
    q3 = as.numeric(quantile(edad_num, 0.75)),
    minimo = min(edad_num),
    maximo = max(edad_num)
  )
print(resumen_edad)



ggplot(edades_elegibles, aes(x = edad_num)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "white",
                 boundary = 0, closed = "left") +
  geom_vline(data = resumen_edad, aes(xintercept = media),
             color = "tomato", linetype = "dashed", linewidth = 1) +
  geom_vline(data = resumen_edad, aes(xintercept = mediana),
             color = "darkgreen", linetype = "solid", linewidth = 1) +
  annotate("text", x = resumen_edad$media, y = Inf,
           label = paste0("Media = ", round(resumen_edad$media, 1)),
           hjust = -0.1, vjust = 2, color = "tomato", size = 4) +
  annotate("text", x = resumen_edad$mediana, y = Inf,
           label = paste0("Mediana = ", resumen_edad$mediana),
           hjust = -0.1, vjust = 4, color = "darkgreen", size = 4) +
  labs(
    title    = "Distribución de la edad",
    subtitle = paste0("n = ", resumen_edad$n,
                      "  |  rango: ", resumen_edad$minimo, "–", resumen_edad$maximo,
                      " años  |  DE = ", round(resumen_edad$desviacion, 1)),
    x = "Edad (años)",
    y = "Número de registros"
  ) +
  theme_minimal(base_size = 13)

# No dividir ni transformar el CSV; solo utilizar columnas derivadas.
resumen_ingreso <- datos_perfilados %>%
  summarise(
    n_numericos = sum(!is.na(ingreso_num)),
    ceros = sum(ingreso_num == 0, na.rm = TRUE),
    negativos = sum(ingreso_num < 0, na.rm = TRUE),
    media = mean(ingreso_num, na.rm = TRUE),
    mediana = median(ingreso_num, na.rm = TRUE),
    maximo = max(ingreso_num, na.rm = TRUE)
  )
print(resumen_ingreso)

# Gráfico de ingresos no negativos; el zoom NO borra registros.
g_ingresos <- datos_perfilados %>%
  filter(!is.na(ingreso_num), ingreso_num >= 0, ingreso_num <= 3000) %>%
  ggplot(aes(x = ingreso_num)) +
  geom_histogram(binwidth = 100, boundary = 0, fill = "#14679E", color = "white") +
  labs(title = "Ingresos mensuales: vista ampliada",
       subtitle = "Subconjunto solo para visualizar; el CSV permanece completo",
       x = "USD", y = "Registros") +
  theme_minimal()
print(g_ingresos)

# Boxplot por condición de actividad con transformación explícita.
g_caja <- datos_perfilados %>%
  filter(!is.na(ingreso_num), ingreso_num >= 0) %>%
  ggplot(aes(x = condicion_actividad, y = log10(ingreso_num + 1))) +
  geom_boxplot(fill = "#D8E9F2", outlier.color = "#E77F23") +
  labs(title = "Dispersión del ingreso según condición de actividad",
       x = "Condición de actividad", y = "log10(ingreso + 1)") +
  theme_minimal()
print(g_caja)


# Copia de trabajo: no cambiar edad, edad_num ni datos.
datos_imputados <- datos_perfilados %>%
  mutate(
    edad_elegible = if_else(
      !is.na(edad_num) & edad_num >= 0 & edad_num <= 110 &
        edad_num == floor(edad_num),
      edad_num,
      NA_real_
    ),
    edad_fue_imputada = is.na(edad_elegible)
  )

print(datos_imputados)


# Calcular sobre las edades elegibles observadas.
media_edad <- mean(datos_imputados$edad_elegible, na.rm = TRUE)
mediana_edad <- median(datos_imputados$edad_elegible, na.rm = TRUE)

# coalesce conserva el valor observado y completa solo cuando hay NA.
datos_imputados <- datos_imputados %>%
  mutate(
    edad_por_media = coalesce(edad_elegible, media_edad),
    edad_por_mediana = coalesce(edad_elegible, mediana_edad)
  )

# Cada provincia tendrá una mediana propia si posee datos válidos.
datos_imputados <- datos_imputados %>%
  group_by(provincia) %>%
  mutate(
    mediana_grupo = if (all(is.na(edad_elegible))) mediana_edad
    else median(edad_elegible, na.rm = TRUE),
    edad_por_grupo = coalesce(edad_elegible, mediana_grupo)
  ) %>%
  ungroup()


# Los ingresos negativos quedan pendientes de revisión; los 0 se conservan.
datos_imputados <- datos_imputados %>%
  mutate(
    ingreso_elegible = if_else(
      !is.na(ingreso_num) & ingreso_num >= 0,
      ingreso_num, NA_real_
    )
  )

media_ingreso <- mean(datos_imputados$ingreso_elegible, na.rm = TRUE)
mediana_ingreso <- median(datos_imputados$ingreso_elegible, na.rm = TRUE)

# Dos escenarios, sin reemplazar el ingreso original.
datos_imputados <- datos_imputados %>%
  mutate(
    ingreso_por_media = coalesce(ingreso_elegible, media_ingreso),
    ingreso_por_mediana = coalesce(ingreso_elegible, mediana_ingreso)
  )


comparacion <- tibble(
  metodo = c("Observada", "Media", "Mediana", "Mediana por provincia"),
  promedio = c(
    mean(datos_imputados$edad_elegible, na.rm = TRUE),
    mean(datos_imputados$edad_por_media, na.rm = TRUE),
    mean(datos_imputados$edad_por_mediana, na.rm = TRUE),
    mean(datos_imputados$edad_por_grupo, na.rm = TRUE)
  ),
  desviacion = c(
    sd(datos_imputados$edad_elegible, na.rm = TRUE),
    sd(datos_imputados$edad_por_media, na.rm = TRUE),
    sd(datos_imputados$edad_por_mediana, na.rm = TRUE),
    sd(datos_imputados$edad_por_grupo, na.rm = TRUE)
  )
)
print(comparacion)


# Se puede ampliar a todas las reglas; el script de módulo 4 trae el catálogo.
reglas_ejemplo <- tibble::tribble(
  ~regla, ~variable, ~tipo, ~severidad,
  "error_id_ausente", "id_persona", "Obligatoriedad", "Error",
  "error_edad_formato", "edad", "Formato", "Error",
  "error_edad_rango", "edad", "Rango ilustrativo", "Revisión",
  "alerta_ingreso_extremo", "ingreso_mensual_usd", "Atípico IQR", "Advertencia"
)
print(reglas_ejemplo)

