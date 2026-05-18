FROM python:3.11-slim

WORKDIR /app

RUN adduser --disabled-password appuser

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

USER appuser

CMD ["python", "app.py"]
