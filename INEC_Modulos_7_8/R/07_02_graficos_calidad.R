# =============================================================================
# MÓDULO 7.2 | GRÁFICOS PARA VISUALIZAR E INTERPRETAR LA CALIDAD
# PRERREQUISITO: 07_01_tablas_calidad.R (02_analisis_modulo_7.rds)
# OBJETIVO: representar datos calculados; no inventar nuevos recuentos.
# =============================================================================
library(here)
library(dplyr)
library(ggplot2)

ruta_resumen <- here::here("resultados", "02_analisis_modulo_7.rds")
if (!file.exists(ruta_resumen)) stop("Ejecute antes 07_01_tablas_calidad.R")
a <- readRDS(ruta_resumen)
carpeta_figuras <- here::here("resultados", "figuras")
dir.create(carpeta_figuras, recursive = TRUE, showWarnings = FALSE)

# GRÁFICO 1. Barras agrupadas: tres indicadores en dos escenarios.
# geom_col() usa el valor de porcentaje existente; position_dodge() separa barras.
g_indicadores <- ggplot(a$indicadores_long,
                        aes(x = indicador, y = porcentaje, fill = escenario)) +
  geom_col(position = position_dodge(width = 0.75), width = 0.65) +
  geom_text(aes(label = paste0(format(porcentaje, decimal.mark=",", nsmall=2), "%")),
            position = position_dodge(width = 0.75), vjust = -0.25, size = 3) +
  coord_cartesian(ylim = c(0, 105)) +
  labs(title = "Indicadores de calidad: original y propuesta",
       subtitle = "Escenarios didácticos; la propuesta no constituye aprobación",
       x = NULL, y = "Porcentaje de evaluaciones", fill = "Escenario") +
  theme_minimal(base_size = 11)
print(g_indicadores)
ggsave(file.path(carpeta_figuras, "07_indicadores_escenarios.png"),
       plot = g_indicadores, width = 9, height = 5.5, dpi = 170)

# GRÁFICO 2. Eventos por regla, separados según su procedencia.
g_alertas <- ggplot(a$incidencias,
                    aes(x = reorder(regla_id, incidencias), y = incidencias,
                        fill = origen)) +
  geom_col() + coord_flip() +
  labs(title = "Número de alertas por regla", x = "Código de regla",
       y = "Eventos de alerta", fill = "Origen") +
  theme_minimal(base_size = 11)
print(g_alertas)
ggsave(file.path(carpeta_figuras, "07_alertas_por_regla.png"),
       plot = g_alertas, width = 9, height = 5.5, dpi = 170)

# GRÁFICO 3. Número de ausencias de los seis campos declarados obligatorios.
g_ausencias <- ggplot(a$faltantes,
                      aes(x = reorder(variable, ausencias), y = ausencias)) +
  geom_col(fill = "#2476A3") + coord_flip() +
  geom_text(aes(label = ausencias), hjust = -0.12, size = 3) +
  labs(title = "Ausencias en campos requeridos", x = NULL,
       y = "Número de celdas ausentes") +
  theme_minimal(base_size = 11)
print(g_ausencias)
ggsave(file.path(carpeta_figuras, "07_ausencias_campos.png"),
       plot = g_ausencias, width = 9, height = 5.5, dpi = 170)

# VERIFICACIÓN: listar imágenes realmente generadas.
list.files(carpeta_figuras, pattern = "^07_.*\\.png$", full.names = TRUE)
# Pregunta: ¿qué diferencia existe entre eventos de alerta y filas afectadas?
