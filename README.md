# Truck signs API

## Description
A repository with a step-by-step guide on how to dockerize a Django app and deploy it to a V-Server.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick start](#quick-start)
3. [Usage](#usage)
    - [Create a docker container](#create-a-docker-container)
    - [Deploy the app to a V-Server](#deploy-the-app-to-a-v-server)

4. [Project Checklist](#project-checklist)

## Prerequisites

- A user with `sudo` rights to a V-Server
- Docker installed in your V-Server
- GitHub account to connect via `SSH keys`
- Connection from your V-Server to GitHub with `SSH Keys`

## Quick start

Clone this repository to your local machine and follow the README.md instructions.

Open your command line and type the following commands:

With SSH configured (if SSH Keys are provided to GitHub)
```
git clone 
```
Classic HTTPS (if no SSH Keys are provided to GitHub)
```
git clone
```
After cloning the repository, navigate to:

```
cd baby-tools-shop/babyshop_app
```

Create you virtual environment:

On macOS
```
    python3 -m venv .venv
```
On Linux
```
    python -m venv .venv
```

Activate your venv:
```
source .venv/bin/activate
```

> **_NOTE:_** To deactivate your venv, just type `deactivate` in the command line.

Install dependencies:
```
pip install -r requirements.txt
```
Run migrations:
On macOS
```
   python3 manage.py migrate
```
On Linux
```
    python manage.py migrate
```
Start the development server:
```
   python manage.py runserver
```

Open the link http://localhost:8000

## Usage

### Create a docker container.

To crete the docker comntainer use the `docker-compose.yml` file, type the following in your ternimal:

```
docker-compose build --no-cache
```

After that run:
```
docker-compose up
```

Two container will be running, the truck signs app and a postgresSQL container that comunicates with the app throught the port. 