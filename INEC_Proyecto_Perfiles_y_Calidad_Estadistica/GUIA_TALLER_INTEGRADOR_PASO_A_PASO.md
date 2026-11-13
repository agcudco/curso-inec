# Taller integrador de calidad de datos: de la encuesta al reporte web

**Curso:** Evaluación de archivos de datos y automatización de reportes de calidad en R  
**Contexto:** Capacitación académica INEC (caso didáctico **totalmente sintético**)  
**Modalidad:** construcción progresiva en RStudio: escribir, ejecutar, interpretar, guardar evidencia y continuar  
**Duración sugerida:** 8 a 10 horas de laboratorio, adaptable a sesiones de 2 horas  
**Conjunto de trabajo:** `data_raw/encuesta_socioeconomica_2026.csv` y `data_raw/hogares_sinteticos_2026.csv`  
**Producto final:** un archivo **RDS** de resultados, un **reporte HTML** y un **sitio web Quarto**, junto con las evidencias intermedias.

> **Advertencia metodológica obligatoria.** Ningún dato de esta simulación procede de levantamientos reales del INEC. La muestra está deliberadamente desbalanceada y se incorporaron errores; no es representativa. La clasificación `pobreza_didactica` aplica un umbral **inventado para enseñar R** (USD 185 por persona/mes), que **NO es el método ni el umbral oficial de pobreza del Ecuador**. Nunca atribuir indicadores ni conclusiones a la población ecuatoriana.

## A. ¿Qué aprenderá el estudiante?

Al finalizar, podrá identificar seis dimensiones operativas de calidad (estructura, completitud, unicidad, consistencia, validez y trazabilidad), conservar el CSV de origen, reconocer `NA`, distinguir anomalías de errores confirmados, validar dominios y formatos, relacionar archivos de personas y hogares, proponer normalizaciones documentadas, calcular estadísticos e indicadores, crear gráficos y comunicar los hallazgos mediante Quarto.

El recorrido replica el orden de la presentación del curso: **explorar (1–3) → controlar (4–6) → comunicar (7–9)**. El proyecto no debe limitarse a ejecutar todo de una vez.

## B. Caso de estudio y desbalance intencional

Se simula una encuesta socioeconómica de personas en cinco provincias ficticiamente representadas a través de hogares. Se incluyen dos períodos: `2026-10` y `2026-11`. El archivo de personas contiene **2.400 filas (1.200 por período) y 24 variables**; el maestro de hogares incluye **800 hogares (400 por período)**.

Se desbalancearon las frecuencias de zona y educación: predominan zona urbana y nivel secundario, y los ingresos son positivos para la gran mayoría. Los valores cero y `NA` son poco frecuentes, para hacer más útiles las prácticas estadísticas. Se insertaron inconsistencias de claves, dominios, formatos, horas, fechas y referencias.

### Variables principales

| Variable | Concepto | Ejemplo | Control propuesto |
|---|---|---|---|
| `id_encuesta` | Identificador de la respuesta | E20261000001 | No debe repetirse |
| `id_persona` | Identificador de persona | P20261000001 | Unicidad por período |
| `id_hogar` | Relación con tabla hogares | H2026100001 | Integridad referencial |
| `periodo_referencia` | Mes de registro | 2026-10 | Patrón `YYYY-MM` |
| `fecha_entrevista` | Fecha del registro | 2026-10-14 | Fecha ISO y coherencia mensual |
| `provincia` y `zona` | Ubicación declarada | Pichincha / Urbana | Catálogos y coherencia con hogar |
| `edad` | Edad en años | 24 | Intervalo **didáctico** 18–110 |
| `nivel_educacion` | Nivel máximo declarado | Secundaria | Catálogo educativo |
| `ingreso_mensual_usd` | Ingreso total personal | 480.50 | Numérico, no negativo; `0` es un dato |
| `ingreso_hogar_mensual_usd` | Ingreso total del hogar | 1350.00 | Coherencia entre personas y hogar |
| `ingreso_per_capita_usd` | Ingreso del hogar por persona | 450.00 | Razón hogar/miembros |
| `pobreza_didactica` | Resultado del umbral ficticio | No pobre | Coherencia con el indicador derivado |

**Definición ilustrativa:**

