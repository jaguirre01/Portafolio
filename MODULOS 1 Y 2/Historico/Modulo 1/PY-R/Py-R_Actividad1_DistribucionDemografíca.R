# Enviar los datos a Python para su análisis y visualización
# Convertir el dataframe de R a un DataFrame de pandas en Python
py_cleaned_data <- r_to_py(cleaned_data)

# Ejecutar código Python para el análisis de datos
py$py_cleaned_data <- py_cleaned_data  # Pasar la variable a Python

py_run_string("
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Acceder a los datos limpios desde R
data = py_cleaned_data  # Ahora puedes acceder a la variable directamente

# Análisis exploratorio de datos en Python
summary_stats = data.describe()

# Visualización en Python utilizando Matplotlib y Seaborn
plt.figure(figsize=(10, 6))
sns.lineplot(x='Fecha', y='Población', data=data, marker='o', color='blue')
plt.title('Tendencia de la Población en El Salvador')
plt.xlabel('Año')
plt.ylabel('Población')
plt.show()

# Comparación de hombres y mujeres
plt.figure(figsize=(10, 6))
sns.lineplot(x='Fecha', y='Hombres', data=data, marker='o', label='Hombres', color='blue')
sns.lineplot(x='Fecha', y='Mujeres', data=data, marker='o', label='Mujeres', color='pink')
plt.title('Comparación de Hombres y Mujeres en El Salvador')
plt.xlabel('Año')
plt.ylabel('Número de Personas')
plt.legend()
plt.show()

# Exportar los datos limpios a Excel
data.to_excel('poblacion_el_salvador_limpio.xlsx', index=False)
")
