library(rvest)
library(dplyr)

#########################################################################
#1. Elección del conjunto de datos
#########################################################################


# URL de la página web
url <- "https://datosmacro.expansion.com/demografia/poblacion/el-salvador"

# Leer datos
page <- read_html(url)

# Creo un "Metodo" para leer la tabla una vez inicialice el url
table <- page %>%
  html_node("table#tb0") %>%
  html_table(fill = TRUE)

print(cleaned_data)


# Si la respuesta es "ok", realizo algunas transformaciones.
# Primero, limpio la tabla usando la función mutate(across(...)).
# Esto es similar a usar replace, debido a que los valores vienen con ".",
# los reemplazo por "" y finalmente convierto los datos a enteros.

cleaned_data <- table %>%
  slice(-1) %>%
  mutate(across(c(Hombres, Mujeres, Población), ~ gsub("\\.", "", .))) %>%
  mutate(across(c(Hombres, Mujeres, Población), as.integer))

# Ver los datos finales
print(cleaned_data)