\[
\text{Ingreso per cápita} = \frac{\text{Ingreso mensual del hogar}}{\text{Número de miembros del hogar}}
\]

En este taller se etiqueta *Pobre* si el ingreso per cápita es menor que **USD 185**. Este cálculo simplificado ignora ajustes, composición familiar y metodología oficial; solo es útil como ejemplo programático.

## C. Requisitos previos para completar el proyecto

- R actualizado, RStudio y **Quarto CLI** instalado (puede venir integrado en versiones compatibles de RStudio).
- Paquetes de R: `here`, `readr`, `dplyr`, `tidyr`, `ggplot2`, `knitr`.
- Descomprimir el ZIP **sin alterar la jerarquía de carpetas** y abrir `encuesta_calidad.Rproj`.
- Acceso de escritura a `resultados/` y permiso para ejecutar las instrucciones de la consola.
- Entender la diferencia entre **Console** (ejecuta expresiones R) y **Terminal** (ejecuta comandos como `quarto render`).

En **Console** de RStudio, instalar una sola vez:

```r
install.packages(c('here','readr','dplyr','tidyr','ggplot2','knitr'))
```

Después comprobar:

```r
getwd()               # Carpeta actual de trabajo
here::here()          # Raíz del proyecto .Rproj
file.exists(here::here('data_raw','encuesta_socioeconomica_2026.csv'))
```

La última instrucción debe devolver `TRUE`. En la pestaña **Terminal** (no en la consola R), comprobar `quarto --version`.

### Estructura que se espera conservar

```text
encuesta_calidad.Rproj
├── data_raw/
│   ├── encuesta_socioeconomica_2026.csv
│   ├── hogares_sinteticos_2026.csv
│   ├── encuesta_socioeconomica_2026_10.csv
│   └── encuesta_socioeconomica_2026_11.csv
├── diccionario/
│   ├── diccionario_variables.csv
│   ├── catalogo_provincias.csv
│   ├── catalogo_educacion.csv
│   └── metadatos.json
├── R/                         # Scripts para construir secuencialmente
├── resultados/
│   ├── tablas/                 # Evidencias CSV
│   ├── figuras/                # Gráficos PNG
│   └── 07_paquete_reporte.rds  # Entregable indispensable
├── reportes/reporte_calidad.qmd
└── web/
    ├── _quarto.yml
    ├── index.qmd
    └── metodologia.qmd
```

---

## D. Etapa 0 — Preparación del proyecto y funciones comunes

**Tiempo orientativo:** 25 minutos.  
**Archivo a estudiar:** `R/00_configuracion.R`.

**Conceptos:** paquete = extensión de funciones; función = conjunto reutilizable de instrucciones; objeto = valor almacenado; ruta relativa = ubicación independiente del disco del profesor; `source()` = cargar y ejecutar instrucciones de otro `.R`.

```r
# Este comando se ejecuta desde Console; no cambie la ruta.
source(here::here('R', '00_configuracion.R'))
```

Explicación: `here::here('R', '00_configuracion.R')` construye la ruta desde la carpeta donde está el `.Rproj`, sin usar `setwd('C:/...')`. `source()` lee el archivo y define las funciones que los demás scripts reutilizan. `library()` carga paquetes; `dir.create()` crea carpetas si todavía no existen.

Se definen tres utilidades fundamentales:

```r
normalizar_ausencia(c('NA','', '0','450.00'))
a_numero(c('100.50','NA','USD 410','0'))
```

**Observe:** `0` debe mantenerse como número cero, `NA` representa ausencia y `USD 410` no se convierte automáticamente mediante `as.numeric()`; por tanto, exige una revisión de formato. `suppressWarnings()` evita mensajes repetidos en ejercicios, pero no garantiza que una conversión sea correcta: el estudiante debe verificar los `NA` que resultaron de la conversión.

**Ejercicio:** explique por qué no debemos sustituir todos los ceros por `NA` y por qué se importan primero las claves como texto.

**Evidencia E0:** captura del proyecto abierto, resultado de `here::here()` y comprobación `TRUE` del CSV.

---

## E. Etapa 1 — Importación y perfilado (Módulos 1, 2 y 3)

**Tiempo:** 50 minutos.  
**Script:** `R/01_importar_perfilar.R`.

