#!/usr/bin/env bash
set -e

# Function to check if a variable is set
check_env_var() {
    if [ -z "${!1}" ]; then
        echo "Error: $1 is not set"
        exit 1
    fi
}

# Function to handle signals
handle_signal() {
    echo "Received signal. Shutting down gracefully..."
    kill -TERM $GUNICORN_PID
    wait $GUNICORN_PID
    exit 1
}

# Set up signal handlers
trap handle_signal SIGTERM SIGINT

# Check required environment variables
check_env_var "DOCKER_DB_NAME"
check_env_var "DOCKER_DB_USER"
check_env_var "DOCKER_DB_PASSWORD"
check_env_var "DOCKER_DB_HOST"

echo "Waiting for postgres to connect ..."

# Try to connect to PostgreSQL with a timeout
TIMEOUT=30
COUNTER=0
while ! nc -z $DOCKER_DB_HOST 5432; do
    sleep 1
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -ge $TIMEOUT ]; then
        echo "Error: Could not connect to PostgreSQL after $TIMEOUT seconds"
        exit 1
    fi
done

echo "PostgreSQL is active"

# Run Django commands
echo "Collecting static files..."
python manage.py collectstatic --noinput --clear
echo "Static files collected in $(pwd)/staticfiles"

# Handle migrations
echo "Creating migrations..."
python manage.py makemigrations

echo "Checking for pending migrations..."
python manage.py showmigrations

echo "Applying migrations..."
python manage.py migrate --noinput

# Create superuser if environment variables are set
if [ "$DJANGO_SUPERUSER_USERNAME" ] && [ "$DJANGO_SUPERUSER_EMAIL" ] && [ "$DJANGO_SUPERUSER_PASSWORD" ]; then
    echo "Creating superuser..."
    # Check if superuser exists
    if python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print(User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists())" | grep -q "True"; then
        echo "Superuser already exists, updating password..."
        python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username='$DJANGO_SUPERUSER_USERNAME'); user.set_password('$DJANGO_SUPERUSER_PASSWORD'); user.save()"
    else
        echo "Creating new superuser..."
        python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')"
    fi
else
    echo "Warning: Superuser environment variables not set. Skipping superuser creation."
fi

echo "Postgresql migrations finished"

# Start Gunicorn WSGI server
echo "Starting Gunicorn WSGI server..."
gunicorn truck_signs_designs.wsgi:application --bind 0.0.0.0:8020 --workers 3 --timeout 120 --error-logfile - --access-logfile - --capture-output --enable-stdio-inheritance --preload &
GUNICORN_PID=$!

# Wait for Gunicorn to finish
wait $GUNICORN_PID