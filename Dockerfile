FROM python:3.10-slim

WORKDIR /app

# Install system dependencies required for mysqlclient
RUN apt-get update && apt-get install -y \
gcc \
default-libmysqlclient-dev \
pkg-config && \
rm -rf /var/lib/apt/lists/* 

COPY requirements.txt .

# Install python dependencies without cache
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python","app.py"]