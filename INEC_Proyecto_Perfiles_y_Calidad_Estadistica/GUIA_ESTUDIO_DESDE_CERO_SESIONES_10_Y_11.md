# Guía de estudio desde cero: sesiones 10 y 11 (versión actualizada)

**Curso:** Evaluación de archivos de datos y automatización de reportes de calidad en R.  
**Duración:** dos sesiones de 2 horas.  
**Nivel:** básico predominante, desde nivel cero hasta nivel intermedio.  
**Caso:** encuesta socioeconómica **sintética** con 2.400 registros, 24 variables y períodos de octubre y noviembre de 2026.  
**Método:** escribir cada bloque, comprenderlo, generar RDS y elaborar un reporte Quarto por sesión.

> Los datos, perfiles y reglas son ejercicios didácticos. No representan estadísticas oficiales del INEC ni producen clasificaciones institucionales.

## ¿Qué cambia en esta versión?

La sesión **10 se conserva íntegra**: preparación, K-means, descripción de tres grupos y reporte `sesion_10_perfiles.qmd`. La sesión **11** ya no incluye clasificación ni árboles de decisión. Se centra en **estadística descriptiva y evaluación de calidad de los perfiles de la sesión 10**.

| Sesión | Pregunta que responde | Entregables |
|---|---|---|
| 10. Identificación de perfiles | ¿Qué registros tienen edades e ingresos similares? | `10_perfiles.rds`, dos gráficos, reporte HTML y Word |
| 11. Estadística de calidad de perfiles | ¿Cómo se diferencian los grupos y cuán completa es la información que los describe? | `11_calidad_perfiles.rds`, tablas, tres gráficos, reporte HTML y Word |

## Antes de empezar: palabras y símbolos para principiantes

| Término | Definición sencilla | Ejemplo |
|---|---|---|
| **Fila o registro** | Una encuesta completa representada como línea de una tabla. | Respuestas de una persona |
| **Columna o variable** | Una característica medida para cada registro. | `edad`, `zona`, `nivel_educacion` |
| **CSV** | Archivo de texto con una tabla. | `encuesta_socioeconomica_2026.csv` |
| **Script `.R`** | Instrucciones guardadas en un archivo, que R ejecuta en orden. | `11_01_estadistica_calidad_perfiles.R` |
| **Objeto** | Resultado que R guarda asociado con un nombre. | `datos`, `tabla`, `resumen` |
| **Función** | Operación preparada para realizar una tarea. | `mean()` obtiene el promedio |
| **Argumento** | Información que le entregamos a una función. | `mean(x, na.rm=TRUE)` |
| **Paquete** | Colección de funciones que se instala para ampliar R. | `dplyr`, `ggplot2` |
| **NA** | Dato no disponible o ausente. | No equivale a cero |
| **RDS** | Archivo que conserva los objetos de R para abrirlos después. | `10_perfiles.rds` |
| **QMD / Quarto** | Documento que reúne explicación, tablas, gráficos y código. | `sesion_11_calidad_perfiles.qmd` |

```r
# Guardar tres edades en un objeto
edades <- c(22, 28, 34)
# Obtener la media aritmética
mean(edades)  # Resultado: 28
```

`<-` significa «guardar en»; `$` selecciona una columna (`datos$edad`); `%>%` pasa el resultado a la siguiente operación; `==` compara igualdad; `&` significa «y»; `|` significa «o». `#` sirve para escribir comentarios explicativos que R ignora al ejecutar.

## Preparación del proyecto

1. Abra `encuesta_calidad.Rproj` en RStudio. No abra los scripts sin el proyecto.
2. Instale, solo si faltan, `here`, `readr`, `dplyr`, `ggplot2` y `knitr`.
3. Compruebe el archivo `data_raw/encuesta_socioeconomica_2026.csv`.
4. Cree resultados al ejecutar `00_configuracion.R`; nunca reemplace el CSV original.
5. Para generar HTML y Word, instale además Quarto CLI. El botón *Render* y la Terminal trabajan con Quarto; una instrucción de Terminal como `quarto render` no puede escribirse directamente en Console de R.

```r
install.packages(c("here", "readr", "dplyr", "ggplot2", "knitr"))
library(here)
file.exists(here::here("data_raw", "encuesta_socioeconomica_2026.csv"))
```

**Resultado esperado de la última línea:** `TRUE`. Si aparece `FALSE`, verifique que abrió el `.Rproj` correcto y que la carpeta `data_raw/` contiene el CSV.

---

# SESIÓN 10 — Identificación de patrones y perfiles

**Pregunta de partida:** ¿podemos reunir las respuestas de personas con edades e ingresos similares para describir sus características?

**Objetivo general:** aprender a identificar grupos exploratorios de registros y describirlos con tablas y gráficos, sin asignarles etiquetas oficiales.

**Plan sugerido de 120 minutos:** conceptos (20), preparación y revisión de datos (25), agrupamiento y gráficos (45), reporte Quarto (25), revisión final (5).

## 10.1. Conceptos antes de escribir código

| Concepto | Explicación para principiantes | Ejemplo sencillo |
|---|---|---|
| **Patrón** | Algo que aparece repetidamente. | Varias personas tienen edades e ingresos parecidos. |
| **Perfil** | Resumen de las características comunes de un grupo. | «Grupo con edad mediana de X e ingreso mediano de Y». |
| **Agrupamiento** | Reunir observaciones semejantes sin decir previamente qué grupo corresponde a cada una. | Unir registros cercanos en edad e ingreso. |
| **Distancia** | Forma matemática de medir qué tan diferentes son dos registros. | Edades 24 y 25 están más cerca que 24 y 60. |
| **K-means** | Algoritmo que forma `k` grupos alrededor de centros y busca reducir las distancias dentro de cada grupo. | Elegimos `k = 3` para aprender; no porque existan exactamente tres tipos de personas. |
| **Centroide** | Punto promedio que representa el centro de un grupo, calculado en las variables usadas. | Centro en edad e ingreso transformado, no una persona real. |
| **Estandarizar** | Poner variables con unidades diferentes en una escala comparable. | Edad en años e ingreso en dólares dejan de competir por magnitud. |
| **Transformación logarítmica** | Cambiar la escala para que diferencias enormes entre ingresos pesen menos en el análisis. | `log1p(0) = 0`; los ingresos grandes se comprimen. |
| **Media** | Suma de valores dividida por cantidad de valores. | Ingresos 100, 200, 900 → media 400. |
| **Mediana** | Valor central después de ordenar. | Ingresos 100, 200, 900 → mediana 200. |
| **Dato atípico** | Valor inusual respecto de los demás. | Un ingreso mucho mayor que el resto; no necesariamente un error. |

### Un ejemplo sin computadora

Considere cinco edades: `20`, `22`, `24`, `61`, `64`. Visualmente aparecen dos conjuntos cercanos. K-means hace algo parecido, pero utiliza las **variables numéricas seleccionadas**, compara distancias y actualiza los centros hasta estabilizar las asignaciones.

**Importante:** los grupos `1`, `2` y `3` son etiquetas arbitrarias. «Grupo 1» no significa «mayor pobreza», «mejor educación» ni «grupo prioritario». Para describirlos debemos mirar sus estadísticas reales.

### ¿Por qué necesitamos preparar los datos?

Imagine que una persona tiene `ingreso_mensual_usd = "USD 410"`. No es un número directo para R. Otra podría tener `-125.00` debido a una anomalía introducida para el taller. Antes de calcular distancias hay que documentar cómo tratamos esos casos, sin convertirlos silenciosamente en ingresos válidos.

## 10.2. Archivo previo: `R/00_configuracion.R`

Este archivo pertenece al taller original. **Funciona como una caja de herramientas compartida**: carga paquetes, prepara las carpetas y define funciones que después utilizan otros scripts. No produce los grupos; permite que los demás archivos trabajen de forma consistente.