**Objetivo:** obtener una visión inicial de la estructura y el contenido, sin corregir nada.

### Paso 1.1. Importar en modo conservador

```r
source(here::here('R','00_configuracion.R'))
personas_raw <- leer_texto(
  here::here('data_raw','encuesta_socioeconomica_2026.csv')
)
```

`leer_texto()` usa `readr::read_csv()` con `col_character()`. Así, un identificador nunca se convierte inesperadamente a número y la entrada `950,50` no es alterada durante la importación. El docente pregunta: ¿por qué `read_csv()` no debe decidir automáticamente todos los tipos de datos?

### Paso 1.2. Comprender estructura y frecuencias

```r
dim(personas_raw)                   # Número de filas y columnas
names(personas_raw)                 # Nombres de campos
head(personas_raw, 6)              # Primeras seis filas
personas_raw %>% count(zona)       # Tabla de frecuencia por zona
```

`dim()` entrega dimensiones, `names()` lista variables, `head()` permite una inspección rápida, `%>%` entrega la salida de la instrucción anterior a la siguiente, y `count()` agrupa y contabiliza.

### Paso 1.3. Distinguir ausencia, cero y formato inválido

```r
personas_raw %>% summarise(
  faltantes = sum(is.na(normalizar_ausencia(ingreso_mensual_usd))),
  ceros = sum(a_numero(ingreso_mensual_usd) == 0, na.rm = TRUE),
  negativos = sum(a_numero(ingreso_mensual_usd) < 0, na.rm = TRUE)
)
```

`is.na()` produce un vector de `TRUE/FALSE`; `sum()` cuenta los verdaderos; `na.rm = TRUE` evita que un `NA` invalide toda la suma. Un valor negativo es una señal de revisión, no un vacío. Un valor extremo alto no debe considerarse error solo por ser infrecuente.

### Paso 1.4. Construir tabla de perfilado

`vapply()` aplica una misma función a todas las columnas y exige el tipo del resultado. El script genera por variable: cantidad de ausencias, valores distintos y porcentaje de ausencia. La función `n_distinct()` cuenta valores diferentes, mientras que `nrow()` entrega el denominador total de personas.

**Evidencia E1:** `resultados/tablas/01_diagnostico_variables.csv` y `resultados/01_datos.rds`. Abra el CSV y explique cuáles variables requieren prioridad de revisión.

Ejecute desde **Console**:

```r
source(here::here('R','01_importar_perfilar.R'))
```

---

## F. Etapa 2 — Validación de variables (Módulo 4)

**Tiempo:** 50 minutos.  
**Script:** `R/02_validar_variables.R`.

**Conceptos principales:** obligatoriedad (el valor debe existir), dominio (pertenecer a un catálogo), rango (estar entre límites), formato (seguir la representación exigida), incidencia (resultado que necesita revisión), severidad (importancia asignada después de validar la metodología).

### Paso 2.1. Crear una regla de dominio

```r
edu_validas <- readr::read_csv(
  here::here('diccionario','catalogo_educacion.csv'),
  show_col_types = FALSE
)$nivel_educacion

x_edu <- normalizar_ausencia(personas$nivel_educacion)
alerta_educacion <- !is.na(x_edu) & !(x_edu %in% edu_validas)
```

`%in%` devuelve si cada categoría pertenece al catálogo; `!` invierte el resultado; `&` exige ambas condiciones. Por ejemplo, `99` no pertenece al catálogo. `SUPERIOR` puede ser un problema de representación: el proceso de normalización posterior podrá proponer `Superior` sin inventar una categoría nueva.

### Paso 2.2. Transformar `TRUE/FALSE` en una tabla auditable

La función `crear_alerta()` captura el identificador, el número de fila, el código de regla, la variable y el valor observado. Se usa un argumento llamado **`columna_origen`** y se calcula `valores` **antes** de crear el `tibble`. Esto evita el conflicto de nombres que se presentó durante una actividad anterior.

```r
alertas_edu <- crear_alerta(
  personas, alerta_educacion, 'V07', 'nivel_educacion',
  'Categoría educativa fuera del catálogo literal'
)
head(alertas_edu)
```

