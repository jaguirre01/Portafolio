import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import (
    accuracy_score, classification_report, confusion_matrix, roc_auc_score, RocCurveDisplay
)
from xgboost import XGBClassifier
import os

# Nombre del archivo CSV
data_file = 'clientes.csv'

# Crear un DataFrame inicial con datos base
data = pd.DataFrame({
    'ingresos_mensuales': [1200, 800, 1500],
    'edad': [35, 29, 40],
    'deudas_totales': [5000, 2000, 3000],
    'numero_tarjetas': [2, 1, 3],
    'historial_crediticio': ['Bueno', 'Malo', 'Regular'],
    'tasa_de_interes': [12.5, 20.0, 15.0],
    'mora_actual': [0, 1, 0],
    'moroso': [0, 1, 0]
})

# Generar datos adicionales para alcanzar 50,000 registros
np.random.seed(42)
for _ in range(49997):
    new_data = data.sample(n=1).copy()
    new_data['ingresos_mensuales'] += np.random.randint(-500, 500)
    new_data['edad'] += np.random.randint(-10, 10)
    new_data['deudas_totales'] += np.random.randint(-1000, 1000)
    new_data['numero_tarjetas'] += np.random.randint(-1, 1)
    new_data['tasa_de_interes'] += np.random.uniform(-5, 5)
    new_data['mora_actual'] = np.random.randint(0, 2)
    new_data['moroso'] = np.random.randint(0, 2)
    data = pd.concat([data, new_data], ignore_index=True)

# Guardar el DataFrame en un archivo CSV
data.to_csv(data_file, index=False)
print(f"Archivo CSV creado: {data_file}")

# Leer el archivo CSV como entrada
data = pd.read_csv(data_file)

# Convertir historial_crediticio a numérico
if data['historial_crediticio'].dtype == 'object':
    encoder = LabelEncoder()
    data['historial_crediticio'] = encoder.fit_transform(data['historial_crediticio'])

# Visualización inicial de los datos
print("Datos cargados desde el CSV:")
print(data.head())
sns.pairplot(data, hue="moroso", diag_kind="kde")
plt.suptitle("Exploración de Datos (Relación entre variables)", y=1.02)
plt.show()

# Preprocesamiento de características
X = data.drop(columns=['moroso'])
y = data['moroso']

# Escalado de características numéricas
scaler = StandardScaler()
X[['ingresos_mensuales', 'edad', 'deudas_totales', 'numero_tarjetas', 'tasa_de_interes']] = scaler.fit_transform(
    X[['ingresos_mensuales', 'edad', 'deudas_totales', 'numero_tarjetas', 'tasa_de_interes']]
)

# Dividir en entrenamiento (80%) y prueba (20%)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Verificar las dimensiones de los conjuntos
print(f"Datos de entrenamiento: {X_train.shape}, Datos de prueba: {X_test.shape}")

# Configurar y entrenar el modelo con GridSearchCV
param_grid = {
    'learning_rate': [0.01, 0.1, 0.3],
    'max_depth': [3, 4, 6],
    'n_estimators': [100, 200, 300],
    'subsample': [0.8, 0.9, 1],
    'colsample_bytree': [0.8, 0.9, 1]
}

xgb = XGBClassifier(use_label_encoder=False, eval_metric='logloss')
grid_search = GridSearchCV(xgb, param_grid, cv=3, scoring='accuracy', verbose=1)
grid_search.fit(X_train, y_train)

# Mejor modelo
print(f"Mejores parámetros: {grid_search.best_params_}")

# Predicciones con el mejor modelo
y_pred = grid_search.best_estimator_.predict(X_test)
y_prob = grid_search.best_estimator_.predict_proba(X_test)[:, 1]

# Evaluar el modelo
accuracy = accuracy_score(y_test, y_pred)
roc_auc = roc_auc_score(y_test, y_prob)

print(f"Precisión: {accuracy:.2f}")
print(f"ROC AUC: {roc_auc:.2f}")
print("\nReporte de Clasificación:\n", classification_report(y_test, y_pred))

# Matriz de Confusión
cm = confusion_matrix(y_test, y_pred)
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=['No Moroso', 'Moroso'], yticklabels=['No Moroso', 'Moroso'])
plt.xlabel('Predicción')
plt.ylabel('Real')
plt.title('Matriz de Confusión')
plt.show()

# Curva ROC
RocCurveDisplay.from_estimator(grid_search.best_estimator_, X_test, y_test)
plt.title("Curva ROC")
plt.show()