### Fragmento A. Cargar herramientas y crear carpetas

```r
# ETAPA 0 — Configuración, conceptos y funciones comunes.
# Objetivo: preparar rutas y ayudas que se reutilizan sin modificar los CSV.
# Una sola vez, si faltan paquetes:
# install.packages(c('here','readr','dplyr','tidyr','ggplot2','knitr'))
suppressPackageStartupMessages({
  library(here)
  library(readr)
  library(dplyr)
  library(ggplot2)
})

for (carpeta in c('resultados', 'resultados/tablas', 'resultados/figuras')) {
  dir.create(here::here(carpeta), recursive = TRUE, showWarnings = FALSE)
}
```


**Lea el código así:** `library(here)` hace que R pueda usar sus rutas; `library(dplyr)` ofrece herramientas para filtrar y resumir; el `for` repite la creación de carpetas para cada ruta indicada. `recursive = TRUE` permite crear carpetas internas; `showWarnings = FALSE` evita mensajes si ya existen. `suppressPackageStartupMessages()` oculta mensajes de bienvenida, no oculta errores de ejecución.

**Comprobación:** examine el panel **Files**: deben existir `resultados/`, `resultados/tablas/` y `resultados/figuras/`.

### Fragmento B. Leer archivos CSV sin perder identificadores

```r
# Los identificadores y las categorías se importan inicialmente como texto.
leer_texto <- function(ruta) {
  if (!file.exists(ruta)) stop('Archivo no encontrado: ', ruta)
  readr::read_csv(ruta,
                  col_types = readr::cols(.default = readr::col_character()),
                  na = 'NA', trim_ws = FALSE, show_col_types = FALSE)
}
```


**Concepto:** leer como texto evita que un identificador o código, por ejemplo `000123`, pierda sus ceros iniciales. `function(ruta)` define una herramienta propia que recibe una ruta; `if` comprueba que exista; `stop()` detiene el proceso si falta. `read_csv()` importa el archivo; `col_character()` indica «leer inicialmente como texto»; `na = "NA"` identifica ese marcador de ausencia; `trim_ws = FALSE` conserva espacios para poder auditarlos.

**Para probarla:** `leer_texto(here::here("data_raw", "encuesta_socioeconomica_2026.csv"))` devolverá una tabla con los valores todavía en texto.

### Fragmento C. Distinguir ausencias y convertir columnas auxiliares

```r
# NA, blanco y los marcadores didácticos son ausencia; cero NO es ausencia.
normalizar_ausencia <- function(x) {
  y <- trimws(as.character(x))
  y[!is.na(y) & toupper(y) %in% c('', 'NA', 'N/D', 'SIN DATO')] <- NA_character_
  y
}

# Convierte texto a número solo en una columna DERIVADA; no toca la fuente.
a_numero <- function(x) suppressWarnings(as.numeric(normalizar_ausencia(x)))
```


- `normalizar_ausencia(x)` toma los valores, quita espacios exteriores con `trimws()` y considera ausencias a `""`, `"NA"`, `"N/D"`, `"SIN DATO"`.
- `toupper()` sirve para comparar textos sin depender de mayúsculas/minúsculas.
- `NA_character_` significa «valor ausente de tipo texto».
- `a_numero(x)` primero normaliza ausencias y después convierte a número con `as.numeric()`; `suppressWarnings()` evita mensajes por caracteres no interpretables. **Ese caso debe detectarse durante la validación**, no tratarse automáticamente como correcto.
- La conversión se aplicará a nuevas columnas como `edad_n`, **no al CSV de origen**.

**Prueba simple:** `a_numero(c("100", "0", "NA", "USD 410"))` devuelve `100`, `0`, `NA`, `NA`. Observe que **cero no se transforma en ausencia**.

### Fragmento D. Función común de alertas (reutilizable, no central en estas sesiones)

```r
# Para registrar alertas, los índices se calculan ANTES de crear el tibble.
# Así se evita el conflicto de nombres con una columna llamada 'variable'.
crear_alerta <- function(tabla, condicion, regla_id, columna_origen,
                        descripcion, severidad = 'REVISAR') {
  if (!columna_origen %in% names(tabla)) stop('No existe: ', columna_origen)
  if (length(condicion) != nrow(tabla)) stop('Condición con longitud incorrecta')
  idx <- which(!is.na(condicion) & condicion)
  valores <- as.character(tabla[[columna_origen]][idx])
  tibble::tibble(
    fila_csv = tabla$fila_csv[idx],
    id_encuesta = tabla$id_encuesta[idx],
    id_persona = tabla$id_persona[idx],
    periodo_referencia = tabla$periodo_referencia[idx],
    regla_id = rep(regla_id, length(idx)),
    variable = rep(columna_origen, length(idx)),
    valor_observado = valores,
    severidad = rep(severidad, length(idx)),
    descripcion = rep(descripcion, length(idx))
  )
}

message('Etapa 0: configuración disponible. Trabaje en el proyecto .Rproj.')
```


`crear_alerta()` transforma una condición lógica por registro en una tabla de incidencias. `which()` localiza las filas donde se cumple la condición; `length()` cuenta los índices; `tabla[[columna_origen]]` obtiene la columna cuyo nombre se recibió como argumento; `tibble()` arma la tabla final. Los valores se extraen **antes** de crear una columna llamada `variable`, para evitar el conflicto que puede causar el error `Subscript variable must be size 1, not 0`.

**No hace falta memorizar esta función para K-means ni árboles**; está disponible para continuar los controles de calidad del curso.

## 10.3. Archivo `R/10_00_preparar_datos_perfiles.R`

**Meta:** convertir la información necesaria en columnas auxiliares claras y guardar un **RDS de preparación**. El CSV no se modifica.

**Entrada:** `resultados/01_datos.rds`, si ya existe con `personas_raw`; de lo contrario se lee `data_raw/encuesta_socioeconomica_2026.csv`.  
**Salidas:** `resultados/10_datos_preparados.rds` y `resultados/tablas/10_diagnostico.csv`.

**Importante:** si existe un RDS anterior, el script lo utiliza. Si quiere obligatoriamente usar el CSV como fuente, retire o renombre temporalmente el RDS previo, en vez de editarlo sin documentarlo.

### Primera instrucción: reutilizar la configuración

```r
source(here::here("R", "00_configuracion.R"))
```


`source()` abre otro script R y ejecuta su contenido. Por eso el archivo `00_configuracion.R` debe estar en la carpeta `R/`. `here::here()` evita escribir una ruta específica de Windows.

### Paso 1. Recuperar los datos

**Qué vamos a conseguir:** Trabajar con una fuente real del proyecto, sin copiar archivos manualmente.

```r
# 1. Reutilizar el punto de control de los modulos originales cuando exista.
ruta_previa <- here::here("resultados", "01_datos.rds")
if (file.exists(ruta_previa)) {
  paquete_previo <- readRDS(ruta_previa)
  if (!"personas_raw" %in% names(paquete_previo)) {
    stop("El RDS previo no contiene 'personas_raw'. Revise el archivo.")
  }
  fuente <- paquete_previo$personas_raw
  procedencia <- "RDS del modulo 1"
} else {
  fuente <- leer_texto(here::here("data_raw", "encuesta_socioeconomica_2026.csv"))
  procedencia <- "CSV original leido como texto"
}
```

**Explicación del fragmento, en lenguaje sencillo:** `here::here()` construye la ruta; `file.exists()` pregunta si el archivo está disponible. `readRDS()` recupera un objeto guardado previamente. Si el RDS ya existe, el script verifica que contenga `personas_raw`; si no existe, `leer_texto()` utiliza el CSV. La variable `procedencia` documenta qué fuente se usó. **Qué revisar:** el nombre del archivo y si el mensaje de procedencia coincide con lo esperado.