**Evidencia E2:** `resultados/tablas/02_alertas_variables.csv`; seleccionen tres reglas, identifiquen una fila y expliquen si es error confirmado, advertencia o ausencia.

```r
source(here::here('R','02_validar_variables.R'))
```

---

## G. Etapa 3 — Consistencia lógica e integridad (Módulo 5)

**Tiempo:** 60 minutos.  
**Script:** `R/03_integridad_consistencia.R`.

**Conceptos:** un identificador de persona no equivale a una clave de hogar. Una **clave primaria** identifica una fila de la tabla maestra; una **clave foránea** referencia un registro de otra tabla. La relación personas → hogares es muchos a uno. La clave completa de este ejemplo incluye `id_hogar` y `periodo_referencia`.

### Paso 3.1. Encontrar claves repetidas

```r
duplicados <- personas %>%
  filter(!is.na(normalizar_ausencia(id_persona))) %>%
  add_count(periodo_referencia, id_persona,
            name = 'repeticiones') %>%
  filter(repeticiones > 1)
```

`add_count()` cuenta por grupo sin eliminar observaciones, a diferencia de algunos resúmenes agrupados. `filter()` conserva únicamente filas que cumplen la condición. No confunda *número de claves repetidas* con *número de filas involucradas en una repetición*.

### Paso 3.2. Detectar claves huérfanas

```r
huerfanos <- personas %>%
  filter(!is.na(normalizar_ausencia(id_hogar))) %>%
  anti_join(hogares,
            by = c('id_hogar', 'periodo_referencia'))
```

`anti_join()` devuelve las personas para las cuales **no aparece** el par de claves en hogares. No borra registros; identifica el subconjunto para auditoría. Una clave ausente se trata separadamente de una clave presente, pero sin correspondencia.

### Paso 3.3. Evaluar consistencia entre variables

```r
# Regla didáctica: ocupado con cero horas declaradas
alerta_ocupado <- personas$condicion_actividad == 'Ocupado' &
  !is.na(personas$horas_n) & personas$horas_n == 0
```

Este criterio debe revisarse con el responsable metodológico: puede haber excepciones legítimas. Las condiciones `TRUE/FALSE` se traducen a una tabla de alertas con regla, fila, valor y descripción.

**Evidencia E3:** `03_huerfanos.csv`, `03_alertas_integridad.csv` y explicación de un duplicado y una referencia sin correspondencia.

```r
source(here::here('R','03_integridad_consistencia.R'))
```

---

## H. Etapa 4 — Depuración propuesta y bitácora (Módulo 6)

**Tiempo:** 60 minutos.  
**Script:** `R/04_depuracion_bitacora.R`.

**Conceptos:** depurar no equivale a borrar o cambiar valores indiscriminadamente. La práctica distingue **conservar fuente → detectar → proponer → autorizar → comparar**. Aquí solo se desarrolla la **propuesta didáctica**, sin afirmar autorización.

### Paso 4.1. Normalizar etiquetas conocidas

```r
canon_zona <- c('urbana'='Urbana', 'rural'='Rural')
canonizar(c('URBANA','Rural ','99'),canon_zona)
```

`tolower()` pasa a minúsculas, `trimws()` elimina espacios extremos, un vector nombrado funciona como diccionario de equivalencias y `coalesce()` conserva el dato original si no se encontró una equivalencia inequívoca. Por ello `99` no se reemplaza automáticamente.

### Paso 4.2. Registrar cambios con identificador estable

La bitácora contiene `id_encuesta`, nombre de variable, valor original, valor propuesto, regla, estado, responsable y fecha. Se compara por `id_encuesta` y no por `id_persona`, porque este último fue duplicado deliberadamente para la práctica.

### Paso 4.3. Comprender la imputación antes de simularla

- **Media aritmética:** suma de los valores observados dividida para el número de valores observados. Es sensible a extremos.
- **Mediana:** valor central una vez ordenada la serie. Tiende a ser más robusta cuando hay extremos.
- **Imputación:** sustitución estimada de un faltante bajo supuestos; **no recupera el valor verdadero**.
- **Mediana por grupos:** se calcula por período y zona con datos monetarios numéricos no negativos, y se usa solo para un escenario separado.

