# Práctica introductoria: mi primer informe Quarto

**Curso:** Evaluación de archivos de datos y automatización de reportes de calidad en R (INEC)  
**Ubicación en el curso:** Antes del módulo 8 (generación automática de reportes)  
**Duración sugerida:** 45–60 minutos  
**Enfoque:** escribir y entender cada sección, no ejecutar un proyecto completo ya terminado.

> **Propósito:** aprender a convertir un texto de informe en un documento reproducible que contiene cálculos, una tabla y un gráfico. La práctica **no sustituye** el reporte completo del módulo 8. Los datos del archivo son sintéticos y el CSV original no se modifica.

## 1. Resultado de aprendizaje

Al finalizar, podrá (1) identificar la diferencia entre `.R`, `.Rproj`, `.md` y `.qmd`; (2) crear un documento Quarto; (3) editar la portada y las secciones de texto; (4) insertar código R ejecutable; (5) presentar una tabla y un gráfico; y (6) generar el mismo informe en HTML y Word.

## 2. Material necesario

- R y RStudio instalados y funcionando.
- Quarto disponible en RStudio. En la pestaña **Terminal** puede comprobarlo mediante `quarto --version`.
- Paquetes R `readr`, `dplyr`, `ggplot2` y `knitr` (instálelos una sola vez desde la **Console** con `install.packages(c("readr", "dplyr", "ggplot2", "knitr"))`).
- `personas_encuesta_sintetica_2026_10.csv` dentro de `data_raw/`.

### Organización mínima

```text
INEC_PreModulo8_Quarto/
├── data_raw/
│   └── personas_encuesta_sintetica_2026_10.csv
├── plantilla_para_construir.qmd
├── reporte_introductorio.qmd
└── GUIA_PASO_A_PASO_QUARTO_PRE_MODULO_8.md
```

Puede colocar estos mismos archivos en la raíz de su proyecto `.Rproj` anterior. **No es necesario crear otro proyecto para este ejercicio.** El archivo `.qmd` debe estar al mismo nivel que `data_raw/` para que la ruta del ejemplo funcione.

## 3. Conceptos básicos antes de escribir

| Elemento | Definición | Ejemplo / uso |
|---|---|---|
| `.R` | Script con instrucciones R. | Calcular indicadores por separado. |
| `.Rproj` | Archivo que abre un proyecto RStudio. | Mantener ordenadas rutas y carpetas. |
| Markdown | Sintaxis sencilla para escribir títulos, listas y texto con énfasis. | `## Resultados`, `**importante**`. |
| `.qmd` | Archivo de texto Quarto con portada, Markdown y bloques ejecutables. | `reporte_introductorio.qmd`. |
| YAML | Encabezado de configuración entre líneas `---`. | `title:`, `format:`, `author:`. |
| Chunk / bloque R | Código entre tres comillas invertidas y `{r}`. | Importar el CSV y crear una tabla. |
| Render | Proceso que ejecuta los bloques y genera un documento de salida. | HTML o Word. |
| Reproducibilidad | Posibilidad de reconstruir resultados con los mismos datos y código. | Renderizar de nuevo el `.qmd`. |

## 4. Paso 1 — Crear el `.qmd` en RStudio (5 minutos)

1. Abra su proyecto habitual en RStudio.
2. Vaya a **File > New File > Quarto Document**.
3. Escriba `Mi primer reporte de calidad de datos` como título.
4. Seleccione **HTML** como formato inicial y R / knitr como motor.
5. Guarde como `reporte_introductorio.qmd` en la carpeta principal del proyecto.
6. Para practicar desde cero, abra primero `plantilla_para_construir.qmd` y complete sus apartados poco a poco. El otro `.qmd` es una **solución de referencia**.

**Comprobación:** pulse **Render** al terminar el encabezado y la introducción. Incluso sin datos, el documento debe mostrar el título y el párrafo inicial.

## 5. Paso 2 — Comprender la portada YAML (5 minutos)

```yaml
---
title: "Mi primer reporte de calidad de datos"
subtitle: "Práctica introductoria a Quarto"
author: "Nombre del participante"
format:
  html:
    toc: true
  docx:
    toc: true
---
```

- `---`: abre y cierra el encabezado YAML; las dos líneas son necesarias.
- `title`: nombre visible del reporte.
- `subtitle`: tema adicional.
- `author`: autor o responsable del informe.
- `format`: formatos que Quarto puede producir. `html` es una página web; `docx` es un documento Word.
- `toc: true`: incluye tabla de contenido automática con los títulos.
- **Sangría:** los espacios son significativos en YAML. No alinee `toc` con `format`.

**Actividad:** cambie título, autor y subtítulo y vuelva a renderizar para observar la diferencia.

## 6. Paso 3 — Escribir las secciones con Markdown (5 minutos)