**Mini comprobación:** Abra el RDS si existe y confirme el nombre de la fuente.

### Paso 2. Verificar que existan las columnas

**Qué vamos a conseguir:** Evitar análisis con columnas inexistentes.

```r
# 2. Asegurar que usamos el mismo esquema de la encuesta del taller.
columnas <- c("id_encuesta", "id_persona", "periodo_referencia", "edad",
              "ingreso_mensual_usd", "zona", "nivel_educacion", "acceso_internet")
faltan <- setdiff(columnas, names(fuente))
if (length(faltan) > 0) stop("Columnas ausentes: ", paste(faltan, collapse = ", "))
```

**Explicación del fragmento, en lenguaje sencillo:** `c()` forma una lista de nombres obligatorios. `names(fuente)` obtiene los nombres actuales de columnas. `setdiff(columnas, names(fuente))` encuentra las columnas requeridas que faltan. Si falta alguna, `stop()` impide continuar, porque un análisis con variables ausentes no sería confiable. **Compruebe** que el diagnóstico inicial muestra las columnas esperadas.

**Mini comprobación:** Use `names(fuente)` para revisar las columnas.

### Paso 3. Crear columnas auxiliares

**Qué vamos a conseguir:** Dejar los valores útiles listos para cálculos, sin alterar los originales.

```r
# 3. Convertir SOLO columnas auxiliares: conservar intactas las originales.
# normalizar_ausencia() y a_numero() proceden de 00_configuracion.R.
datos <- fuente %>%
  dplyr::mutate(
    fila_csv = dplyr::row_number() + 1L,
    edad_n = a_numero(edad),
    ingreso_n = a_numero(ingreso_mensual_usd),
    zona_limpia = normalizar_ausencia(zona),
    educacion_limpia = normalizar_ausencia(nivel_educacion),
    acceso_limpio = normalizar_ausencia(acceso_internet),
    zona_norm = dplyr::case_when(
      toupper(zona_limpia) == "URBANA" ~ "Urbana",
      toupper(zona_limpia) == "RURAL" ~ "Rural",
      TRUE ~ NA_character_
    ),
    educacion_norm = dplyr::case_when(
      toupper(educacion_limpia) == "SIN INSTRUCCION" ~ "Sin instruccion",
      toupper(educacion_limpia) == "PRIMARIA" ~ "Primaria",
      toupper(educacion_limpia) == "SECUNDARIA" ~ "Secundaria",
      toupper(educacion_limpia) == "SUPERIOR" ~ "Superior",
      toupper(educacion_limpia) == "POSGRADO" ~ "Posgrado",
      TRUE ~ NA_character_
    ),
    acceso_norm = dplyr::case_when(
      toupper(acceso_limpio) == "SI" ~ "Si",
      toupper(acceso_limpio) == "NO" ~ "No",
      TRUE ~ NA_character_
    )
  )
```

**Explicación del fragmento, en lenguaje sencillo:** Este es el paso más largo, pero hace algo sencillo: **crea versiones auxiliares interpretables**. `mutate()` agrega columnas, `row_number()` asigna una posición de referencia, `a_numero()` convierte edad e ingreso y `normalizar_ausencia()` distingue textos vacíos. `case_when()` equivale a una serie de decisiones: «si ocurre esto, escriba aquello». `toupper()` permite reconocer `URBANA` y `Urbana` como la misma zona. Los valores que no encajan reciben `NA_character_` para que se revisen. **No se pierde** la columna original.

**Mini comprobación:** Ejecute `head(datos[, c("edad", "edad_n", "zona", "zona_norm")])`.

### Paso 4. Definir qué registros son aptos

**Qué vamos a conseguir:** Marcar qué filas pueden entrar en el agrupamiento.

```r
# 4. La edad y el ingreso deben ser numericOS plausibles para la practica.
# Rango de edad 18–110: criterio DIDACTICO, NO regla oficial.
# 0 USD es ingreso valido. Los ingresos negativos NO se imputan ni borran.
datos <- datos %>%
  dplyr::mutate(
    edad_valida = !is.na(edad_n) & edad_n >= 18 & edad_n <= 110,
    ingreso_valido = !is.na(ingreso_n) & ingreso_n >= 0,
    apto_agrupamiento = edad_valida & ingreso_valido
  )
```

**Explicación del fragmento, en lenguaje sencillo:** Una regla lógica con `&` exige que ambas condiciones sean verdaderas. `!is.na(edad_n)` significa «hay edad disponible»; `edad_n >= 18 & edad_n <= 110` define el intervalo **solo para este ejercicio**. `ingreso_n >= 0` admite cero, pero no negativos. `apto_agrupamiento` marca si el registro puede entrar en K-means. **Una fila no apta sigue existiendo en la base**, solo queda fuera de este modelo.

**Mini comprobación:** Ejecute `table(datos$apto_agrupamiento)`.

### Paso 5. Transformar los ingresos

**Qué vamos a conseguir:** Reducir la influencia de ingresos muy altos en el cálculo de distancia.

```r
# 5. log1p(x) equivale a log(1+x). Reduce la asimetria y admite ingreso cero.
# Solo calculamos logaritmo en posiciones con ingreso numerico no negativo.
datos$ingreso_log <- NA_real_
pos_validas <- which(datos$ingreso_valido)
datos$ingreso_log[pos_validas] <- log1p(datos$ingreso_n[pos_validas])
```

**Explicación del fragmento, en lenguaje sencillo:** `log1p(x)` calcula el logaritmo natural de `(1 + x)` y permite usar el ingreso cero. Se aplica únicamente a ingresos válidos. `which()` encuentra las posiciones aptas; el uso de corchetes `[]` coloca resultados solo en ellas. ¿Por qué? Para que un valor muy alto no domine tanto el agrupamiento. **La tabla original de ingresos sigue en dólares**; el logaritmo solo ayuda en el cálculo de semejanza.

**Mini comprobación:** Compare `head(datos$ingreso_n)` y `head(datos$ingreso_log)`.

### Paso 6. Contar los registros incluidos y excluidos

**Qué vamos a conseguir:** Mostrar cuántos registros pueden utilizarse y por qué.

```r
# 6. Cuantificar filas admisibles/excluidas: no esconder el denominador.
diagnostico <- tibble::tibble(
  registros_totales = nrow(datos),
  edad_invalida_o_ausente = sum(!datos$edad_valida),
  ingreso_invalido_o_ausente = sum(!datos$ingreso_valido),
  registros_aptos = sum(datos$apto_agrupamiento),
  registros_excluidos = sum(!datos$apto_agrupamiento)
)
print(diagnostico)
```

**Explicación del fragmento, en lenguaje sencillo:** `tibble()` construye una tabla-resumen. `nrow(datos)` cuenta filas. Como R interpreta `TRUE` como 1 y `FALSE` como 0 al usar `sum()`, `sum(datos$apto_agrupamiento)` cuenta registros aptos. La tabla muestra, entre otros valores, cuántos registros fueron excluidos. **No interprete una exclusión como una corrección**. Las causas pueden superponerse, por lo que sumar los conteos de edad e ingreso inválidos puede contar una fila dos veces.

**Mini comprobación:** Compare `diagnostico$registros_totales` con la suma de aptos y excluidos.

### Paso 7. Guardar el RDS de preparación

**Qué vamos a conseguir:** Guardar el avance para usarlo aunque se cierre RStudio.

```r
# 7. Guardar RDS para recuperar datos tipados sin depender del Environment.
ruta_rds <- here::here("resultados", "10_datos_preparados.rds")
saveRDS(list(datos = datos, diagnostico = diagnostico,
             procedencia = procedencia, fecha = as.character(Sys.Date())),
        ruta_rds)
readr::write_csv(diagnostico, here::here("resultados", "tablas", "10_diagnostico.csv"))
stopifnot(file.exists(ruta_rds))
message("Sesión 10, preparación lista: ", ruta_rds)
```

