CREATE DATABASE medical_db;
\c medical_db;

CREATE TABLE pet_medical_cards (
    card_id SERIAL PRIMARY KEY,
    pet_id INT NOT NULL, -- Logical FK -> booking_db.pets(pet_id)
    allergies TEXT,
    ver_status VARCHAR(50) NOT NULL DEFAULT 'PENDING'
);

CREATE TABLE daily_reports (
    report_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL, -- Logical FK -> booking_db.bookings(booking_id)
    staff_id INT NOT NULL,   -- Logical FK -> auth_db.persons(user_id)
    act_status VARCHAR(100) NOT NULL,
    report_text TEXT
);

CREATE TABLE files (
    file_id SERIAL PRIMARY KEY,
    card_id INT REFERENCES pet_medical_cards(card_id) ON DELETE CASCADE,
    report_id INT REFERENCES daily_reports(report_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    s3_object_key TEXT NOT NULL,
    CONSTRAINT check_file_owner CHECK (
        (card_id IS NOT NULL AND report_id IS NULL) OR
        (card_id IS NULL AND report_id IS NOT NULL)
    )
);