```r
median(c(100, 300, 500, 9000))  # 400
mean(c(100, 300, 500, 9000))    # 2475
```

El script crea `ingreso_imputado_demo`, **pero no modifica** `ingreso_mensual_usd` ni permite usar esa variable para afirmar que se corrigió la pobreza oficial.

**Evidencia E4:** `resultados/tablas/04_bitacora_propuesta.csv` y `resultados/04_escenarios.rds`. Compare tres normalizaciones y un caso que se mantiene pendiente de revisión.

```r
source(here::here('R','04_depuracion_bitacora.R'))
```

---

## I. Etapa 5 — Indicadores y tablas de seguimiento (Módulos 6 y 7)

**Tiempo:** 75 minutos.  
**Script:** `R/05_indicadores_tablas.R`.

Cada indicador requiere **unidad de análisis, numerador, denominador y regla de aplicabilidad**. Nunca entregue un porcentaje sin definir sobre qué elementos se calculó.

### 5.1. Completitud

\[
\operatorname{Completitud}=100\frac{\text{campos requeridos presentes}}{\text{campos requeridos evaluados}}
\]

En el ejercicio se examinan seis campos obligatorios para todas las filas. Una ausencia cuenta como campo no presente. El número `0.00` **sí está presente**.

### 5.2. Validez

\[
\operatorname{Validez}=100\frac{\text{evaluaciones aplicables que cumplen}}{\text{evaluaciones aplicables}}
\]

Se aplica a edad, ingreso, educación, zona y provincia. Los valores ausentes se registran en completitud y quedan fuera de la validación específica de formato o dominio; **un texto inválido no se excluye**, sino que cuenta como incumplimiento aplicable.

### 5.3. Unicidad

\[
\operatorname{Unicidad}=100\frac{\text{filas con clave presente que no participan en duplicidad}}{\text{filas con clave presente}}
\]

Se define la clave como `(periodo_referencia, id_persona)`. Se considera no única cada fila que participa en una clave repetida, no solamente la segunda aparición. Esta convención debe comunicarse porque otras métricas de unicidad utilizan definiciones distintas.

### 5.4. Consistencia

\[
\operatorname{Consistencia}=100\frac{\text{relaciones lógicas evaluadas que se cumplen}}{\text{relaciones aplicables evaluadas}}
\]

El ejercicio emplea relación laboral (`condicion_actividad`/`horas_trabajo_semana`) y coherencia temporal (fecha/período), respetando la aplicabilidad. No se trata de un indicador institucional universal.

### 5.5. Interpretar un ejemplo

Si se verifican 1.000 campos obligatorios y hay 980 presentes, la completitud es **98 %**. Si se verifican 500 reglas aplicables y 475 cumplen, la validez es **95 %**. No se pueden comparar ambos denominadores como si midieran la misma unidad.

### 5.6. Comparación entre períodos

El script calcula las mismas cuatro definiciones en 2026-10 y 2026-11, tanto para original como propuesta. Como los datos fueron diseñados para el aula, **ninguna diferencia constituye evidencia de mejora o deterioro en el INEC**.

**Evidencia E5:** `05_indicadores.csv`, `05_indicadores_periodo.csv`, `05_resumen_ingresos.csv`, `05_educacion_zona.csv`, `05_pobreza_zona.csv`, `05_resumen_alertas.csv`. Explique una diferencia en puntos porcentuales y compruebe el numerador/denominador de un indicador.

```r
source(here::here('R','05_indicadores_tablas.R'))
```

---

## J. Etapa 6 — Gráficos de seguimiento (Módulo 7)

**Tiempo:** 55 minutos.  
**Script:** `R/06_graficos_seguimiento.R`.

**Objetivo:** transformar tablas en figuras con títulos, ejes, unidades y advertencias correctas.

| Gráfico | Función principal | Qué responde |
|---|---|---|
| Barras agrupadas | `geom_col(position='dodge')` | ¿Cómo varía un indicador entre escenarios? |
| Barras por educación | `facet_wrap(~periodo_referencia)` | ¿Qué niveles educativos predominan por período? |
| Histograma de ingresos | `geom_histogram()` | ¿Cómo se distribuyen los ingresos observados? |
| Alertas por regla | `coord_flip()` | ¿Cuáles reglas generan más incidencias? |
| Barras proporcionales | `geom_col(position='fill')` | ¿Qué proporción representa cada etiqueta de pobreza didáctica? |