**Explicación del fragmento, en lenguaje sencillo:** `list()` reúne datos, diagnóstico y procedencia. `saveRDS()` los guarda sin perder los tipos. `write_csv()` exporta una tabla simple para revisar en Excel. `stopifnot()` detiene el proceso si el archivo no existe; `message()` informa la ruta al terminar. **Archivo esperado:** `resultados/10_datos_preparados.rds`. Piense en él como una caja cerrada que recuperaremos en el siguiente script.

**Mini comprobación:** Ejecute `file.exists(here::here("resultados", "10_datos_preparados.rds"))`.

## 10.4. Archivo `R/10_01_identificar_perfiles.R`

**Meta:** construir grupos exploratorios y guardar las tablas, gráficos y el modelo.  
**Entrada:** `resultados/10_datos_preparados.rds`.  
**Salidas:** `resultados/10_perfiles.rds`, tablas CSV y dos figuras PNG.

**Frase sencilla:** «Tomamos registros válidos, los agrupamos por similitud de edad e ingreso y describimos cómo son los grupos».

### Paso 1. Leer el RDS anterior

```r
# 1. Recuperar exactamente los datos ya preparados.
ruta_entrada <- here::here("resultados", "10_datos_preparados.rds")
if (!file.exists(ruta_entrada)) stop("Primero ejecute R/10_00_preparar_datos_perfiles.R")
preparacion <- readRDS(ruta_entrada)
datos <- preparacion$datos
```

**¿Qué hace este fragmento?** `readRDS()` abre lo que guardó el script anterior. El objeto `preparacion` es una lista; `preparacion$datos` accede a la tabla preparada. Si falta el archivo, el programa se detiene con una instrucción clara de qué etapa completar antes.

**Pregunta de lectura:** ¿De qué archivo salieron los datos?

### Paso 2. Elegir registros aptos

```r
# 2. Seleccionar solo edades e ingresos validos. No corregimos la fuente.
muestra <- datos %>% dplyr::filter(apto_agrupamiento)
if (nrow(muestra) < 3) stop("No hay suficientes observaciones para tres grupos")
```

**¿Qué hace este fragmento?** `filter(apto_agrupamiento)` conserva únicamente las filas con edad e ingreso válidos para esta práctica. `nrow()` cuenta las filas resultantes. El `if` evita intentar tres grupos cuando hay menos de tres registros. **No borra ninguna fila del CSV**.

**Pregunta de lectura:** ¿Una fila excluida desaparece del CSV?

### Paso 3. Estandarizar variables

```r
# 3. scale() centra por media y divide por desviacion estandar cada variable.
# Sin ello, una variable con unidades mayores dominaria la distancia euclidiana.
matriz <- as.matrix(muestra[, c("edad_n", "ingreso_log")])
matriz_z <- scale(matriz)
if (anyNA(matriz_z)) stop("No es posible estandarizar: revise las variables")
```

**¿Qué hace este fragmento?** `as.matrix()` convierte dos columnas numéricas en una matriz, formato que necesita el algoritmo. `scale()` transforma cada columna para que tenga una escala comparable: resta el promedio y divide por su desviación estándar. `anyNA()` detecta si la estandarización dejó valores ausentes. **Nota:** se utiliza ingreso transformado (`ingreso_log`), no dólares originales, para definir distancias.

**Pregunta de lectura:** ¿Qué ocurriría si usáramos dólares sin estandarizar?

### Paso 4. Formar tres grupos

```r
# 4. Fijar semilla para reproducibilidad; nstart prueba varios centros iniciales.
set.seed(2026)
modelo <- stats::kmeans(matriz_z, centers = 3, nstart = 25, iter.max = 100)
```

**¿Qué hace este fragmento?** `set.seed(2026)` establece una semilla para obtener resultados reproducibles. `kmeans(..., centers = 3)` solicita tres grupos. `nstart = 25` prueba 25 inicios distintos para buscar una solución mejor; `iter.max = 100` limita iteraciones de cada intento. **No significa** que haya exactamente tres perfiles naturales en la realidad: `3` es una elección docente.

**Pregunta de lectura:** ¿Por qué fijamos una semilla?

### Paso 5. Añadir la etiqueta de grupo

```r
# 5. Asignar etiqueta neutral a cada observacion.
# Los numeros de grupo son ARBITRARIOS; no son niveles de pobreza.
muestra$grupo <- factor(paste0("Grupo ", modelo$cluster),
                       levels = paste0("Grupo ", 1:3))
```

**¿Qué hace este fragmento?** `modelo$cluster` guarda para cada fila el número de grupo asignado. `paste0("Grupo ", ...)` construye etiquetas legibles, como `Grupo 2`. `factor()` identifica una variable categórica y define el orden de los niveles. **Importante:** los números de los grupos no representan una clasificación de riqueza o pobreza.

**Pregunta de lectura:** ¿"Grupo 1" significa "más pobre"?

### Paso 6. Resumir perfiles con promedios y porcentajes

```r
# 6. Construir perfiles descriptivos por grupo.
perfiles <- muestra %>%
  dplyr::group_by(grupo) %>%
  dplyr::summarise(
    personas = dplyr::n(),
    edad_media = round(mean(edad_n), 1),
    edad_mediana = round(median(edad_n), 1),
    ingreso_medio = round(mean(ingreso_n), 2),
    ingreso_mediano = round(median(ingreso_n), 2),
    .groups = "drop"
  ) %>%
  dplyr::mutate(pct_muestra = round(100 * personas / sum(personas), 1))

zonas <- muestra %>% dplyr::count(grupo, zona_norm, name = "n") %>%
  dplyr::group_by(grupo) %>%
  dplyr::mutate(pct_grupo = round(100 * n / sum(n), 1)) %>%
  dplyr::ungroup()

educacion <- muestra %>% dplyr::count(grupo, educacion_norm, name = "n") %>%
  dplyr::group_by(grupo) %>%
  dplyr::mutate(pct_grupo = round(100 * n / sum(n), 1)) %>%
  dplyr::ungroup()

print(perfiles)
```

**¿Qué hace este fragmento?** `group_by(grupo)` organiza temporalmente los datos por grupo. `summarise()` calcula una fila de resumen por grupo: `n()` cuenta personas, `mean()` obtiene la media, `median()` obtiene el centro ordenado y `round()` limita decimales. `count(grupo, zona_norm)` obtiene frecuencias; `mutate()` añade porcentajes; `ungroup()` elimina la agrupación temporal. `pct_muestra` divide por toda la muestra, mientras que `pct_grupo` usa como denominador el tamaño de **cada** grupo.

**Pregunta de lectura:** ¿Cuál es la diferencia entre media y mediana?

### Paso 7. Dibujar los gráficos

```r
# 7. Graficos: una figura de edades e ingresos y otra de educacion por grupo.
figura_perfiles <- ggplot2::ggplot(
    muestra, ggplot2::aes(x = edad_n, y = ingreso_n, color = grupo)) +
  ggplot2::geom_point(alpha = 0.5, size = 1.5) +
  ggplot2::labs(title = "Perfiles exploratorios: edad e ingreso",
                subtitle = "Grupos calculados con edad estandarizada y log(1 + ingreso)",
                x = "Edad (años)", y = "Ingreso mensual (USD)", color = "Grupo") +
  ggplot2::theme_minimal()

figura_educacion <- ggplot2::ggplot(
    educacion, ggplot2::aes(x = grupo, y = pct_grupo, fill = educacion_norm)) +
  ggplot2::geom_col() +
  ggplot2::labs(title = "Composición educativa de los grupos",
                x = "Grupo", y = "Porcentaje dentro del grupo", fill = "Nivel") +
  ggplot2::theme_minimal()

ggplot2::ggsave(here::here("resultados", "figuras", "10_perfiles.png"),
                figura_perfiles, width = 9, height = 5.5, dpi = 160)
ggplot2::ggsave(here::here("resultados", "figuras", "10_educacion_por_grupo.png"),
                figura_educacion, width = 9, height = 5.5, dpi = 160)
```

