CREATE DATABASE payment_db;
\c payment_db;

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL, -- Logical FK -> booking_db.bookings(booking_id)
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    idem_key VARCHAR(255) UNIQUE NOT NULL
);
