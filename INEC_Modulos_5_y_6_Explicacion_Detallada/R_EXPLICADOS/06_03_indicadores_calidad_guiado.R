# ============================================================================
# MÓDULO 6.3 | MÉTRICAS AUDITABLES Y SEGUIMIENTO
# Completitud: casillas requeridas presentes / casillas requeridas evaluadas.
# Validez: pruebas de reglas satisfechas / pruebas de reglas aplicables.
# Unicidad: registros con clave personal no repetida / registros con clave.
# CADA indicador tiene su propio denominador: NO promediar porcentajes.
# ============================================================================
# EXPLICACIÓN DOCENTE | OBJETIVO: cargar funciones auxiliares y la copia sin modificar de las entradas.
# ----------------------------------------------------------------------
source(here::here("R", "00_preparacion.R"))

# PASO 1. Definir qué campos son requeridos en este escenario didáctico.
# EXPLICACIÓN DOCENTE | c(...) crea vector de nombres de 6 variables obligatorias EN ESTE CASO DIDÁCTICO.
# EXPLICACIÓN DOCENTE | Su selección determina el denominador; no es política INEC.
# ----------------------------------------------------------------------
requeridas <- c("id_persona", "id_hogar", "provincia", "edad",
                "fecha_levantamiento", "personas_hogar")

# PASO 2. Crear función con criterios y denominadores explícitos.
# EXPLICACIÓN DOCENTE | OBJETIVO: encapsular todas las reglas en una función reproducible.
# EXPLICACIÓN DOCENTE | PARÁMETRO: datos = tibble con 27 columnas del archivo de personas.
# EXPLICACIÓN DOCENTE | Devuelve tibble con indicador, numerador, denominador y porcentaje.
# ----------------------------------------------------------------------
calcular_indicadores <- function(datos) {
  # COMPLETITUD: 6 campos x número de registros.
# EXPLICACIÓN DOCENTE | length(requeridas) cuenta campos requeridos y nrow(datos) filas.
# EXPLICACIÓN DOCENTE | Producto = total de celdas evaluables; aquí se asume que todas aplican a cada fila.
# ----------------------------------------------------------------------
  n_requeridas <- length(requeridas) * nrow(datos)
# EXPLICACIÓN DOCENTE | vapply(requeridas, function(nombre) {...}, integer(1)) aplica conteo por columna
# EXPLICACIÓN DOCENTE | exigiendo un entero de salida por campo; [[nombre]] accede a variable dinámica.
# EXPLICACIÓN DOCENTE | limpiar_ausencias() homogeniza marcadores; !is.na() comprueba presencia;
# EXPLICACIÓN DOCENTE | sum() agrega celdas presentes en las seis variables.
# ----------------------------------------------------------------------
  n_presentes <- sum(vapply(requeridas, function(nombre) {
    sum(!is.na(limpiar_ausencias(datos[[nombre]])))
  }, integer(1)))

  # VALIDEZ: 3 pruebas con distinto conjunto de registros aplicables:
  # - provincia presente y en catálogo (módulo 4)
  # - edad presente, entera y entre 0 y 110 (rango meramente didáctico)
  # - ingreso presente, formato numérico y valor no negativo
# EXPLICACIÓN DOCENTE | read_csv(...)$provincia devuelve vector de categorías permitidas en el catálogo auxiliar.
# EXPLICACIÓN DOCENTE | OBJETIVO: fijar un dominio EXPLÍCITO en lugar de asumir que todo texto es válido.
# ----------------------------------------------------------------------
  catalogo <- readr::read_csv(here::here("diccionario", "catalogo_provincias_didactico.csv"),
                             show_col_types = FALSE)$provincia
# EXPLICACIÓN DOCENTE | Se normaliza de forma TEMPORAL el tratamiento de ausencias de cada campo.
# EXPLICACIÓN DOCENTE | suppressWarnings(as.numeric()) permite detectar textos numéricos convertibles;
# EXPLICACIÓN DOCENTE | la máscara de formato grepl() conserva la restricción original: p. ej. "20.0" no es edad entera.
# ----------------------------------------------------------------------
  prov <- limpiar_ausencias(datos$provincia)
  edad <- limpiar_ausencias(datos$edad)
  ingreso <- limpiar_ausencias(datos$ingreso_mensual_usd)
  edad_num <- suppressWarnings(as.numeric(edad))
  ingreso_num <- suppressWarnings(as.numeric(ingreso))
# EXPLICACIÓN DOCENTE | Denominadores de VALIDEZ = pruebas aplicables CON DATO PRESENTE.
# EXPLICACIÓN DOCENTE | Las ausencias no desaparecen: ya son evaluadas por COMPLETITUD.
# EXPLICACIÓN DOCENTE | Se definen tres denominadores distintos según la variable.
# ----------------------------------------------------------------------
  den_prov <- sum(!is.na(prov))
  den_edad <- sum(!is.na(edad))
  den_ing <- sum(!is.na(ingreso))
# EXPLICACIÓN DOCENTE | %in% catalogo valida dominio, y grepl(patrón, texto) verifica forma.
# EXPLICACIÓN DOCENTE | Patrón ^[0-9]{1,3}$ = entero textual de 1 a 3 dígitos;
# EXPLICACIÓN DOCENTE | patrón ^[0-9]+\.[0-9]{2}$ = decimal con 2 cifras (\. es punto literal).
# EXPLICACIÓN DOCENTE | La edad también se compara contra el rango DIDÁCTICO 0..110.
# EXPLICACIÓN DOCENTE | Ingreso >=0 cuenta cero como válido; casos NA no suman al numerador.
# ----------------------------------------------------------------------
  num_prov <- sum(!is.na(prov) & prov %in% catalogo)
  num_edad <- sum(!is.na(edad) & grepl("^[0-9]{1,3}$", edad) &
                    !is.na(edad_num) & edad_num >= 0 & edad_num <= 110)
  num_ing <- sum(!is.na(ingreso) &
                   grepl("^[0-9]+\\.[0-9]{2}$", ingreso) &
                   !is.na(ingreso_num) & ingreso_num >= 0)

  # UNICIDAD: contar filas cuya clave aparece exactamente una vez.
# EXPLICACIÓN DOCENTE | Las claves NA se excluyen de evaluación de UNICIDAD; las ausencias se
# EXPLICACIÓN DOCENTE | cuentan en COMPLETITUD. !duplicated(x) y !duplicated(x, fromLast=TRUE)
# EXPLICACIÓN DOCENTE | seleccionan filas cuyo ID aparece exactamente UNA VEZ en todo el conjunto.
# ----------------------------------------------------------------------
  ids <- limpiar_ausencias(datos$id_persona)
  ids <- ids[!is.na(ids)]
  n_ids <- length(ids)
  n_ids_sin_repeticion <- sum(!duplicated(ids) & !duplicated(ids, fromLast = TRUE))

# EXPLICACIÓN DOCENTE | c(...) construye 3 conteos de éxitos; denominadores 3 conteos evaluables.
# EXPLICACIÓN DOCENTE | ifelse(denominadores>0, n/d, NA_real_) evita porcentaje cuando no hay casos.
# EXPLICACIÓN DOCENTE | round(100*...,2) comunica porcentajes sin ocultar base.
# EXPLICACIÓN DOCENTE | NOTA: no se deben promediar porcentajes de dimensiones diferentes.
# ----------------------------------------------------------------------
  numeradores <- c(n_presentes, num_prov + num_edad + num_ing,
                   n_ids_sin_repeticion)
  denominadores <- c(n_requeridas, den_prov + den_edad + den_ing, n_ids)
  tibble::tibble(
    indicador = c("Completitud", "Validez", "Unicidad"),
    numerador = numeradores,
    denominador = denominadores,
    porcentaje = round(100 * ifelse(denominadores > 0,
                                    numeradores / denominadores, NA_real_), 2)
  )
}