**¿Qué hace este fragmento?** `ggplot()` inicia un gráfico; `aes()` indica qué columnas van en los ejes y en el color; `geom_point()` dibuja un punto por registro; `geom_col()` crea barras con porcentajes ya calculados. `labs()` escribe títulos y nombres de ejes; `theme_minimal()` usa un diseño sencillo; `ggsave()` guarda archivos PNG. **Para interpretar el gráfico:** no confunda un color de grupo con una categoría oficial.

**Pregunta de lectura:** ¿Qué relación debe haber entre barras y tabla de porcentajes?

### Paso 8. Guardar los resultados

```r
# 8. Guardar tablas, el modelo y los datos en formato nativo RDS.
paquete <- list(
  metadatos = list(titulo = "Identificacion de perfiles — encuesta ficticia",
                   fecha = as.character(Sys.Date()),
                   centros = 3, observaciones = nrow(muestra),
                   advertencia = "No es una clasificacion oficial ni inferencia poblacional"),
  diagnostico = preparacion$diagnostico,
  datos_preparados = datos,
  datos_agrupados = muestra,
  modelo = modelo,
  tablas = list(perfiles = perfiles, zonas = zonas, educacion = educacion),
  figuras = c("resultados/figuras/10_perfiles.png",
              "resultados/figuras/10_educacion_por_grupo.png")
)
archivo <- here::here("resultados", "10_perfiles.rds")
saveRDS(paquete, archivo, compress = "gzip")
readr::write_csv(perfiles, here::here("resultados", "tablas", "10_perfiles.csv"))
readr::write_csv(zonas, here::here("resultados", "tablas", "10_zonas_perfiles.csv"))
readr::write_csv(educacion, here::here("resultados", "tablas", "10_educacion_perfiles.csv"))
stopifnot(nrow(readRDS(archivo)$tablas$perfiles) == 3)
message("Sesion 10: reporte listo para renderizar usando ", archivo)
```

**¿Qué hace este fragmento?** `list()` reúne modelo, tablas, metadatos y datos de referencia en un solo objeto. `saveRDS()` crea el archivo que leerá Quarto. `write_csv()` permite revisar las tablas también fuera de R. `stopifnot()` comprueba que existan tres filas de perfiles. **Qué revisar:** `resultados/10_perfiles.rds` y los PNG. Sin estos productos el informe Quarto no tendrá contenido.

**Pregunta de lectura:** ¿Cuál es el archivo RDS que leerá Quarto?

## 10.5. Primer informe Quarto: `reportes/sesion_10_perfiles.qmd`

**Qué es un `.qmd`:** es un documento que contiene secciones escritas, pequeños bloques R y configuración. Quarto combina esas partes para generar un archivo que se pueda leer en el navegador (HTML) o editar en Word (DOCX).

### A. El encabezado YAML

```yaml
title: "Sesión 10 | Identificación de patrones y perfiles"
subtitle: "Encuesta socioeconómica sintética — ejercicio exploratorio en R"
author: "Participante de la capacitación"
lang: es
format:
  html:
    toc: true
    code-fold: true
    embed-resources: true
  docx:
    toc: true
execute:
  echo: false
  warning: false
  message: false
```


- `title` y `subtitle`: texto de la portada.
- `author`: persona responsable; puede cambiarla por el nombre del participante.
- `lang: es`: idioma en español.
- `html` y `docx`: formatos de salida; `toc: true` activa el índice.
- `embed-resources: true`: facilita un HTML con recursos incorporados.
- `execute: echo: false`: ejecuta el código, pero no imprime las instrucciones R en el informe final.

### B. Las secciones del documento

| Apartado del QMD | Explicación | De dónde sale su contenido |
|---|---|---|
| 1. Introducción | Cuenta qué pregunta quiere responder el estudio. | Texto escrito por el estudiante. |
| 2. Objetivo | Indica para qué se agrupan las respuestas. | Texto metodológico. |
| 3. Metodología | Explica edad, ingreso, exclusiones, logaritmo y K-means. | Script 10_00 y 10_01. |
| 4. Perfiles | Incluye una tabla de tamaño, edad e ingreso por grupo. | `paquete$tablas$perfiles`. |
| 5. Distribución | Muestra un diagrama de puntos. | `resultados/figuras/10_perfiles.png`. |
| 6. Zona y educación | Compara la composición de los grupos. | Tabla y PNG preparados. |
| 7. Conclusiones | Describe hallazgos, sin declarar causalidad. | Lectura responsable de las tablas. |
| 8–9. Limitaciones y evidencias | Aclara qué no representa el modelo y cuándo fue generado. | Metadatos del RDS. |

### C. Bloque Quarto 1: `cargar-resultados`

````qmd
```{r}
#| label: cargar-resultados
# 1. El QMD solo LEE el RDS generado por el script 10_01.
# 2. No requiere objetos previos abiertos en la consola de RStudio.
if (!requireNamespace("here", quietly = TRUE) ||
    !requireNamespace("knitr", quietly = TRUE)) {
  stop("Instale here y knitr antes de renderizar")
}
ruta <- here::here("resultados", "10_perfiles.rds")
if (!file.exists(ruta)) stop("Falta resultados/10_perfiles.rds. Ejecute los scripts 10_00 y 10_01")
paquete <- readRDS(ruta)
```
````

**Explicación:** `requireNamespace()` comprueba si están instalados `here` y `knitr`. `readRDS()` abre el resultado de la sesión 10. **Por eso el reporte no depende de objetos abiertos en Environment.**

### C. Bloque Quarto 2: `tbl-cobertura`

````qmd
```{r}
#| label: tbl-cobertura
knitr::kable(paquete$diagnostico,
             caption = "Registros disponibles y excluidos del agrupamiento")
```
````

**Explicación:** `knitr::kable()` transforma el `diagnostico` en una tabla legible; permite explicar cuántos registros se excluyeron, sin ocultar el denominador.

### C. Bloque Quarto 3: `tbl-perfiles`

````qmd
```{r}
#| label: tbl-perfiles
knitr::kable(paquete$tablas$perfiles,
             caption = "Características descriptivas de cada grupo",
             digits = 1)
```
````

**Explicación:** `kable(paquete$tablas$perfiles)` muestra la tabla de grupos. `digits = 1` establece la presentación de decimales en la tabla.

### C. Bloque Quarto 4: `fig-perfiles`

````qmd
```{r}
#| label: fig-perfiles
#| fig-cap: "Distribución por edad e ingreso; cada punto corresponde a un registro sintético."
#| out-width: "100%"
knitr::include_graphics(here::here("resultados", "figuras", "10_perfiles.png"))
```
````

**Explicación:** `knitr::include_graphics()` inserta el PNG ya generado. `fig-cap` escribe el pie de figura y `out-width` controla su tamaño visual.

### C. Bloque Quarto 5: `tbl-zonas`

````qmd
```{r}
#| label: tbl-zonas
knitr::kable(paquete$tablas$zonas,
             caption = "Composición de los grupos por zona")
```
````

**Explicación:** `kable()` presenta la tabla cruzada por grupo y zona. Los porcentajes deben interpretarse dentro de su denominador.

### C. Bloque Quarto 6: `fig-educacion`

````qmd
```{r}
#| label: fig-educacion
#| fig-cap: "Distribución porcentual de educación en cada grupo."
#| out-width: "100%"
knitr::include_graphics(here::here("resultados", "figuras", "10_educacion_por_grupo.png"))
```
````

