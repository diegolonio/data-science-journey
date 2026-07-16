import pandas as pd
import joblib
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

# Cargar datos como DataFrame (pandas solo se usa aqui, en entrenamiento)
iris = load_iris(as_frame=True)
X = iris.data
y = iris.target

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

accuracy = model.score(X_test, y_test)
print(f"Accuracy en test: {accuracy:.3f}")

# Guardar el artefacto: esto es lo UNICO que pasa a la imagen final
joblib.dump(
    {"model": model, "target_names": list(iris.target_names)},
    "model.joblib",
)
print("Modelo guardado en model.joblib")
