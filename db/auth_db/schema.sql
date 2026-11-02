CREATE DATABASE auth_db;
\c auth_db;

CREATE TABLE persons (
    user_id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('OWNER', 'VET', 'STAFF', 'ADMIN'))
);
