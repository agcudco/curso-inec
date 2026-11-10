# INEC | TALLER MÓDULOS 7 y 8 (PARA CONSTRUIR DURANTE LA CLASE)
# No se resuelven aquí las actividades; use la guía y scripts como apoyo.

# ACTIVIDAD 1. Abra el .Rproj y reconstruya primero los objetos 5 y 6.
# TODO: ejecutar y comprender 06_99_guardar_hitos_para_reporte.R

# ACTIVIDAD 2. Recuperar los resultados guardados.
# TODO: asignar hitos <- readRDS(here::here(...))

# ACTIVIDAD 3. Pasar indicadores al formato largo.
# TODO: unir indicadores_antes y indicadores_propuestos con bind_rows()

# ACTIVIDAD 4. Pasar indicadores a formato ancho.
# TODO: aplicar pivot_wider() y calcular variacion_pp

# ACTIVIDAD 5. Construir una tabla de eventos por regla.
# TODO: count(regla_id, severidad) sobre alertas_logicas e integridad

# ACTIVIDAD 6. Contar filas distintas con alertas.
# TODO: union() sobre fila_csv y contar sin NA

# ACTIVIDAD 7. Crear gráficos 1–3 con ggplot2.
# TODO: geom_col(), geom_text(), coord_flip(), ggsave()

# ACTIVIDAD 8. Comprobar si existe otro período real.
# TODO: explicar por qué 2026/10 no constituye otro mes

# ACTIVIDAD 9. Crear QMD y redactar YAML.
# TODO: formatos HTML + Word; params: periodo: "2026-10"

# ACTIVIDAD 10. Añadir setup, tabla, figuras y conclusiones.
# TODO: knitr::kable(), knitr::include_graphics(), expresiones inline R

# ACTIVIDAD 11. Renderizar, comparar y revisar outputs.
# TODO: usar la terminal para quarto render ... --to html / docx
