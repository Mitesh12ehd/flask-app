# Flask App with MySQL — CI/CD using Jenkins

A simple Flask web application connected to a MySQL database, with a Jenkins pipeline for automated build and deployment to an EC2 instance using Docker.

---

## Project Overview

- **Backend:** Python / Flask
- **Database:** MySQL 8
- **Containerization:** Docker, Docker Compose
- **CI/CD:** Jenkins
- **Deployment Target:** AWS EC2

---

## Run Locally

### Prerequisites

- Python 3
- pip3
- MySQL Server

### 1. Install and Start MySQL

```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
```

### 2. Create Database and User

```bash
sudo mysql
```

```sql
CREATE DATABASE flaskdb;
CREATE USER 'flaskuser'@'localhost' IDENTIFIED BY 'flaskpass';
GRANT ALL PRIVILEGES ON flaskdb.* TO 'flaskuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Install MySQL Client Libraries

These are required to build the `mysqlclient` Python package.

```bash
sudo apt update
sudo apt install pkg-config default-libmysqlclient-dev build-essential python3-dev
```

| Package | Purpose |
|---|---|
| `pkg-config` | Helps the compiler locate MySQL libraries |
| `default-libmysqlclient-dev` | Provides MySQL header files |
| `build-essential` | Installs gcc, g++, make |
| `python3-dev` | Python headers needed for building extensions |

### 4. Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
```

### 5. Install Dependencies

```bash
pip install -r requirements.txt
```

### 6. Set Environment Variables

```bash
export MYSQL_HOST=localhost
export MYSQL_USER=flaskuser
export MYSQL_PASSWORD=flaskpass
export MYSQL_DB=flaskdb
```

### 7. Run the Application

```bash
python3 app.py
```

The app will be available at `http://localhost:5000`.

---

## Dockerfile

Uses `python:3.10-slim` as the base image. Installs the required system dependencies (`gcc`, `default-libmysqlclient-dev`, `pkg-config`) needed to build the `mysqlclient` Python package, then installs Python dependencies and starts the app on port 5000.

Refer to `Dockerfile` in the repository.

---

## Docker Compose

Defines two services: the Flask app and the MySQL database, both on the same Docker network.

The image name is set dynamically via environment variables (`DOCKER_REPO` and `IMAGE_NAME`) so each Jenkins build deploys the correct image tag. The MySQL service includes a healthcheck so the Flask app only starts once the database is ready.

Refer to `docker-compose.yaml` in the repository.

---

## Jenkins CI/CD Pipeline

### Infrastructure Setup

1. Create an EC2 instance.
2. Install and configure Jenkins on the instance.
3. Install Docker on the Jenkins server.

### Required Jenkins Credentials

| Credential ID | Type | Description |
|---|---|---|
| `docker-hub-cred` | Username/Password | Docker Hub login |
| `ec2-server-key` | SSH Private Key | SSH access to the deployment EC2 instance |

### Pipeline Stages

**Stage 1 — Build Image**

Builds a Docker image from the repository. The image is tagged using the Jenkins build number to ensure each build produces a unique, traceable image.

**Stage 2 — Push Image**

Logs in to Docker Hub using stored credentials and pushes the tagged image to the private repository.

**Stage 3 — Deploy Application**

Connects to the target EC2 instance over SSH and performs the following steps:

1. Copies `docker-compose.yaml` to the server.
2. Logs in to Docker Hub on the remote server.
3. Runs `docker compose down` to stop the running containers.
4. Runs `docker compose up -d` with the new image tag passed as environment variables.
5. Prunes unused Docker images from the Jenkins server.

Refer to `Jenkinsfile` in the repository.

---

## Webhook Trigger

To trigger the pipeline automatically on every push to the repository:

1. In Jenkins, open your pipeline job and go to **Configure**.
2. Under **Build Triggers**, enable **GitHub hook trigger for GITScm polling**.
3. In your GitHub repository, go to **Settings > Webhooks > Add webhook**.
4. Set the Payload URL to `http://<JENKINS_SERVER_IP>:8080/github-webhook/`.
5. Set Content type to `application/json`.
6. Select **Just the push event** and save.

Jenkins will now automatically start a new build whenever code is pushed to the repository.