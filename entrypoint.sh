#!/bin/bash

# Exit on subcommand errors
set -Eeuo pipefail

# Start the PostgreSQL server
service postgresql start

# Setup users
sudo -u postgres createuser root --superuser --login
sudo -u postgres psql -c "CREATE ROLE $POSTGRES_USER PASSWORD '$POSTGRES_PASSWORD' SUPERUSER LOGIN"
sudo -u postgres createdb "$POSTGRES_DB" --owner "$POSTGRES_USER"
# TODO: is this needed?
sudo -u postgres psql -c "ALTER ROLE $POSTGRES_USER SET search_path TO public,pgml"

echo "PostgreSQL is up - installing extensions..."

# Preinstall some extensions for the user
PGPASSWORD=$POSTGRES_PASSWORD psql -c 'CREATE EXTENSION IF NOT EXISTS pg_bm25' -d "$POSTGRES_DB" -U "$POSTGRES_USER" -h 127.0.0.1 -p 5432
PGPASSWORD=$POSTGRES_PASSWORD psql -c 'CREATE EXTENSION IF NOT EXISTS pg_ivm' -d "$POSTGRES_DB" -U "$POSTGRES_USER" -h 127.0.0.1 -p 5432
PGPASSWORD=$POSTGRES_PASSWORD psql -c 'CREATE EXTENSION IF NOT EXISTS pg_graphql' -d "$POSTGRES_DB" -U "$POSTGRES_USER" -h 127.0.0.1 -p 5432
PGPASSWORD=$POSTGRES_PASSWORD psql -c 'CREATE EXTENSION IF NOT EXISTS pgml' -d "$POSTGRES_DB" -U "$POSTGRES_USER" -h 127.0.0.1 -p 5432
PGPASSWORD=$POSTGRES_PASSWORD psql -c 'CREATE EXTENSION IF NOT EXISTS vector' -d "$POSTGRES_DB" -U "$POSTGRES_USER" -h 127.0.0.1 -p 5432

echo "PostgreSQL extensions installed - tailing server..."

# Keep the container running
tail -f /dev/null

echo "PostgreSQL server has stopped - exiting..."
