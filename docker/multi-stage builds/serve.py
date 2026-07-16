import joblib
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Iris API")

# El modelo se carga una sola vez, al arrancar el contenedor
artifact = joblib.load("model.joblib")
model = artifact["model"]
target_names = artifact["target_names"]


class PredictRequest(BaseModel):
    features: list[float]


@app.post("/predict")
def predict(body: PredictRequest):
    prediction = model.predict([body.features])[0]
    probabilities = model.predict_proba([body.features])[0]

    return {
        "prediction": target_names[prediction],
        "probabilities": {
            name: round(float(p), 3)
            for name, p in zip(target_names, probabilities)
        },
    }


@app.get("/health")
def health():
    return {"status": "ok"}
