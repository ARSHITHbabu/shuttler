-- PostgreSQL Database Setup Script
-- Run this in pgAdmin or psql after installing PostgreSQL

-- Create the database
CREATE DATABASE badminton_academy;

-- Connect to the database (in psql, use: \c badminton_academy)
-- In pgAdmin, right-click on the database and select "Query Tool"

-- Verify the database was created
SELECT datname FROM pg_database WHERE datname = 'badminton_academy';
