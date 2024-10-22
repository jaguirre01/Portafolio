#######################################
#Este script tiene como objetivo analizar el crecimiento de la población en 
#El Salvador, enfocándome en las diferencias entre hombres y mujeres. 
#Quiero entender las tendencias demográficas y presentar los resultados de una 
#manera visual y atractiva, utilizando gráficos y tarjetas informativas. 
#Esto hará que los datos sean más fáciles de interpretar y ayudará a comunicar 
#los resultados a diferentes audiencias
#######################################


# Cargar librerías necesarias
library(rvest)      # Para leer contenido HTML
library(dplyr)      # Para manipular y limpiar datos
library(ggplot2)    # Para crear gráficos
library(htmltools)  # Para trabajar con HTML
library(writexl)    # Para exportar a Excel

#######################################
# 1. Elección del conjunto de datos
#######################################

url <- "https://datosmacro.expansion.com/demografia/poblacion/el-salvador"
page <- read_html(url)
table <- page %>% html_node("table#tb0") %>% html_table(fill = TRUE)

#######################################
# 2. Limpieza y transformación de los datos4
#######################################Q
cleaned_data <- table %>%
  slice(-1) %>%  # Eliminar la primera fila
  mutate(across(c(Hombres, Mujeres, Población), ~ gsub("\\.", "", .))) %>%  # Reemplazar puntos por comas
  mutate(across(c(Hombres, Mujeres, Población), as.integer))  # Convertir a enteros

#######################################
# 3. Análisis exploratorio de datos (EDA)
#######################################

summary_stats <- cleaned_data %>%
  summarise(
    Media_Hombres = mean(Hombres),
    Media_Mujeres = mean(Mujeres),
    Media_Poblacion = mean(Población),
    Max_Hombres = max(Hombres),
    Max_Mujeres = max(Mujeres),
    Max_Poblacion = max(Población),
    Min_Hombres = min(Hombres),
    Min_Mujeres = min(Mujeres),
    Min_Poblacion = min(Población)
  )
print(summary_stats)

#######################################
# 4. Visualización de resultados
#######################################

stat_cards <- tags$div(
  style = "display: flex; flex-wrap: wrap; gap: 20px;",
  # Tarjetas para estadísticas
  tags$div(
    style = "border: 1px solid #007BFF; border-radius: 5px; padding: 10px; width: 200px; background-color: #E7F3FF;",
    tags$h3("Promedio de Hombres"),
    tags$p(style = "font-size: 24px; font-weight: bold; color: #007BFF;", sprintf("%.0f", summary_stats$Media_Hombres))
  ),
  tags$div(
    style = "border: 1px solid #FF69B4; border-radius: 5px; padding: 10px; width: 200px; background-color: #FFEBEE;",
    tags$h3("Promedio de Mujeres"),
    tags$p(style = "font-size: 24px; font-weight: bold; color: #FF69B4;", sprintf("%.0f", summary_stats$Media_Mujeres))
  ),
  tags$div(
    style = "border: 1px solid #FFA500; border-radius: 5px; padding: 10px; width: 200px; background-color: #FFF3CD;",
    tags$h3("Diferencia de Género"),
    tags$p(style = "font-size: 24px; font-weight: bold; color: #FFA500;", sprintf("%.0f", summary_stats$Media_Mujeres - summary_stats$Media_Hombres))
  ),
  tags$div(
    style = "border: 1px solid #28A745; border-radius: 5px; padding: 10px; width: 200px; background-color: #D4EDDA;",
    tags$h3("Población Total Promedio"),
    tags$p(style = "font-size: 24px; font-weight: bold; color: #28A745;", sprintf("%.0f", summary_stats$Media_Poblacion))
  ),
  # Tarjeta de Conclusiones ajustada al mismo tamaño y usando variables
  tags$div(
    style = "border: 1px solid #6c757d; border-radius: 5px; padding: 10px; width: 930px; background-color: #f8f9fa;",
    tags$h3("Conclusiones"),
    tags$ul(
      tags$li(sprintf("Población Promedio: Aproximadamente %.0f personas; %.0f hombres y %.0f mujeres.", 
                      summary_stats$Media_Poblacion, summary_stats$Media_Hombres, summary_stats$Media_Mujeres)),
      tags$li(sprintf("Máximos y Mínimos: Máximo de %.0f personas y mínimo de %.0f.", 
                      summary_stats$Max_Poblacion, summary_stats$Min_Poblacion)),
      tags$li(sprintf("Diferencia de Género: Promedio de %.0f mujeres más que hombres.", 
                      summary_stats$Media_Mujeres - summary_stats$Media_Hombres)),
      tags$li("Recomendación general: Implementar un sistema de seguimiento regular para adaptar políticas públicas según las tendencias de crecimiento poblacional.."),
    )
  )
)

html_print(stat_cards)

# Gráfico de la tendencia de la población total
ggplot(cleaned_data, aes(x = Fecha, y = Población)) +
  geom_line(color = "blue") +
  geom_point(color = "red") +
  labs(title = "Tendencia de la Población en El Salvador",
       x = "Año",
       y = "Población") +
  theme_minimal()

# Comparación de hombres y mujeres
ggplot(cleaned_data, aes(x = Fecha)) +
  geom_line(aes(y = Hombres, color = "Hombres")) +
  geom_line(aes(y = Mujeres, color = "Mujeres")) +
  geom_point(aes(y = Hombres, color = "Hombres")) +
  geom_point(aes(y = Mujeres, color = "Mujeres")) +
  labs(title = "Comparación de Hombres y Mujeres en El Salvador",
       x = "Año",
       y = "Número de Personas") +
  scale_color_manual(values = c("Hombres" = "blue", "Mujeres" = "pink")) +
  theme_minimal()

# Gráfico de densidad poblacional
ggplot(cleaned_data, aes(x = Fecha, y = Densidad)) +
  geom_line(color = "green") +
  geom_point(color = "darkgreen") +
  labs(title = "Densidad Poblacional en El Salvador)",
       x = "Año",
       y = "Densidad") +
  theme_minimal()