```markdown
## Introducción
Este informe utiliza **datos sintéticos** para aprender Quarto.

## Objetivos
- Importar datos.
- Crear una tabla.
- Crear un gráfico.

## Metodología
Se analizará el CSV de octubre de 2026.

## Resultados
Aquí se mostrarán los resultados de R.

## Interpretación y discusión
Explicar dos hallazgos del análisis.

## Conclusiones
Resumir el aprendizaje y sus limitaciones.

## Referencias
- Documentación de Quarto.
```

**¿Qué significa cada símbolo?** `##` crea una sección de segundo nivel. `###` es una subsección. `-` crea una viñeta; `**texto**` produce negrita. El texto normal son párrafos que aparecerán en el informe. Mantener dos párrafos separados con una línea vacía mejora la legibilidad.

**Actividad:** escriba la introducción con sus propias palabras; incluya la advertencia de que los datos **no son estadísticas oficiales del INEC**.

## 7. Paso 4 — Insertar el primer bloque ejecutable de R (10 minutos)

Un bloque R se abre con tres comillas invertidas seguidas de `{r}` y se cierra con otras tres comillas invertidas. En este bloque **sí se ejecuta código**; el texto de las otras secciones no se ejecuta.

````markdown
```{r}
# Cargar funciones para leer archivos y trabajar con tablas.
library(readr)
library(dplyr)

# Ruta del archivo relativa al .qmd.
ruta_csv <- "data_raw/personas_encuesta_sintetica_2026_10.csv"

# Si el archivo no existe, detener con un mensaje claro.
if (!file.exists(ruta_csv)) stop("No encuentro el CSV")

# Leer las columnas como texto para conservar códigos.
datos <- read_csv(
  ruta_csv,
  col_types = cols(.default = col_character()),
  na = "NA",
  trim_ws = FALSE,
  show_col_types = FALSE
)

# Mostrar la cantidad de registros y variables.
dim(datos)
```
````

**Funciones, una por una:**

- `library(paquete)` activa funciones de un paquete ya instalado.
- `<-` asigna el valor de la derecha al objeto de la izquierda.
- `file.exists(ruta)` devuelve `TRUE` si el archivo existe.
- `if (condición)` ejecuta su cuerpo solo cuando la condición es verdadera.
- `stop(mensaje)` detiene el documento ante un problema serio.
- `read_csv()` importa CSV; `col_types = cols(.default = col_character())` lee todas las columnas como caracteres, evitando modificar identificadores o códigos de clasificación.
- `na = "NA"` interpreta esa cadena exacta como dato ausente; otros marcadores requieren revisión aparte.
- `trim_ws = FALSE` conserva espacios originales que podrían ser importantes en el diagnóstico.
- `show_col_types = FALSE` oculta el aviso informativo de inferencia de tipos.
- `dim(datos)` muestra filas y columnas, sin modificar datos.

**Resultado esperado:** un vector con dos números que representan el tamaño del archivo. **No copie números de la diapositiva al reporte**: deben salir del CSV que cada participante importó.

## 8. Paso 5 — Mostrar un indicador dentro del texto (3 minutos)

En una frase normal puede insertar código R *inline* encerrado entre comillas invertidas:

````markdown
El archivo contiene **`r nrow(datos)` registros** y **`r ncol(datos)` variables**.
````

`nrow()` obtiene el total de filas y `ncol()` las columnas. La expresión se evalúa al renderizar: si cambia el CSV, cambia también la frase. Asegúrese de que el bloque de lectura **aparezca antes** en el archivo.

## 9. Paso 6 — Crear una tabla estadística básica (7 minutos)

````markdown
```{r}
# Contar cuántas filas pertenecen a cada condición de actividad.
resumen <- datos %>%
  count(condicion_actividad, name = "registros", sort = TRUE)

# Presentar la tabla con formato legible en HTML y Word.
knitr::kable(resumen, caption = "Registros por condición de actividad")
```
````

`%>%` pasa el resultado de una operación a la siguiente. `count()` agrupa observaciones iguales y las cuenta; `name` define cómo se llamará la columna numérica y `sort = TRUE` ordena de mayor a menor. `knitr::kable()` toma una tabla existente y la muestra como tabla de informe; **no calcula indicadores nuevos**.

**Actividad:** identifique qué categoría es más frecuente. ¿La suma de registros por categoría coincide con el número total de filas?

## 10. Paso 7 — Crear el primer gráfico (7 minutos)

````markdown
```{r}
library(ggplot2)

ggplot(resumen, aes(x = condicion_actividad, y = registros)) +
  geom_col(fill = "#246B9C") +
  labs(
    title = "Condición de actividad",
    x = "Categoría",
    y = "Número de registros"
  ) +
  theme_minimal()
```
````

`ggplot()` inicia el gráfico y recibe la tabla; `aes()` indica qué columnas representan los ejes; `geom_col()` dibuja barras de altura igual al **conteo ya calculado**; `labs()` define títulos; y `theme_minimal()` utiliza un estilo sencillo. El signo `+` agrega elementos a la misma figura.

