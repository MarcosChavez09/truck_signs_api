# Truck signs API

## Description

A repository with a step-by-step guide on how to dockerize a Django online store app and deploy it to a V-Server.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick start](#quick-start)
3. [Usage](#usage)
    - [Configure the environment variables](#configure-the-environment-variables)
    - [Create a docker container](#create-a-docker-container)
    - [Starting and stopping the containers](#starting-and-stopping-the-containers)
    - [Deploy the app to a V-Server](#deploy-the-app-to-a-v-server)

4. [Project Checklist](#project-checklist)

## Prerequisites

- A user with `sudo` rights to a V-Server
- Docker installed in your V-Server
- GitHub account to connect via `SSH keys`
- Connection from your V-Server to GitHub with `SSH Keys`

## Quick start

Clone this repository to your local machine. Open your terminal and run the following commands:

With SSH configured (if SSH Keys are provided to GitHub)
```
git clone git@github.com:MarcosChavez09/truck_signs_api.git
```
Classic HTTPS (if no SSH Keys are provided to GitHub)
```
git clone https://github.com/MarcosChavez09/truck_signs_api.git
```
After cloning the repository, navigate to:

```
cd truck_signs_api
```

#### Configure the environment variables.

Copy the content of the `simple_env_config.env` file that is inside the `truck_signs_designs/settings` folder into a `.env` file:

```
cd truck_signs_designs/settings && cp simple_env_config.env .env
```

Provide values for the variables: 

```
SECRET_KEY=<your_secret_key>
DB_PASSWORD=<your_db_password>
DOCKER_DB_PASSWORD=<your_db_password>
DJANGO_SUPERUSER_USERNAME=<your_admin_user_name>
DJANGO_SUPERUSER_PASSWORD=<your_admin_password>

```

> **_NOTE:_** To generate a secret key, run this one-liner in your terminal and copy the output:
> ```
>python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'

Create your virtual environment:

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

Open the link http://localhost:8000/admin

## Usage

### Create a docker container.

To create the docker container use the `start.sh` script, type the following in your terminal:

```
bash start.sh
```

or
```
./start.sh
```
The script will start the web and the database container. Visit http://localhost:8020/admin

You can log in as admin with the provided values for the `django superuser`.

### Starting and stopping the containers.

To stop all running containers:
```
docker stop $(docker ps -a -q)
```

To remove all containers (this will delete all containers, not just the ones from this project):
```
docker rm $(docker ps -a -q)
```

To stop and remove only the containers used by this project: 
```
docker stop truck-signs-web truck_signs_db
docker rm truck-signs-web truck_signs_db
```

To remove the database volume (this will delete all data in the database):
```
docker volume rm truck_signs_postgres_data
```

To restart the application, just run the `start.sh` script again.

### Deploy the app to a V-Server.

1. Login to your V-Server
```
    ssh -i ~/.ssh/<name_of_your_key25519> <your_user_name>@<ip_server_address>
```
2. Create a new folder in your `home` directory and clone this repository there
```
    mkdir -p ~/projects
    cd ~/projects
    git clone git@github.com:MarcosChavez09/truck_signs_api.git
```
3. Copy the content of the `simple_env_config.env` file that is inside the `truck_signs_designs/settings` folder into a `.env` file. Open your `.env` file, find `ALLOWED_HOSTS` and add your `<ip_server_address>`

> **_NOTE:_** Same step as before but this time on you V-Server.

```
# .env

    ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,<your_server_ip> 
``` 
4. Install Docker on your V-Server if you haven't done so yet. 

5. Start the `start.sh` script again.

6. Visit the link `http://<ip_server_address>:8020/admin`

## Project Checklist

- 📄 [Checklist (PDF)](docs/checklist.pdf)