**Funciones de `ggplot2`:** `ggplot(datos, aes(...))` define la relación entre datos y elementos visuales; `geom_col()` grafica valores ya calculados; `geom_histogram()` forma intervalos y cuenta casos; `labs()` añade etiquetas; `theme_minimal()` aplica un tema; `ggsave()` guarda una imagen con tamaño y resolución definidos.

```r
source(here::here('R','06_graficos_seguimiento.R'))
```

**Evidencia E6:** cinco PNG en `resultados/figuras/`. Seleccione uno y explique el denominador, una conclusión que sí se justifica y una conclusión que sería indebida.

**Error conceptual habitual:** el histograma solo usa ingresos numéricos no negativos y acerca la vista a 0–3.000 USD; no significa que se hayan borrado los ingresos superiores a USD 3.000 del CSV original.

---

## K. Etapa 7 — Crear el archivo RDS: entregable indispensable

**Tiempo:** 35 minutos.  
**Script:** `R/07_construir_rds_reporte.R`.

### 7.1. ¿Qué es un RDS y para qué sirve?

Un **RDS** es un archivo binario de R que almacena un objeto R conservando su estructura y tipos (tibble, data.frame, lista, fechas, etc.). No es un CSV: puede contener varias tablas y metadatos en un único archivo. Es adecuado para separar el proceso de análisis del proceso de elaboración del reporte.

La función `saveRDS(objeto, ruta)` guarda un objeto; `readRDS(ruta)` lo recupera. A diferencia de `.RData`, no introduce automáticamente múltiples nombres en el entorno de trabajo: el estudiante asigna explícitamente el objeto recuperado.

### 7.2. Preparar el paquete de insumos

```r
res <- readRDS(here::here('resultados','05_tablas.rds'))
paquete_reporte <- list(
  metadatos = list(titulo='Encuesta socioeconómica sintética'),
  tablas = res$tablas,
  alertas = res$alertas,
  bitacora = res$bitacora
)

saveRDS(paquete_reporte,
        here::here('resultados','07_paquete_reporte.rds'))
```

El script completo recoge las tablas reales de la etapa 5, los registros de incidencias y bitácora, además de las rutas verificadas de las figuras. La lista `metadatos` añade procedencia, período y advertencia metodológica.

### 7.3. Comprobar que el RDS se puede volver a leer

```r
x <- readRDS(here::here('resultados','07_paquete_reporte.rds'))
names(x)
str(x, max.level = 2)
nrow(x$tablas$indicadores)
```

Los resultados esperados incluyen `metadatos`, `tablas`, `alertas`, `bitacora` y `figuras`; habrá **8 filas** de indicadores generales: cuatro dimensiones × dos escenarios.

**Evidencia E7 (obligatoria):** archivo físico `resultados/07_paquete_reporte.rds`, captura de `names(x)` y comprobación de lectura. El RDS **se genera al ejecutar** esta etapa; no se entrega como producto terminado para evitar sustituir el aprendizaje.

```r
source(here::here('R','07_construir_rds_reporte.R'))
```

---

## L. Etapa 8 — Crear el reporte HTML con Quarto (Módulo 8)

**Tiempo:** 60 minutos.  
**Archivo:** `reportes/reporte_calidad.qmd`.

Quarto combina **Markdown** (texto y encabezados), **YAML** (metadatos del documento) y **bloques ejecutables de R** (tablas, gráficos e indicadores). Se sigue este orden:

### Paso 8.1. Comprender el encabezado YAML

```yaml
---
title: "Informe técnico de calidad de datos"
lang: es
format:
  html:
    toc: true
    code-fold: true
  docx:
    toc: true
execute:
  echo: false
---
```

`title` es el título, `lang` define el idioma, `format` indica formatos disponibles, `toc: true` crea un índice, `code-fold: true` permite plegar código en HTML y `echo: false` oculta el código sin impedir su ejecución.

### Paso 8.2. Leer el RDS desde el documento

En un bloque R del `.qmd`:

````markdown
```{r}
library(here)
ruta <- here::here('resultados','07_paquete_reporte.rds')
informe <- readRDS(ruta)
```
````