**Explicación:** `include_graphics()` inserta la imagen de composición educativa por grupo. Compruebe que se creó antes de renderizar.

### C. Bloque Quarto 7: `comentarios-automaticos-perfiles`

````qmd
```{r}
#| label: comentarios-automaticos-perfiles
#| results: asis
# Comentar resultados a partir de las tablas, sin escribir cifras manuales.
p <- paquete$tablas$perfiles
mas_numeroso <- p[which.max(p$personas), ]
mayor_mediana <- p[which.max(p$ingreso_mediano), ]
cat(sprintf("- El grupo con más observaciones es **%s**, con **%s registros**.\n",
            mas_numeroso$grupo, mas_numeroso$personas))
cat(sprintf("- La mayor mediana de ingreso corresponde a **%s** (USD %.2f).\n",
            mayor_mediana$grupo, mayor_mediana$ingreso_mediano))
cat(sprintf("- El análisis incluyó **%s de %s registros**; las exclusiones se documentaron en la metodología.\n",
            paquete$metadatos$observaciones,
            paquete$diagnostico$registros_totales))
```
````

**Explicación:** `which.max()` localiza el grupo con más registros o mayor mediana de ingreso; `sprintf()` da formato a los números; `cat()` escribe frases automáticas. El participante debe **revisar** esas frases y agregar interpretación contextual.

### C. Bloque Quarto 8: `tbl-procedencia`

````qmd
```{r}
#| label: tbl-procedencia
cat("Fecha de generación: ", paquete$metadatos$fecha, "\n\n")
cat("Registros analizados: ", paquete$metadatos$observaciones, "\n\n")
cat("Cantidad de grupos: ", paquete$metadatos$centros, "\n")
```
````

**Explicación:** `cat()` muestra fecha, número de observaciones y grupos guardados en el RDS: evidencia para reproducibilidad.

## 10.6. Archivo `R/10_02_renderizar_reporte.R`

**Meta:** convertir el QMD anterior en documentos. **Renderizar** significa procesar el documento y producir un archivo terminado.

```r
# =============================================================================
# SESION 10 — SCRIPT 10_02: RENDERIZAR EL REPORTE EN HTML Y WORD
# Ejecutar desde la consola R, NO escribir 'quarto render' sin system2().
# =============================================================================
source(here::here("R", "00_configuracion.R"))
rds <- here::here("resultados", "10_perfiles.rds")
qmd <- here::here("reportes", "sesion_10_perfiles.qmd")
if (!file.exists(rds)) stop("Primero ejecute R/10_01_identificar_perfiles.R")
if (!file.exists(qmd)) stop("No se encuentra reportes/sesion_10_perfiles.qmd")
cli <- Sys.which("quarto")
if (!nzchar(cli)) stop("Quarto CLI no disponible. Instale Quarto y compruebe 'quarto --version' en Terminal.")

# Por defecto genera ambos formatos. Cambie a c('html') para solo HTML.
formatos <- c("html", "docx")
for (formato in formatos) {
  message("Generando reporte de sesion 10 en: ", formato)
  estado <- system2(cli, args = c("render", shQuote(qmd), "--to", formato))
  if (!identical(as.integer(estado), 0L)) stop("Quarto devolvio un error: ", formato)
  salida <- sub("\\.qmd$", paste0(".", formato), qmd)
  if (!file.exists(salida)) stop("No se genero el archivo esperado: ", salida)
  message("Generado: ", salida)
}
```


**Lea el programa en este orden:**

1. `source(...)` carga la configuración común.
2. `rds <- ...` y `qmd <- ...` indican dónde están los resultados y el documento fuente.
3. `file.exists()` detiene el proceso si falta una entrada.
4. `Sys.which("quarto")` localiza el programa Quarto instalado.
5. `formatos <- c("html", "docx")` define los formatos solicitados; para empezar, puede usar `c("html")`.
6. `for (formato in formatos)` repite el renderizado una vez para cada formato.
7. `system2()` llama a Quarto desde R (como si escribiera el comando en una Terminal).
8. Se revisa el código de salida `0`, que normalmente significa ejecución exitosa, y la existencia del archivo generado.

**Cómo ejecutarlo desde la Console de RStudio:**

```r
source(here::here("R", "10_02_renderizar_reporte.R"))
```

**Cómo ejecutarlo desde la pestaña Terminal, alternativamente:**

```bash
quarto render reportes/sesion_10_perfiles.qmd --to html
```

No escriba `quarto render ...` sin comillas directamente en **Console**, ya que R lo interpreta como código R y muestra `Error: unexpected symbol`.

### Lista de verificación de la sesión 10

- [ ] Se creó `resultados/10_datos_preparados.rds`.
- [ ] Se creó `resultados/10_perfiles.rds`.
- [ ] Existen `resultados/figuras/10_perfiles.png` y `10_educacion_por_grupo.png`.
- [ ] Se generó `reportes/sesion_10_perfiles.html`.
- [ ] El informe contiene introducción, objetivo, metodología, tabla, gráficos, interpretación y limitaciones.
- [ ] El estudiante redactó tres observaciones propias, sin atribuir validez oficial a los grupos.

**Ejercicio básico:** observe la tabla de perfiles e indique qué grupo tiene la edad mediana más alta, cuál tiene el ingreso mediano más alto y si son el mismo. **Reto intermedio:** explique por qué K-means puede cambiar si no se estandarizan variables.

---


# SESIÓN 11 — Análisis estadístico de la calidad y variabilidad de perfiles

## 11.1. ¿Por qué necesitamos esta sesión?

En la sesión 10 construimos tres grupos de encuestas según edades e ingresos parecidos. La siguiente pregunta no es predecir quién pertenece a un grupo: **ya conocemos su grupo**. Ahora queremos analizar la información que lo describe.

Por ejemplo, dos grupos pueden tener una mediana de ingreso similar, pero uno puede tener ingresos bastante parecidos entre sí y el otro ingresos muy diferentes. Del mismo modo, podemos tener un grupo con información educativa más completa que otro. Esta distinción es útil para interpretar tablas sin confundir una observación poco común con un error.

**Objetivo general:** evaluar tamaño, medidas centrales, dispersión, completitud y posibles valores atípicos dentro de los perfiles ya construidos, y elaborar un informe descriptivo reproducible.

**Resultado esperado:** un RDS `11_calidad_perfiles.rds`, tablas CSV, tres imágenes PNG y reportes HTML/Word.

## 11.2. Conceptos estadísticos con ejemplos fáciles

### A. Frecuencia y porcentaje

- **Frecuencia:** cuántas personas pertenecen a una categoría o grupo.
- **Porcentaje:** qué parte representan respecto de un total identificado.

**Ejemplo inventado:** si se agruparon 100 encuestas y 40 pertenecen al grupo A, el porcentaje del grupo A es `40 / 100 × 100 = 40 %`. El denominador son las encuestas **agrupadas**, no necesariamente todos los registros del archivo inicial.

### B. Media y mediana

- **Media:** suma de valores dividida para la cantidad de valores. Ejemplo: `(100 + 200 + 900) / 3 = 400`.
- **Mediana:** valor que queda en medio cuando ordenamos los datos. Para `100, 200, 900`, la mediana es `200`.

Por tanto, un valor especialmente alto puede elevar la media; la mediana suele variar menos ante extremos. Ninguna de las dos es siempre «mejor»: responden preguntas distintas.

### C. Dispersión y desviación estándar

La **dispersión** nos dice si los valores del grupo están cerca unos de otros o si son variados. La **desviación estándar** resume cuán alejados suelen estar los valores respecto de la media, utilizando una fórmula basada en las diferencias al cuadrado. Una desviación estándar alta expresa mayor variabilidad en las unidades originales.

