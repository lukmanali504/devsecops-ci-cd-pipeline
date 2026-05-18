FROM python:3.7

WORKDIR /app

RUN apt-get update && \
    apt-get install -y openssl telnet ftp vim

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

USER root

CMD ["python", "app.py"]