**Actividad:** compare los valores de las barras con las cifras de la tabla. No interprete frecuencias como porcentajes sin calcular antes el denominador.

## 11. Paso 8 — Interpretar antes de concluir (5 minutos)

En **Interpretación**, escriba dos observaciones verificables desde la tabla y el gráfico. Por ejemplo: «La categoría más frecuente es ___, con ___ registros». Complete los espacios **después de observar el resultado real**. En **Conclusiones**, resuma lo aprendido: fuente utilizada, qué muestra la tabla, qué no permite inferir el gráfico, y qué habría que revisar en los módulos de validación posteriores.

**Diferencia importante:** la tabla y el gráfico describen el archivo; no prueban por sí solos la ausencia de errores, la representatividad estadística ni la validez de los datos.

## 12. Paso 9 — Generar HTML y Word (5 minutos)

**Desde RStudio:** abra el `.qmd` y pulse **Render**. Quarto generará inicialmente el primer formato del YAML (HTML, en este ejemplo). Para generar Word use la **Terminal** de RStudio, no la Console de R:

```bash
quarto render reporte_introductorio.qmd --to html
quarto render reporte_introductorio.qmd --to docx
```

Se producirán archivos `reporte_introductorio.html` y `reporte_introductorio.docx` en la ubicación de salida predeterminada. La opción `embed-resources: true` del ejemplo completo ayuda a producir un HTML que incluya recursos en un solo archivo.

**No confundir:** `Render` genera un informe; `Run` ejecuta un bloque R aislado. El documento completo debe poder renderizarse incluso tras reiniciar RStudio, sin reutilizar objetos preexistentes de la sesión.

## 13. Lista de verificación antes de entregar

- [ ] El archivo `.qmd` está guardado en la raíz del proyecto.
- [ ] El CSV original está dentro de `data_raw/` y se conserva intacto.
- [ ] Quarto y los paquetes requeridos están disponibles.
- [ ] La portada refleja el título, responsable y tema del informe.
- [ ] Hay introducción, objetivos, metodología, resultados, interpretación, conclusiones y referencias.
- [ ] El reporte contiene al menos **una tabla y un gráfico obtenidos del CSV**.
- [ ] Los valores del texto están calculados o fueron comprobados manualmente.
- [ ] El HTML se genera sin errores.
- [ ] El Word se genera sin errores.
- [ ] El informe indica que los datos son sintéticos.

## 14. Errores frecuentes y soluciones

| Mensaje / síntoma | Causa probable | Qué revisar |
|---|---|---|
| `could not find function "read_csv"` | No se cargó `readr`. | `library(readr)` al inicio. |
| `there is no package called ...` | Falta instalar el paquete. | `install.packages()` en la Console. |
| `No encuentro el CSV` | Ruta incorrecta desde el `.qmd`. | Archivo en `data_raw/`; revisar mayúsculas y nombre exacto. |
| `object 'datos' not found` | No se ejecutó el bloque de importación. | Orden de bloques; ejecutar Render. |
| `quarto: command not found` | Quarto no está instalado o no está disponible en Terminal. | Verificar instalación y reiniciar RStudio. |
| Word no contiene el gráfico | Bloque no ejecutado o falló la renderización. | Revisar log de Render y rutas de imágenes. |
| Error en YAML | Sangría, dos puntos o cierre incorrecto. | Conservar las dos líneas `---` y usar espacios. |

## 15. Mini-actividad evaluable

1. Cambie el título del documento y agregue su nombre.
2. Escriba una introducción de 3–4 líneas sobre la base sintética.
3. Importe el CSV conservando los códigos como texto.
4. Cree una tabla con `count(provincia)` y agregue `knitr::kable()`.
5. Genere un gráfico de barras con `ggplot2`.
6. Escriba dos hallazgos y una limitación sobre el alcance de los datos.
7. Entregue `reporte_introductorio.qmd` y el HTML obtenido al pulsar Render.

## 16. Puente con el módulo 8

| Esta práctica previa | En el módulo 8 |
|---|---|
| Importar directamente el CSV | Recuperar resultados de módulos 5–7 guardados en archivos. |
| Crear una tabla de frecuencias | Integrar indicadores de completitud, validez y unicidad. |
| Crear un gráfico sencillo | Incluir varios gráficos de seguimiento y comparación. |
| Escribir conclusiones manualmente | Elaborar conclusiones basadas en incidencias y reglas documentadas. |
| Renderizar HTML y DOCX | Introducir parámetros por período, automatización y validación de entradas. |

**Referencias:** [Quarto — Hello](https://quarto.org/docs/get-started/hello/rstudio.html); [Quarto — Using R](https://quarto.org/docs/computations/r.html); [Quarto — RStudio](https://quarto.org/docs/tools/rstudio). Los ejemplos y datos del taller son sintéticos y no sustituyen procedimientos institucionales del INEC.
