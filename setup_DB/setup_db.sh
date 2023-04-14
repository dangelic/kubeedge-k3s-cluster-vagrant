#!/bin/bash

# Install PostgresDB
sudo apt install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update
apt install postgresql postgresql-contrib

# Define the new password for the postgres user
NEW_PASSWORD="postgres"
# Execute the ALTER USER command using psql with -c option
psql -U postgres -c "ALTER USER postgres WITH PASSWORD '$NEW_PASSWORD';"

# Check the exit status of the psql command
if [ $? -eq 0 ]; then
    echo "Password for postgres user has been changed."
else
    echo "Failed to change password for postgres user."
fi

# Define the database name
DB_NAME="mqtt"

# Define the create database SQL statement
CREATE_DB_SQL="CREATE DATABASE $DB_NAME;"



# Create table for RAW MQTT data
TABLE_NAME="mqtt_data_raw"

# Define the SQL query to create the table
SQL_QUERY="CREATE TABLE IF NOT EXISTS $TABLE_NAME (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  data JSON
);"

# Execute the SQL query using psql
psql -U postgres -d $DATABASE_NAME -c "$SQL_QUERY"

# Check the exit status of the psql command
if [ $? -eq 0 ]; then
    echo "Table $TABLE_NAME has been created."
else
    echo "Failed to create table $TABLE_NAME."
fi

# Create table for PROCESSED MQTT data

TABLE_NAME="mqtt_data_processed"

# Define the SQL query to create the table
SQL_QUERY="CREATE TABLE IF NOT EXISTS $TABLE_NAME (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  data JSON
);"

# Execute the SQL query using psql
psql -U postgres -d $DATABASE_NAME -c "$SQL_QUERY"

# Check the exit status of the psql command
if [ $? -eq 0 ]; then
    echo "Table $TABLE_NAME has been created."
else
    echo "Failed to create table $TABLE_NAME."
fi