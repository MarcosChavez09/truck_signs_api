#!/usr/bin/env bash
set -e

# Function to check if a variable is set
check_env_var() {
    if [ -z "${!1}" ]; then
        echo "Error: $1 is not set"
        exit 1
    fi
}

# Check required environment variables
check_env_var "DOCKER_DB_NAME"
check_env_var "DOCKER_DB_USER"
check_env_var "DOCKER_DB_PASSWORD"
check_env_var "DOCKER_DB_HOST"

echo "Waiting for postgres to connect ..."

while ! nc -z $DOCKER_DB_HOST 5432; do
  sleep 0.1
done

echo "PostgreSQL is active"

# Run Django commands
echo "Current directory: $(pwd)"
echo "Listing staticfiles directory before collectstatic:"
ls -la staticfiles/ || echo "staticfiles directory doesn't exist yet"

echo "Collecting static files..."
python manage.py collectstatic --noinput --clear
echo "Static files collected in $(pwd)/staticfiles"

# Handle migrations
echo "Creating migrations..."
python manage.py makemigrations

echo "Checking for pending migrations..."
python manage.py showmigrations

echo "Applying migrations..."
python manage.py migrate

# Create superuser if environment variables are set
if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "Creating superuser..."
    python manage.py createsuperuser \
        --noinput \
        --username "$DJANGO_SUPERUSER_USERNAME" \
        --email "$DJANGO_SUPERUSER_EMAIL" || true
else
    echo "Warning: Superuser environment variables not set. Skipping superuser creation."
fi

echo "Postgresql migrations finished"

# Start Django development server
echo "Starting Django development server..."
python manage.py runserver 0.0.0.0:8020