# PASO 3. Línea base, ANTES de cualquier normalización.
# EXPLICACIÓN DOCENTE | OBJETIVO: obtener línea base ANTES de las normalizaciones de etiquetas.
# EXPLICACIÓN DOCENTE | La función se alimenta de personas_raw, que conserva datos del CSV.
# ----------------------------------------------------------------------
indicadores_antes <- calcular_indicadores(personas_raw)
print(indicadores_antes)

# PASO 4. ESCENARIO de normalización controlada, no producto autorizado.
# EXPLICACIÓN DOCENTE | OBJETIVO: obtener personas_propuesta definida por la simulación de normalización.
# EXPLICACIÓN DOCENTE | PRECAUCIÓN: source() ejecuta 06_01 (y vuelve a llamar 00_preparacion),
# EXPLICACIÓN DOCENTE | construyendo una propuesta en memoria, no editando el archivo físico.
# ----------------------------------------------------------------------
source(here::here("R", "06_01_normalizacion_bitacora_guiado.R"))
indicadores_propuestos <- calcular_indicadores(personas_propuesta)
print(indicadores_propuestos)

# PASO 5. Comparar sin atribuir causalidad ni aprobar datos.
# EXPLICACIÓN DOCENTE | bind_rows() combina indicadores con etiqueta de escenario.
# EXPLICACIÓN DOCENTE | mutate(escenario=...) agrega origen de cada bloque.
# EXPLICACIÓN DOCENTE | ggplot(..., fill=escenario) asigna color según etapa;
# EXPLICACIÓN DOCENTE | geom_col(position="dodge") compara barras adyacentes;
# EXPLICACIÓN DOCENTE | geom_text(position_dodge(width=0.9)) alinea etiquetas con las barras;
# EXPLICACIÓN DOCENTE | coord_cartesian(ylim=c(0,110)) cambia ventana visual SIN eliminar observaciones.
# ----------------------------------------------------------------------
comparativa <- dplyr::bind_rows(
  indicadores_antes %>% mutate(escenario = "Antes"),
  indicadores_propuestos %>% mutate(escenario = "Propuesta")
)
ggplot(comparativa, aes(x = indicador, y = porcentaje, fill = escenario)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0(porcentaje, "%")),
            position = position_dodge(width = 0.9), vjust = -0.25, size = 3) +
  coord_cartesian(ylim = c(0, 110)) +
  labs(title = "Métricas de calidad por escenario (didáctico)",
       x = "Indicador", y = "Porcentaje") +
  theme_minimal()

# PASO 6. Control final: no confundir "unicidad" con completitud de la clave;
# filas con ID ausente se excluyen del denominador de unicidad y se informan
# como problema de completitud.
# OPCIONAL: guardar en resultados, una vez aprobada la salida:
# readr::write_csv(comparativa, here::here("resultados", "comparativa_metricas.csv"))
