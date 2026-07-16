# ---------- Etapa 1: entrenamiento ----------
# Aqui vive todo lo pesado: pandas, datos, el script de training.
# Nada de esta etapa llega a la imagen final salvo lo que se copie explicitamente.
FROM python:3.12-slim AS trainer

WORKDIR /app

COPY requirements-train.txt .
RUN pip install --no-cache-dir -r requirements-train.txt

COPY train.py .

# El entrenamiento ocurre DURANTE el build y genera model.joblib
RUN python train.py

# ---------- Etapa 2: servir ----------
# Imagen limpia: solo lo minimo para cargar el modelo y responder predicciones
FROM python:3.12-slim

WORKDIR /app

COPY requirements-serve.txt .
RUN pip install --no-cache-dir -r requirements-serve.txt

# Se copia SOLO el artefacto desde la etapa de entrenamiento
COPY --from=trainer /app/model.joblib .

COPY serve.py .

EXPOSE 5000

CMD ["uvicorn", "serve:app", "--host", "0.0.0.0", "--port", "5000"]
