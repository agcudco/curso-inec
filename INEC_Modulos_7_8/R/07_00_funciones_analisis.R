# =============================================================================
# MÓDULO 7 | FUNCIONES REUTILIZABLES DE CÁLCULO Y PRESENTACIÓN
# OBJETIVO: mantener las definiciones de indicadores coherentes con el módulo 6
# y evitar que el informe y los gráficos calculen porcentajes distintos.
# Este archivo DEFINE funciones, no ejecuta análisis ni escribe archivos.
# =============================================================================

normalizar_ausencia <- function(x) {
  # trimws() elimina espacios de extremos; toupper() uniformiza mayúsculas.
  y <- trimws(as.character(x))
  y[is.na(y) | toupper(y) %in% c("", "NA", "N/D", "SIN DATO")] <- NA_character_
  y
}

validar_hitos <- function(hitos) {
  # stopifnot() detiene el análisis ante un punto de control incompleto.
  necesarios <- c("personas_raw", "personas_propuesta", "alertas_logicas",
                  "alertas_integridad", "bitacora_propuesta",
                  "indicadores_antes", "indicadores_propuestos")
  ausentes <- setdiff(necesarios, names(hitos))
  if (length(ausentes)) stop("Faltan objetos en el RDS: ", paste(ausentes, collapse=", "))
  if (nrow(hitos$personas_raw) != nrow(hitos$personas_propuesta)) {
    stop("Las versiones original y propuesta tienen distinta cantidad de filas")
  }
  columnas_alerta <- c("fila_csv", "regla_id", "severidad")
  for (nm in c("alertas_logicas", "alertas_integridad")) {
    if (!all(columnas_alerta %in% names(hitos[[nm]]))) {
      stop("La tabla ", nm, " no tiene todas las columnas esperadas")
    }
  }
  for (nm in c("indicadores_antes", "indicadores_propuestos")) {
    if (!all(c("indicador", "numerador", "denominador", "porcentaje") %in%
             names(hitos[[nm]]))) stop("Estructura incorrecta en: ", nm)
  }
  invisible(TRUE)
}

# MISMA DEFINICIÓN DIDÁCTICA DEL MÓDULO 6.
# Se utiliza únicamente cuando llega un SEGUNDO ARCHIVO o un período distinto.
# El cálculo principal se toma de los indicadores ya producidos en el módulo 6.
calcular_indicadores_compatibles <- function(datos, catalogo_provincias) {
  requeridas <- c("id_persona", "id_hogar", "provincia", "edad",
                  "fecha_levantamiento", "personas_hogar")
  faltantes <- setdiff(c(requeridas, "ingreso_mensual_usd"), names(datos))
  if (length(faltantes)) stop("Columnas faltantes: ", paste(faltantes, collapse = ", "))

  # Completitud: presencia de los seis campos exigidos para la práctica.
  den_comp <- length(requeridas) * nrow(datos)
  num_comp <- sum(vapply(requeridas, function(nm) {
    sum(!is.na(normalizar_ausencia(datos[[nm]])))
  }, integer(1)))

  # Validez: cantidad de pruebas superadas / cantidad de pruebas aplicables.
  prov <- normalizar_ausencia(datos$provincia)
  edad <- normalizar_ausencia(datos$edad)
  ing  <- normalizar_ausencia(datos$ingreso_mensual_usd)
  edad_num <- suppressWarnings(as.numeric(edad))
  ing_num <- suppressWarnings(as.numeric(ing))
  den_val <- sum(!is.na(prov)) + sum(!is.na(edad)) + sum(!is.na(ing))
  num_val <- sum(!is.na(prov) & prov %in% catalogo_provincias) +
    sum(!is.na(edad) & grepl("^[0-9]{1,3}$", edad) &
          !is.na(edad_num) & edad_num >= 0 & edad_num <= 110) +
    sum(!is.na(ing) & grepl("^[0-9]+\\.[0-9]{2}$", ing) &
          !is.na(ing_num) & ing_num >= 0)

  # Unicidad: solo IDs de persona declarados; repetición desde ambos extremos.
  ids <- normalizar_ausencia(datos$id_persona)
  ids <- ids[!is.na(ids)]
  den_uni <- length(ids)
  num_uni <- sum(!duplicated(ids) & !duplicated(ids, fromLast = TRUE))

  numeradores <- c(num_comp, num_val, num_uni)
  denominadores <- c(den_comp, den_val, den_uni)
  tibble::tibble(
    indicador = c("Completitud", "Validez", "Unicidad"),
    numerador = numeradores,
    denominador = denominadores,
    porcentaje = round(100 * ifelse(denominadores > 0,
                                   numeradores / denominadores, NA_real_), 2)
  )
}

