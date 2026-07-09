FROM python:3.14.6-trixie

WORKDIR /app 

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=5000"]