Quarto iniciará una sesión R independiente. Por eso el documento **no debe depender** de `personas`, `alertas` o `indicadores` que estén abiertos en el panel Environment de RStudio: los recupera desde el RDS.

### Paso 8.3. Insertar una tabla y un gráfico

````markdown
## Resultados de calidad

```{r}
knitr::kable(informe$tablas$indicadores,
             caption='Indicadores de calidad por escenario')
```

```{r}
knitr::include_graphics(
  here::here('resultados','figuras','06_indicadores.png')
)
```
````

`knitr::kable()` presenta el data.frame como tabla; `knitr::include_graphics()` incorpora una figura existente. El reporte contiene introducción, objetivos, metodología, indicadores, comparación entre períodos, educación, ingresos, pobreza didáctica, alertas, limitaciones y conclusiones.

### Paso 8.4. Renderizar HTML y Word

**Opción A — Terminal de RStudio (no Console):**

```bash
quarto render reportes/reporte_calidad.qmd --to html
quarto render reportes/reporte_calidad.qmd --to docx
```

**Opción B — Console de RStudio:**

```r
system2('quarto', c('render', 'reportes/reporte_calidad.qmd', '--to', 'html'))
system2('quarto', c('render', 'reportes/reporte_calidad.qmd', '--to', 'docx'))
```

Los productos deberían aparecer en `reportes/reporte_calidad.html` y `reportes/reporte_calidad.docx`. Si el proyecto se mueve, es necesario conservar `resultados/07_paquete_reporte.rds` y `resultados/figuras/` junto a los archivos fuente.

**Evidencia E8:** HTML y DOCX (Word es opcional), más captura del informe con tabla y gráfico visibles. **Validación:** los resultados del HTML deben coincidir con las tablas del RDS, sin números redactados manualmente en el cuerpo del informe.

---

## M. Etapa 9 — Publicar el sitio web Quarto (Módulos 8 y 9)

**Tiempo:** 40 minutos.  
**Archivos:** `web/_quarto.yml`, `web/index.qmd`, `web/metodologia.qmd`.

A diferencia de un único HTML, un proyecto Quarto de tipo `website` organiza **varias páginas conectadas** y una navegación superior. El sitio del taller tiene una portada de indicadores y una página de metodología.

En la **Terminal**:

```bash
quarto render web
```

Esto genera una carpeta de páginas web: `web/_site/`. Abra `web/_site/index.html` en el navegador. La publicación en un servidor externo requiere un proceso adicional y permisos; para esta entrega basta con el sitio estático local.

**Evidencia E9:** carpeta `web/_site/` con `index.html` y `metodologia.html`, y captura de ambas páginas abiertas.

---

## N. Orden correcto de ejecución y verificación

**No seleccione todos los scripts y pulse Run de una sola vez.** Primero termine cada fase, inspeccione su resultado y documente qué ocurrió. Desde la consola R, ejecute uno por uno:

```r
source(here::here('R','01_importar_perfilar.R'))
source(here::here('R','02_validar_variables.R'))
source(here::here('R','03_integridad_consistencia.R'))
source(here::here('R','04_depuracion_bitacora.R'))
source(here::here('R','05_indicadores_tablas.R'))
source(here::here('R','06_graficos_seguimiento.R'))
source(here::here('R','07_construir_rds_reporte.R'))
source(here::here('R','08_verificar_entregables.R'))
```

**Atención:** cada script comienza con `source()` de la configuración y recupera archivos guardados. Si modifica una etapa anterior, debe volver a producir sus dependencias posteriores, no solo volver a ejecutar Quarto.

### Problemas frecuentes y solución didáctica