**Ejemplo:** ingresos `400, 410, 420` son menos dispersos que `100, 400, 730`, aunque ambos conjuntos tienen una media de 410.

### D. Cuartiles y rango intercuartílico (IQR)

- **Q1:** valor que deja aproximadamente un cuarto de las observaciones por debajo.
- **Q3:** valor que deja aproximadamente tres cuartos por debajo.
- **IQR:** `Q3 - Q1`; representa el ancho de la mitad central de los datos.

Los cuartiles ayudan a resumir una distribución de ingresos sin depender demasiado de los extremos.

### E. Diagrama de caja (*boxplot*)

Es un gráfico donde la caja va de Q1 a Q3 y una línea indica la mediana. Los «bigotes» representan observaciones dentro de límites convencionales. Puntos aislados fuera de esos límites son **candidatos a valores atípicos**, no errores confirmados.

### F. Completitud por perfil

**Completitud** significa «qué proporción de los valores esperados está presente». Ejemplo: en un grupo de 50 encuestas, 45 tienen educación informada: completitud educativa `45 / 50 × 100 = 90 %`.

Importante: edad e ingreso se exigieron para integrar K-means. Si calculamos su completitud **solamente entre los incluidos**, obtendremos 100 % por construcción. Para aprender calidad sin ocultar esta selección, calcularemos la cobertura original por separado y la completitud de **zona, educación y acceso a internet** dentro de cada grupo.

### G. Identificación de valores atípicos con IQR

Regla orientativa: ingreso fuera de `Q1 - 1,5 × IQR` o `Q3 + 1,5 × IQR`. Un ingreso real alto puede estar fuera de esos límites sin ser falso. Por eso el nombre correcto es «candidato para revisión».

## 11.3. Script `11_00_evaluar_completitud_perfiles.R`

**Objetivo:** utilizar el RDS de la sesión 10 y construir tablas de cobertura y completitud. El participante debe crear este archivo dentro de `R/` y ejecutar los pasos en el orden indicado.

### Paso 1: abrir la configuración y el RDS de la sesión 10

```r
source(here::here("R", "00_configuracion.R"))
ruta_10 <- here::here("resultados", "10_perfiles.rds")
if (!file.exists(ruta_10)) stop("Falta el RDS de la sesión 10")
paquete_10 <- readRDS(ruta_10)
```

- `source()` ejecuta un archivo R que contiene funciones compartidas.
- `here::here()` crea rutas relativas al proyecto, evitando rutas personales de Windows.
- `file.exists()` verifica que el archivo exista.
- `if()` solo ejecuta una instrucción si se cumple la condición.
- `stop()` detiene con un mensaje explicativo si falta un requisito.
- `readRDS()` recupera un objeto de R, en este caso una lista que contiene las tablas de la sesión anterior.

### Paso 2: seleccionar los registros agrupados

```r
datos <- paquete_10$datos_agrupados
nrow(datos)
names(datos)
```

`$` recupera un componente de la lista; `nrow()` cuenta filas; `names()` devuelve los nombres de las columnas. Compruebe que exista `grupo`, `edad_n`, `ingreso_n`, `zona_norm`, `educacion_norm` y `acceso_norm`.

### Paso 3: calcular el número y porcentaje por perfil

```r
tamanos <- datos %>%
  dplyr::count(grupo, name = "registros") %>%
  dplyr::mutate(
    pct_de_agrupados = round(100 * registros / sum(registros), 1)
  )
print(tamanos)
```

`%>%` lleva una tabla a la siguiente función. `count()` agrupa y cuenta observaciones. `mutate()` agrega una columna sin borrar las existentes. `sum()` suma los registros de todos los grupos. `round(...,1)` redondea a un decimal; el porcentaje está referido a los registros **que recibieron un grupo**.

### Paso 4: calcular la completitud de tres variables por grupo

```r
variables_calidad <- c("zona_norm", "educacion_norm", "acceso_norm")
completitud <- dplyr::bind_rows(lapply(variables_calidad, function(campo) {
  datos %>%
    dplyr::group_by(grupo) %>%
    dplyr::summarise(registros = dplyr::n(),
                     faltantes = sum(is.na(.data[[campo]])),
                     .groups = "drop") %>%
    dplyr::mutate(variable = campo,
                  presentes = registros - faltantes,
                  pct_completitud = round(100 * presentes / registros, 1))
}))
```

- `c()` crea un vector de tres nombres.
- `lapply()` repite una operación para cada nombre de variable.
- `function(campo)` indica la acción que se repetirá; `campo` cambia en cada vuelta.
- `group_by(grupo)` separa los cálculos para cada perfil.
- `summarise()` produce una fila de resumen por grupo.
- `n()` cuenta registros dentro del grupo.
- `.data[[campo]]` indica «la columna cuyo nombre está guardado en `campo`».
- `is.na()` identifica datos ausentes; `sum()` cuenta cuántos aparecen porque `TRUE` vale 1 en una suma lógica.
- `bind_rows()` coloca las tablas de los tres campos una debajo de la otra.

### Paso 5: registrar la cobertura y guardar resultados

```r
cobertura <- tibble::tibble(
  filas_del_archivo = paquete_10$diagnostico$registros_totales,
  filas_agrupadas = nrow(datos),
  filas_excluidas = paquete_10$diagnostico$registros_excluidos
)
paquete_11_base <- list(datos = datos, cobertura = cobertura,
                        tamanos = tamanos, completitud = completitud)
saveRDS(paquete_11_base, here::here("resultados", "11_base_calidad.rds"))
```

`list()` reúne varios objetos bajo un único nombre. `tibble()` construye una tabla legible. `saveRDS()` guarda el paquete para no depender de variables temporales. El script completo añade el porcentaje de cobertura, controles y exporta los CSV.

**Compruebe:** deben existir `resultados/11_base_calidad.rds`, `resultados/tablas/11_tamanos_perfiles.csv` y `resultados/tablas/11_completitud_perfiles.csv`.

## 11.4. Script `11_01_estadistica_calidad_perfiles.R`

**Objetivo:** calcular estadísticas, detectar posibles extremos de ingreso, elaborar tres gráficos y guardar un RDS listo para Quarto.

### Paso 1: leer el punto de control

```r
source(here::here("R", "00_configuracion.R"))
base <- readRDS(here::here("resultados", "11_base_calidad.rds"))
datos <- base$datos
```

No necesita cargar manualmente los CSV: los datos ya están organizados en el RDS de la etapa anterior.

### Paso 2: calcular medidas por grupo

```r
estadisticas <- datos %>%
  dplyr::group_by(grupo) %>%
  dplyr::summarise(
    n = dplyr::n(),
    ingreso_media = mean(ingreso_n),
    ingreso_mediana = median(ingreso_n),
    ingreso_sd = sd(ingreso_n),
    ingreso_q1 = as.numeric(quantile(ingreso_n, 0.25)),
    ingreso_q3 = as.numeric(quantile(ingreso_n, 0.75)),
    .groups = "drop"
  ) %>%
  dplyr::mutate(ingreso_iqr = ingreso_q3 - ingreso_q1)
```

- `mean()` calcula la media.
- `median()` busca el valor central ordenado.
- `sd()` resume dispersión de ingresos alrededor de la media.
- `quantile(., 0.25)` y `quantile(., 0.75)` obtienen Q1 y Q3.
- `as.numeric()` elimina atributos del resultado de `quantile()`.
- `mutate()` calcula IQR como diferencia entre cuartiles.

El script completo repite estas operaciones para edad, redondea la presentación y añade la diferencia entre media y mediana de ingresos.

### Paso 3: obtener límites de revisión de ingresos