construir_analisis <- function(hitos) {
  validar_hitos(hitos)
  # bind_rows() mantiene los indicadores de cada escenario en una tabla larga.
  indicadores_long <- dplyr::bind_rows(
    dplyr::mutate(hitos$indicadores_antes, escenario = "Original"),
    dplyr::mutate(hitos$indicadores_propuestos, escenario = "Propuesta")
  )
  if (any(duplicated(indicadores_long[c("indicador", "escenario")]))) {
    stop("Un mismo indicador aparece dos veces en un escenario")
  }
  if (any(indicadores_long$numerador > indicadores_long$denominador,
          na.rm = TRUE)) stop("Un numerador supera su denominador")
  # pivot_wider() convierte filas por escenario en columnas comparables.
  indicadores_ancho <- indicadores_long |>
    tidyr::pivot_wider(
      id_cols = "indicador", names_from = "escenario",
      values_from = c("numerador", "denominador", "porcentaje"),
      names_glue = "{.value}_{escenario}"
    ) |>
    dplyr::mutate(variacion_pp = porcentaje_Propuesta - porcentaje_Original)

  # Incidencias de los módulos 5.1 y 5.2: una fila por regla y severidad.
  incidencias <- dplyr::bind_rows(
    hitos$alertas_logicas |>
      dplyr::count(regla_id, severidad, name = "incidencias") |>
      dplyr::mutate(origen = "Consistencia lógica"),
    hitos$alertas_integridad |>
      dplyr::count(regla_id, severidad, name = "incidencias") |>
      dplyr::mutate(origen = "Integridad")
  ) |>
    dplyr::select(origen, regla_id, severidad, incidencias) |>
    dplyr::arrange(origen, regla_id)

  # Distinción: cantidad de eventos no equivale a cantidad de filas afectadas.
  filas_alertadas <- union(
    hitos$alertas_logicas$fila_csv, hitos$alertas_integridad$fila_csv
  )
  filas_alertadas <- unique(filas_alertadas[!is.na(filas_alertadas)])
  n_filas <- nrow(hitos$personas_raw)
  cobertura_alertas <- tibble::tibble(
    medida = c("Eventos de alerta", "Filas con al menos una alerta", "Filas del CSV"),
    total = c(nrow(hitos$alertas_logicas) + nrow(hitos$alertas_integridad),
              length(filas_alertadas), n_filas)
  )
  porcentaje_filas_alertadas <- if (n_filas > 0) round(100 * length(filas_alertadas) / n_filas, 2) else NA_real_

  requeridas <- c("id_persona", "id_hogar", "provincia", "edad",
                  "fecha_levantamiento", "personas_hogar")
  # vapply() devuelve un entero por columna de forma controlada.
  faltantes <- tibble::tibble(
    variable = requeridas,
    ausencias = vapply(requeridas, function(nm) {
      sum(is.na(normalizar_ausencia(hitos$personas_raw[[nm]])))
    }, integer(1)),
    evaluados = n_filas
  ) |>
    dplyr::mutate(porcentaje = round(100 * ausencias / evaluados, 2))

  # Resumen estadístico DESCRIPTIVO de campos numéricos. Se excluyen
  # formatos no convertibles y valores fuera de dominio didáctico para estas
  # estadísticas; permanecen intactos en los datos de origen y en alertas.
  # Los ingresos altos no se eliminan solo por ser atípicos.
  resumen_numericos <- dplyr::bind_rows(lapply(
    c("edad", "ingreso_mensual_usd"), function(campo) {
      texto <- normalizar_ausencia(hitos$personas_raw[[campo]])
      x <- suppressWarnings(as.numeric(texto))
      admitido <- !is.na(x) & x >= 0
      if (campo == "edad") admitido <- admitido & x <= 110 & x == floor(x)
      aceptados <- x[admitido]
      tibble::tibble(
        variable = campo,
        ausencias_declaradas = sum(is.na(texto)),
        no_convertibles = sum(!is.na(texto) & is.na(x)),
        fuera_dominio = sum(!is.na(x) & !admitido),
        validos_estadisticos = length(aceptados),
        ceros = sum(aceptados == 0),
        media = if (length(aceptados)) round(mean(aceptados), 2) else NA_real_,
        mediana = if (length(aceptados)) round(median(aceptados), 2) else NA_real_,
        q1 = if (length(aceptados)) round(as.numeric(quantile(aceptados, 0.25)), 2) else NA_real_,
        q3 = if (length(aceptados)) round(as.numeric(quantile(aceptados, 0.75)), 2) else NA_real_,
        maximo = if (length(aceptados)) max(aceptados) else NA_real_
      )
    }
  ))

  bitacora_resumen <- hitos$bitacora_propuesta |>
    dplyr::count(variable, estado, name = "cambios_propuestos") |>
    dplyr::arrange(dplyr::desc(cambios_propuestos))
  periodos <- hitos$personas_raw |>
    dplyr::count(periodo_referencia, name = "filas") |>
    dplyr::mutate(
      formato_aaaa_mm = !is.na(periodo_referencia) &
        grepl("^[0-9]{4}-(0[1-9]|1[0-2])$", periodo_referencia),
      interpretacion = ifelse(formato_aaaa_mm, "Formato esperado", "Revisar formato")
    )

  list(
    metadata = list(fecha_analisis = Sys.time(), n_registros = n_filas,
                    nota = "Simulación. Propuesta no autorizada.",
                    porcentaje_filas_alertadas = porcentaje_filas_alertadas),
    indicadores_long = indicadores_long,
    indicadores_ancho = indicadores_ancho,
    incidencias = incidencias,
    cobertura_alertas = cobertura_alertas,
    faltantes = faltantes,
    resumen_numericos = resumen_numericos,
    bitacora_resumen = bitacora_resumen,
    periodos = periodos
  )
}