| Situación | Causa habitual | Verificación / solución |
|---|---|---|
| `could not find function "%>%"` | `dplyr` no fue cargado | Ejecute etapa 0 / `library(dplyr)` |
| No aparece el CSV | Proyecto abierto desde otra carpeta | Abra `.Rproj`, use `here::here()` y `file.exists()` |
| `object 'personas' not found` | Se ejecutó un bloque antes de importar | Ejecute etapa 1; los siguientes scripts leen RDS |
| `can't extract column variable` | Colisión entre argumento `variable` y columna de tibble | Use `columna_origen` y extraiga valores antes de crear el `tibble` |
| `invalid argument to unary operator` | Texto tratado como número | Use `a_numero()` y verifique formatos inválidos |
| `readRDS` no encuentra el archivo | No se ejecutó la etapa 7 | Genere `07_paquete_reporte.rds` y revise su ruta |
| `quarto: command not found` | Quarto CLI no está disponible en Terminal | Instale Quarto y verifique `quarto --version` |
| Reporte vacío o desactualizado | No se regeneraron los insumos | Repita etapas 5–7 y ejecute `quarto render` |
| Porcentajes distintos | Reglas o denominadores diferentes | Revise definición del indicador y escenario utilizado |

## O. Actividad de interpretación: preguntas que deben responder

1. ¿Por qué un dataset con pocas ausencias todavía puede tener problemas de validez, unicidad e integridad?
2. ¿Cómo distinguirá una fila repetida de dos personas con un mismo identificador?
3. ¿Qué significa un `id_hogar` sin correspondencia, y por qué no debemos eliminarlo sin investigación?
4. ¿Qué diferencia existe entre media y mediana ante un ingreso extremo alto?
5. ¿Cuál es la diferencia entre corrección **propuesta** y corrección **aprobada**?
6. ¿Qué indicador mejoró entre escenario original y propuesta? ¿Es correcto afirmar que mejoró la estadística oficial?
7. ¿Por qué `saveRDS()` es necesario antes de elaborar el reporte Quarto?
8. ¿Qué diferencia práctica existe entre generar un documento HTML y generar un sitio web de dos páginas?
9. ¿Por qué los resultados desbalanceados no deben extrapolarse a Ecuador?
10. ¿Por qué la variable `pobreza_didactica` no equivale a pobreza monetaria oficial?

## P. Entregables de la actividad integradora

| Código | Producto comprobable | Archivo o evidencia | Puntos |
|---|---|---|---:|
| E0 | Proyecto RStudio ordenado | `.Rproj` y captura de rutas | 1 |
| E1 | Diagnóstico y perfilado | `01_diagnostico_variables.csv` y `01_datos.rds` | 2 |
| E2 | Alertas de validación | `02_alertas_variables.csv` | 2 |
| E3 | Integridad y consistencia | `03_alertas_integridad.csv`, `03_huerfanos.csv` | 3 |
| E4 | Propuesta con trazabilidad | `04_bitacora_propuesta.csv` + explicación | 2 |
| E5 | Tablas e indicadores con fórmula | CSV `05_*.csv`, numeradores y denominadores | 3 |
| E6 | Visualizaciones documentadas | Cinco PNG en `resultados/figuras/` | 2 |
| E7 | **Paquete RDS** verificable | **`resultados/07_paquete_reporte.rds`** | **2** |
| E8 | Reporte Quarto HTML | `reportes/reporte_calidad.html` | 2 |
| E9 | Sitio web navegable | `web/_site/index.html` y metodología | 1 |
| **Total** | | | **20** |

### Criterios de aprobación del producto final

El archivo fuente no fue modificado; los productos se pueden regenerar; el RDS existe y puede leerse desde una sesión nueva; el HTML obtiene sus indicadores del RDS; el sitio web abre sus páginas y gráficos; las tasas tienen denominadores; las propuestas de depuración no se declaran aprobadas; y el informe reconoce que la muestra y el umbral de pobreza son ficticios.

## Q. Referencias para consulta

- Posit. [RStudio Projects](https://docs.posit.co/ide/user/ide/guide/code/projects.html)
- Tidyverse. [readr](https://readr.tidyverse.org/), [dplyr](https://dplyr.tidyverse.org/), [ggplot2](https://ggplot2.tidyverse.org/)
- Wickham et al. [R for Data Science (2e)](https://r4ds.hadley.nz/)
- Quarto. [Getting Started](https://quarto.org/docs/get-started/), [HTML](https://quarto.org/docs/output-formats/html-basics.html), [Websites](https://quarto.org/docs/websites/), [MS Word](https://quarto.org/docs/output-formats/ms-word.html)

*Fin de la guía integradora. El punto de llegada es un informe derivado de datos y un sitio web, no un documento armado manualmente.*