```r
limites <- datos %>%
  dplyr::group_by(grupo) %>%
  dplyr::summarise(q1 = as.numeric(quantile(ingreso_n, 0.25)),
                   q3 = as.numeric(quantile(ingreso_n, 0.75)),
                   .groups = "drop") %>%
  dplyr::mutate(iqr = q3 - q1,
                limite_inferior = pmax(0, q1 - 1.5 * iqr),
                limite_superior = q3 + 1.5 * iqr)
```

`pmax(0, ...)` impide que el límite inferior sea negativo: los ingresos válidos seleccionados son no negativos. Este ajuste es específico del ejercicio y debe explicarse en el informe.

### Paso 4: relacionar límites y observaciones

```r
revisados <- datos %>%
  dplyr::left_join(limites, by = "grupo") %>%
  dplyr::mutate(
    candidato_atipico = ingreso_n < limite_inferior |
                        ingreso_n > limite_superior
  )
```

`left_join()` agrega los límites a cada fila a partir del grupo, conservando las observaciones de la tabla izquierda. `|` significa «o». La nueva columna es `TRUE` cuando un ingreso queda fuera de los límites. **No se cambia ningún ingreso ni se elimina una fila.**

### Paso 5: contar los candidatos a revisión

```r
resumen_atipicos <- revisados %>%
  dplyr::group_by(grupo) %>%
  dplyr::summarise(n = dplyr::n(),
                   candidatos = sum(candidato_atipico),
                   pct_candidatos = round(100 * candidatos / n, 1),
                   .groups = "drop")
```

Esta tabla muestra tanto las cantidades absolutas como sus denominadores. Una tasa mayor puede deberse a una distribución naturalmente muy dispersa: no implica automáticamente que ese perfil tenga datos inválidos.

### Paso 6: crear los tres gráficos

El script completo construye:

1. **Barras de tamaños:** `ggplot()` inicia el gráfico, `aes()` asigna ejes, `geom_col()` dibuja barras cuyo alto ya contiene el conteo.
2. **Diagrama de caja:** `geom_boxplot()` representa mediana, caja Q1–Q3, bigotes y puntos fuera del criterio gráfico.
3. **Mapa de calor de completitud:** `geom_tile()` usa celdas para cruzar grupos y variables; `geom_text()` muestra el porcentaje dentro de cada celda.

`ggsave()` guarda cada figura en `resultados/figuras/` para que Quarto pueda incluirla directamente.

### Paso 7: crear `11_calidad_perfiles.rds`

```r
paquete <- list(
  tablas = list(estadisticas = estadisticas,
                atipicos = resumen_atipicos,
                completitud = base$completitud),
  cobertura = base$cobertura
)
saveRDS(paquete, here::here("resultados", "11_calidad_perfiles.rds"))
```

El script completo también guarda metadatos, límites, detalles y rutas de figuras. No confunda **CSV** (tabla intercambiable) con **RDS** (objeto de R que puede contener varias tablas).

**Resultados a comprobar:** RDS, tabla de media/mediana/IQR por perfil, tabla de candidatos atípicos y tres gráficos.

## 11.5. Elaborar el informe `sesion_11_calidad_perfiles.qmd`

Quarto reúne texto, tablas y gráficos. El documento queda guardado en `reportes/` y contiene:

| Sección | Contenido | De dónde vienen los datos |
|---|---|---|
| Portada | Título, autor y formatos HTML/Word | Encabezado YAML |
| Introducción | Qué se evaluó y qué limitaciones hay | Texto del participante |
| Objetivos | Completitud, dispersión y revisión de extremos | Texto del participante |
| Metodología | Grupos de sesión 10 y cobertura | `paquete$cobertura` |
| Tamaños | Tabla y gráfico de frecuencias | `paquete$tablas$tamanos` |
| Estadísticos | Media, mediana, desviación y cuartiles | `paquete$tablas$estadisticas` |
| Completitud | Matriz de valores presentes por grupo | `paquete$tablas$completitud` |
| Atípicos | Tabla de candidatos | `paquete$tablas$atipicos` |
| Interpretación | Conclusiones descriptivas | Cálculos y observaciones propias |

### Encabezado YAML

```yaml
---
title: "Sesión 11 | Estadística de calidad de los perfiles"
lang: es
format:
  html:
    toc: true
  docx:
    toc: true
---
```

`---` abre y cierra el encabezado. `title` configura título, `lang` selecciona español y `format` declara las salidas. `toc: true` genera una tabla de contenidos.

### Primer bloque: leer el RDS

````markdown
```{r}
#| label: cargar-rds
paquete <- readRDS(here::here("resultados", "11_calidad_perfiles.rds"))
```
````

### Tabla de estadísticos

````markdown
```{r}
#| label: tabla-estadisticos
knitr::kable(paquete$tablas$estadisticas,
             caption = "Estadísticos de los perfiles")
```
````

`kable()` crea una tabla presentable tanto en HTML como en Word. La tabla se genera desde los resultados del RDS, no escribiendo cifras manuales.

### Incorporar un gráfico

````markdown
```{r}
#| label: grafico-completitud
knitr::include_graphics(
  here::here("resultados", "figuras", "11_completitud_por_perfil.png")
)
```
````

`include_graphics()` incorpora una figura previamente guardada. Al regenerar los gráficos, la nueva imagen puede incorporarse sin editar el informe.

## 11.6. Script `11_02_renderizar_reporte.R`

```r
source(here::here("R", "00_configuracion.R"))
qmd <- here::here("reportes", "sesion_11_calidad_perfiles.qmd")
cli <- Sys.which("quarto")
for (formato in c("html", "docx")) {
  estado <- system2(cli,
    args = c("render", shQuote(qmd), "--to", formato))
  if (estado != 0L) stop("Error al generar ", formato)
}
```

- `Sys.which("quarto")` localiza Quarto CLI.
- `for()` repite el proceso para HTML y Word.
- `system2()` ejecuta un comando del sistema desde R.
- `shQuote()` protege rutas que contienen espacios.
- `stop()` detiene si el renderizado devuelve error.

**Verifique** los archivos `reportes/sesion_11_calidad_perfiles.html` y `reportes/sesion_11_calidad_perfiles.docx`.

**Errores frecuentes:** si no existe el RDS, ejecute 11_00 y 11_01; si faltan PNG, ejecute 11_01; si Quarto no está en PATH, instale Quarto y reinicie RStudio. Un comando `quarto render ...` se ejecuta en **Terminal**, no escrito directamente en la **Console de R**.

## 11.7. Actividad de cierre

Redacte al menos una observación sobre tamaño de grupos, una sobre diferencias entre media y mediana, otra sobre completitud y una sobre los posibles ingresos atípicos. Explique por qué una variación en las estadísticas no demuestra diferencias causales ni significa error confirmado.

---

# Orden exacto y entregables finales

## Desde la consola RStudio

```r
# Sesión 10 (se conservan archivos y procedimientos)
source(here::here("R", "10_00_preparar_datos_perfiles.R"))
source(here::here("R", "10_01_identificar_perfiles.R"))
source(here::here("R", "10_02_renderizar_reporte.R"))

# Sesión 11 (nueva estadística de calidad)
source(here::here("R", "11_00_evaluar_completitud_perfiles.R"))
source(here::here("R", "11_01_estadistica_calidad_perfiles.R"))
source(here::here("R", "11_02_renderizar_reporte.R"))
```

## Productos que debe entregar cada participante

| Sesión | Entregables |
|---|---|
| 10 | Script de preparación, script K-means, `10_perfiles.rds`, tablas, dos PNG e informe Quarto HTML (Word opcional) |
| 11 | Scripts de completitud y estadísticos, `11_calidad_perfiles.rds`, cuatro tablas CSV, tres PNG e informe Quarto HTML (Word opcional) |

**Regla metodológica:** las medidas se calculan con datos sintéticos y no autorizan correcciones automáticas ni conclusiones sobre Ecuador.
